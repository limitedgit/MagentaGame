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
    let black = SKTexture(imageNamed: "playerWhite") //black circle with white outline, player sprite default
    let pink = SKTexture(imageNamed: "playerPink") //pink circle, player sprite when touched
    let player = SKSpriteNode(imageNamed:"playerWhite")// player sprite
    var gameArea = CGRect() //area where player stays in
//    var pause = false   //is the game paused
    let scoreLabel = SKLabelNode(fontNamed: "Comic Sans MS") //label to display score
    let levelLabel = SKLabelNode(fontNamed: "Comic Sans MS") //label to display level (second score)
    var colored = false //whether player is touched (pink)
    var level = 0 //starting level
    
    struct PhysicsCategories{
        static let None: UInt32 = 0 //no contact
        static let Player: UInt32 = 0b1 //1 the player
        static let omni: UInt32 = 0b10 //2 the obstacle that always affects the player
        static let Magenta: UInt32 = 0b100 //4 the obstacle that only affects the touched player
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        //setup gamearea
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableWidth = size.height / maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        gameArea = CGRect(x:margin, y:0,  width: playableWidth, height: size.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sceneDidLoad() {
        //create player
        player.setScale(0.25)
        player.position = CGPoint(x:self.size.width/2, y: self.size.height*0.2)
        player.zPosition = 1
        player.name = "PLAYER"
        player.physicsBody = SKPhysicsBody(texture: (player.texture)!, size: (player.texture?.size())!)
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.categoryBitMask = PhysicsCategories.Player
        self.addChild(player)
        
        
        //create initial background
        let startGround = SKSpriteNode(imageNamed:"startGround")
        startGround.size = self.size
        startGround.position = CGPoint(x:self.size.width/2, y:self.size.height/2)
        startGround.name = "startGround"
        startGround.zPosition = 0
        self.addChild(startGround)
        
        
        //init score label
        scoreLabel.text = "0"
        scoreLabel.fontSize = 64
        scoreLabel.fontColor = pinkk
        scoreLabel.position = CGPoint(x: self.size.width * 0.25, y: self.size.height * 0.9)
        scoreLabel.name = "score"
        scoreLabel.zPosition = 1
        self.addChild(scoreLabel)
        
        //init level label
        levelLabel.text = "level: \(level)"
        levelLabel.fontSize = 64
        levelLabel.fontColor = pinkk
        levelLabel.position = CGPoint(x: self.size.width * 0.75, y: self.size.height * 0.9)
        levelLabel.zPosition = 1
        self.addChild(levelLabel)
        
        
        //create moving background
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
    
    // whether the game has not started, started or ended
    enum gameState {
        case pregame
        case ingame
        case postgame
    }
    
    //change player to pink
    func changeToPink(){
        player.texture = pink
        colored = true
    }
    
    //change player back to default black with white outline
    func changeToBlack(){
        player.texture = black
        colored = false
    }
    
    //TODO spawn enemies
    func startGame(){
        let omniEnemy = SKSpriteNode(imageNamed: "omniEnemy")
        omniEnemy.physicsBody = SKPhysicsBody(texture: omniEnemy.texture!, size: omniEnemy.texture!.size())
        omniEnemy.physicsBody?.affectedByGravity = true
        omniEnemy.physicsBody?.categoryBitMask = PhysicsCategories.omni
        omniEnemy.physicsBody?.collisionBitMask = PhysicsCategories.None
        omniEnemy.physicsBody?.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.omni | PhysicsCategories.Magenta
    }
    //start in pregame
    var currentGameState = gameState.pregame
    
    //variables for moving background and scores
    var lastUpdateTime: TimeInterval = 0
    var frameDeltatime: TimeInterval = 0
    var amountToMovePerSecond = CGFloat(600.0)
    let scorePerSecond = CGFloat(10.0)
    var currentScore = CGFloat(0.0)
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            
        if currentGameState == gameState.pregame{
            //start the game when player touches screen
            currentGameState = gameState.ingame
            startGame()
        } else if currentGameState == gameState.ingame{
            //changes colour when touched
            changeToPink()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //stopping touch changes back to black
        changeToBlack()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            //player follows touch
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
    
    //TODO create game over screen
    func gameOver(){
        
    }
    
    
    //display the score
    func startNewLevel(){
    
        level += 1
        levelLabel.text = "level: \(level)"

        
    }
    
    
    //TODO: need asset for animation for when player comes into contact with objects
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
    

    //contact rules for players and enemies
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
    
    
    
    //time based functions
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        else {
            frameDeltatime = currentTime - lastUpdateTime
            lastUpdateTime = currentTime
        }
        //update score
        currentScore += scorePerSecond * CGFloat(frameDeltatime)
        let amountToMoveBackground = amountToMovePerSecond * CGFloat(frameDeltatime)
        if Int(currentScore).isMultiple(of: 100) && currentScore > CGFloat(level) * 100.0 + 1{
            startNewLevel()
        }
        
        //move background
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
        //move and remove starting background
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
