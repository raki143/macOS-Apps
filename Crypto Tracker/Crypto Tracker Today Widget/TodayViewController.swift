//
//  TodayViewController.swift
//  Crypto Tracker Today Widget
//
//  Created by Rakesh Kumar on 10/11/19.
//  Copyright © 2019 Rakesh Kumar. All rights reserved.
//

import Cocoa
import NotificationCenter

class TodayViewController: NSViewController, NCWidgetProviding {
    
    @IBOutlet weak var bitcoinLabel: NSTextField!
    
    @IBOutlet weak var ethereumLabel: NSTextField!
    
    @IBOutlet weak var litecoinLabel: NSTextField!
    

    override var nibName: NSNib.Name? {
        return NSNib.Name("TodayViewController")
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        
        if let url = URL(string: "https://min-api.cryptocompare.com/data/pricemulti?fsyms=BTC,ETH,LTC&tsyms=USD") {
                   URLSession.shared.dataTask(with: url) { (data, response, error) in
                       if let data = data {
                           if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                               
                                   if let btcD = json["BTC"] as? [String:Double] {
                                       if let btcPrice = btcD["USD"] {
                                        DispatchQueue.main.async {
                                            self.bitcoinLabel.stringValue = "Bitcoin - \(self.doubleToMoney(double: btcPrice))"
                                        }
                                       }
                                   }
                                   if let ethD = json["ETH"] as? [String:Double] {
                                       if let ethPrice = ethD["USD"] {
                                        DispatchQueue.main.async {
                                            self.ethereumLabel.stringValue = "Ethereum - \(self.doubleToMoney(double: ethPrice))"
                                        }
                                       }
                                   }
                                   if let ltcD = json["LTC"] as? [String:Double] {
                                       if let ltcPrice = ltcD["USD"] {
                                        DispatchQueue.main.async {
                                            self.litecoinLabel.stringValue = "Litecoin - \(self.doubleToMoney(double: ltcPrice))"
                                        }
                                       }
                                   }
                           }
                       }
                   }.resume()
               }
        completionHandler(.newData)
    }
    
    func doubleToMoney(double:Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .currency
        if let fancyPrice = formatter.string(from: NSNumber(floatLiteral: double)) {
            return fancyPrice
        } else {
            return "ERROR 1"
        }
    }

}
