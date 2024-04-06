//
//  FolderListCell.swift
//  OfflineFileApp
//
//  Created by VC on 01/04/24.
//

import UIKit

class FolderListCell: UICollectionViewCell {

    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var folderName: UILabel!
    @IBOutlet weak var createdDateLbl: UILabel!
    @IBOutlet weak var folderIcon: UIImageView!
    @IBOutlet weak var favouriteBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.outerView.layer.cornerRadius = 5
    }
    
    
    
    
}
