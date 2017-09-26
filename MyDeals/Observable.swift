//
//  Observable.swift
//  MyDeals
//
//  Created by Mathieu Corti on 9/15/17.
//  Copyright © 2017 Mathieu Corti. All rights reserved.
//

import Foundation

class Observable {
    
    private var observerArray:[Observer] = []

    func attachObserver(observer : Observer) {
        observerArray.append(observer)
    }
    
    func notify(propertyName: String, propertyValue: Any?) {
        for observer in observerArray {
            observer.notify(propertyName: propertyName, propertyValue: propertyValue)
        }
    }
}
