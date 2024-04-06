//
//  FilesViewCell.swift
//  OfflineFileApp
//
//  Created by VC on 03/04/24.
//

import UIKit

class FilesViewCell: UICollectionViewCell {

    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var displayImg: UIImageView!
    @IBOutlet weak var uploadImg: UIImageView!
    @IBOutlet weak var documentView: UIView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var selectedBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        outerView.layer.cornerRadius = 10
    }

}
