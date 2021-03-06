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
    var shouldSort: Bool = false  // Bool for sorting by asc or no sort
    var barBtn: UIBarButtonItem?  // Reference to sort toggle button
    var chosenCell: BLETableViewCell! // The chosen cell the user tapped
    

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
        
        // Save peripheral variables
        let perName = bleManager.peripheralList[indexPath.row].name
        let perRSSI = bleManager.peripheralList[indexPath.row].RSSI
        let connectableValue = bleManager.peripheralList[indexPath.row].connectable
        
        // Change imageview based on if peripheral is connectable or not
        if connectableValue == 1 {
            cell.connectableImage.image = UIImage(named: "connectable")
            
        } else {
            cell.connectableImage.image = UIImage(named: "not_connectable")
        }
        
        // Style for ifConnected label
        let isConnectedValue = bleManager.peripheralList[indexPath.row].connected
        switch(isConnectedValue) {
        case 1:
            cell.isConnectedLabel.text = "Connecting..."
        case 2:
            cell.isConnectedLabel.text = "Connected"
            /* BUG: multiple cells are affected?
            cell.isConnectedLabel.textColor = UIColor(red: 0.0/255, green: 190.0/255, blue: 112.0/255, alpha: 1)
             */
        default:
            cell.isConnectedLabel.text = "Not connected"
        }
        
        // Style for unavailable devices
        if connectableValue == 0 {
            cell.isConnectedLabel.text = "Unavailable"
        }
        
        cell.nameLabel.text = perName
        cell.RSSILabel.text = perRSSI.description
        cell.dataImage.image = getSignalImage(signal: perRSSI)// Style for signal bar image based on RSSI

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // If device is connectable, try to connect
        if bleManager.peripheralList[indexPath.row].connectable == 1 {
            // Display that we are trying to connect on cell select
            bleManager.peripheralList[indexPath.row].connected = 1  // "Connecting..."
            print("Trying to connect..")
            
            // Save chosen peripheral & connect
            bleManager.chosenPeripheral = bleManager.peripheralList[indexPath.row]
            bleManager.centralManager.connect(bleManager.chosenPeripheral.peripheralObj, options: nil)
        } else {
            print("Device is not connectable..")
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        reloadTableView()
    }
    
    // Returns a UIImage based on the signal strength (RSSI)
    func getSignalImage(signal: Int) -> UIImage {
        var signalImage: UIImage!
        
        switch signal {
        case let x where x <= -100:
            signalImage = UIImage(named: "signal_none")
        case -99 ... -80:
            signalImage = UIImage(named: "signal_low")
        case -79 ... -70:
            signalImage = UIImage(named: "signal_medium")
        case -69 ... -60:
            signalImage = UIImage(named: "signal_high")
        case -59 ... 200:
            signalImage = UIImage(named: "signal_full")
        default:
            signalImage = UIImage(named: "signal_default")
        }
        return signalImage
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
    
    // When successfully connected to a peripheral, change label text
    // Called from BLEManager class
    func onPeripheralConnection(uuid: String) {
        if let index = bleManager.peripheralList.firstIndex(where: { $0.uuid == uuid}) {
            bleManager.peripheralList[index].connected = 2 // "Connected"
        }
        reloadTableView()
    }
}

// Allows me to call the reloadview from BLE manager
protocol RefreshDelegate {
    func reloadTableView()
    func onPeripheralConnection(uuid: String)
}
