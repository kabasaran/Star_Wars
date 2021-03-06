//
//  GameScene.swift
//  Star_Wars
//
//  Created by KABA Saran on 13/02/2020.
//  Copyright © 2020 KABA Saran. All rights reserved.
//

import SpriteKit
import GameplayKit


struct PhysicsCategory {
  static let none      : UInt32 = 0
  static let vert   : UInt32 = 0b001       // 1
  static let rouge: UInt32 = 0b010      // 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    private var labelScore : SKLabelNode?
    private var labelResult : SKLabelNode?
    private var labelTitle : SKLabelNode?
    private var labelChrono : SKLabelNode?
    private var labelHorloge : SKLabelNode?
    private var carreVert: SKSpriteNode?
    private var score: Int = 0
    private var chrono: Int = 0
    

    override func sceneDidLoad() {
        
        self.lastUpdateTime = 0
        
        // Get label node from scene and store it for use later
        self.labelScore = self.childNode(withName: "//lbl_score") as? SKLabelNode
        self.labelResult = self.childNode(withName: "//lbl_result") as? SKLabelNode
        
        self.labelHorloge = self.childNode(withName: "//lbl_horloge") as? SKLabelNode
        self.labelChrono = self.childNode(withName: "//lbl_chrono") as? SKLabelNode
        if let label = labelChrono
        {
            chrono = Int(label.text!)!
            
        }
        
        self.labelTitle = self.childNode(withName: "//lbl_title") as? SKLabelNode
        print(chrono)
        if let label = self.labelTitle {
            label.alpha = 0.0
            label.run(SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.fadeIn(withDuration: 2.0),
                    SKAction.fadeOut(withDuration: 2.0)
                    ])
            ))
        }
      

        carreVert?.physicsBody?.categoryBitMask = PhysicsCategory.vert
        carreVert?.physicsBody?.contactTestBitMask = PhysicsCategory.rouge
        carreVert?.physicsBody?.collisionBitMask = PhysicsCategory.none
        carreVert?.physicsBody?.usesPreciseCollisionDetection = true
        
        self.carreVert = self.childNode(withName: "//carre_vert") as? SKSpriteNode
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        run(SKAction.repeatForever(
          SKAction.sequence([
            SKAction.run(addCarreRouge),
            SKAction.wait(forDuration: 1.0),
            SKAction.run(compteARebours)
            ])
        ))
        
    }
    
    func compteARebours()
    {
        chrono = chrono - 1
        labelChrono?.text = String(chrono)

        let endGame = SKLabelNode(fontNamed: "Zapfino")
        endGame.fontSize = 100.0
        let endScore = SKLabelNode(fontNamed: "Zapfino")
        endScore.fontSize = 50.0
        if chrono == 0 && score < 1
        {
            endGame.text = "You Lose! \n"
            endScore.text = "Your score is: " + String(score)
            self.removeAllChildren()
            self.removeAllActions()
            
            endGame.position = CGPoint(x: 20, y: 100)
            endScore.position = CGPoint(x: 30, y: -10)
            
            self.addChild(endGame)
            self.addChild(endScore)
        }
        else if(chrono == 0)
        {
            endGame.text = "Well done ;)"
            endScore.text = "Your score is: " + String(score)
            self.removeAllChildren()
            self.removeAllActions()
            
            endGame.position = CGPoint(x: 20, y: 100)
            endScore.position = CGPoint(x: 30, y: -10)
            
            self.addChild(endGame)
            self.addChild(endScore)
        }
    }
    func random(min: CGFloat, max: CGFloat) -> CGFloat{

        return (CGFloat(Float(arc4random()) / 0xFFFFFFFF)) * (max - min) + min
    }
    
    func addCarreRouge(){
        
        var rouge = SKSpriteNode()
        
        if let clone = self.carreVert?.copy() as! SKSpriteNode?{
            
            rouge = clone
            rouge.name = "rouge"
            rouge.color = .red
            
            //print(rouge.size)
            
            let actualY = random(min: -rouge.size.height*8, max: size.height - rouge.size.height/2)
            rouge.position = CGPoint(x: size.width - rouge.size.width/2, y: actualY)
        
            //rouge.physicsBody = SKPhysicsBody(rectangleOf: rouge.size)
            
            rouge.physicsBody?.isDynamic = true //pour detecter la collision
            rouge.physicsBody?.affectedByGravity = false
            
            rouge.physicsBody?.categoryBitMask = PhysicsCategory.rouge // 3
            rouge.physicsBody?.contactTestBitMask = PhysicsCategory.vert // 4
            rouge.physicsBody?.collisionBitMask = PhysicsCategory.none // 5
            
           // Add the clone to the scene
           addChild(rouge)

            let actualDuration = random(min: CGFloat(2.0), max: CGFloat(8.0))
            
            // Create the actions
            let actionMove = SKAction.move(to: CGPoint(x: -rouge.size.width*5, y: actualY),
                                           duration: TimeInterval(actualDuration))
            let actionMoveDone = SKAction.removeFromParent()
            rouge.run(SKAction.sequence([actionMove, actionMoveDone]))
            
        }
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
      // 1
      var firstBody: SKPhysicsBody
      var secondBody: SKPhysicsBody
        
        /*
         
         if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
         firstBody = contact.bodyA
         secondBody = contact.bodyB
         
         
         */
    
        
      if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
        firstBody = contact.bodyA
        secondBody = contact.bodyB
      } else {
        firstBody = contact.bodyB
        secondBody = contact.bodyA
      }
      // 2
      if ((firstBody.categoryBitMask & PhysicsCategory.vert != 0) &&
          (secondBody.categoryBitMask & PhysicsCategory.rouge != 0)) {
        if let rouge = secondBody.node as? SKSpriteNode {
          projectileDidCollide(rouge: rouge)
        }
      }
    }
    
    func projectileDidCollide(rouge: SKSpriteNode) {
       rouge.removeFromParent()
        
        if let label = self.labelResult
        {
            score = score + 1
            label.text = String(score)
        }
    }
 /*

     static let leftArrow                 : UInt16 = 0x7B
     static let rightArrow                : UInt16 = 0x7C
     */
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 0x31://espace
            if let label = self.labelTitle {
                label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
            }
            case 0x7B://gauche
                if let clone = self.carreVert?.copy() as! SKSpriteNode?{
                    clone.position.x = clone.position.x - 20.0
                    carreVert?.position = clone.position
                }
            case 0x7C://droite
                if let clone = self.carreVert?.copy() as! SKSpriteNode?{
                    clone.position.x = clone.position.x + 20.0
                    carreVert?.position = clone.position
                }
        case 0x7D://bas
            if let clone = self.carreVert?.copy() as! SKSpriteNode?{
                clone.position.y = clone.position.y - 20.0
                carreVert?.position = clone.position
            }
        case 0x7E://haut
            if let clone = self.carreVert?.copy() as! SKSpriteNode?{
                clone.position.y = clone.position.y + 20.0
                carreVert?.position = clone.position
            }
            
        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
       
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
    }
}
