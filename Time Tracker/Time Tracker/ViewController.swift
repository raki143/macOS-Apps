//
//  ViewController.swift
//  Time Tracker
//
//  Created by Rakesh Kumar on 30/10/19.
//  Copyright © 2019 Rakesh Kumar. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet weak var goalLabel: NSTextField!
    
    @IBOutlet weak var goalTimePopUpButton: NSPopUpButton!
    
    @IBOutlet weak var inOutButton: NSButton!
    
    @IBOutlet weak var currentlyLabel: NSTextField!
    
    @IBOutlet weak var tableView: NSTableView!
    
    @IBOutlet weak var goalProgressIndicator: NSProgressIndicator!
    
    @IBOutlet weak var remainingLabel: NSTextField!
    
    private var currentPeriod: Period?
    private var timer: Timer?
    private var periods = [Period]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        goalTimePopUpButton.removeAllItems()
        goalTimePopUpButton.addItems(withTitles: popUpTitles())
        getPeriods()
    }
    
    private func getPeriods() {
        
        if let context = (NSApp.delegate as? AppDelegate)?.persistentContainer.viewContext {
            if let name = Period.entity().name {
                let fetchRequest = NSFetchRequest<Period>(entityName: name)
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "outDate", ascending: false)]
                if var periods = try? context.fetch(fetchRequest) {
                    
                    for index in 0..<periods.count {
                        let period = periods[index]
                        if period.outDate == nil {
                            currentPeriod = period
                            startTimer()
                            periods.remove(at: index)
                            break
                        }
                    }
                    
                    self.periods = periods
                }
            }
        }
        tableView.reloadData()
        updateView()
    }
    
    
    @IBAction func goalTimeChanged(_ sender: Any) {
        updateView()
    }
    
    @IBAction func inOutTapped(_ sender: Any) {
        
        if currentPeriod == nil {
            // Clocking In
            if let context = (NSApp.delegate as? AppDelegate)?.persistentContainer.viewContext {
                
                currentPeriod = Period(context: context)
                currentPeriod?.inDate = Date()
            }
            
            startTimer()
        } else {
            // Clocking Out
            currentPeriod?.outDate = Date()
            currentPeriod = nil
            timer?.invalidate()
            timer = nil
            getPeriods()
        }
        (NSApp.delegate as? AppDelegate)?.saveAction(nil)
        updateView()
    }
    
    @IBAction func reset(_ sender: Any) {
        if let context = (NSApp.delegate as? AppDelegate)?.persistentContainer.viewContext {
            for period in periods {
                context.delete(period)
            }
            
            if let currentPeriod = currentPeriod {
                context.delete(currentPeriod)
                self.currentPeriod = nil
            }
            getPeriods()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            self.updateView()
        })
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    private func popUpTitles() -> [String] {
        var titles = [String]()
        for number in 1...100 {
            titles.append("\(number)h")
        }
        return titles
    }
    
    private func updateView() {
        let goalTime = goalTimePopUpButton.indexOfSelectedItem + 1
        if goalTime == 1 {
            goalLabel.stringValue = "Goal: 1 Hour"
        }else {
            goalLabel.stringValue = "Goal: \(goalTime) Hours"
        }
        
        if currentPeriod == nil {
            inOutButton.title = "IN"
            currentlyLabel.isHidden = true
        } else {
            inOutButton.title = "OUT"
            currentlyLabel.isHidden = false
            currentlyLabel.stringValue = currentPeriod!.currentlyString()
        }
        
        remainingLabel.stringValue = remainingTimeAsString()
        
        let ratio = totalTimeInterval() / goalTimeInterval()
        goalProgressIndicator.doubleValue = ratio
    }
    
    private func remainingTimeAsString() -> String {
        
        let remainingTime = goalTimeInterval() - totalTimeInterval()
        
        if remainingTime <= 0 {
           
            return "Finished! \(Period.stringFromDates(date1: Date(), date2: Date(timeIntervalSinceNow: totalTimeInterval())))"
        }else {
            return "Remaining: \(Period.stringFromDates(date1: Date(), date2: Date(timeIntervalSinceNow: remainingTime)))"
        }
    }
    
    private func totalTimeInterval() -> TimeInterval {
        var time = 0.0
        
        for period in periods {
            time += period.time()
        }
        
        if let currentPeriod = currentPeriod {
            time += currentPeriod.time()
        }
        
        return time
    }
    
    private func goalTimeInterval() -> TimeInterval {
        return Double(goalTimePopUpButton.indexOfSelectedItem + 1) * 60.0 * 60.0
    }
    
    //MARK:- Tableview delegate methods
    func numberOfRows(in tableView: NSTableView) -> Int {
        return periods.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "periodCell"), owner: self) as? PeriodCell
        
        let period = periods[row]
        
        cell?.timeTotalTextField.stringValue = Period.stringFromDates(date1: Date(), date2: Date(timeIntervalSinceNow: period.time()))
        cell?.timeRangeTextField.stringValue = "\(period.prettyInDate()) - \(period.prettyOutDate())"
        
        return cell
    }
}

class PeriodCell: NSTableCellView {
    
    @IBOutlet weak var timeRangeTextField: NSTextField!
    
    
    @IBOutlet weak var timeTotalTextField: NSTextField!
    
}
