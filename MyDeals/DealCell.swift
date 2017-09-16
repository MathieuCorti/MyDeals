//
//  DealCell.swift
//  MyDeals
//
//  Created by Mathieu Corti on 8/22/17.
//  Copyright © 2017 Mathieu Corti. All rights reserved.
//

import UIKit

class DealCell: UITableViewCell {
    
    var link : String = String()

    @IBOutlet weak var dealTitle: UILabel!
    @IBOutlet weak var dealMerchant: UILabel!
    @IBOutlet weak var dealPicture: UIImageView!
    
    @IBOutlet weak var goToDealButton: UIButton!
    
    @IBOutlet weak var cardView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        // Customize card view
        contentView.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.94, alpha:1.0)
        cardView.layer.cornerRadius = 3.0
        cardView.layer.masksToBounds = false
        
        // Add shadow
        cardView.layer.shadowColor = UIColor(red:0.94, green:0.94, blue:0.94, alpha:0.2).cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 0)
        cardView.layer.shadowOpacity = 0.8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // Disabled
//    @IBAction func goToDeal(_ sender: UIButton) {
//        
//        let url = URL(string: link)!
//        
//        if #available(iOS 10.0, *) {
//            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//        } else {
//            UIApplication.shared.openURL(url)
//        }
//    }

}
