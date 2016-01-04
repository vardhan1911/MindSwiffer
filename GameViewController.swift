//
//  GameViewController.swift
//  TestView
//
//  Created by Vardhan Dharnidharka on 12/19/15.
//  Copyright © 2015 Vardhan Inc. All rights reserved.
//

import UIKit

enum GameMode {
    case Easy
    case Intermediate
    case Hard
}

class GridDimensions {
    var numRows: Int = 0
    var numCols: Int = 0
    
    var topPadding: CGFloat = 0.0
    var leftPadding: CGFloat = 0.0
    var cellDimension: CGFloat = 0.0
    var cellPadding: CGFloat = 0.0
    
    var scrollContentSize: CGSize
    
    init() {
        scrollContentSize = CGSize()
    }
    
    func update(gameMode: GameMode, frameSize: CGSize) {
        switch gameMode {
        case .Easy:
            self.numCols = 9
            self.numRows = 9
            self.scrollContentSize = CGSize(width: frameSize.width, height: frameSize.height)
        case .Intermediate:
            self.numCols = 16
            self.numRows = 16
            self.scrollContentSize = CGSize(width: frameSize.width, height: frameSize.height)
        case .Hard:
            self.numRows = 16
            self.numCols = 30
            self.scrollContentSize = CGSize(width: frameSize.width, height: frameSize.height)
        }
        
        cellDimension = frameSize.height/18
        cellPadding = (frameSize.height/18)/18
        
        topPadding = ((frameSize.height) - (CGFloat(self.numRows) * self.cellDimension) - (CGFloat(self.numRows-1) * self.cellPadding))/2

        // Setup scrollview size
        let scrollWidth: CGFloat = max(
            (CGFloat(self.numCols) * self.cellDimension) + (CGFloat(self.numCols-1) * self.cellPadding) + 2 * cellPadding,
            frameSize.width)
        
        self.scrollContentSize.width = scrollWidth
        
        leftPadding = ((self.scrollContentSize.width) - (CGFloat(self.numCols) * self.cellDimension) - (CGFloat(self.numCols-1) * self.cellPadding))/2
    }
    
    func getScrollViewSize() -> CGSize {
        return self.scrollContentSize
    }
}

class GameViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView! {
        didSet { scrollView.delegate = self }
    }
    
    var gameMode: GameMode = GameMode.Intermediate
    var gridDimensions: GridDimensions = GridDimensions()
    var tiles: [TileButton] = [TileButton]()
    
    private var brain: Brain!
    var startTime = NSDate.timeIntervalSinceReferenceDate()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        gridDimensions.update(gameMode, frameSize: view.frame.size)
        scrollView.backgroundColor = GameColors.color2
        scrollView.contentSize = gridDimensions.getScrollViewSize()
        scrollView.layer.borderWidth = 1.0
        scrollView.layer.borderColor = GameColors.color1.CGColor
        
        startGame()
    }
    
    func startGame() {
        for button in self.tiles { button.removeFromSuperview() }
        self.tiles.removeAll()
        
        self.brain = Brain(gameMode: self.gameMode, gameGrid: self.gridDimensions)
        TileButton.numOpened = 0
        TileButton.numFlags = 0
        // Put custom UIButton
        setupButtons()
        startTime = NSDate.timeIntervalSinceReferenceDate()
    }
    
    func setupButtons() {
        let cellDim: CGFloat = self.gridDimensions.cellDimension
        let padding: CGFloat = self.gridDimensions.cellPadding
        var startY: CGFloat = self.gridDimensions.topPadding
        
        var counter: Int = 0
        for var jdx = 1; jdx <= self.gridDimensions.numRows; ++jdx {
            var startX: CGFloat = self.gridDimensions.leftPadding
            
            for var idx = 1; idx <= self.gridDimensions.numCols; ++idx {
                let oneButton = makeButton()
                oneButton.idx = (jdx-1)*self.gridDimensions.numCols + (idx-1)
                oneButton.val = self.brain.tileVals[oneButton.idx]
                oneButton.frame = CGRectMake(startX, startY, cellDim, cellDim)
                
                scrollView.addSubview(oneButton)
                self.tiles.append(oneButton)
                
                startX += (cellDim) + padding
                counter += 1
            }
            startY += (cellDim + padding)
        }
    }
    
    func makeButton() -> TileButton {
        let button: TileButton = TileButton()
        button.layer.backgroundColor = GameColors.color1.CGColor
        button.layer.cornerRadius = 2
        
        let singleTap = UITapGestureRecognizer(target: self, action: "singleTap:")
        singleTap.numberOfTapsRequired = 1
        button.addGestureRecognizer(singleTap)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: "longTap:")
        doubleTapGesture.numberOfTapsRequired = 2
        button.addGestureRecognizer(doubleTapGesture)
        
        singleTap.requireGestureRecognizerToFail(doubleTapGesture)
        
        return button
    }
    
    func bombPressed(button: TileButton) {
        button.openButton(-100)
        for btn: TileButton in self.tiles {
            if btn.isFlagged && btn.val == -1 { continue }
            if btn.isFlagged && btn.val != -1 {
                btn.openButton(-200)
            }
            else if btn.val == -1 {
                btn.openButton(btn.val)
            }
        }
        showGameOverAlert()
    }
    
    func singleTap(gestureRecognizer: UIGestureRecognizer) {
        
        // Open tile if closed, else expand numbers
        let button: TileButton = (gestureRecognizer.view as? TileButton)!
        if !button.isOpen {
            button.toggleFlag()
        }
        else {
            // Check if cell value is equal to # of 'flagged' around it
            let neighbors = brain.getNeighbors(button.idx)
            var numFlags: Int = 0
            for neighbor in neighbors {
                if self.tiles[neighbor].isFlagged { numFlags += 1 }
            }

            if (numFlags == button.val) {
                for neighbor in neighbors {
                    if self.tiles[neighbor].isFlagged && self.tiles[neighbor].val != -1 {
                        self.tiles[neighbor].openButton(-200)
                        bombPressed(self.tiles[neighbor])
                        return
                    }
                }
                
                button.openButton(button.val)
                let idxsToOpen = brain.blankOpened(button.idx)
                for idx in idxsToOpen {
                    let btn = self.tiles[idx]
                    btn.openButton(btn.val)
                }
            }
        }
        
        checkWonGame()
    }
    
    func checkWonGame() {
        if (TileButton.numOpened + brain.numMines) == brain.numTiles {
            showWonGameAlert()
        }
    }
    
    func longTap(gestureRecognizer: UIGestureRecognizer) {
        let button: TileButton = (gestureRecognizer.view as? TileButton)!
        
        let val = button.val
        if (val == -1) {
            bombPressed(button)
        }
        else if (val == 0) {
            // this is funky
            button.openButton(val)
            let idxsToOpen = brain.blankOpened(button.idx)
            for idx in idxsToOpen {
                let btn = self.tiles[idx]
                btn.openButton(btn.val)
            }
        }
        else {
            button.openButton(val)
        }
    }

    
    @IBAction func showGameOverAlert() {
        // Initialize Alert Controller
        let alertController = UIAlertController(title: "Game Over", message: "Oops! You stepped on a mine.. :(", preferredStyle: .Alert)
        
        // Initialize Actions
        let yesAction = UIAlertAction(title: "Try again!", style: .Default) { (action) -> Void in
            self.startGame()
        }
        
        let noAction = UIAlertAction(title: "Give up", style: .Default) { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: {});
        }
        
        // Add Actions
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        // Present Alert Controller
        self.presentViewController(alertController, animated: true, completion: nil)
    }


    @IBAction func showWonGameAlert() {
        // Initialize Alert Controller
        let alertController = UIAlertController(title: "You Won!", message: "You are a genius!", preferredStyle: .Alert)
        
        // Initialize Actions
        let yesAction = UIAlertAction(title: "Do it again!", style: .Default) { (action) -> Void in
            self.startGame()
        }
        
        let noAction = UIAlertAction(title: "Give up", style: .Default) { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: {});
        }
        
        // Add Actions
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        // Present Alert Controller
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            // Show stats menu for a second
            let current = NSDate.timeIntervalSinceReferenceDate()
            let elapsed = round(current - startTime)
            let alertController = UIAlertController(title: "You are almost there",
                message: "\(Int(elapsed)) seconds played.\n\(TileButton.numFlags) flags placed.\n\(brain.numMines) mines in total",
                preferredStyle: .Alert)

            self.presentViewController(alertController, animated: true, completion: nil)
            
            let delay = 1 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue(), {
                alertController.dismissViewControllerAnimated(true, completion: nil)
            })
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.All
    }
}
