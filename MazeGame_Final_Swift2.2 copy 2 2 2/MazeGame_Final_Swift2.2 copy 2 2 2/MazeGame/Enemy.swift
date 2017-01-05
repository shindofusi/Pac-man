import Foundation
import SpriteKit
enum HeroIs {
    case Southwest, Southeast, Northwest, Northeast
}
enum EnemyDirection {
    case Up, Down, Left, Right
}


class Enemy: SKNode {
    
    var heroLocationIs = HeroIs.Southwest
    var currentDirection = EnemyDirection.Up
    var enemySpeed:Float = 5
    var isStuck:Bool = false
    var previousLocation1:CGPoint = CGPointZero
    var previousLocation2:CGPoint = CGPoint(x: 1, y: 1)
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init (fromSKSWithImage  image:String ){
        
        super.init()
        
        let enemySprite = SKSpriteNode( imageNamed:image)
        addChild(enemySprite)
        
        setUpPhysics(enemySprite.size)
        
        enemySprite.color = SKColor.blackColor()
        
    }
    
    init (theDict:Dictionary<NSObject, AnyObject>){
        
        super.init()
        
        let theX:String = theDict["x"] as AnyObject? as! String
        let x:Int =  Int(theX)!
        let theY:String = theDict["y"] as AnyObject? as! String
        let y:Int =  Int(theY)!
        
        
        let location:CGPoint = CGPoint(x: x, y: y * -1)
        
        let image = theDict["name"] as AnyObject? as! String
        
        let enemySprite = SKSpriteNode( imageNamed:image)
        
        self.position = CGPoint(x: location.x + (enemySprite.size.width / 2) , y: location.y - (enemySprite.size.height / 2))        
        addChild(enemySprite)
        
     
        
         setUpPhysics(enemySprite.size)
        
    }
    
    
    func setUpPhysics(size:CGSize) {
        
        // self.physicsBody = SKPhysicsBody(circleOfRadius: enemySprite.size.width / 2  )
        self.physicsBody = SKPhysicsBody(rectangleOfSize: size )
        self.physicsBody?.categoryBitMask = BodyType.enemy.rawValue
        self.physicsBody?.collisionBitMask = BodyType.boundary.rawValue | BodyType.boundary2.rawValue | BodyType.enemy.rawValue
        self.physicsBody?.contactTestBitMask = BodyType.hero.rawValue | BodyType.enemy.rawValue
        self.physicsBody?.allowsRotation = false
        self.zPosition = 90
        
        
        
        
    }
    
    
    func decideDirection() {
        
        let previousDirection = currentDirection
        
        switch (heroLocationIs) {
            
        case .Southwest:
            if (previousDirection == .Down) {
                
                currentDirection = .Left
            } else {
                
                currentDirection = .Down
            }
        case .Southeast:
            
            if ( previousDirection == .Down) {
                
                currentDirection = .Right
            } else {
                
                currentDirection = .Down
            }
            
        case .Northeast:
            
            if ( previousDirection == .Up) {
                
                currentDirection = .Right
            } else {
                
                currentDirection = .Up
            }
            
        case .Northwest:
            
            if ( previousDirection == .Up) {
                
                currentDirection = .Left
            } else {
                
                currentDirection = .Up
            }
            
            
            
            
        }
        
        
        
    }
    
    
    
    func update() {
        
        
        /* check if enemy is stuck, that means has stayed in same location for more than one update */
        
        if ( Int(previousLocation2.y) == Int(previousLocation1.y) &&  Int(previousLocation2.x) == Int(previousLocation1.x) ) {
            
            isStuck = true
            decideDirection()
            
        }
        
        
        let superDice = arc4random_uniform(1000)
        
        if (superDice == 0) {
            print("randomly changing direction ")
            
            let diceRoll = arc4random_uniform(4)
            
            switch (diceRoll) {
                
            case 0:
                currentDirection = .Up
            case 1:
                currentDirection = .Left
            case 2:
                currentDirection = .Right
            default:
                currentDirection = .Down
                
            }
        }
        
        
        
        previousLocation2 = previousLocation1
        
        
        
        
        if (currentDirection == .Up) {
            
            self.position = CGPoint(x: self.position.x, y: self.position.y + CGFloat(enemySpeed) )
            
            if (heroLocationIs == .Northeast) {
                
                self.position = CGPoint(x: self.position.x + CGFloat(enemySpeed), y: self.position.y  )
                
            } else if (heroLocationIs == .Northwest) {
               
                self.position = CGPoint(x: self.position.x -  CGFloat(enemySpeed), y: self.position.y  )
            }
            
        } else if ( currentDirection == .Down){
            
            self.position = CGPoint(x: self.position.x  , y: self.position.y - CGFloat(enemySpeed) )
            
            if ( heroLocationIs == .Southeast) {
                
                self.position = CGPoint(x: self.position.x + CGFloat(enemySpeed)  , y: self.position.y  )
                
            } else if ( heroLocationIs == .Southwest) {
                
                self.position = CGPoint(x: self.position.x - CGFloat(enemySpeed)  , y: self.position.y  )
            }
            
        } else if ( currentDirection == .Right){
            
            self.position = CGPoint(x: self.position.x + CGFloat(enemySpeed) , y: self.position.y )
            
            if ( heroLocationIs == .Southeast) {
                
                self.position = CGPoint(x: self.position.x , y: self.position.y - CGFloat(enemySpeed) )
                
            } else  if ( heroLocationIs == .Northeast) {
                
                self.position = CGPoint(x: self.position.x , y: self.position.y + CGFloat(enemySpeed)  )
            }
            
        } else if ( currentDirection == .Left){
            
            self.position = CGPoint(x: self.position.x - CGFloat(enemySpeed) , y: self.position.y  )
            
            if ( heroLocationIs == .Southwest) {
                
                self.position = CGPoint(x: self.position.x , y: self.position.y - CGFloat(enemySpeed) )
                
            } else if ( heroLocationIs == .Northwest) {
                
                self.position = CGPoint(x: self.position.x , y: self.position.y + CGFloat(enemySpeed)  )
            }
            
        }
        
        previousLocation1 = self.position
        
        /* after moving enemy, save location to another location variable, for comparing stuckness */
        
    }
    
    
    
    func bumped() {
        
        switch(currentDirection){
         
        case .Up:
            currentDirection = .Down
        case .Down:
            currentDirection = .Up
        case .Left:
            currentDirection = .Right
        case .Right:
            currentDirection = .Left
            
        }
        
        
    }
    
    
}















