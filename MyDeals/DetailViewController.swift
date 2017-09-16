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
                imageView.downloadAsyncFrom(link: deal.imageLink!)
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
            
            if deal.link == nil {
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
            
        }
    }
    
    var dealItem: Deal? {
        didSet {
            // Update the view.
            configureView()
        }
    }

}

