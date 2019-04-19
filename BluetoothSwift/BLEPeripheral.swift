//
//  CBPeripheral.swift
//  BluetoothSwift
//
//  Created by Devine.He on 2019/2/13.
//  Copyright © 2019 okinrefiend. All rights reserved.
//

import Foundation
import CoreBluetooth

class BLEPeripheral : NSObject {
    /// 系统的外设
    public let peripheral:CBPeripheral
    /// 信号强度,当信号是127时，RSSI未读取到或者不可用
    public var rssi:NSNumber = 127
    /// 外设名
    public let name:String
    /// 外设的Id
    public let identifier:String
    /// 广播值
    public var advertisementData:[String : Any]?
    
    init(with peripheral:CBPeripheral) {
        self.peripheral = peripheral

        self.identifier = peripheral.identifier.uuidString
        self.name = peripheral.name ?? "Unnamed"
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? BLEPeripheral else {
            return false
        }
        return object.identifier == self.identifier
    }
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        return hasher.finalize()
    }
    
}
