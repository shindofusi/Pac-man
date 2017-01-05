//
//  Speed.swift
//  pacman
//
//  Created by user121698 on 12/5/16.
//  Copyright © 2016 Aaron Sun. All rights reserved.
//

import Foundation
import SpriteKit

class Speed:SKNode {
    
    var willAutoAdvanceLevel:Bool = false
    var speedSprite:SKSpriteNode?
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        
        super.init()
        speedSprite = SKSpriteNode(imageNamed: "speed")
        addChild(speedSprite!)
        
        createPhysicsBody()
        
    }
    
    init (fromTMXFileWithDict theDict:Dictionary<NSObject, AnyObject> ) {
        
        super.init()
        
        let theX:String = theDict["x"] as AnyObject? as! String
        let x:Int =  Int(theX)!
        
        
        let theY:String = theDict["y"] as AnyObject? as! String
        let y:Int =  Int(theY)!
        
        
        let location:CGPoint = CGPoint(x: x, y: y * -1)
        speedSprite = SKSpriteNode(imageNamed: "speed")
        addChild(speedSprite!)
        
        self.position = CGPoint(x: location.x + (speedSprite!.size.width / 2), y: location.y - (speedSprite!.size.height / 2))  //must use this because Tiled uses position in the top left of the shape
        
        createPhysicsBody()
        
        
    }
    
    
    
    func createPhysicsBody() {
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: speedSprite!.size.width / 2  )
        
        self.physicsBody?.categoryBitMask = BodyType.speed.rawValue
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.contactTestBitMask = BodyType.hero.rawValue
        
        self.zPosition = 90
        
    }
    
    
}
