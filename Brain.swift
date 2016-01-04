//
//  Brain.swift
//  TestView
//
//  Created by Vardhan Dharnidharka on 12/19/15.
//  Copyright © 2015 Vardhan Inc. All rights reserved.
//

import Foundation

class Brain {
    
    var numMines: Int // Number of mines in the current game
    var numTiles: Int // Number of tiles based on grid row x col

    var numCols: Int
    var numRows: Int
    
    var tileVals: [Int]
    var mines = Set<Int>()
    
    init(gameMode: GameMode, gameGrid: GridDimensions) {
        switch gameMode {
        case .Easy:
            self.numMines = 10
        case .Intermediate:
            self.numMines = 40
        case .Hard:
            self.numMines = 99
        }
        self.numRows = gameGrid.numRows
        self.numCols = gameGrid.numCols
        
        self.numTiles = gameGrid.numCols * gameGrid.numRows
        self.tileVals = [Int](count: self.numTiles, repeatedValue: 0)
        
        self.setupMines()
        self.populateTileValues()
    }
    
    // MARK: Blank opened
    var tempAdded = Set<Int>()
    
    func blankOpenedUtil(idx: Int) -> Set<Int> {
        var indicesToOpen = Set<Int>()
        
        let neighbors = getNeighbors(idx)
        
        for neighbor in neighbors {
            if tempAdded.contains(neighbor) { continue }
            tempAdded.insert(neighbor)
            if self.tileVals[neighbor] >= 0 { indicesToOpen.insert(neighbor) }
            if self.tileVals[neighbor] == 0 {
                indicesToOpen = indicesToOpen.union(blankOpenedUtil(neighbor))
            }
        }
        return indicesToOpen
    }
    
    func blankOpened(idx: Int) -> Set<Int> {
        tempAdded.removeAll()
        return blankOpenedUtil(idx)
    }
    
    private func populateTileValues() {
        // Iterate over tile values and guess if its a 'number', 'blank' or 'mine'
        for idx in 0...self.numTiles-1 {
            if hasMine(idx) == 1 {
                self.tileVals[idx] = -1;
            }
            else {
                self.tileVals[idx] = getTileValue(idx)
            }
        }
    }

    
    // Get the value of a tile based on the number of mines around it
    // TODO: Cache 'neighbors' of an 'idx' for faster lookup
    private func getTileValue(idx: Int) -> Int {
        var val: Int = 0
        let neighbors: [Int] = getNeighbors(idx)
        for neighbor: Int in neighbors {
            val += hasMine(neighbor)
        }
        
        return val
    }
    
    // Given a cell 'idx', return the 'idx' of its neighbors
    func getNeighbors(idx: Int) -> [Int] {
        var neighbors = [Int]()
        var firstRow: Bool = false
        var lastRow: Bool = false
        var firstCol: Bool = false
        var lastCol: Bool = false
        
        if idx < numCols { firstRow = true }
        if idx >= (numCols)*(numRows-1) { lastRow = true }
        
        if idx % numCols == 0 {firstCol = true }
        if idx % numCols == (numCols-1) { lastCol = true }
        
        if !firstRow {
            neighbors.append(idx-numCols)
            if !firstCol { neighbors.append(idx-numCols-1) }
            if !lastCol  { neighbors.append(idx-numCols+1) }
        }
        
        if !firstCol { neighbors.append(idx-1) }
        if !lastCol  { neighbors.append(idx+1) }
        
        if !lastRow {
            neighbors.append(idx+numCols)
            if !firstCol { neighbors.append(idx+numCols-1) }
            if !lastCol  { neighbors.append(idx+numCols+1) }
        }
        
        return neighbors
    }

    // Checks if given 'idx' contains a mine or not
    private func hasMine(idx: Int) -> Int {
        if mines.contains(idx) {
            return 1
        }
        return 0;
    }
    
    private func setupMines() {
        var numMines = self.numMines
        while numMines != 0 {
            let random = Int(arc4random_uniform(UInt32(self.numTiles)))
            
            // Check if random is in 'mines' already
            if !mines.contains(random) {
                numMines = numMines - 1
                mines.insert(random)
            }
        }
    }
}