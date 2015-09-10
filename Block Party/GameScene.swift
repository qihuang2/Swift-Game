//
//  GameScene.swift
//  Block Party
//
//  Created by Qi Feng Huang on 2/15/15.
//  Copyright (c) 2015 Qi Feng Huang. All rights reserved.
//

import SpriteKit

enum GameMode{
    case Playing
    case MainMenu
    case LevelSelect
    case Lose
    case Win
}


class GameScene: SKScene, SKPhysicsContactDelegate{
    private var hero: Hero!
    private let scoreHudLayer = SKNode()    //score layer
    private let characterLayer = SKNode()
    private let buttonLayer = SKNode()
    private let gameOverNode = SKNode() //game over scene
    private let directionsNode: SKNode = SKNode() // game directions
    
    private var gameState:GameMode
    
    private let currentScoreLabel: SKLabelNode = SKLabelNode(fontNamed: "markerfelt-wide")
    private let bestScoreLabel: SKLabelNode = SKLabelNode(fontNamed: "markerfelt-wide")
    
    private var score: Int = 0
    private let bestScore: Int              //best score achieved
    
    let spriteAtlas:SKTextureAtlas = SKTextureAtlas(named: "characters")
    
    override init(size: CGSize){
        gameState = .MainMenu
        
        //get game's best score
        if let best:Int = NSUserDefaults.standardUserDefaults().integerForKey("highScore"){
            bestScore = best
        }
        else{
            NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "highScore")
            bestScore = 0
        }
        
        super.init(size: size)
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func didMoveToView(view: SKView) {
        self.backgroundColor = UIColor.blackColor()
        
        setUpHero()
        setUpGameDirections()
        createPhysicsBound()
        setUpGameScore()
        
        characterLayer.zPosition = 75
        self.addChild(characterLayer)
        self.addChild(directionsNode)
        self.addChild(scoreHudLayer)
    }
    
    private func setUpHero(){
        hero = Hero(spriteTexture: SKTexture(imageNamed: "hero"))
        hero.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        characterLayer.addChild(hero)
    }
    
    //how to play instructions
    private func setUpGameDirections(){
        let directionsLabel:SKLabelNode = SKLabelNode(fontNamed: "markerfelt-wide")
        directionsLabel.fontColor = UIColor.whiteColor()
        directionsLabel.fontSize = 60
        directionsLabel.text = "TOUCH TO START"
        directionsLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.65)
        
        let directionsLabel2:SKLabelNode = SKLabelNode(fontNamed: "markerfelt-wide")
        directionsLabel2.fontColor = UIColor.redColor()
        directionsLabel2.fontSize = 60
        directionsLabel2.text = "DON'T LET GO"
        directionsLabel2.position = CGPoint(x: self.size.width / 2, y: directionsLabel.position.y - directionsLabel.frame.size.height)
        
