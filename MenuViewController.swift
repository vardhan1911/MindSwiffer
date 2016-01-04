//
//  MenuViewController.swift
//  TestView
//
//  Created by Vardhan Dharnidharka on 12/18/15.
//  Copyright © 2015 Vardhan Inc. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet weak var easyButton: UIButton!
    @IBOutlet weak var intermediateButton: UIButton!
    @IBOutlet weak var hardButton: UIButton!
    
    let gameColors: GameColors = GameColors()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setColorToMenuScreen()
    }
    
    func setColorToMenuScreen() {
        easyButton.backgroundColor = GameColors.color2
        easyButton.setTitleColor(GameColors.color1, forState: .Normal)
        easyButton.layer.cornerRadius = 5
//        easyButton.layer.shadowColor = GameColors.color2.CGColor
//        easyButton.layer.shadowOpacity = 0.5;
//        easyButton.layer.shadowRadius = 4;
//        easyButton.layer.shadowOffset = CGSizeMake(12.0, 12.0);
        
        intermediateButton.backgroundColor = GameColors.color2
        intermediateButton.setTitleColor(GameColors.color1, forState: .Normal)
        intermediateButton.layer.cornerRadius = 5
        
        hardButton.backgroundColor = GameColors.color2
        hardButton.setTitleColor(GameColors.color1, forState: .Normal)
        hardButton.layer.cornerRadius = 5
        
        view.backgroundColor = GameColors.color1

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationNavigationController = segue.destinationViewController as? UINavigationController {
            if let gvc = destinationNavigationController.topViewController as? GameViewController {
                if let identifier = segue.identifier {
                    switch identifier {
                    case "Easy":
                        gvc.gameMode = GameMode.Easy
                    case "Medium":
                        gvc.gameMode = GameMode.Intermediate
                    case "Hard":
                        gvc.gameMode = GameMode.Hard
                    default: break
                    }
                }
            }
        }
        
    }

    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            //            print("In Motion Ended")
            //            GameColors.color1 = UIColor.redColor()
            //            setColorToMenuScreen()
            //            self.easyButton.setNeedsDisplay()
        }
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }

    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return .Portrait
    }
    
}

//extension UINavigationController {
////    public override func shouldAutorotate() -> Bool {
////        return visibleViewController!.shouldAutorotate()
////    }
//////
//    public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
//        return visibleViewController!.supportedInterfaceOrientations()
//    }
////    public override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
////        return visibleViewController!.preferredInterfaceOrientationForPresentation()
////    }
//}
