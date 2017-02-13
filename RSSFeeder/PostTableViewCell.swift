//
//  PostTableViewCell.swift
//  RSSFeeder
//
//  Created by Антон Рыскалев on 12.02.17.
//  Copyright © 2017 Антон Рыскалев. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var pubDateLabel: UILabel!
    @IBOutlet weak var imagePost: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.descriptionLabel.lineBreakMode = .byWordWrapping
        self.descriptionLabel.numberOfLines = 5
        
        self.titleLabel.lineBreakMode = .byWordWrapping
        self.titleLabel.numberOfLines = 2
    
    }

}
