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
        let name: String
        let RSSI: String
        let connectable: NSNumber
        let uuid: String
        let ad: [String : Any]
        
        init(name: String, RSSI: NSNumber, connectable: NSNumber, uuid: String,ad: [String : Any]) {
            self.name = "\(name)"
            self.RSSI = "\(RSSI)"
            self.connectable = connectable
            self.uuid = uuid
            self.ad = ad
        }
    }
    
    // Object that scans, discovers, connects, manages, peripherals
    var centralManager: CBCentralManager!
    // Reference to chosen peripheral object when connection is established
    var chosenPeripheral: CBPeripheral!
    // Array holds nearby scanned peripherals
    var peripheralList: [Peripheral] = []
    
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
            peripheralList.append(Peripheral(name: peripheral.name ?? "N/A", RSSI: RSSI, connectable: (advertisementData["kCBAdvDataIsConnectable"]) as! NSNumber, uuid: peripheral.identifier.uuidString, ad: advertisementData))
            
            // Print list
            print("START OF LIST ==========")
            print(peripheralList)
        }

        
        /*
        // Stop scanning and connect to peripheral
        self.centralManager.stopScan()
        self.chosenPeripheral = peripheral     // Save class-level reference of chosen peripheral
        self.chosenPeripheral.delegate = self  // Delegate self to the chosenPeripheral
        
        self.centralManager.connect(peripheral, options: nil)  // Finally connect
         */
    }
    
    // Called when a connection is made to a BLE device
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.chosenPeripheral.discoverServices(nil)
    }

    
    
}
