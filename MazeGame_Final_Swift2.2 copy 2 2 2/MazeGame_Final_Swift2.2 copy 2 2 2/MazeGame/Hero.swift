
import Foundation
import SpriteKit



enum Direction {
    
    case Up, Down, Right, Left, None
    
}

enum DesiredDirection {
    
    case Up, Down, Right, Left, None
    
}

class Hero:SKNode {
    var currentSpeed:Float = 5
    var currentDirection = Direction.Right
    var desiredDirection = DesiredDirection.None
    
    var movingAnimation:SKAction = SKAction()
    var objectSprite:SKSpriteNode?
    
    var downBlocked:Bool = false
    var upBlocked:Bool = false
    var leftBlocked:Bool = false
    var rightBlocked:Bool = false
    
    var nodeUp:SKNode?
    var nodeDown:SKNode?
    var nodeLeft:SKNode?
    var nodeRight:SKNode?
    
    var buffer:Int = 10
  
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init (theDict:[String: AnyObject] ) {
        
        super.init()
        //println(theDict)
        
        
        let image:String = theDict["HeroImage"] as AnyObject? as! String 
        
        objectSprite = SKSpriteNode(imageNamed: image)
        addChild(objectSprite!)
    
       
        
        if let atlasName:String = theDict["MovingAtlasFile"] as AnyObject? as? String {
            
            let frameArray:AnyObject = theDict["MovingFrames"]!
            
            if let framesAsNSArray:NSArray = frameArray as? NSArray {
                
                setUpAnimationWithArray(framesAsNSArray, andAtlasNamed: atlasName)
                runAnimation()
                
            }
            
            
        } else {
            
            setUpAnimation()
            runAnimation()
            
        }
        
        
      
        
        
        
        
        
        let largerSize:CGSize = CGSize(width: objectSprite!.size.width * 1.2, height: objectSprite!.size.height * 1.2)
        
        
        let bodyShape:String = theDict["BodyShape"] as AnyObject? as! String
        
        if ( bodyShape == "circle") {
            //23
            self.physicsBody = SKPhysicsBody(circleOfRadius: (objectSprite?.size.width)! / 2)
            
        } else {
            
            self.physicsBody = SKPhysicsBody(rectangleOfSize: largerSize)
            
        }
        
        
        
        self.physicsBody!.friction = 0
        self.physicsBody!.dynamic = true
        
        self.physicsBody!.restitution = 0
        self.physicsBody!.allowsRotation = false
        self.physicsBody!.affectedByGravity = false
        self.physicsBody!.categoryBitMask = BodyType.hero.rawValue
               self.physicsBody!.contactTestBitMask = BodyType.boundary.rawValue | BodyType.star.rawValue
        
        
        
        nodeUp = SKNode()
        addChild(nodeUp!)
        nodeUp!.position = CGPoint(x:0, y:buffer)
        createUpSensorPhysicsBody( whileTravellingUpOrDown: false )
        
        nodeDown = SKNode()
        addChild(nodeDown!)
        nodeDown!.position = CGPoint(x:0, y: -buffer )
        createDownSensorPhysicsBody( whileTravellingUpOrDown: false)
        
        nodeRight = SKNode()
        addChild(nodeRight!)
        nodeRight!.position = CGPoint(x: buffer, y:0 )
        createRightSensorPhysicsBody( whileTravellingLeftOrRight: true)
        
        nodeLeft = SKNode()
        addChild(nodeLeft!)
        nodeLeft!.position = CGPoint(x: -buffer, y:0 )
        createLeftSensorPhysicsBody( whileTravellingLeftOrRight: true)
        
        
        
    }
    
    func update(){
        
        
        switch currentDirection {
            
            case .Right:
                self.position = CGPoint(x: self.position.x + CGFloat(currentSpeed), y: self.position.y)
                objectSprite!.zRotation = CGFloat( degreesToRadians(0) )
            case .Left:
                 self.position = CGPoint(x: self.position.x - CGFloat(currentSpeed), y: self.position.y)
                 objectSprite!.zRotation = CGFloat( degreesToRadians(180) )
            case .Up:
                 self.position = CGPoint(x: self.position.x, y: self.position.y  + CGFloat(currentSpeed))
                 objectSprite!.zRotation = CGFloat( degreesToRadians(90) )
            case .Down:
                 self.position = CGPoint(x: self.position.x , y: self.position.y - CGFloat(currentSpeed))
                 objectSprite!.zRotation = CGFloat( degreesToRadians(-90) )
            case .None:
            
                 self.position = CGPoint(x: self.position.x, y: self.position.y)
            
        }
        
        
    }
    
    
    
    func degreesToRadians(degrees: Double) -> Double {
        return degrees / 180 * Double(M_PI)
    }
    
    
    
