//
//  GameScene.swift
//  Coin Man
//
//  Created by Ajin on 25/03/24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var coinMan: SKSpriteNode?
    var coinTimer: Timer?
    var bombTimer: Timer?
    var ground: SKSpriteNode?
    var ceil: SKSpriteNode?
    var scoreLabel: SKLabelNode?
    var yourScoreLabel: SKLabelNode?
    var finalScore: SKLabelNode?
    
    let coinManCategory: UInt32 = 0x1 << 1
    let coinCategory: UInt32 = 0x1 << 2
    let bombCategory: UInt32 = 0x1 << 3
    let groundAndCeilCategory: UInt32 = 0x1 << 4
    
    var score: Int = 0
    
    override func didMove(to view: SKView) {
        
        // Get label node from scene and store it for use later
        physicsWorld.contactDelegate = self
        
        coinMan = childNode(withName: "coinMan") as? SKSpriteNode
        coinMan?.physicsBody?.categoryBitMask = coinManCategory
        coinMan?.physicsBody?.contactTestBitMask = coinCategory | bombCategory
        coinMan?.physicsBody?.collisionBitMask = groundAndCeilCategory
        
        var coinManRun: [SKTexture] = []
        for number in 1...5{
            coinManRun.append(SKTexture(imageNamed: "frame-\(number)"))
        }
        coinMan?.run(SKAction.repeatForever(SKAction.animate(with: coinManRun, timePerFrame: 0.09)))
        
        //ground = childNode(withName: "ground") as? SKSpriteNode
        //ground?.physicsBody?.categoryBitMask = groundAndCeilCategory
        //ground?.physicsBody?.collisionBitMask = coinManCategory
        
        ceil = childNode(withName: "ceil") as? SKSpriteNode
        ceil?.physicsBody?.categoryBitMask = groundAndCeilCategory
        
        scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode
        
        startTimers()
        createGrass()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if scene?.isPaused == false{
            coinMan?.physicsBody?.applyForce(CGVector(dx: 0, dy: 100_000))
        }
        
        let touch = touches.first
        if let location = touch?.location(in: self){
            let nodes = nodes(at: location)
            
            for node in nodes{
                if node.name == "play"{
                    node.removeFromParent()
                    restartGame()
                }
            }
        }
    }
    
    func createGrass(){
        let sizingGrass = SKSpriteNode(imageNamed: "grass")
        let numberOfGrass = Int(size.width / sizingGrass.size.width)
        for number in 0...numberOfGrass{
            let grass = SKSpriteNode(imageNamed: "grass")
            grass.physicsBody = SKPhysicsBody(rectangleOf: grass.size)
            grass.physicsBody?.categoryBitMask = groundAndCeilCategory
            grass.physicsBody?.collisionBitMask = coinManCategory
            grass.physicsBody?.affectedByGravity = false
            grass.physicsBody?.isDynamic = false
            
            let grassX = -size.width/2 + grass.size.width + grass.size.width * CGFloat(number)
            grass.position = CGPoint(x: grassX, y: -size.height/2 + grass.size.height/2 + 25)
            addChild(grass)
            
            let speed = 100.0
            
            let firstMoveLeft = SKAction.moveBy(
                x: -grass.size.width - grass.size.width * CGFloat(number),
                y: 0,
                duration: TimeInterval(grass.size.width + grass.size.width * CGFloat(number))/speed)
            
            let resetGrass = SKAction.moveBy(
                x: size.width + grass.size.width,
                y: 0,
                duration: 0)
            
            let grassFullMove = SKAction.moveBy(
                x: -size.width - grass.size.width,
                y: 0,
                duration: TimeInterval(size.width + grass.size.width)/speed)
            
            let grassMovingForever = SKAction.repeatForever(SKAction.sequence([grassFullMove, resetGrass]))
            
            grass.run(SKAction.sequence([firstMoveLeft, resetGrass, grassMovingForever]))
        }
    }
    
    func restartGame(){
        startTimers()
        score = 0
        finalScore?.removeFromParent()
        yourScoreLabel?.removeFromParent()
        scene?.isPaused = false
    }
    
    func startTimers(){
        score = 0
        scoreLabel?.text = "Score: \(score)"
        coinTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.createCoin()
        })
        bombTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { _ in
            self.createBomb()
        })
    }
    
    func createCoin(){
        let sizingGrass = SKSpriteNode(imageNamed: "grass")
        let coin = SKSpriteNode(imageNamed: "star")
        coin.physicsBody = SKPhysicsBody(circleOfRadius: coin.size.width/2)
        coin.physicsBody?.affectedByGravity = false
        coin.physicsBody?.categoryBitMask = coinCategory
        coin.physicsBody?.contactTestBitMask = coinManCategory
        coin.physicsBody?.collisionBitMask = 0
        addChild(coin)
        
        let maxY = size.height/2 - coin.size.height/2
        let minY = -size.height/2 + coin.size.height/2 + sizingGrass.size.height
        let range = maxY - minY
        let coinY = maxY - CGFloat(arc4random_uniform(UInt32(range)))
        
        coin.position = CGPoint(x: size.width/2 + coin.size.width/2, y: coinY)
        let moveLeft = SKAction.moveBy(x: -size.width - coin.size.width/2, y: 0, duration: 6)
        coin.run(SKAction.sequence([moveLeft, SKAction.removeFromParent()]))
    }
    
    func createBomb(){
        let sizingGrass = SKSpriteNode(imageNamed: "grass")
        let bomb = SKSpriteNode(imageNamed: "bomb")
        bomb.physicsBody = SKPhysicsBody(circleOfRadius: bomb.size.width/2)
        bomb.physicsBody?.affectedByGravity = false
        bomb.physicsBody?.categoryBitMask = bombCategory
        bomb.physicsBody?.contactTestBitMask = coinManCategory
        bomb.physicsBody?.collisionBitMask = 0
        addChild(bomb)
        
        let maxY = size.height/2 - bomb.size.height/2
        let minY = -size.height/2 + bomb.size.height/2 + sizingGrass.size.height
        let range = maxY - minY
        let bombY = maxY - CGFloat(arc4random_uniform(UInt32(range)))
        
        bomb.position = CGPoint(x: size.width/2 + bomb.size.width/2, y: bombY)
        let moveLeft = SKAction.moveBy(x: -size.width - bomb.size.width/2, y: 0, duration: 6)
        bomb.run(SKAction.sequence([moveLeft, SKAction.removeFromParent()]))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if contact.bodyA.categoryBitMask == coinCategory{
            addScore()
            contact.bodyA.node?.removeFromParent()
        }
        if contact.bodyB.categoryBitMask == coinCategory{
            addScore()
            contact.bodyB.node?.removeFromParent()
        }
        
        if contact.bodyA.categoryBitMask == bombCategory{
            gameOver()
        }
        if contact.bodyB.categoryBitMask == bombCategory{
            gameOver()
        }
        
    }
    
    func gameOver(){
        scene?.isPaused = true
        coinTimer?.invalidate()
        bombTimer?.invalidate()
        
        yourScoreLabel = SKLabelNode(text: "Your score:")
        yourScoreLabel?.position = CGPoint(x: 0, y: 200)
        yourScoreLabel?.fontSize = 100
        if let yourScoreLabel = yourScoreLabel{
            addChild(yourScoreLabel)
        }
        
        finalScore = SKLabelNode(text: "\(score)")
        finalScore?.position = CGPoint(x: 0, y: 0)
        finalScore?.fontSize = 200
        if let finalScore = finalScore{
            addChild(finalScore)
        }
        
        let playButton = SKSpriteNode(imageNamed: "play.fill")
        playButton.name = "play"
        playButton.position = CGPoint(x: 0, y: -200)
        addChild(playButton)
    }
    
    func addScore(){
        score += 1
        scoreLabel?.text = "Score: \(score)"
    }
}
