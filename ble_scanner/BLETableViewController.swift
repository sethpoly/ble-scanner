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
        
        cell.nameLabel.text = bleManager.peripheralList[indexPath.row].name
        cell.RSSILabel.text = bleManager.peripheralList[indexPath.row].RSSI.description
        
        // Styling for connectable img
        let connectableValue = bleManager.peripheralList[indexPath.row].connectable
        var connectableImg: UIImage?
        
        // Change imageview based on if peripheral is connectable or not
        if connectableValue == 1 {
            connectableImg = UIImage(named: "connectable")
            
        } else {
            connectableImg = UIImage(named: "not_connectable")
        }
        
        cell.connectableImage.image = connectableImg
        
        // Style for ifConnected label
        let isConnectedValue = bleManager.peripheralList[indexPath.row].connected
        switch(isConnectedValue) {
        case 1:
            cell.isConnectedLabel.text = "Connecting..."
            break
        case 2:
            cell.isConnectedLabel.text = "Connected"
            /* BUG: multiple cells are affected?
            cell.isConnectedLabel.textColor = UIColor(red: 0.0/255, green: 190.0/255, blue: 112.0/255, alpha: 1)
             */
            break
        default:
            cell.isConnectedLabel.text = "Not connected"
            break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Display that we are trying to connect on cell select
        bleManager.peripheralList[indexPath.row].connected = 1  // "Connecting..."
        print("Trying to connect..")
        
        // Save chosen peripheral & connect
        bleManager.chosenPeripheral = bleManager.peripheralList[indexPath.row]
        bleManager.centralManager.connect(bleManager.chosenPeripheral.peripheralObj, options: nil)
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        reloadTableView()
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

// Allows us to call the reloadview from BLE manager
protocol RefreshDelegate {
    func reloadTableView()
    func onPeripheralConnection(uuid: String)
}
