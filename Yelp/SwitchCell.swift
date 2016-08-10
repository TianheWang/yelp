//
//  SwitchCell.swift
//  Yelp
//
//  Created by tianhe_wang on 8/9/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

// what's protocal
// what's delegate
// what's @objc
@objc protocol SwitchCellDelegate {
//    ??? what's didChangeValue here?
    optional func switchCell(switchCell: SwitchCell, didChangeValue value: Bool)
}

class SwitchCell: UITableViewCell {

    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet weak var onSwitch: UISwitch!

    // weak??
    weak var delegate: SwitchCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        onSwitch.addTarget(self, action: #selector(SwitchCell.switchValueChanged), forControlEvents: UIControlEvents.ValueChanged)
    }

    func switchValueChanged() {
        print("switch value changed")
        delegate?.switchCell?(self, didChangeValue: onSwitch.on)
    }
}
