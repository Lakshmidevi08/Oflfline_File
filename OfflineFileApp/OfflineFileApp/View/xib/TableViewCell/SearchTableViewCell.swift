//
//  SearchTableViewCell.swift
//  OfflineFileApp
//
//  Created by VC on 05/04/24.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.outerView.layer.cornerRadius = 10
    }
    
}
