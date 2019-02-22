//
//  GameScene.swift
//  BattleBombs
//
//  Created by Franky Aguilar on 2/16/19.
//  Copyright © 2019 Franky Aguilar. All rights reserved.
//

import SpriteKit
import Foundation

protocol GameSceneProtocol {
    func did_FinishSettingUpGame()
    func did_WinGame()
    func did_loseGame()
}

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    var protocolDelegate: GameSceneProtocol?
    
    var animationTexture = [SKTexture]()
    var bombSprites = [GrassSprite]()
    
    var plantedBombs = 0
    var hits = 0
    var numberOfPlants = 4
    var numberOfMoves = 3
    var gameSetup = true
    var gameOver = false
    override func didMove(to view: SKView) {
        print("DID MOVE")
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
        
        if !self.gameSetup {
            //            self.loadGameState()
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
            if gameOver {
                return
            }
            
            let location = touch.location(in: self)
            let node = self.nodes(at: location).first
            
            if node?.name == "Plant" {
                
                let object = node as! GrassSprite
                let sprite = self.bombSprites[object.tag!]
                
                if (gameSetup == true) {
                    if !sprite.isBomb! {
                        if plantedBombs < numberOfPlants {
                            plantedBombs += 1
                            sprite.texture = SKTexture(image: UIImage(named: "plot_plant.png")!)
                            sprite.isBomb = true
                        }
                        if plantedBombs == numberOfPlants {
                            self.gameSetup = false
                            self.protocolDelegate?.did_FinishSettingUpGame()
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
                        sprite.setState(state: 2)
                        
                        if (self.hits == numberOfMoves) {
                            gameOver = true
                            self.protocolDelegate?.did_loseGame()
                        }
                    } else {
                        if (sprite.spriteState == 1) {
                            return // NO TURN
                        }
                        if (sprite.spriteState == 2) {
                            return // NO TURN
                        }
                        sprite.setState(state: 1)
                        sprite.spriteState = 1
                        
                        self.protocolDelegate?.did_WinGame()
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
    
    
    func loadGameState(loadState:String) {
        self.gameSetup = false
        
        for (i, bomb) in self.bombSprites.enumerated() {
            let isBomb = self.getQueryStringParameter(url: loadState, param: "\(i)isBomb")
            let spriteState = self.getQueryStringParameter(url: loadState, param: "\(i)state")
            
            bomb.isBomb = isBomb?.bool
            bomb.spriteState = Int(spriteState!)!
            
        }
    }
    
    func saveGameStates() -> [String:Any] {
        var saveState = [String:Any]()
        for (i, bomb) in self.bombSprites.enumerated() {
            saveState["\(i)isBomb"] = bomb.isBomb?.description
            saveState["\(i)state"] = String(bomb.spriteState)
        }
        return saveState
    }
    
    func resetGame() {
        let texture =  SKTexture(imageNamed: "plot_blank.png")

        for bomb in self.bombSprites {
            bomb.isBomb = false
            bomb.spriteState = 0
            bomb.texture = texture
        }
        
        self.plantedBombs = 0
        self.hits = 0
        self.gameOver = false
        self.gameSetup = true
    }
    
    func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
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
    
    func setState(state:Int) {
        self.spriteState = state
        
        if (state == 0) {
            self.texture = SKTexture(image: UIImage(named: "plot_blank.png")!)
        }
        
        if (state == 1) {
            self.texture = SKTexture(image: UIImage(named: "plot_miss.png")!)
        }
        
        if (state == 2) {
            self.texture = SKTexture(image: UIImage(named: "plot_hit.png")!)
        }
        
    }
    
}




extension String {
    var bool: Bool? {
        switch self.lowercased() {
        case "true", "t", "yes", "y", "1":
            return true
        case "false", "f", "no", "n", "0":
            return false
        default:
            return nil
        }
    }
}

