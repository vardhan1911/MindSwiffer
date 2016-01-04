//
//  TileButton.swift
//  TestView
//
//  Created by Vardhan Dharnidharka on 12/19/15.
//  Copyright © 2015 Vardhan Inc. All rights reserved.
//

import UIKit

class TileButton: UIButton {

    var idx: Int = -1
    var val: Int = 0    // Cell Value -1: Mine, 0: Empty & Others: Value
    
    static var numFlags = 0
    static var numOpened = 0
    
    var isFlagged: Bool = false {
        didSet {
            if isFlagged {
                setTitle("F", forState: .Normal)
                TileButton.numFlags += 1
            }
            else {
                setTitle("", forState: .Normal)
                TileButton.numFlags -= 1
            }
        }
    }
    
    var isOpen: Bool = false {
        didSet { TileButton.numOpened += 1 }
    }
    
    func toggleFlag() {
        if self.isOpen { return }
        self.isFlagged = !self.isFlagged
    }
    
    func openButton(val:Int) {
        if self.isOpen { return }
        self.isOpen = true
        setTitle(String(val), forState: .Normal)
    }
    
    override func setTitle(var title: String?, forState state: UIControlState) {
        
        if title == "F" {
//            super.setTitle("🚩", forState: state)
            super.setTitle("❤️", forState: state)
        }
        else if title == "" {
            super.setTitle(title, forState: state)
        }
        else {
            super.layer.backgroundColor = GameColors.color1.colorWithAlphaComponent(0.20).CGColor
            
            switch title! {
            case "-100":
                title = "💥"
            case "-200":
                title = "🚫"
            case "-1":
                title = "💣"
            case "1":
                self.setTitleColor(GameColors.num1, forState: state)
            case "2":
                self.setTitleColor(GameColors.num2, forState: state)
            case "3":
                self.setTitleColor(GameColors.num3, forState: state)
            case "4":
                self.setTitleColor(GameColors.num4, forState: state)
            case "5":
                self.setTitleColor(GameColors.num5, forState: state)
            case "6":
                self.setTitleColor(GameColors.num6, forState: state)
            case "7":
                self.setTitleColor(GameColors.num7, forState: state)
            case "8":
                self.setTitleColor(GameColors.num8, forState: state)
            default:
                title = ""
            }
            super.setTitle(title, forState: state)
            self.titleLabel?.font = UIFont(name: "ChalkboardSE-Bold", size: 24)
        }
   }

}
