//
//  WorkItemTableViewCell.swift
//  GigP
//
//  Created by Krishna Vemulapali on 2019-05-01.
//  Copyright © 2019 Krishna Vemulapali. All rights reserved.
//

import UIKit

class WorkItemTableViewCell: UITableViewCell {

    
    @IBOutlet var workDesc: UILabel!
    @IBOutlet var earnings: UILabel!
    @IBOutlet var client: UILabel!
    @IBOutlet var hours: UILabel!
    @IBOutlet var hst: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
