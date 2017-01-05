

import SpriteKit
import AVFoundation


enum BodyType:UInt32 {

    case hero = 1
    case boundary = 2
    case sensorUp = 4
    case sensorDown = 8
    case sensorRight = 16
    case sensorLeft = 32
    case star = 64
    case enemy = 128
    case boundary2 = 256
    case ghosting = 512
    case teleport = 1024
    case speed = 2048

}

class GameScene: SKScene, SKPhysicsContactDelegate, NSXMLParserDelegate {
    var viewController: UIViewController?
    var currentSpeed:Float = 5
    var enemySpeed:Float = 4
    var heroLocation:CGPoint = CGPointZero
    var mazeWorld:SKNode = SKNode()
    var hero:Hero?
    var heroIsDead:Bool = false
    var starsAcquired:Int = 0
    var starsTotal:Int = 0
    var enemyCount:Int = 0
    var enemyDictionary:[String : CGPoint] = [:]
    var currentTMXFile:String?
    var enemyLogic:Double = 5
    var gameLabel:SKLabelNode?
    var userLabel:SKFieldNode?
    var parallaxBG:SKSpriteNode?
    var parallaxOffset:CGPoint = CGPointZero
    var bgSoundPlayer:AVAudioPlayer?
    
    var scoreLabel:SKLabelNode?
    var totalPoints = 0
    
