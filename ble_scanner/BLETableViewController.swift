//
//  BLETableViewController.swift
//  ble_scanner
//
//  Created by Seth Polyniak on 6/17/21.
//  Copyright © 2021 Seth Polyniak. All rights reserved.
//

import UIKit
import CoreBluetooth

class BLETableViewController: UITableViewController {
        
    @IBOutlet var bleTableView: UITableView!
    
    var bleManager = BLEManager()
    var scanTimer: Timer?  // Timer used to stop scanning after X seconds
    var timerCount = 5     // Timer will run for X seconds
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Start timer while manager is scanning
        scanTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(startScanTimer), userInfo: nil, repeats: true)
        
        // Set up filter button
        initFilterButton()
    }
    
    // Creates a filter bar button on nav bar
    func initFilterButton(){
        let filterBtn: UIButton = UIButton(type: UIButton.ButtonType.custom)
        // Set img for btn
        filterBtn.setImage(UIImage(named: "filter.jpg"), for: UIControl.State.normal)
        // Add function for button
        filterBtn.addTarget(self, action: #selector(BLETableViewController.buttonTapped), for: UIControl.Event.touchUpInside)
        // Set frame
        filterBtn.frame = CGRect(x:0,y:0,width:32,height:32)
        
        let barBtn = UIBarButtonItem(customView: filterBtn)
        // Assign button
        self.navigationItem.rightBarButtonItem = barBtn
    }
    
    @objc func startScanTimer() {
        print("Scan timer started")
        reloadTableView()
        timerCount -= 1
        
        if timerCount <= 0 {
            print("Timer finished.")
            scanTimer?.invalidate()
        }
        
        
    }
    
    @objc func buttonTapped() {
        print("Button Tapped")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bleManager.peripheralList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bleTableViewCell", for: indexPath) as! BLETableViewCell
        
        cell.nameLabel.text = bleManager.peripheralList[indexPath.row].name
        cell.RSSILabel.text = bleManager.peripheralList[indexPath.row].RSSI
        cell.connectableBtn.setTitle(bleManager.peripheralList[indexPath.row].connectable.description, for: .normal)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected \(indexPath.row)")
    }
    
    // Reload the table view after a few seconds of scanning for devices
    func reloadTableView(){
        bleTableView.reloadData()
    }
 
}
