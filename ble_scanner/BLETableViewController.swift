//
//  BLETableViewController.swift
//  ble_scanner
//
//  Created by Seth Polyniak on 6/17/21.
//  Copyright © 2021 Seth Polyniak. All rights reserved.
//

import UIKit
import CoreBluetooth

class BLETableViewController: UITableViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
        
    // Object that scans, discovers, connects, manages, peripherals
    var centralManager: CBCentralManager!
    
    // Reference to chosen peripheral object when connection is established
    var chosenPeripheral: CBPeripheral!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Init centralManager
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        // Set up filter button
        initFilterButton()
    }
    
    // Creates a filter bar button on nav bar
    func initFilterButton(){
        let filterBtn: UIButton = UIButton(type: UIButtonType.custom)
        // Set img for btn
        filterBtn.setImage(UIImage(named: "filter.jpg"), for: UIControlState.normal)
        // Add function for button
        filterBtn.addTarget(self, action: #selector(BLETableViewController.buttonTapped), for: UIControlEvents.touchUpInside)
        // Set frame
        filterBtn.frame = CGRect(x:0,y:0,width:32,height:32)
        
        let barBtn = UIBarButtonItem(customView: filterBtn)
        // Assign button
        self.navigationItem.rightBarButtonItem = barBtn
    }
    
    func buttonTapped() {
        print("Button Tapped")
    }


   /* override func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    } */

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bleTableViewCell", for: indexPath)
        
       // cell.textLabel?.text = "Cell Row: \(indexPath.row) Section: \(indexPath.section)"

        return cell
    }
 
    
    // Checks hardware status of Bluetooth on your device (powered on, BLE available/enabled, etc.)
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // BLE is on, start scanning for peripherals
        if central.state == CBManagerState.poweredOn {
            print("BLE powered on")
            
            // Could populate the withServices param to scan for specific UUIDs (like in the bauer lock example)
            central.scanForPeripherals(withServices: nil, options: nil)
        }
            // BLE is off or not found, print err message
        else {
            print("ERROR: BLE not compatible or off")
        }
    }
    
    // Is called for each peripheral that is found in the scanForPeripherals func
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        // Check if peripheral has name, assign it, and print
        if let name = peripheral.name {
            print(name)
            
            // Stop scanning and connect to peripheral
            self.centralManager.stopScan()
            self.chosenPeripheral = peripheral     // Save class-level reference of chosen peripheral
            self.chosenPeripheral.delegate = self  // Delegate self to the chosenPeripheral
            
            self.centralManager.connect(peripheral, options: nil)  // Finally connect
        }
    }
    
    // Called when a connection is made to a BLE device
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.chosenPeripheral.discoverServices(nil)
    }

}