    func goUp(){
        
        if (upBlocked == true) {
            
            desiredDirection = DesiredDirection.Up
            
        } else {
            
            runAnimation()
        
            currentDirection = .Up
            desiredDirection = .None
            downBlocked = false
            
            self.physicsBody?.dynamic = true
        
            createUpSensorPhysicsBody(whileTravellingUpOrDown: true)
            createDownSensorPhysicsBody(whileTravellingUpOrDown: true )
            createLeftSensorPhysicsBody(whileTravellingLeftOrRight: false )
            createRightSensorPhysicsBody(whileTravellingLeftOrRight: false )
        
        }
    }
    
    func goDown(){
        
        if (downBlocked == true) {
            
            desiredDirection = DesiredDirection.Down
            
        } else {
        
            
            currentDirection = .Down
            desiredDirection = .None
            runAnimation()
            
            upBlocked = false
            
            self.physicsBody?.dynamic = true
        
            createUpSensorPhysicsBody(whileTravellingUpOrDown: true)
            createDownSensorPhysicsBody(whileTravellingUpOrDown: true )
            createLeftSensorPhysicsBody(whileTravellingLeftOrRight: false )
            createRightSensorPhysicsBody(whileTravellingLeftOrRight: false )
            
        }
        
    }
    func goRight(){
        
        if (rightBlocked == true) {
            
            desiredDirection = DesiredDirection.Right
            
        } else {
        
        
            currentDirection = .Right
            desiredDirection = .None
            runAnimation()
            
            leftBlocked = false
            
            self.physicsBody?.dynamic = true
        
            createUpSensorPhysicsBody(whileTravellingUpOrDown: false)
            createDownSensorPhysicsBody(whileTravellingUpOrDown: false )
            createLeftSensorPhysicsBody(whileTravellingLeftOrRight: true )
            createRightSensorPhysicsBody(whileTravellingLeftOrRight: true )
            
        }
        
    }
    func goLeft(){
        
        
        if (leftBlocked == true) {
            
            desiredDirection = DesiredDirection.Left
            
        } else {
        
            currentDirection = .Left
            desiredDirection = .None
            runAnimation()
            
            rightBlocked = false
            
            self.physicsBody?.dynamic = true
        
            createUpSensorPhysicsBody(whileTravellingUpOrDown: false)
            createDownSensorPhysicsBody(whileTravellingUpOrDown: false )
            createLeftSensorPhysicsBody(whileTravellingLeftOrRight: true )
            createRightSensorPhysicsBody(whileTravellingLeftOrRight: true )
            
        }
    }
    
    
    
    func setUpAnimationWithArray(theArray:NSArray, andAtlasNamed theAtlas:String ) {
        
        let atlas = SKTextureAtlas(named: theAtlas) //without the .atlas extension
        
        
        var atlasTextures:[SKTexture] = []
        
       
        for i in 0 ..< theArray.count {
            
            let texture:SKTexture = atlas.textureNamed( theArray[i] as! String  )
            atlasTextures.insert (texture, atIndex:i)
        }
        
        let atlasAnimation = SKAction.animateWithTextures(atlasTextures, timePerFrame: 1.0/30, resize: true, restore:false )
        movingAnimation = SKAction.repeatActionForever(atlasAnimation)
        
        
    }
    
    
    
    
    func setUpAnimation() {
        
        let atlas = SKTextureAtlas(named: "moving") //without the .atlas extension
        let array:[String] = ["moving0001", "moving0002"]
        
        var atlasTextures:[SKTexture] = []
        
        for i in 0 ..< array.count {
        
            
            let texture:SKTexture = atlas.textureNamed( array[i] )
            atlasTextures.insert (texture, atIndex:i)
        }
        
        let atlasAnimation = SKAction.animateWithTextures(atlasTextures, timePerFrame: 1.0/30, resize: true, restore:false )
        movingAnimation = SKAction.repeatActionForever(atlasAnimation)
        
        
    }
    
    func runAnimation(){
        
        objectSprite!.runAction(movingAnimation)
        
    }
    
    func stopAnimation(){
        
        objectSprite!.removeAllActions()
        
        
        
    }
    
    
    func createUpSensorPhysicsBody(whileTravellingUpOrDown whileTravellingUpOrDown:Bool) {
        
        var size:CGSize = CGSizeZero
        
        if (whileTravellingUpOrDown == true) {
            
            size = CGSize(width: 16, height: 2)
        } else {
            
            size = CGSize(width: 16.2, height: 18)
        }
        
        
        nodeUp!.physicsBody = nil // get rid of any existing physics body
        let bodyUp:SKPhysicsBody = SKPhysicsBody(rectangleOfSize: size)
        nodeUp!.physicsBody = bodyUp
        nodeUp!.physicsBody?.categoryBitMask = BodyType.sensorUp.rawValue
        nodeUp!.physicsBody?.collisionBitMask = 0
        nodeUp!.physicsBody?.contactTestBitMask = BodyType.boundary.rawValue
        nodeUp!.physicsBody?.pinned = true
        nodeUp!.physicsBody?.allowsRotation = false
        
        
    }
    
