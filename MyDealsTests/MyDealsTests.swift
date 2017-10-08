//
//  MyDealsTests.swift
//  MyDealsTests
//
//  Created by Mathieu Corti on 8/22/17.
//  Copyright © 2017 Mathieu Corti. All rights reserved.
//

import XCTest
@testable import MyDeals

class MyDealsTests: XCTestCase {
    
    var currentExp: XCTestExpectation?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDescriptionsToSave() {
        
        let descriptionToSave: String = "sentence1\nsentence2"
        let descriptionToDisplay: String = "<p>sentence1<br>sentence2</p>"
        
        let descriptionToSavePrepared = EditDealView.prepareDescriptionToSave(description: descriptionToSave)
        let descriptionToDisplayPrepared = EditDealView.prepareDescriptionToDisplay(description: descriptionToDisplay)
        
     
        assert(descriptionToSavePrepared == descriptionToDisplay)
        assert(descriptionToDisplayPrepared == descriptionToSave)
    }
    
    func checkDeals(_: String, _: Any?) {

        if (Deals.sharedInstance.deals[INDEX_GROUPON].count == Constants.NBR_GROUPON_DEALS) {
            currentExp?.fulfill()
        }
    }
    
    func mesuring(_: String, _: Any?) {
    }
    
    func testDownloadDeals() {

        currentExp = expectation(description: "Download deals")
        Deals.sharedInstance.attachObserver(observer: Observer(onNotify: self.checkDeals))
        Deals.sharedInstance.fetchGrouponDeals()
        
        
        waitForExpectations(timeout: 500, handler: { error in XCTAssertNil(error, "Timeout")})
    }
    
    func testDownloadImage() {
        
        let imageView: UIImageView = UIImageView()
        
        imageView.downloadFrom(link: "https://www.w3schools.com/w3images/lights.jpg")
        
        assert(imageView.image != nil)
    }
    
    func testPerformanceRetreivingDealsFromCoreData() {
        self.measure {
            Deals.sharedInstance.attachObserver(observer: Observer(onNotify: self.mesuring))
            Deals.sharedInstance.retrieveUserDeals()
        }
    }
    
}
