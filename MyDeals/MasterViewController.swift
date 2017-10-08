//
//  MasterViewController.swift
//  MyDeals
//
//  Created by Mathieu Corti on 8/22/17.
//  Copyright © 2017 Mathieu Corti. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController {
    
    // TODO : Color #E9323F
    
    var detailViewController: DetailViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register observer
        Deals.sharedInstance.attachObserver(observer: Observer(onNotify: self.updateTableView))
        Deals.sharedInstance.retrieveUserDeals()
        Deals.sharedInstance.fetchGrouponDeals()

        // Add edit button
        navigationItem.leftBarButtonItem = editButtonItem
        
        // Remove separators
        self.tableView.separatorStyle = .none
        
        // Change background color
        self.tableView.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
        
        // Change title color
        if let navController = self.navigationController {
            navController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
            
            //
            // 1/2 Fix provided by @Joe for search bar color bug
            // https://stackoverflow.com/questions/40208982/mismatched-colors-on-uinavigationbar-and-uisearchbar
            //

            // To Get transparent navigationBar
            navController.navigationBar.setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
            // To remove black hairline under the Navigationbar
            navController.navigationBar.shadowImage = UIImage()
            navController.navigationBar.isTranslucent = false
            // To apply your tint background to navigationBar
            navController.navigationBar.barTintColor = UIColor(red:0.98, green:0.20, blue:0.33, alpha:1.0)
        }

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count - 1] as! UINavigationController).topViewController as? DetailViewController
        }
    }
    
    private func updateTableView(_: String, _: Any?) {
        // Update tableview
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDetail" {
            
            if let indexPath = tableView.indexPathForSelectedRow {
                
                let deal = Deals.sharedInstance.deals[indexPath.section][indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.dealItem = deal
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }

        } else if segue.identifier == "viewWebDeal" {
            
            let senderObj = sender as! UIButton
            if let cell = senderObj.superview?.superview as? DealCell,
                let indexPath = tableView.indexPath(for: cell) {
                
                let deal = Deals.sharedInstance.deals[indexPath.section][indexPath.row]
                let controller = segue.destination as! WebView
                controller.link = deal.link!
            }
            
        }
    }

    // MARK: - Table View
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 25))
        returnedView.backgroundColor = UIColor(red:0.99, green:0.17, blue:0.32, alpha:1.0)
        returnedView.layer.borderColor = UIColor(red:0.99, green:0.17, blue:0.32, alpha:1.0).cgColor
        
        let label = UILabel(frame: CGRect(x: 10, y: 8, width: view.frame.size.width, height: 25))
        label.text = SECTIONS[section]
        label.textColor = UIColor.white
        returnedView.addSubview(label)
        
        return returnedView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return SECTIONS[section]
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Deals.sharedInstance.deals[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let deal = tableView.dequeueReusableCell(withIdentifier: "Deal", for: indexPath) as! DealCell

        let dealObject = Deals.sharedInstance.deals[indexPath.section][indexPath.row]
        
        deal.dealTitle.text     = dealObject.title
        deal.dealTitle.numberOfLines = 1
        deal.dealTitle.minimumScaleFactor = 0.5
        deal.dealTitle.adjustsFontSizeToFitWidth = true

        deal.dealMerchant.text  = dealObject.merchant
        
        if dealObject.imageSrc == Constants.IMG_SRC_LINK {
            deal.dealPicture.downloadAsyncFrom(link: dealObject.imageLink!)
        } else if dealObject.imageSrc == Constants.IMG_SRC_UIIMG {
            deal.dealPicture.image = UIImage(data: dealObject.image! as Data)
        }

        if dealObject.link == nil || (dealObject.link?.isEmpty)! {
         
            deal.goToDealButton.isUserInteractionEnabled = false
            deal.goToDealButton.setTitle("In store", for: .normal)
            
            // Invert button color
            deal.goToDealButton.backgroundColor = UIColor.white
            deal.goToDealButton.tintColor = UIColor(red:0.91, green:0.20, blue:0.25, alpha:1.0)
            
        } else {
            
            deal.link = dealObject.link!
            // Edit button
            deal.goToDealButton.layer.cornerRadius = 3
            
        }
        
        return deal
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            DatabaseController.getContext().delete(Deals.sharedInstance.deals[indexPath.section][indexPath.row])
            Deals.sharedInstance.deals[indexPath.section].remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            DatabaseController.saveContext()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

    func addFakeData() {
        
        var deal:Deal = NSEntityDescription.insertNewObject(forEntityName: "Deal", into: DatabaseController.getContext()) as! Deal
        deal.title = "1 free hot coffee"
        deal.merchant = "@Starbucks"
        deal.desc = "Go to starbucks and grab your free coffee !<br>Only the 25 of august."
        deal.price = "Free"
        deal.imageLink = "https://s-media-cache-ak0.pinimg.com/originals/42/a7/c0/42a7c061205975eee974e10a3d4b5487.jpg"
        deal.link = ""
        deal.isEditable = true
        deal.imageSrc = Constants.IMG_SRC_LINK
        
        deal = NSEntityDescription.insertNewObject(forEntityName: "Deal", into: DatabaseController.getContext()) as! Deal
        deal.title = "30% off sport items"
        deal.merchant = "@Amazon"
        deal.desc = "30% free on all the sport items on amazon.com."
        deal.price = "30% off"
        deal.imageLink = "http://www.thesempost.com/wp-content/uploads/2014/09/amazon-thumb.png"
        deal.link = "https://www.amazon.com/sports-outdoors/b?ie=UTF8&node=3375251"
        deal.isEditable = true
        deal.imageSrc = Constants.IMG_SRC_LINK
        
        deal = NSEntityDescription.insertNewObject(forEntityName: "Deal", into: DatabaseController.getContext()) as! Deal
        deal.title = "eBay 20% off Tech Sale at 62 Stores"
        deal.merchant = "@Ebay"
        deal.desc = "This offer commences at 16.00 (AEST) on 14 August 2017 and ends at 23.59 (AEST) on 21 August 2017 (“Offer Period”).<br>Only 3 transactions per person during the Offer Period.<br>The total discount is capped at $1000 per transaction.<br>To search the sale, use the blue search box via the main link.<br>Use the code PTECH20."
        deal.price = "20% off"
        deal.imageLink = "https://d2hzvxamqgodh.cloudfront.net/sites/default/files/dealimage/new-ebay-logo_2.jpg"
        deal.link = "https://www.ebay.com.au/rpp/tech-sale"
        deal.isEditable = true
        deal.imageSrc = Constants.IMG_SRC_LINK
        
        deal = NSEntityDescription.insertNewObject(forEntityName: "Deal", into: DatabaseController.getContext()) as! Deal
        deal.title = "Sony MDR-1000X $392 Delivered"
        deal.merchant = "@Amazon"
        deal.desc = "Isolate yourself from external noise with industry-leading noise cancelation<br>Enjoy Bluetooth wireless connectivity and Hi-Fi quality audio, Driver Unit 40mm, dome type(CCAW Voice Coil), Frequency Response (Hz) 4Hz-40 000Hz<br>Listen to ambient sounds quickly and clearly with Quick Attention<br>Hear music at its best with Hi-Res Audio"
        deal.price = "US $309.57 (~AU $392)"
        deal.imageLink = "http://brain-images.cdn.dixons.com/6/7/10151876/l_10151876_004.jpg"
        deal.link = "https://www.amazon.com/exec/obidos/ASIN/B01KHZ4ZYY/ozba0e-20"
        deal.isEditable = true
        deal.imageSrc = Constants.IMG_SRC_LINK
        
        deal = NSEntityDescription.insertNewObject(forEntityName: "Deal", into: DatabaseController.getContext()) as! Deal
        deal.title = "15 Wicked Wings for $10"
        deal.merchant = "@KFC"
        deal.desc = "Also available: Zinger Mozzarella Burger $7.95 ($10.50 in combo). The Zinger Mozzarella Burger is a zinger burger with bacon and a fried Mozzarella patty.<br><br>The starts on 8th August (7th August in QLD/WA only)."
        deal.price = "10$"
        deal.imageLink = "https://upload.wikimedia.org/wikipedia/en/thumb/b/bf/KFC_logo.svg/1024px-KFC_logo.svg.png"
        deal.link = "https://www.kfc.com.au/menu/chicken/15-wings-for-10"
        deal.isEditable = true
        deal.imageSrc = Constants.IMG_SRC_LINK
        
        deal = NSEntityDescription.insertNewObject(forEntityName: "Deal", into: DatabaseController.getContext()) as! Deal
        deal.title = "50x 6x4' Photos - $2.95 Posted"
        deal.merchant = "@Snapfish"
        deal.desc = "Just came across this chasing Snapfish vouchers, and thought it worthy of a rehash. The app links in with your Google Photos, Facebook etc so really easy to pick a bunch of photos to make a hard copy :)"
        deal.price = "2.95$"
        deal.imageLink = "https://lh3.googleusercontent.com/7d6vwBri4TBAzPp28Y1hnW55M5xJpE06EIDIj2KH7bWToZLlR62NRuE5duGS7D5GxVc=w300"
        deal.link = "https://www.snapfish.com.au/store/mobileapps"
        deal.isEditable = true
        deal.imageSrc = Constants.IMG_SRC_LINK
        
        deal = NSEntityDescription.insertNewObject(forEntityName: "Deal", into: DatabaseController.getContext()) as! Deal
        deal.title = "Minecraft: Pocket Edition"
        deal.merchant = "@Google Play"
        deal.desc = "The pocket edition of Minecraft is on sale.<br><br>Rating 4.5 from 1,977,355 reviews."
        deal.price = "1.49$ (Was $14.99)"
        deal.imageLink = "https://lh3.googleusercontent.com/30koN0eGl-LHqvUZrCj9HT4qVPQdvN508p2wuhaWUnqKeCp6nrs9QW8v6IVGvGNauA=w300"
        deal.link = "https://play.google.com/store/apps/details?id=com.mojang.minecraftpe"
        deal.isEditable = true
        deal.imageSrc = Constants.IMG_SRC_LINK
        
        DatabaseController.saveContext()
    }

}