    func createDownSensorPhysicsBody(whileTravellingUpOrDown whileTravellingUpOrDown:Bool){
        
        var size:CGSize = CGSizeZero
        
        if (whileTravellingUpOrDown == true) {
            
            size = CGSize(width: 16, height: 2)
        } else {
            
            size = CGSize(width: 16.2 , height:18 )
        }
        
        
        
        nodeDown?.physicsBody = nil
        let bodyDown:SKPhysicsBody = SKPhysicsBody(rectangleOfSize: size )
        
        
        
        nodeDown!.physicsBody = bodyDown
        nodeDown!.physicsBody?.categoryBitMask = BodyType.sensorDown.rawValue
        nodeDown!.physicsBody?.collisionBitMask = 0
        nodeDown!.physicsBody?.contactTestBitMask = BodyType.boundary.rawValue
        nodeDown!.physicsBody!.pinned = true
        nodeDown!.physicsBody!.allowsRotation = false
        
        
    }
    
    func createLeftSensorPhysicsBody( whileTravellingLeftOrRight whileTravellingLeftOrRight:Bool){
        
        var size:CGSize = CGSizeZero
        
        if (whileTravellingLeftOrRight == true) {
            
            size = CGSize(width: 1, height: 16)
        } else {
            
            size = CGSize(width: 16, height: 16.2)
        }
        
        
        
        nodeLeft?.physicsBody = nil
        let bodyLeft:SKPhysicsBody = SKPhysicsBody(rectangleOfSize: size )
        nodeLeft!.physicsBody = bodyLeft
        nodeLeft!.physicsBody?.categoryBitMask = BodyType.sensorLeft.rawValue
        nodeLeft!.physicsBody?.collisionBitMask = 0
        nodeLeft!.physicsBody?.contactTestBitMask = BodyType.boundary.rawValue
        nodeLeft!.physicsBody!.pinned = true
        nodeLeft!.physicsBody!.allowsRotation = false
        
        
        
    }
    
    func createRightSensorPhysicsBody( whileTravellingLeftOrRight whileTravellingLeftOrRight:Bool){
        
        
        var size:CGSize = CGSizeZero
        
        if (whileTravellingLeftOrRight == true) {
            
            size = CGSize(width: 1, height: 8)
        } else {
            
            size = CGSize(width: 16, height: 16.2)
        }
        
        
        
        
        nodeRight?.physicsBody = nil
        let bodyRight:SKPhysicsBody = SKPhysicsBody(rectangleOfSize: size )
        nodeRight!.physicsBody = bodyRight
        nodeRight!.physicsBody?.categoryBitMask = BodyType.sensorRight.rawValue
        nodeRight!.physicsBody?.collisionBitMask = 0
        nodeRight!.physicsBody?.contactTestBitMask = BodyType.boundary.rawValue
        nodeRight!.physicsBody!.pinned = true
        nodeRight!.physicsBody!.allowsRotation = false
        
        
    }
    func upSensorContactStart() {
        
        upBlocked = true
        
        if (currentDirection == Direction.Up) {
            
            currentDirection = Direction.None
            self.physicsBody?.dynamic = false
            stopAnimation()
        }
        
        
    }
    
    func downSensorContactStart() {
        
        
        downBlocked = true
        
        if (currentDirection == Direction.Down) {
            
            currentDirection = Direction.None
            self.physicsBody?.dynamic = false
            stopAnimation()
        }
        
    }
    
    func leftSensorContactStart() {
        
        
        leftBlocked = true
        
        if (currentDirection == Direction.Left) {
            
            currentDirection = Direction.None
            self.physicsBody?.dynamic = false
            stopAnimation()
        }
        
    }

    func rightSensorContactStart() {
        
        
        rightBlocked = true
        
        if (currentDirection == Direction.Right) {
            
            currentDirection = Direction.None
            self.physicsBody?.dynamic = false
            stopAnimation()
        }
        
    }

    
    func upSensorContactEnd() {
        
        upBlocked = false
        
        if (desiredDirection == DesiredDirection.Up) {
            
            goUp()
            desiredDirection == DesiredDirection.None
        }
        
        
    }
    
    func downSensorContactEnd() {
        
        
        downBlocked = false
        
        if (desiredDirection == DesiredDirection.Down) {
            
            goDown()
            desiredDirection == DesiredDirection.None
        }

        
    }
    
    func leftSensorContactEnd() {
        
        
       
        
        leftBlocked = false
        
        if (desiredDirection == DesiredDirection.Left) {
            
            goLeft()
            desiredDirection == DesiredDirection.None
        }

        
    }
    
    func rightSensorContactEnd() {
        
        
      
        
        rightBlocked = false
        
        if (desiredDirection == DesiredDirection.Right) {
            
            goRight ()
            desiredDirection == DesiredDirection.None
        }

        
    }

    
}
















