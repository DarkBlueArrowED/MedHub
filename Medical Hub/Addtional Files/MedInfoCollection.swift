//
//  MedInfoCollection.swift
//  Medical Hub
//
//  Created by Walter Bassage on 27/03/2018.
//  Copyright © 2018 Walter Bassage. All rights reserved.
//

import Foundation


class MedInfoCollection {
    
    var medData: [String]?
    
    init() {
        let medDataURL = Bundle.main.url(forResource: "MedInfo", withExtension: "plist")!
        self.medData = NSArray(contentsOf: medDataURL) as? [String]
    }
    
}
