//
//  ViewController.swift
//  ble_scanner
//
//  Created by Seth Polyniak on 6/17/21.
//  Copyright © 2021 Seth Polyniak. All rights reserved.
//

import UIKit
import CoreBluetooth  // Framework used to manage any BLE functionality

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    // Object that scans, discovers, connects, manages, peripherals
    var centralManager: CBCentralManager!
    
    // Reference to peripheral object when connection is established
    var peripheral: CBPeripheral!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Init centralManager
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
    }

    // Checks hardware status of Bluetooth on your device (powered on, BLE available/enabled, etc.)
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            print("BLE powered on")
        }
        else {
            print("ERROR: BLE not compatible or off")
        }
    }

}

