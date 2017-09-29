//
//  DetailViewController.swift
//  MyDeals
//
//  Created by Mathieu Corti on 8/22/17.
//  Copyright © 2017 Mathieu Corti. All rights reserved.
//

import UIKit

protocol FormatCommand {
    func execute() -> NSAttributedString
}

class FormatHtml : FormatCommand {
    
    let rawValue:String
    
    required init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    func execute() -> NSAttributedString {
        
        let htmlData = NSString(string: rawValue).data(using: String.Encoding.unicode.rawValue)
        
        let formattedValue = try! NSAttributedString(data: htmlData!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
        return formattedValue
    }
}


class DetailViewController: UIViewController {

    @IBOutlet weak var dealTitle: UILabel!
    @IBOutlet weak var dealMerchant: UILabel!
    @IBOutlet weak var dealImage: UIImageView!
    @IBOutlet weak var dealPrice: UILabel!
    @IBOutlet weak var dealDescription: UITextView!
    
    @IBOutlet weak var goToDeal_button: UIButton!
    @IBOutlet weak var editDeal_button: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Add rounded corners to button
        goToDeal_button.layer.cornerRadius = 3
        
        if let navController = self.navigationController {
            navController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        }
        
        configureView()
    }
    
    func configureView() {

        // Update the user interface for the detail item.
        if let deal = dealItem {

            if !deal.isEditable {
                editDeal_button.isEnabled = false
            }
            if let title = dealTitle {
                title.text = deal.title
                title.numberOfLines = 1
                title.minimumScaleFactor = 0.5
                title.adjustsFontSizeToFitWidth = true
            }
            if let merchant = dealMerchant {
                merchant.text = deal.merchant
            }
            if let imageView = dealImage {
                
                if deal.imageSrc == Constants.IMG_SRC_LINK {
                    imageView.downloadAsyncFrom(link: deal.imageLink!)
                } else if deal.imageSrc == Constants.IMG_SRC_UIIMG {
                    imageView.image = UIImage(data: deal.image! as Data)
                }
                
            }
            if let price = dealPrice {
                price.text = deal.price
            }
            if let description = dealDescription, let dealDesc = deal.desc {
                
                // Store command
                let formatCommand: FormatCommand = FormatHtml(rawValue: dealDesc)
                
                description.isEditable = false
                description.attributedText = formatCommand.execute()
                
//                description.text = deal.desc
            }
            
            if deal.link == nil || (deal.link?.isEmpty)! {
                if let gtd = goToDeal_button {
                    gtd.isHidden = true
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Disabled
//    @IBAction func goToDeal(_ sender: UIButton) {
//        
//        if let deal = dealItem {
//            
//            let url = URL(string: deal.link)!
//            
//            if #available(iOS 10.0, *) {
//                UIApplication.shared.open(url, options: [:], completionHandler: nil)
//            } else {
//                UIApplication.shared.openURL(url)
//            }
//        }
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "viewWebDeal", let deal = dealItem {
            
            let controller = segue.destination as! WebView
            controller.link = deal.link!
            
        } else if segue.identifier == "editDeal" {

            let controller = segue.destination as! EditDealView
            controller.isNewDeal = false
            controller.deal = dealItem!
        }
    }
    
    var dealItem: Deal? {
        didSet {
            // Update the view.
            configureView()
        }
    }

}

