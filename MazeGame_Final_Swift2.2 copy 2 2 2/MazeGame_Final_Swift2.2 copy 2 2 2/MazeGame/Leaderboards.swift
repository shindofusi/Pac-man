//
//  Leaderboards.swift
//  Pacman
//
//  Created by Alexander Cheung on 12/5/16.
//  Copyright © 2016 teampac. All rights reserved.
//

import UIKit

var highScoreList:[Int] = [Int]()

class Leaderboards: UIViewController {

    @IBOutlet weak var L1: UILabel!
    @IBOutlet weak var L2: UILabel!
    @IBOutlet weak var L3: UILabel!
    @IBOutlet weak var L4: UILabel!
    @IBOutlet weak var L5: UILabel!
    @IBOutlet weak var L6: UILabel!
    @IBOutlet weak var L7: UILabel!

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var check: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if (check.objectForKey("anyKey") != nil){
            var string : NSMutableArray = check.objectForKey("anyKey") as! NSMutableArray
            if string.count > 0{
                    for index in 0...string.count-1 {
                        let insert = string[index] as! Int
                        highScoreList.append(insert)
                    }

            }
        }
        highScoreList.sortInPlace() { $0 > $1 }
        displayScores()
        
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayScores(){
        if highScoreList.count>0 {
            L1.text = "1. \(highScoreList[0])"
        }else{
            L1.text = "1. Up For Grabs!"
        }
        if highScoreList.count>1 {
            L2.text = "2. \(highScoreList[1])"
        }else{
            L2.text = "2. Up For Grabs!"
        }
        if highScoreList.count>2 {
            L3.text = "3. \(highScoreList[2])"
        }else{
            L3.text = "3. Up For Grabs!"
        }
        if highScoreList.count>3 {
            L4.text = "4. \(highScoreList[3])"
        }else{
            L4.text = "4. Up For Grabs!"
        }
        if highScoreList.count>4 {
            L5.text = "5. \(highScoreList[4])"
        }else{
            L5.text = "5. Up For Grabs!"
        }
        if highScoreList.count>5 {
            L6.text = "6. \(highScoreList[5])"
        }else{
            L6.text = "6. Up For Grabs!"
        }
        if highScoreList.count>6 {
            L7.text = "7. \(highScoreList[6])"
        }else{
            L7.text = "7. Up For Grabs!"
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