    var speedBoost:Float = 10
    var speedTriggered = false
    var speedCounter = 0
    var deadEnemies:[Enemy] = []
    var repeatEnemies:[Enemy] = []
    var ghostingTriggered = false
    var ghostingCounter = 0
    var teleportTriggered = false
    var hasTeleported = false
    var teleportLocation:CGPoint = CGPointZero
    var teleportIncrement = 0
    var teleportPositions:[CGPoint] = []
    
    
    override func didMoveToView(view: SKView) {
        
        teleportIncrement = 0
        teleportPositions = []
        let path = NSBundle.mainBundle().pathForResource("GameData", ofType: "plist")
        
        
        let dict = NSDictionary(contentsOfFile: path!)!
        let heroDict:NSDictionary = dict.objectForKey("HeroSettings")! as! NSDictionary
        let gameDict:NSDictionary = dict.objectForKey("GameSettings") as! NSDictionary
        let levelArray:AnyObject = dict.objectForKey("LevelSettings")!
        
        if let levelNSArray:NSArray = levelArray as? NSArray{
            
            
            let levelDict:NSDictionary = levelNSArray[currentLevel] as! NSDictionary
            
            let tmxFile = levelDict["TMXFile"] as? String

                currentTMXFile = tmxFile
            
            if let speed = levelDict["Speed"] as? Float  {
                currentSpeed = speed
                print( currentSpeed )
            }
            if let espeed = levelDict["EnemySpeed"] as? Float  {
                
                enemySpeed = espeed
                print( enemySpeed )
            }
            
            if let elogic = levelDict["EnemyLogic"] as? Double   {
                
                enemyLogic = elogic
                print( enemyLogic )
            }
            if let musicFile = levelDict["Music"] as? String    {
                playBackgroundSound(musicFile)
            }

        }
        self.backgroundColor = SKColor.blueColor()
       
        view.showsPhysics = gameDict["ShowPhysics"] as! Bool
        
        
        if ( gameDict["Gravity"] != nil) {
            let newGravity:CGPoint = CGPointFromString( gameDict["Gravity"] as! String )
             physicsWorld.gravity = CGVector(dx: newGravity.x, dy: newGravity.y)
            
        } else {
            
             physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        }
        
        
        if ( gameDict["ParallaxOffset"] != nil) {
            
           let parallaxOffsetAsString = gameDict["ParallaxOffset"] as! String
            parallaxOffset = CGPointFromString(parallaxOffsetAsString )
          
        }

        
        
        
        
       
        physicsWorld.contactDelegate = self
        self.anchorPoint = CGPoint(x:0.5, y:0.5)
        
            self.enumerateChildNodesWithName("*") {
                node, stop in
                
                node.removeFromParent()
                
            }
            mazeWorld = SKNode()
            addChild(mazeWorld)
        
       
        
        hero = Hero(theDict: heroDict as! Dictionary)
        hero!.position =  heroLocation
        mazeWorld.addChild(hero!)
        hero!.currentSpeed = currentSpeed
        
        let waitAction:SKAction = SKAction.waitForDuration(0.5)
        self.runAction(waitAction, completion: {
            
            let swipeRight:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipedRight(_:)) )
            swipeRight.direction = .Right
            view.addGestureRecognizer(swipeRight)
            
            let swipeLeft:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipedLeft(_:)) )
            swipeLeft.direction = .Left
            view.addGestureRecognizer(swipeLeft)
            
            let swipeUp:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipedUp(_:)) )
            swipeUp.direction = .Up
            view.addGestureRecognizer(swipeUp)
            
            let swipeDown:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipedDown(_:)) )
            swipeDown.direction = .Down
            view.addGestureRecognizer(swipeDown)
            
            
            }
        )
            parseTMXFileWithName(currentTMXFile!)
        
        tellEnemiesWhereHeroIs()
        createLabel()
    }
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */

        scoreLabel!.text = "Score: " + String(totalPoints)
        if (speedTriggered == true && speedCounter < 300){
            speedCounter++
        }
        else {
            hero!.currentSpeed = currentSpeed
            speedTriggered = false
            speedCounter = 0
        }
        if (ghostingTriggered == true && ghostingCounter < 300) {
            if (ghostingCounter == 0) {
                mazeWorld.childNodeWithName("enemy1")?.removeAllChildren()
                mazeWorld.childNodeWithName("enemy2")?.removeAllChildren()
                mazeWorld.childNodeWithName("enemy3")?.removeAllChildren()
                mazeWorld.childNodeWithName("enemy4")?.removeAllChildren()
                mazeWorld.childNodeWithName("enemy1")?.addChild(SKSpriteNode( imageNamed:"ghost"))
                mazeWorld.childNodeWithName("enemy2")?.addChild(SKSpriteNode( imageNamed:"ghost"))
                mazeWorld.childNodeWithName("enemy3")?.addChild(SKSpriteNode( imageNamed:"ghost"))
                mazeWorld.childNodeWithName("enemy4")?.addChild(SKSpriteNode( imageNamed:"ghost"))

            }

            ghostingCounter++
            if (deadEnemies.count > 0){
                for (enemy) in deadEnemies {
                    for (enemies) in repeatEnemies {
                        if (enemies.name! == enemy.name!) {
                            repeatEnemies.removeAll()
                            deadEnemies.removeAll()
                            loseLife()
                            ghostingCounter = 299
                            heroIsDead = true
                        }
                    }
                    if (!heroIsDead) {
                        totalPoints += 10
                        resetEnemy(enemy)
                        deadEnemies.removeFirst()
                        repeatEnemies.append(enemy)
                        enemy.removeAllChildren()
                        enemy.addChild(SKSpriteNode( imageNamed:enemy.name!))
   
                    }
                }
            }
            if (ghostingCounter == 299) {
                mazeWorld.childNodeWithName("enemy1")?.removeAllChildren()
                mazeWorld.childNodeWithName("enemy2")?.removeAllChildren()
                mazeWorld.childNodeWithName("enemy3")?.removeAllChildren()
                mazeWorld.childNodeWithName("enemy4")?.removeAllChildren()
                mazeWorld.childNodeWithName("enemy1")?.addChild(SKSpriteNode( imageNamed:"enemy1"))
                mazeWorld.childNodeWithName("enemy2")?.addChild(SKSpriteNode( imageNamed:"enemy2"))
                mazeWorld.childNodeWithName("enemy3")?.addChild(SKSpriteNode( imageNamed:"enemy3"))
                mazeWorld.childNodeWithName("enemy4")?.addChild(SKSpriteNode( imageNamed:"enemy4"))
                ghostingCounter = 0
                repeatEnemies.removeAll()
                ghostingTriggered = false

            }
        }
        if (teleportTriggered == true && hasTeleported == true){
            hero!.position = teleportLocation
            hasTeleported = false
        }

        if ( heroIsDead == false ){
        
            if (hero != nil){
            hero!.update()
            }
            
            
            mazeWorld.enumerateChildNodesWithName("enemy*") {
                node, stop in
                
                if let enemy = node as? Enemy {
                    
                    
                    if (enemy.isStuck == true) {
                        
                        enemy.heroLocationIs = self.returnTheDirection(enemy)
                        enemy.decideDirection()
                        enemy.isStuck = false
                    }
                    
                    enemy.update()
                    
                    
                    
                }
            }
        } else  {
            
            
            resetEnemies()
            hero?.rightBlocked = false
            hero!.position = heroLocation
            heroIsDead = false
            hero!.currentDirection = .Right
            hero!.desiredDirection = .None
            hero!.goRight()
            hero!.runAnimation()
        }
    }
    
    
    
    func swipedRight(sender:UISwipeGestureRecognizer) {
        
        hero!.goRight()
    }
    func swipedLeft(sender:UISwipeGestureRecognizer) {
        
        hero!.goLeft()
    }
    func swipedDown(sender:UISwipeGestureRecognizer) {
        
        hero!.goDown()
    }
    func swipedUp(sender:UISwipeGestureRecognizer) {
        
        hero!.goUp()
    }
    
    
   
    func didBeginContact(contact: SKPhysicsContact) {
        
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch(contactMask) {
            
        case BodyType.enemy.rawValue | BodyType.enemy.rawValue:
            
            if let enemy1 = contact.bodyA.node as? Enemy  {
                enemy1.bumped()
                
            } else if let enemy2 = contact.bodyB.node as? Enemy {
                
                enemy2.bumped()
            }
            
        case BodyType.hero.rawValue | BodyType.enemy.rawValue:
            if let enemy = contact.bodyB.node as? Enemy {
                if (ghostingTriggered == true){
                    deadEnemies.append(enemy)
                }
                else {
                    reloadLevel()
                }
            }

         case BodyType.boundary.rawValue | BodyType.sensorUp.rawValue:
            
            hero!.upSensorContactStart()
        case BodyType.boundary.rawValue | BodyType.sensorDown.rawValue:
            
            hero!.downSensorContactStart()
            
        case BodyType.boundary.rawValue | BodyType.sensorLeft.rawValue:
            
            hero!.leftSensorContactStart()
            
        case BodyType.boundary.rawValue | BodyType.sensorRight.rawValue:
            
            hero!.rightSensorContactStart()
            
            
            
        case BodyType.hero.rawValue | BodyType.star.rawValue:
            
            let collectSound:SKAction = SKAction.playSoundFileNamed("collect_something.caf", waitForCompletion: false)
            self.runAction(collectSound)
          
            
            if let star = contact.bodyA.node as? Star {
                star.removeFromParent()
                
                if ( star.willAutoAdvanceLevel == true){
                    
                    loadNextLevel()
                    
                }
                
                
            } else if let star = contact.bodyB.node as? Star {
                
                star.removeFromParent()
                
                if ( star.willAutoAdvanceLevel == true){
                    
                    loadNextLevel()
                    
                }
                
            }
            
            starsAcquired += 1
            totalPoints += 1
            
            if (starsAcquired == starsTotal) {
                
                loadNextLevel()
            }
            
        case BodyType.hero.rawValue | BodyType.ghosting.rawValue:
            if let ghosting = contact.bodyA.node as? Ghosting {
                ghosting.removeFromParent()
                ghostingCounter = 0
                deadEnemies.removeAll()
                repeatEnemies.removeAll()
                ghostingTriggered = true
            } else if let ghosting = contact.bodyB.node as? Ghosting {
                ghosting.removeFromParent()
                ghostingCounter = 0
                deadEnemies.removeAll()
                repeatEnemies.removeAll()
                ghostingTriggered = true
            }
        case BodyType.hero.rawValue | BodyType.teleport.rawValue:
            if let teleport = contact.bodyA.node as? Teleport {
                if (!teleportTriggered){
                    teleportLocation = teleportPositions[teleport.id ^ 1]
                }
                teleportTriggered = true
                hasTeleported = true
            } else if let teleport = contact.bodyB.node as? Teleport {
                if (!teleportTriggered){
                    teleportLocation = teleportPositions[teleport.id ^ 1]
                }
                teleportTriggered = true
                hasTeleported = true
            }
        case BodyType.hero.rawValue | BodyType.speed.rawValue:
            if let speed = contact.bodyA.node as? Speed {
                speed.removeFromParent()
                hero!.currentSpeed = speedBoost
                speedCounter = 0
                speedTriggered = true
                
            } else if let speed = contact.bodyB.node as? Speed {
                speed.removeFromParent()
                hero!.currentSpeed = speedBoost
                speedCounter = 0
                speedTriggered = true
            }

            
        default:
            return
            
        }
        
    }
    
    
    
    func didEndContact(contact: SKPhysicsContact) {
        
         let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch(contactMask) {
            
        case BodyType.boundary.rawValue | BodyType.sensorUp.rawValue:
            
            hero!.upSensorContactEnd()
            
        case BodyType.boundary.rawValue | BodyType.sensorDown.rawValue:
            
            hero!.downSensorContactEnd()
            
        case BodyType.boundary.rawValue | BodyType.sensorLeft.rawValue:
            
            hero!.leftSensorContactEnd()
            
        case BodyType.boundary.rawValue | BodyType.sensorRight.rawValue:
            
            hero!.rightSensorContactEnd()
        case BodyType.hero.rawValue | BodyType.teleport.rawValue:
            if let teleport = contact.bodyA.node as? Teleport {
                teleportTriggered = false
            } else if let teleport = contact.bodyB.node as? Teleport {
                teleportTriggered = false
            }

            
        default:
            return
            
        }
        
    }
    
    // MARK: Parse TMX File
    
    func parseTMXFileWithName(name:String) {
        
        let path:String = NSBundle.mainBundle().pathForResource(name , ofType: "tmx")!
        let data:NSData = NSData(contentsOfFile: path)!
        let parser:NSXMLParser = NSXMLParser(data: data)
        
        parser.delegate = self
        parser.parse()
        
    }
   func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String])  {
        
        if (elementName == "object") {
            
            let type:AnyObject? = attributeDict["type"]
            
                if (type as? String == "Boundary") {
                    
                    var tmxDict = attributeDict
                    let theName:String = attributeDict["name"] as AnyObject? as! String
                    tmxDict.updateValue(theName, forKey: "image")
                
                    let newBoundary:Boundary = Boundary(theDict: tmxDict)
                    mazeWorld.addChild(newBoundary)
                }
                
                else if (type as? String == "Star" || type as? String == "Star2") {
                    
                    let newStar:Star = Star(fromTMXFileWithDict: attributeDict)
                    mazeWorld.addChild(newStar)
                    
                    starsTotal += 1
                    
                    if ( type as? String == "Star2" ) {
                        
                        
                        newStar.willAutoAdvanceLevel = true
                    }
                    
                    
                    
                }
                
                
                else if (type as? String == "Portal") {
                
                    let theName:String = attributeDict["name"] as AnyObject? as! String
                    
                    if (theName == "StartingPoint") {
                       
                        let theX:String = attributeDict["x"] as AnyObject? as! String
                        let x:Int = Int(theX)!
                        
                        
                        let theY:String = attributeDict["y"] as AnyObject? as! String
                        let y:Int = Int(theY)!
                        
                        hero!.position = CGPoint(x: x , y: y * -1)
                        heroLocation = hero!.position
                        
                        
                    }
                
                
                }
                else if (type as? String == "Enemy") {
                    
                    enemyCount += 1
                    
                    let theName:String = attributeDict["name"] as AnyObject? as! String
                    
                    let newEnemy:Enemy = Enemy(theDict: attributeDict)
                    mazeWorld.addChild(newEnemy)
                    
                    newEnemy.name = theName
                    newEnemy.enemySpeed = enemySpeed
                    
                    let location:CGPoint = newEnemy.position
                    
                    enemyDictionary.updateValue(location, forKey: newEnemy.name!)
                    
                    
                }
                else if (type as? String == "ghosting") {
                    let newGhosting:Ghosting = Ghosting(fromTMXFileWithDict: attributeDict)
                    mazeWorld.addChild(newGhosting)
                }
                else if (type as? String == "teleport") {
                    let newTeleport:Teleport = Teleport(fromTMXFileWithDict: attributeDict)
                    mazeWorld.addChild(newTeleport)
                    newTeleport.id = teleportIncrement
                    teleportIncrement++
                    teleportPositions.append(newTeleport.position)
                }
                else if (type as? String == "speed") {
                    let newSpeed:Speed = Speed(fromTMXFileWithDict: attributeDict)
                    mazeWorld.addChild(newSpeed)
            }

            
            
            
        }
        
    }
    
    
    override func didSimulatePhysics() {
        
        if (heroIsDead == false ){
            
            if ( hero != nil){
                self.centerOnNode(hero!)
            }
            
        }
    }
    
    func centerOnNode(node:SKNode) {
        
        
        let cameraPositionInScene:CGPoint = self.convertPoint(node.position, fromNode: mazeWorld)
        mazeWorld.position = CGPoint(x: mazeWorld.position.x - cameraPositionInScene.x, y: mazeWorld.position.y - cameraPositionInScene.y)
        

        
    }
    
    func tellEnemiesWhereHeroIs () {
        
        let enemyAction:SKAction = SKAction.waitForDuration(enemyLogic)
        self.runAction(enemyAction, completion: {
            
                self.tellEnemiesWhereHeroIs()
            
            }
        )
    
        
        
        mazeWorld.enumerateChildNodesWithName("enemy*") {
            node, stop in
        
            if let enemy = node as? Enemy {
                
                
                 enemy.heroLocationIs = self.returnTheDirection(enemy)
                
            }
    
        
        }
        
    }
    
    
    func returnTheDirection(enemy:Enemy) -> HeroIs {
        
        if (self.hero!.position.x < enemy.position.x && self.hero!.position.y < enemy.position.y) {
            
            return HeroIs.Southwest
            
        } else if (self.hero!.position.x > enemy.position.x && self.hero!.position.y < enemy.position.y) {
            
            return HeroIs.Southeast
            
        } else if (self.hero!.position.x < enemy.position.x && self.hero!.position.y >  enemy.position.y) {
            
           return HeroIs.Northwest
            
        } else if (self.hero!.position.x > enemy.position.x && self.hero!.position.y >  enemy.position.y) {
            
           return HeroIs.Northeast
            
        } else {
            
            return HeroIs.Northeast
        }
        
    }
    
    
    // MARK: Reload Level 
    
    func reloadLevel() {
        
        loseLife()
        heroIsDead = true
        
    }
    
    
    func resetEnemies() {
        
        for (name, location) in enemyDictionary {
            
            mazeWorld.childNodeWithName(name)?.position = location
            
        }
        
        
    }
    
    func resetEnemy(enemy:Enemy) {
        for (name, location) in enemyDictionary {
            if (name == enemy.name!){
                mazeWorld.childNodeWithName(name)?.position = location
            }
        }
        
        
    }
    
    func loadNextLevel() {
        if(currentLevel <= 3){
        currentLevel += 1
        if (bgSoundPlayer != nil) {
            bgSoundPlayer!.stop()
            bgSoundPlayer = nil
        }
            loadNextTMXLevel()
        } else{
            let check : NSUserDefaults = NSUserDefaults.standardUserDefaults()
            if (check.objectForKey("anyKey") == nil){
                let int : NSMutableArray = []
                int.addObject(totalPoints as NSInteger)
                let userFavorites = NSUserDefaults.standardUserDefaults()
                userFavorites.setObject(int, forKey:"anyKey")
                userFavorites.synchronize()
            } else{
                let string = check.objectForKey("anyKey") as! NSMutableArray
                //print(string[1])
                //var checker = self.movieTitle.text! as! NSString
                
                    var middleMan = [Int]()
                    if(string.count > 0){
                        for index in 0...string.count-1 {
                            let insert = string[index] as! Int
                            middleMan.append(insert)
                        }
                    }
                    middleMan.append(totalPoints)
                    check.setObject(middleMan, forKey:"anyKey")
                    check.synchronize()
                
            }
            livesLeft = 3
            currentLevel = 0
            print("OutOfLives")
            self.viewController!.performSegueWithIdentifier("OutOfLives", sender: viewController)
            print("Should Have Segued")
        }
    }
    
    
    func loadNextTMXLevel(){
        
        
        let scene:GameScene = GameScene(size: self.size)
        scene.scaleMode = .AspectFill
        
        self.view?.presentScene(scene, transition: SKTransition.fadeWithDuration(1))
        
        
    }
    func loseLife() {
        
        livesLeft = livesLeft - 1
        
        if (livesLeft == 0 ){
            
            
            var check : NSUserDefaults = NSUserDefaults.standardUserDefaults()
            if (check.objectForKey("anyKey") == nil){
                var int : NSMutableArray = []
                int.addObject(totalPoints as NSInteger)
                let userFavorites = NSUserDefaults.standardUserDefaults()
                userFavorites.setObject(int, forKey:"anyKey")
                userFavorites.synchronize()
            } else{
                var string = check.objectForKey("anyKey") as! NSMutableArray
                //print(string[1])
                //var checker = self.movieTitle.text! as! NSString
                    var middleMan = [Int]()
                    if(string.count > 0){
                        for index in 0...string.count-1 {
                            let insert = string[index] as! Int
                            middleMan.append(insert)
                        }
                    }
                    middleMan.append(totalPoints)
                    check.setObject(middleMan, forKey:"anyKey")
                    check.synchronize()
                
            }
            livesLeft = 3
            currentLevel = 0
            //resetGame()
            view!.paused = true
            print("OutOfLives")
            self.viewController!.performSegueWithIdentifier("OutOfLives", sender: viewController)
            print("Should Have Segued")
            
        } else {
            
            gameLabel!.text = "Lives: " + String(livesLeft)
            // update text for lives label
            
        }
        
        
    }
    
    func resetGame(){
        
        livesLeft = 3
        currentLevel = 0
        
        
        if (bgSoundPlayer != nil) {
            
            bgSoundPlayer!.stop()
            bgSoundPlayer = nil
            
        }

        
            
           loadNextTMXLevel()
            
        
        
    }
    
    func createLabel() {
        
        scoreLabel = SKLabelNode(fontNamed: "BM germar")
        scoreLabel!.horizontalAlignmentMode = .Right
        scoreLabel!.verticalAlignmentMode = .Center
        scoreLabel!.fontColor = SKColor.whiteColor()
        scoreLabel!.text = "Score: " + String(totalPoints)
        
        gameLabel = SKLabelNode(fontNamed: "BM germar")
        gameLabel!.horizontalAlignmentMode = .Left
        gameLabel!.verticalAlignmentMode = .Center
        gameLabel!.fontColor = SKColor.whiteColor()
        gameLabel!.text = "Lives: " + String(livesLeft)
        
        addChild(scoreLabel!)
        addChild(gameLabel!)
        
        
        if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
            
            scoreLabel!.position = CGPoint(x: (self.size.width / 2.3), y: -(self.size.height / 3) )
            gameLabel!.position = CGPoint(x: -(self.size.width / 2.3), y: -(self.size.height / 3) )
            
        } else if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            
            scoreLabel!.position = CGPoint(x: (self.size.width / 2.3), y: -(self.size.height / 2.3) )
            gameLabel!.position = CGPoint(x: -(self.size.width / 2.3), y: -(self.size.height / 2.3) )
            
        } else {
            
            scoreLabel!.position = CGPoint(x: (self.size.width / 2.3), y: -(self.size.height / 3) )
            gameLabel!.position = CGPoint(x: -(self.size.width / 2.3), y: -(self.size.height / 3) )
       
        }

    
    
    }


    func createBackground(image:String) {
        self.view?.backgroundColor = UIColor.blueColor()
    }
    
    
    func playBackgroundSound(name:String) {
        
        
        if (bgSoundPlayer != nil) {
            
            bgSoundPlayer!.stop()
            bgSoundPlayer = nil
            
        }
        
        
        let fileURL:NSURL = NSBundle.mainBundle().URLForResource( name , withExtension: "mp3")!
        
        do {
            bgSoundPlayer = try AVAudioPlayer(contentsOfURL: fileURL)
        } catch _ {
            bgSoundPlayer = nil
        }
        
        
        bgSoundPlayer!.volume = 0.5  //half volume
        bgSoundPlayer!.numberOfLoops = -1
        bgSoundPlayer!.prepareToPlay()
        bgSoundPlayer!.play()
        
        
    }
  
 
    
}





