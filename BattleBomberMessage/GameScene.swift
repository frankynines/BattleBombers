//
//  GameScene.swift
//  BattleBombs
//
//  Created by Franky Aguilar on 2/16/19.
//  Copyright © 2019 Franky Aguilar. All rights reserved.
//

import SpriteKit
import Foundation

protocol BrianProtocol {
    func didChangeState()
}

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    var protocolDelegate: BrianProtocol?
    
    var animationTexture = [SKTexture]()
    var bombSprites = [GrassSprite]()
    
    var plantedBombs = 0
    var hits = 0
    var gameSetup = true
    
    var gameState = [
            ["isBomb": false,
             "isHit": false,
             "isMiss": false],
            
            ["isBomb": false,
             "isHit": false,
             "isMiss": false],
            
            ["isBomb": false,
             "isHit": false,
             "isMiss": false],
            
            ["isBomb": false,
             "isHit": false,
             "isMiss": false],
            
            ["isBomb": false,
             "isHit": false,
             "isMiss": false]
   ]
    
    
    override func didMove(to view: SKView) {
    
        for i in 0...9{
            let image = UIImage(named: "\(i).png")
            self.animationTexture.append(SKTexture(image:image!))
        }

        let points = [
            CGPoint(x: -95, y: 95),
            CGPoint(x: 95, y: 95),
            CGPoint(x: 0, y: 0),
            CGPoint(x: -95, y: -95),
            CGPoint(x: 95, y: -95)
        ]
        for (i, point) in points.enumerated() {
            self.drawTile(position: point, tag: i)
        }
        
        if self.gameSetup {
            print("New Game")
        }
        
    }
    
    func drawTile(position:CGPoint, tag: Int) {
        let texture =  SKTexture(imageNamed: "plot_blank.png")
        let tileSprite = GrassSprite(texture: texture)
        tileSprite.name = "Plant"
        tileSprite.position = position
        tileSprite.setupSprite()
        tileSprite.tag = tag
        tileSprite.spriteState = 0
        tileSprite.isBomb = false
        self.bombSprites.append(tileSprite)
        
        self.addChild(tileSprite)

    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        if let touch = touches.first {
            let location = touch.location(in: self)
            let node = self.nodes(at: location).first
            
            if node?.name == "Plant" {
                
                let object = node as! GrassSprite
                let sprite = self.bombSprites[object.tag!]
                print(sprite.tag)
                print(sprite.isBomb)
                print(sprite.spriteState)

                if (gameSetup == true) {
                    if !sprite.isBomb! {
                        if plantedBombs < 3 {
                            plantedBombs += 1
                            sprite.texture = SKTexture(image: UIImage(named: "plot_plant.png")!)
                            sprite.isBomb = true
                        }
                        if plantedBombs == 3 {
                            self.gameSetup = false
                            // SHOULD SEND INVITE
                        }
                    }
                    
                    
                } else if (gameSetup == false) {
                    //FULL GAME PLAY
                    print(sprite)
                    if sprite.isBomb == true {
                        if (sprite.spriteState == 2) {
                            return  // NO TURN
                        }
                        sprite.spriteState = 2
                        self.animateExplosion(position: (node?.position)!)
                        self.hits += 1
                        sprite.texture = SKTexture(image: UIImage(named: "plot_hit.png")!)

                        if (hits == 3) {
                            print("GAME OVER WIN")
                        }
                        
                    } else {
                        if (sprite.spriteState == 1) {
                            return // NO TURN
                        }
                        sprite.texture = SKTexture(image: UIImage(named: "plot_miss.png")!)
                        sprite.spriteState = 1
                        //MISS, Send Message
                    }
                }
                
                
                self.saveGameStates()
                
            }
        }
        
    }
    
    func animateExplosion(position:CGPoint) {
        let explosionSprite = SKSpriteNode(texture: self.animationTexture[0])
        self.addChild(explosionSprite)
        explosionSprite.size = CGSize(width: 360, height: 360)
        explosionSprite.position = position
        explosionSprite.run(SKAction.animate(with: self.animationTexture, timePerFrame: 0.05), completion: {
            explosionSprite.removeFromParent()
        })
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    
    func loadGameState() {
        //        This method should loop through all of the bombSprites and set thier state according to previous
    }
    
    
    func saveGameStates() {
        //This should update global Game state and Return
//        print(self.bombSprites)
       
    }
}

class GrassSprite: SKSpriteNode {
    var spriteState = 0
    var tag: Int?
    var isBomb: Bool?
    func setupSprite() {
        self.scale(to: CGSize(width: 180, height: 180))
        self.position = position
        
    }

}






