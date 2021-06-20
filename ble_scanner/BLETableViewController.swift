//
//  BLETableViewController.swift
//  ble_scanner
//
//  Created by Seth Polyniak on 6/17/21.
//  Copyright © 2021 Seth Polyniak. All rights reserved.
//

import UIKit
import CoreBluetooth

class BLETableViewController: UITableViewController, RefreshDelegate, CBPeripheralDelegate {
    
        
    @IBOutlet var bleTableView: UITableView!
        
    var bleManager = BLEManager()
    var scanTimer: Timer?  // Timer used to stop scanning after X seconds
    var timerCount = 10    // Timer will run for X seconds
    var shouldSort: Bool = false  // Bool for sorting by asc or no sort
    
    var barBtn: UIBarButtonItem?  // Reference to sort toggle button
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Connect delegate to self
        bleManager.refreshDelegate = self
        
        // Init refresh control to reload tableview
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(self.reloadTableView), for: UIControlEvents.valueChanged)
        
        // Style navbar and inits sort button
        styleNavBar()
    }
    
    func styleNavBar(){
        self.navigationItem.title = "BLE Scanner"
        initSortButton()  // Set up sort button
    }
    
    // Creates a sort bar button on nav bar
    func initSortButton(){
        let sortBtn: UIButton = UIButton(type: UIButton.ButtonType.custom)
        // Set img for btn
        sortBtn.setImage(UIImage(named: "sort.png"), for: UIControl.State.normal)
        // Add function for button
        sortBtn.addTarget(self, action: #selector(BLETableViewController.togglesort), for: UIControl.Event.touchUpInside)
        // Set frame
        sortBtn.frame = CGRect(x:0,y:0,width:24,height:24)
        
        barBtn = UIBarButtonItem(customView: sortBtn)
        
        barBtn?.customView?.backgroundColor = UIColor(red: 39.0/255, green: 131.0/255, blue: 196.0/255, alpha: 0)

        // Assign button
        self.navigationItem.rightBarButtonItem = barBtn
    }
    
    @objc func togglesort() {
        shouldSort = !shouldSort  // Set so all incoming peripherals are sorted automatically
        
        // Toggle button background on button press
        barBtn?.customView?.backgroundColor =  shouldSort ? UIColor(red: 39.0/255, green: 131.0/255, blue: 196.0/255, alpha: 1)
            : UIColor(red: 39.0/255, green: 131.0/255, blue: 196.0/255, alpha: 0)

        
        print("Sorting enabled: \(shouldSort)")
        reloadTableView()   // Reload view
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bleManager.peripheralList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bleTableViewCell", for: indexPath) as! BLETableViewCell
        
        cell.nameLabel.text = bleManager.peripheralList[indexPath.row].name
        cell.RSSILabel.text = bleManager.peripheralList[indexPath.row].RSSI.description
        
        // Styling for connectable label
        let connectableValue = bleManager.peripheralList[indexPath.row].connectable
        var connectableText: String
        var connectableColor: UIColor
        
        if connectableValue == 1 {
            connectableText = "Connect"
            connectableColor = UIColor.green
            
        } else {
            connectableText = "Unavailable"
            connectableColor = UIColor.red
        }
        
        cell.connectableLabel.text = connectableText
        cell.connectableLabel.backgroundColor = connectableColor

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Trying to connect..")
        
        bleManager.chosenPeripheral = bleManager.peripheralList[indexPath.row].peripheralObj     // Save class-level reference of chosen peripheral
        bleManager.centralManager.connect(bleManager.chosenPeripheral, options: nil)  // Finally connect
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Reload tableview with peripheralList data
    @objc func reloadTableView() {
        // Sorts by asc before reloading view
        if shouldSort {
            bleManager.peripheralList.sort { $0.RSSI < $1.RSSI }  // Sort RSSI ascending
        }
        bleTableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
}

// Allows us to call the reloadview from BLE manager
protocol RefreshDelegate {
    func reloadTableView()
}
