
import Foundation
import SpriteKit


class Boundary:SKNode  {
    
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
//    
    init (theDict:[NSObject:AnyObject] ) {
        
        super.init()
        
        let image:String = theDict["image"] as AnyObject? as! String
        let theX:String = theDict["x"] as AnyObject? as! String
        let x:Int = Int(theX)!
        
        
        let theY:String = theDict["y"] as AnyObject? as! String
        let y:Int = Int(theY)!
        
        let theWidth:String = theDict["width"] as AnyObject? as! String
        let width:Int = Int(theWidth)!
        
        
        let theHeight:String = theDict["height"] as AnyObject? as! String
        let height:Int = Int(theHeight)!
        
        let location:CGPoint = CGPoint(x: x, y: y * -1)
        let size:CGSize = CGSize(width: width, height: height)
        
        self.position = CGPoint(x: location.x + (size.width / 2), y: location.y - (size.height / 2))
        let rect:CGRect = CGRectMake( -(size.width / 2), -(size.height / 2), size.width, size.height)
        
        createBoundary(rect, image: image)
        
    }
    
    
    func createBoundary(rect:CGRect, image:String) {
        let shape = SKSpriteNode(imageNamed: image)
        shape.size = CGSize(width: Int(rect.width), height: Int(rect.height))
        addChild(shape)
        
            self.physicsBody = SKPhysicsBody(rectangleOfSize: rect.size)
        
        self.physicsBody!.dynamic = false
        self.physicsBody!.categoryBitMask = BodyType.boundary.rawValue
        self.physicsBody!.friction = 0
        self.physicsBody!.allowsRotation = false
        
        self.zPosition = 100
        
        
    }
    
    
    
    
    func makeMoveable() {
        
        self.physicsBody?.dynamic = true
        self.physicsBody!.categoryBitMask = BodyType.boundary2.rawValue
        self.physicsBody?.collisionBitMask = BodyType.hero.rawValue | BodyType.enemy.rawValue | BodyType.boundary.rawValue | BodyType.boundary2.rawValue
        
        
    }
    
    
}









