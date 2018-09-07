//
//  Constants.swift
//  FighterJet
//
//  Created by Paul Yang on 11/26/15.
//  Copyright © 2015 Paul Yang. All rights reserved.

// file of constants containing sizes and push/gravity magnitudes used for various iphone sizes

import Foundation
import UIKit

class Constants {
    struct Magnitudes {
        
        // iphone 4 magnitudes are tuned correctly
        
        // magnitudes for gravity -- pulling jet down
        static let gravityMagnitudes:[CGFloat] = [0.8, 0.8, 0.95, 1.0]  // for iphone4, iphone5, iphone6, iphone6+
        
        // magnitudes for push -- pushing jet up at an angle of 95 degrees
        static let pushUpMagnitudes:[CGFloat] = [0.4, 0.5, 0.8, 1.1]  // for iphone4, iphone5, iphone6, iphone6+
        
        static let bombUpMagitudeMax:[CGFloat] = [0.8, 1.0, 1.4, 2.2]
        static let bombUpMagitudeMin:[CGFloat] = [0.5, 0.65, 1.1, 1.5]
    }
    
    struct Sizes {
        static let jetHeight:[CGFloat] = [28, 30, 35, 40]
        static let jetWidth:[CGFloat] = [55, 60, 70, 80]
        
        static let bombWidth:[CGFloat] = [30, 35, 40, 45]
        static let bombHeight:[CGFloat] = [40, 45, 50, 55]
        
        static let ufoWidth:[CGFloat] = [55, 55, 65, 75]
        static let ufoHeight:[CGFloat] = [40, 45, 50, 45]
        static let scoreLabelWidth:[CGFloat] = [80,80,80,80]
        static let scoreLabelHeight:[CGFloat] = [80,80,80,80]
        static let highScoreLabelWidth:[CGFloat] = [50,60,70,80]
        static let highScoreLabelHeight:[CGFloat] = [50,60,70,80]
        static let continueLabelWidth:[CGFloat] = [140,140,140,140]
        static let continueLabelHeight:[CGFloat] = [60,60,60,60]
    }
    
    struct Positions {
        static let bombFromTopYOriginScalar:[CGFloat] = [0.75, 0.75, 0.75, 0.75]
        static let bombFromBottomYOriginScalar:[CGFloat] = [0.1, 0.05, 0.05, 0.05]
        static let scoreLabelX:[CGFloat] = [110,110,130,150]
        static let scoreLabelY:[CGFloat] = [120,120,120,120]
        static let highScoreLabelX:[CGFloat] = [250,250,300,320]
        static let highScoreLabelY:[CGFloat] = [420,500,600,670]
        static let continueLabelX:[CGFloat] = [120, 120, 140, 170]
        static let continueLabelY:[CGFloat] = [420,500,600,670]
    }
}

