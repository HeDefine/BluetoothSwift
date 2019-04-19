//
//  BluetoothDelegate.swift
//  BluetoothSwift
//
//  Created by Devine.He on 2019/1/25.
//  Copyright © 2019 okinrefiend. All rights reserved.
//

import Foundation

@objc protocol BLEServerDelegate : NSObjectProtocol {
    /// 当前蓝牙不可用, 已关闭系统弹窗, 所以建议弹窗用
    ///
    /// - Parameters:
    ///   - errorType: 蓝牙不可用的原因
    ///   - errorMsg: 蓝牙不可用的信息
    func BLEIsNotAvailable(errorType:BLEStateErrorType,errorMsg:String)

    /// 蓝牙重新打开
    ///
    /// - Parameter isFirst: 是否是刚初始化还是蓝牙开关切换
    func BLEBecomeAvailable(_ isFirst:Bool)
    
    /// 扫描到的设备列表
    ///
    /// - Parameter scannedPeripheral: 扫描到的设备列表
    func BLEUpdateScannedPeripheral(_ scannedPeripheral:Array<BLEPeripheral>)
    
    func BLEPeripheralStateUpdate()
}
