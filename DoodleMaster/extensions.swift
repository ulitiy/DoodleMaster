//
//  extensions.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 22.12.2020.
//  Copyright © 2020 Aleksandr Ulitin. All rights reserved.
//

extension Double {
    func format(_ f: String) -> String {
        return String(format: "%\(f)f", self)
    }
    
    func formatPercent(_ f: String) -> String {
        (self * 100).format(f)
    }
}
