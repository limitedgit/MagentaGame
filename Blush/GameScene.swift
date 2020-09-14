//
//  GameScene.swift
//  Blush
//
//  Created by apple on 8/14/20.
//  Copyright © 2020 apple. All rights reserved.
//

import SpriteKit
import GameplayKit

let pinkk: UIColor = UIColor(named: "pinkk")!
class GameScene: SKScene {
    let black = SKTexture(imageNamed: "playerWhite")
    let pink = SKTexture(imageNamed: "playerPink")
    let player = SKSpriteNode(imageNamed:"playerWhite")
    var gameArea = CGRect()
    var pause = false
    let scoreLabel = SKLabelNode(fontNamed: "Comic Sans MS")
    let levelLabel = SKLabelNode(fontNamed: "Comic Sans MS")
    var colored = false
    var level = 0
    
    struct PhysicsCategories{
        static let None: UInt32 = 0
        static let Player: UInt32 = 0b1 //1
        static let omni: UInt32 = 0b10 //2
        static let Magenta: UInt32 = 0b100 //4
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableWidth = size.height / maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        gameArea = CGRect(x:margin, y:0,  width: playableWidth, height: size.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sceneDidLoad() {
        player.setScale(0.25)
        player.position = CGPoint(x:self.size.width/2, y: self.size.height*0.2)
        player.zPosition = 1
        player.name = "PLAYER"
        player.physicsBody = SKPhysicsBody(texture: (player.texture)!, size: (player.texture?.size())!)
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.categoryBitMask = PhysicsCategories.Player
        self.addChild(player)
        
        
        
        let startGround = SKSpriteNode(imageNamed:"startGround")
        startGround.size = self.size
        startGround.position = CGPoint(x:self.size.width/2, y:self.size.height/2)
        startGround.name = "startGround"
        startGround.zPosition = 0
        self.addChild(startGround)
        
        
        
        scoreLabel.text = "0"
        scoreLabel.fontSize = 64
        scoreLabel.fontColor = pinkk
        scoreLabel.position = CGPoint(x: self.size.width * 0.25, y: self.size.height * 0.9)
        scoreLabel.name = "score"
        scoreLabel.zPosition = 1
        self.addChild(scoreLabel)
        
        levelLabel.text = "level: \(level)"
        levelLabel.fontSize = 64
        levelLabel.fontColor = pinkk
        levelLabel.position = CGPoint(x: self.size.width * 0.75, y: self.size.height * 0.9)
        levelLabel.zPosition = 1
        self.addChild(levelLabel)
        
        
        
        for i in 1...2 {
            let background = SKSpriteNode(imageNamed: "background")
            background.size = self.size
            background.anchorPoint = CGPoint(x:0.5, y:0)
            background.position = CGPoint(x:self.size.width/2, y: self.size.height*CGFloat(i))
            background.name = "background"
            background.zPosition = 0
            self.addChild(background)
        }

    }
    
    enum gameState {
        case pregame
        case ingame
        case postgame
    }
    
    
    func changeToPink(){
        player.texture = pink
        colored = true
    }
    
    func changeToBlack(){
        player.texture = black
        colored = false
    }
    
    func startGame(){
        let omniEnemy = SKSpriteNode(imageNamed: "omniEnemy")
        omniEnemy.physicsBody = SKPhysicsBody(texture: omniEnemy.texture!, size: omniEnemy.texture!.size())
        omniEnemy.physicsBody?.affectedByGravity = true
        omniEnemy.physicsBody?.categoryBitMask = PhysicsCategories.omni
        omniEnemy.physicsBody?.collisionBitMask = PhysicsCategories.None
        omniEnemy.physicsBody?.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.omni | PhysicsCategories.Magenta
    }
    
    var currentGameState = gameState.pregame
    
    
    var lastUpdateTime: TimeInterval = 0
    var frameDeltatime: TimeInterval = 0
    var amountToMovePerSecond = CGFloat(600.0)
    let scorePerSecond = CGFloat(10.0)
    var currentScore = CGFloat(0.0)
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            
        if currentGameState == gameState.pregame{
            currentGameState = gameState.ingame
            startGame()
        } else if currentGameState == gameState.ingame{
            changeToPink()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        changeToBlack()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if currentGameState == gameState.ingame{
            changeToPink()
        for touch in touches {
           let pointOfTouch = touch.location(in:self)
            let previousPointOfTouch = touch.previousLocation(in:self)
            
            let amountDraggedX = pointOfTouch.x - previousPointOfTouch.x
            player.position.x += amountDraggedX
            let amountDraggedY = pointOfTouch.y - previousPointOfTouch.y
            player.position.y += amountDraggedY
            
            
            if player.position.x > (gameArea.maxX - player.size.width/2){
                player.position.x = (gameArea.maxX - player.size.width/2)
            }
            if player.position.x < (gameArea.minX + player.size.width/2){
                player.position.x = (gameArea.minX + player.size.width/2)
            }
            if player.position.y > (gameArea.maxY - player.size.height/2){
                player.position.y = (gameArea.maxY - player.size.height/2)
            }
            if player.position.y < (gameArea.minY + player.size.height/2){
                player.position.y = (gameArea.minY + player.size.height/2)
            }
        }
        }
    }
    
    func gameOver(){
        
    }
    
    func startNewLevel(){
        
        level += 1
        levelLabel.text = "level: \(level)"

        
    }
    
    func spawnExplosion(position: CGPoint) {
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.setScale(0)
        explosion.position = position
        explosion.zPosition = 3
        self.addChild(explosion)
        
        let scaleIn = SKAction.scale(to: 1, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        let explosionSequence = SKAction.sequence([scaleIn, fadeOut, delete])
        explosion.run(explosionSequence)
    }
    

    func didBeginContact(contact: SKPhysicsContact) {
        var body1 =  SKPhysicsBody()
        var body2 =  SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            body1 = contact.bodyA
            body2 = contact.bodyB
        } else {
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.omni {
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            if body1.node != nil{
            spawnExplosion(position: body1.node!.position)
            }
            gameOver()
        } else if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Magenta {
            if (colored == true) {
                body1.node?.removeFromParent()
                body2.node?.removeFromParent()
                if body1.node != nil{
                spawnExplosion(position: body1.node!.position)
                }
                           gameOver()
            } else {
                //do nothing
            }
        }
        
        
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        else {
            frameDeltatime = currentTime - lastUpdateTime
            lastUpdateTime = currentTime
        }
        currentScore += scorePerSecond * CGFloat(frameDeltatime)
        let amountToMoveBackground = amountToMovePerSecond * CGFloat(frameDeltatime)
        if Int(currentScore).isMultiple(of: 100) && currentScore > CGFloat(level) * 100.0 + 1{
            startNewLevel()
        }
        
        self.enumerateChildNodes(withName: "background") {
            background, stop in
            if self.currentGameState == gameState.ingame{
                self.scoreLabel.text = "\(Int(self.currentScore))"
                
                        background.position.y -= amountToMoveBackground
                    if background.position.y < -self.size.height{
                        background.position.y += self.size.height*2
                    }
                }
            
        }
        self.enumerateChildNodes(withName: "startGround") {
            background, stop in
            if self.currentGameState == gameState.ingame && self.isPaused == false{
                        background.position.y -= amountToMoveBackground
                    if background.position.y < -self.size.height{
                        background.removeFromParent()
                    }
                }
            
        }
        
    }

    
}