        directionsNode.addChild(directionsLabel)
        directionsNode.addChild(directionsLabel2)
    }
    
    private var charmsToRemove:[Charm] = []
    func didBeginContact(contact: SKPhysicsContact) {
        if gameState == .Playing{
            //collides with enemy, go to game over scene. collide with charm, add point and update text in label
            //get object hero collided with
            let other = (contact.bodyA.categoryBitMask == PhysicsCategory.Hero ? contact.bodyB : contact.bodyA)
            switch other.categoryBitMask{
                case PhysicsCategory.Enemy:
                    gameState = .Lose
                    other.node?.removeAllActions()
                    goToGameOverScene()
                    break
                
                case PhysicsCategory.Charm:
                    charmsToRemove.append(other.node as! Charm)
                    break
                
                default:
                    break;
            }
        }
    }
    
    private var changeInScore:Int = 0   //every 30 points, speed increases
    override func didSimulatePhysics() {
        //remove the charms hero coliided with
        if !charmsToRemove.isEmpty{
            for c in charmsToRemove{
                c.removeFromParent()
                score += c.worth
                changeInScore += c.worth
                currentScoreLabel.text = "\(score)"
                
                if changeInScore > 30 {
                    EnemyCircle.makeMovementFaster()    //make movements faster
                    changeInScore = 0
                }
    
            }
            charmsToRemove.removeAll()
        }
        
    }
    
    private var currentPoint:CGPoint! //where player's finger is
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if self.gameState == .MainMenu {
            gameState = .Playing
            let touch = touches.first
            currentPoint = touch!.locationInNode(self)
            directionsNode.removeFromParent()              //remove game directions
            startSpawning()                                 //start spawning
        }
        else if self.gameState == .Lose{
            restart()                   //if on lose scene, restart game when tapped
        }
    }
    
    //update heros positions
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if self.gameState == .Playing{
            let touch = touches.first
            let position = touch!.locationInNode(self)  //where finger moved to
            
            let changeInPosition = CGPoint(x: position.x - currentPoint.x, y: position.y - currentPoint.y)
            
            currentPoint = position //update current position
            
            //move hero
            hero.position = CGPoint(x: hero.position.x + changeInPosition.x, y: hero.position.y + changeInPosition.y)
        }
    }
    
    //if player stops touching, game over
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if self.gameState == .Playing{
            self.gameState = .Lose
            goToGameOverScene()
        }
    }
    
    
    //creates boundaries of game
    private func createPhysicsBound(){
        self.physicsWorld.gravity = CGVector.zeroVector
        physicsWorld.contactDelegate = self
        let bounds = SKNode()
        bounds.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(origin: CGPointZero, size: self.size))
        
        bounds.physicsBody!.categoryBitMask = PhysicsCategory.Boundary
        bounds.physicsBody!.collisionBitMask = PhysicsCategory.None
        
        bounds.physicsBody!.restitution = 0
        bounds.physicsBody!.friction = 0
        
        characterLayer.addChild(bounds)
    }
    
    func startSpawning(){
        let waitAction1:SKAction = SKAction.waitForDuration(0.25)
        let spawnEnemyBlock = SKAction.runBlock(spawnEnemy)
        
        //spawn enemy, wait, repeat
        let repeatEnemySpwanAction = SKAction.repeatActionForever(SKAction.sequence([spawnEnemyBlock, waitAction1]))
        
        characterLayer.runAction(repeatEnemySpwanAction)
        
        let waitAction2:SKAction = SKAction.waitForDuration(1.2)
        let spawnCharmBlock = SKAction.runBlock(spawnCharm)
        let repeatCharmSpawnAction = SKAction.repeatActionForever(SKAction.sequence([spawnCharmBlock,waitAction2]))
        
        characterLayer.runAction(repeatCharmSpawnAction)
    }
    
    //creates enemy, adds to scene, and moves enemy
    private func spawnEnemy(){
        let spawnLocation = SideOfScene(rawValue: Int(arc4random_uniform(4)))!
        let enemy = EnemyCircle(spriteTexture: spriteAtlas.textureNamed("enemy0"), spwanLocation: spawnLocation)
        enemy.position = EnemyCircle.getPosition(self.size, circle: enemy)
        enemy.name = "enemy"
        characterLayer.addChild(enemy)
        enemy.runAction(SKAction.sequence([EnemyCircle.getMoveAction(self.size, circle: enemy)]))
    }
    
    //creates charm,adds to scene, and moves charm
    private func spawnCharm(){
        let worth = Int(arc4random_uniform(3))
        let texture = spriteAtlas.textureNamed("charm\(worth)")
        let charm:Charm = Charm(spriteTexture: texture, worth: worth+1*2)
        charm.position = charm.getPosition(self.size)
        charm.name = "charm"
        characterLayer.addChild(charm)
        charm.runAction(charm.getMoveAction())
    }
    
    //sets up in game scores
    private func setUpGameScore(){
        currentScoreLabel.fontColor = SKColor.whiteColor()
        currentScoreLabel.fontSize = 150
        currentScoreLabel.text = "\(score)"
        currentScoreLabel.verticalAlignmentMode = .Center
        currentScoreLabel.name = "time node"
        currentScoreLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.8)
        currentScoreLabel.zPosition = -50
        
        
        bestScoreLabel.fontColor = UIColor.redColor()
        bestScoreLabel.fontSize = 120
        bestScoreLabel.text = "Best : \(bestScore)"
        bestScoreLabel.verticalAlignmentMode = .Center
        bestScoreLabel.position = CGPoint(x: self.size.width / 2, y: currentScoreLabel.position.y + currentScoreLabel.frame.size.height)
        bestScoreLabel.zPosition = -50
        
        scoreHudLayer.addChild(bestScoreLabel)
        scoreHudLayer.addChild(currentScoreLabel)
    }
    
    //sets up and shows game over nodes
    func goToGameOverScene(){
        if gameOverNode.parent == nil {
            characterLayer.removeAllActions()  //stops spawning
            characterLayer.alpha = 0.3          //fades out
            
            gameOverNode.alpha = 0
            gameOverNode.zPosition = 80
            
            //remove all actions from nodes; stops everything from moving
            characterLayer.enumerateChildNodesWithName("enemy") { node, _ in
                node.removeAllActions()
            }
            characterLayer.enumerateChildNodesWithName("charm") { node, _ in
                node.removeAllActions()
            }
            
            //update high score if current score is better
            if score > bestScore{
                NSUserDefaults.standardUserDefaults().setObject(self.score, forKey: "highScore")
                bestScoreLabel.text = "NEW Best:  \(score)"
            }
           
            
            //moves current score label and best score label to game over scene
            currentScoreLabel.removeFromParent()
            currentScoreLabel.zPosition = 100
            currentScoreLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.6)
            gameOverNode.addChild(currentScoreLabel)
            
            bestScoreLabel.removeFromParent()
            bestScoreLabel.zPosition = 100
            bestScoreLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.75)
            gameOverNode.addChild(bestScoreLabel)
            
            
            let retryLabel:SKLabelNode = SKLabelNode(fontNamed: "markerfelt-wide")
            retryLabel.fontColor = UIColor.whiteColor()
            retryLabel.fontSize = 70
            retryLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.25)
            retryLabel.text = "TAP TO RESTART"
            
            gameOverNode.addChild(retryLabel)
            self.addChild(gameOverNode)
            
            gameOverNode.runAction(SKAction.fadeInWithDuration(0.2))
        }
    }

    
    //restarts game
    func restart(){
        self.scene?.removeFromParent()
        let trans = SKTransition.crossFadeWithDuration(0.75)
        let newScene = GameScene(size: size)
        newScene.scaleMode = .AspectFill
        view!.presentScene(newScene, transition: trans)
    }
    
    func getGameStatus()->GameMode{
        return self.gameState
    }
}
