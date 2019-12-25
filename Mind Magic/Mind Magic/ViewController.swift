//
//  ViewController.swift
//  Mind Magic
//
//  Created by Rakesh Kumar on 25/12/19.
//  Copyright © 2019 Rakesh Kumar. All rights reserved.
//

import Cocoa
import GameplayKit

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    private var answer = ""
    private var guesses = [String]()

    @IBOutlet var tableView: NSTableView!
    @IBOutlet var guess: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

       startNewGame()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func submitGuess(_ sender: Any) {
        
        // check for 4 unique characters
        let guessString = guess.stringValue
        guard Set(guessString).count == 4 else {return}
        
        // ensure there are no non digit characters
        let badCharacters = CharacterSet(charactersIn: "0123456789").inverted
        guard guessString.rangeOfCharacter(from: badCharacters) == nil else { return }
        
        // add guess to the array and the tableview
        guesses.insert(guessString, at: 0)
        tableView.insertRows(at: IndexSet(integer: 0), withAnimation: .slideDown)
        
        // did player win ?
        let resultString = result(for: guessString)
        
        if resultString.contains("4b") {
            let alert = NSAlert()
            alert.messageText = "You Win!"
            alert.informativeText = "Congratulations! Click ok to play again"
            
            alert.runModal()
            startNewGame()
        }
        
    }
    
    private func result(for guess: String) -> String {
        var cows = 0
        var bulls = 0
        
        let guessLetters = Array(guess)
        let answerLetters = Array(answer)
        
        for (index,letter) in guessLetters.enumerated() {
            if letter == answerLetters[index] {
                bulls += 1
            } else if answerLetters.contains(letter) {
                cows += 1
            }
        }
        return "\(bulls)b \(cows)c"
    }
    
    private func startNewGame() {
        guess.stringValue = ""
        answer = ""
        guesses.removeAll()
        
        var numbers = Array(0...9)
        numbers = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: numbers) as! [Int]
        
        for _ in 0 ..< 4 {
            answer.append(String(numbers.removeLast()))
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return guesses.count
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let view = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else {
            return nil
        }
        
        if tableColumn?.title == "Guess" {
            // Guess column; show a previous guess
            view.textField?.stringValue = guesses[row]
        }else {
            // Result Column
            view.textField?.stringValue = result(for: guesses[row])
        }
        return view
    }
}

