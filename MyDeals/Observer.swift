//
//  Observer.swift
//  MyDeals
//
//  Created by Mathieu Corti on 9/15/17.
//  Copyright © 2017 Mathieu Corti. All rights reserved.
//

import Foundation

protocol PropertyObserver : class {
    func notify(propertyName: String, propertyValue: Any?)
}


final class Observer : PropertyObserver {
    
    private var onNotify: (_ propertyName: String, _ propertyValue: Any?) -> ()
    
    init(onNotify: @escaping (_ propertyName: String, _ propertyValue: Any?) -> ()) {
        self.onNotify = onNotify
    }
    
    func notify(propertyName: String, propertyValue: Any?) {
        onNotify(propertyName, propertyValue)
    }
}
