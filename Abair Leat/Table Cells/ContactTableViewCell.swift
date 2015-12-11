//
//  ContactTableViewCell.swift
//  Abair Leat
//
//  Created by Aaron Signorelli on 27/11/2015.
//  Copyright © 2015 Superpixel. All rights reserved.
//

import UIKit
import Haneke

class ContactTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setup(profile: Profile) {
        self.avatar.hnk_setImageFromURL(NSURL(string: profile.avatarUrlString)!)
        self.name.text = profile.name
    }
    
}
