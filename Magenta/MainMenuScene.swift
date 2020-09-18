//
//  MainMenuScene.swift
//  Blush
//
//  Created by apple on 8/16/20.
//  Copyright © 2020 apple. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class MainMenuScene: SKScene {
    let pink: UIColor = UIColor(named: "pinkk")!
    
    override func sceneDidLoad() {
        let background = SKSpriteNode(imageNamed: "startGround")
        background.size = self.size
        background.position = CGPoint(x:self.size.width/2, y:self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        let startButton = SKLabelNode()
        startButton.text = "Tap to Start"
        startButton.fontSize = 100
        startButton.fontColor = SKColor.white
        startButton.position = CGPoint(x: self.size.width/2, y: self.size.height*0.25)
        startButton.zPosition = 1
        
        self.addChild(startButton)
        
        let skinsButton = SKSpriteNode(imageNamed: "skins")
        skinsButton.name = "skinsButton"
        
        
        let title = SKLabelNode(fontNamed: "Bold")
        title.text = "Magenta"
        title.fontSize = 200
        title.fontColor = pink
        title.position = CGPoint(x: self.size.width/2, y: self.size.height*0.75)
        title.zPosition = 1
        self.addChild(title)
     
        
        let fadeSequence = SKAction.sequence([.fadeIn(withDuration: 0.5), .fadeOut(withDuration: 0.5)])
        startButton.run(.repeatForever(fadeSequence))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location(in: self)
            let nodeITapped = atPoint(pointOfTouch)
            
            if nodeITapped.name == "skinsButton"{
                
            } else{
                let sceneToMoveTo = GameScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                let myTransition = SKTransition.fade(withDuration: 0.5)
                self.view?.presentScene(sceneToMoveTo, transition: myTransition)
            }
            
            
            
        }
    }
    



}
