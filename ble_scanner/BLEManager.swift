//
//  BLEManager.swift
//  ble_scanner
//
//  Created by Seth Polyniak on 6/18/21.
//  Copyright © 2021 Seth Polyniak. All rights reserved.
//

import UIKit
import CoreBluetooth

class BLEManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    struct Peripheral {
        var name: String
        let RSSI: Int
        let connectable: NSNumber
        let uuid: String
        let ad: [String : Any]
        let peripheralObj: CBPeripheral
        var connected: Int
        
        init(name: String, RSSI: NSNumber, connectable: NSNumber, uuid: String,ad: [String : Any], peripheralObj: CBPeripheral, connected: Int) {
            self.name = "\(name)"
            self.RSSI = Int(truncating: RSSI)
            self.connectable = connectable
            self.uuid = uuid
            self.ad = ad
            self.peripheralObj = peripheralObj
            self.connected = connected
        }
    }
    
    // Object that scans, discovers, connects, manages, peripherals
    var centralManager: CBCentralManager!
    // Reference to chosen peripheral object when connection is established
    var chosenPeripheral: Peripheral!
    // Array holds nearby scanned peripherals
    var peripheralList: [Peripheral] = []
    // Delegate so we can reload the view from this class
    var refreshDelegate: RefreshDelegate?
    
    // First function call when object is created
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // Checks hardware status of Bluetooth on your device (powered on, BLE available/enabled, etc.)
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // BLE is on, start scanning for peripherals
        if central.state == CBManagerState.poweredOn {
            print("BLE powered on. Scanning for devices.")
            central.scanForPeripherals(withServices: nil, options: nil)
        } else {
            print("ERROR: BLE not compatible or off")
        }
    }
    
    // Is called for each peripheral that is found in the scanForPeripherals func
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        let uuid = peripheral.identifier.uuidString //  Use uuid as unique value
        
        // Check if already scanned peripheral
        if !peripheralList.contains(where: { $0.uuid == uuid}) {
            peripheralList.append(Peripheral(name: peripheral.name ?? "N/A", RSSI: RSSI, connectable: (advertisementData["kCBAdvDataIsConnectable"]) as! NSNumber, uuid: peripheral.identifier.uuidString, ad: advertisementData, peripheralObj: peripheral, connected: 0))
            
            // Print newly added peripheral name
            print("New peripheral added to list: \(peripheral.name ?? "N/A")")
            
            // Refresh tableview whenever new peripheral is found
            self.refreshDelegate?.reloadTableView()
        }
    }
    
    // Called when a connection is made to a BLE device
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(String(describing: peripheral.name))")
        self.refreshDelegate?.onPeripheralConnection(uuid: peripheral.identifier.uuidString)
        //peripheral.delegate = self
        //self.chosenPeripheral.discoverServices(nil)
        
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect..")
    }
}
