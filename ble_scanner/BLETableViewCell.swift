//
//  BLETableViewCell.swift
//  ble_scanner
//
//  Created by Seth Polyniak on 6/17/21.
//  Copyright © 2021 Seth Polyniak. All rights reserved.
//

import UIKit

class BLETableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dataImage: UIImageView!
    @IBOutlet weak var RSSILabel: UILabel!
    @IBOutlet weak var connectableImage: UIImageView!
}
