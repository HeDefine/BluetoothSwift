//
//  BLEError.swift
//  BluetoothSwift
//
//  Created by Devine.He on 2019/1/30.
//  Copyright © 2019 okinrefiend. All rights reserved.
//

import Foundation

@objc enum BLEStateErrorType:Int {
    case Unknow
    case Resetting
    case UnSupported
    case UnAuthorized
    case PoweredOff
}

@objc enum PeripheralState:Int {
    case Online
    case Failed
    case Offline
}
