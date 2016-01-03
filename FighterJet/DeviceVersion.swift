//
//  DeviceVersion.swift
//  FoodGasm
//
//  Created by Paul Yang on 8/5/15.
//  Copyright (c) 2015 Paul Yang. All rights reserved.
//

import Foundation
import UIKit

class DeviceVersion {

    // stuff to detect phone version
    // http://stackoverflow.com/questions/24059327/detect-current-device-with-ui-user-interface-idiom-in-swift
    enum UIUserInterfaceIdiom : Int
    {
        case Unspecified
        case Phone
        case Pad
    }
    
    
    struct ScreenSize
    {
        static let SCREEN_WIDTH         = UIScreen.mainScreen().bounds.size.width
        static let SCREEN_HEIGHT        = UIScreen.mainScreen().bounds.size.height
        static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
        static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    }
    
    struct DeviceType
    {
        static let IS_IPHONE_4_OR_LESS  = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
        static let IS_IPHONE_5          = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
        static let IS_IPHONE_6          = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
        static let IS_IPHONE_6P         = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
        static let IS_IPAD              = UIDevice.currentDevice().userInterfaceIdiom == .Pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
    }
    
    //    how to use
    //    if DeviceType.IS_IPHONE_6P {
    //    println("IS_IPHONE_6P")
    //    }
    
    struct Version{
        static let SYS_VERSION_FLOAT = (UIDevice.currentDevice().systemVersion as NSString).floatValue
        static let iOS7 = (Version.SYS_VERSION_FLOAT < 8.0 && Version.SYS_VERSION_FLOAT >= 7.0)
        static let iOS8 = (Version.SYS_VERSION_FLOAT >= 8.0 && Version.SYS_VERSION_FLOAT < 9.0)
        static let iOS9 = (Version.SYS_VERSION_FLOAT >= 9.0 && Version.SYS_VERSION_FLOAT < 10.0)
    }
    
    //    how to use
    //    if Version.iOS8 {
    //    println("iOS8")
    //    }

//    class func getDeviceType() -> String {
//        var device:String = ""
//        if DeviceType.IS_IPHONE_6P {
//     //       device
//        }
//    }
    class func getDeviceIndex() -> Int {
        var deviceTypeIndex:Int = 0
        if (DeviceVersion.DeviceType.IS_IPHONE_4_OR_LESS) {
            deviceTypeIndex = 0
        }
        else if (DeviceVersion.DeviceType.IS_IPHONE_5) {
            deviceTypeIndex = 1
        }
        else if (DeviceVersion.DeviceType.IS_IPHONE_6) {
            deviceTypeIndex = 2
        }
        else if (DeviceVersion.DeviceType.IS_IPHONE_6P) {
            deviceTypeIndex = 3
        }
        return deviceTypeIndex
    }

}