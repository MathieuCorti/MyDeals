//
//  Deals.swift
//  MyDeals
//
//  Created by Mathieu Corti on 9/14/17.
//  Copyright © 2017 Mathieu Corti. All rights reserved.
//

import Foundation
import CoreData

let SECTION_MY_DEALS = "My deals"
let SECTION_GROUPON  = "Groupon"

let SECTIONS         = [SECTION_MY_DEALS, SECTION_GROUPON]

let INDEX_MY_DEALS   = SECTIONS.index(of: SECTION_MY_DEALS)!
let INDEX_GROUPON    = SECTIONS.index(of: SECTION_GROUPON)!

final class Deals : Observable {
    
    static let DEALS_NAME = "deals"
    
    // Singleton instance
    static let sharedInstance = Deals()

    // Observer
    var observer:PropertyObserver?
    
    var deals: [[Deal]] = [[], []] {
        didSet {
            self.notify(propertyName: Deals.DEALS_NAME, propertyValue: self.deals)
        }
    }

    override private init() {
        super.init()
//        retrieveUserDeals()
//        fetchGrouponDeals()
    }

    // Fetch deals
    func fetchGrouponDeals() {
        
        let url:String = "https://partner-api.groupon.com/deals.json?tsToken=US_AFF_0_201236_212556_0&division_id=new-york&channel_id=goods&safe=true&offset=0&limit=20"
        let urlRequest:URL = URL(string: url)!
        
        URLSession.shared.dataTask(with: urlRequest, completionHandler: {
            (data, reponse, error) in
            
            if error != nil {
                print(error.debugDescription)
                return
            }
            
            do {
                
                let parsedData   = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                let grouponDeals = parsedData["deals"] as! Array<AnyObject>
                
                for deal in grouponDeals {
                    
                    let newDeal:Deal = Deal(needSave: false, context: DatabaseController.getContext())
                    
                    // TITLE
                    newDeal.title = (deal["shortAnnouncementTitle"] as? String)!
                    
                    // MERCHANT
                    let fullMerchant = deal["merchant"] as? NSDictionary
                    newDeal.merchant = (fullMerchant?["id"] as? String)!
                    
                    // DESCRIPTION
                    newDeal.desc = (deal["pitchHtml"] as? String)!
                    
                    // PRICE
                    let options = deal["options"] as! Array<AnyObject>
                    if options.count >= 1 {
                        
                        let fullprice = options[0]["price"] as? NSDictionary
                        newDeal.price = (fullprice?["formattedAmount"] as? String)!
                        
                    } else {
                        
                        newDeal.price = ""
                    }
                    
                    // LINK
                    newDeal.link = (deal["dealUrl"] as? String)!
                    
                    // IMAGE LINK
                    newDeal.imageLink = (deal["largeImageUrl"] as? String)!
                    
                    // DISABLE EDITTING
                    newDeal.isEditable = false
                    
                    self.deals[INDEX_GROUPON].append(newDeal)
                    self.notify(propertyName: Deals.DEALS_NAME, propertyValue: self.deals)
                }
                
            } catch {
                print("Error: \(error)")
            }
            
        }).resume()
    }
    
    func retrieveUserDeals() {
        
        // Load data from db
        let fetchRequest:NSFetchRequest<Deal> = Deal.fetchRequest()
        
        do {
            deals[INDEX_MY_DEALS] = try DatabaseController.getContext().fetch(fetchRequest)
            notify(propertyName: Deals.DEALS_NAME, propertyValue: deals)
        }
        catch {
            print("Error: \(error)")
        }
    }
    
}
