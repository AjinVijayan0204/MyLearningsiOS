//
//  PostTableViewCell.swift
//  Instagram
//
//  Created by Ajin on 06/02/24.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var postedImage: UIImageView!
    @IBOutlet weak var postedByLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
