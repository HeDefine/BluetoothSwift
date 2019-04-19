//
//  BluetoothServer.swift
//  BluetoothSwift
//
//  Created by Devine.He on 2019/1/23.
//  Copyright © 2019 okinrefiend. All rights reserved.
//

import CoreBluetooth

class BLEServer : NSObject {
    open var filterServices : [CBUUID]?
    open var filterCharacters : [CBUUID]?
    
    /// 已搜索到的设备
    open var scannedPeripheral = [BLEPeripheral]()
    /// 已连接的设备
    open var connectedPeripherals = [BLEPeripheral]()
    
    /// 单例
    public static let sharedServer = BLEServer()
    /// 协议
    open weak var delegate : BLEServerDelegate?

    private var centralManager : CBCentralManager?
    private var isFirstAvaiable: Bool = true
    
    private override init() {
        super.init()
        
        //iOS11以后，如果只是在通知中心关闭蓝牙，手机的蓝牙并不会关闭，系统弹窗并不会弹出来。
        //所以最好是自定义弹窗，但是若这边不关闭系统弹窗的话，在手机设置中关闭蓝牙会弹出两个提示框,所以设为false
        let options:[String:Any] = [CBCentralManagerOptionShowPowerAlertKey:false]
        
        //如果开启了background-mode里面的bluetooth,才可启用,否则会报错
//        options[CBCentralManagerOptionRestoreIdentifierKey] = "my.bluetooth.restoreId"

        centralManager = CBCentralManager.init(delegate: self,
                                               queue: DispatchQueue.init(label: "my.bluetooth.thread"),
                                               options: options)
    }
}

// MARK: - 生命周期 LifeCycle
extension BLEServer {
    ///这个方法用来重置所有默认数据。
    public func reset() {
        /** x:不严谨的方法.(如果外部持有单例的话,会导致reset以后的单例和原来的单例不一致)
         * BluetoothServer.sharedServer = BluetoothServer()
         */
        
        //严谨的重置方法:  1.断开所有连接  2.清空所有数据,重置到默认数据
        isFirstAvaiable = true
        centralManager = CBCentralManager.init(delegate: self, queue: .main)
    }
    
    /// 保证自身的复制是自己，不会产生新的实例对象
    ///
    /// - Returns: Server实例
    override func copy() -> Any {
        return self
    }
    
    /// 保证复制的是自己，不会产生新的可变实例对象
    ///
    /// - Returns: Server自身
    override func mutableCopy() -> Any {
        return self
    }
}

// MARK: - 私有方法 Private Method
private extension BLEServer {
    /// 检查蓝牙的状态
    ///
    /// - Parameter state: 蓝牙状态
    private func checkManagerState(state: CBManagerState) {
        switch state {
        case .unknown:
            NSLog("当前蓝牙状态未知,请稍后再试")
            delegate?.BLEIsNotAvailable(errorType: .Unknow, errorMsg: "当前蓝牙状态未知,请稍后再试")
            break
        case .resetting:
            NSLog("蓝牙正在重置中...")
            delegate?.BLEIsNotAvailable(errorType: .Resetting, errorMsg: "蓝牙正在重置中...")
            break
        case .unsupported:
            NSLog("当前设备不支持蓝牙")
            delegate?.BLEIsNotAvailable(errorType: .UnSupported, errorMsg:"当前设备不支持蓝牙")
            break
        case .unauthorized:
            NSLog("没有开启蓝牙权限")
            delegate?.BLEIsNotAvailable(errorType: .UnAuthorized, errorMsg:"没有开启蓝牙权限")
            break
        case .poweredOff:
            NSLog("当前蓝牙已关闭,请开启蓝牙")
            delegate?.BLEIsNotAvailable(errorType: .PoweredOff, errorMsg:"当前蓝牙已关闭,请开启蓝牙")
            break
        case .poweredOn:
            NSLog("当前蓝牙可用")
            delegate?.BLEBecomeAvailable(isFirstAvaiable)
            isFirstAvaiable = false
            break
        }
    }
}

// MARK: - 公共实例方法 Public Instance Method
extension BLEServer {
    // MARK: 设备 开始扫描/停止扫描
    /// 扫描设备(默认一直扫描)
    ///
    /// - Parameter seconds: 扫描时间
    public func scanPeripherals(for seconds:TimeInterval = 0) {
        guard let manager = centralManager else {
            assert(false, "Manager should initialize at first")
            return
        }
        guard manager.state == .poweredOn else {
            checkManagerState(state: manager.state)
            return
        }
        guard !manager.isScanning else {
            NSLog("已经在扫描了")
            return
        }
        
        NSLog("开始扫描...")
        scannedPeripheral.removeAll()
        
        manager.scanForPeripherals(withServices: filterServices)
        
        if seconds != 0 {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
                self.stopScan()
            }
        }
    }
    
    /// 停止扫描设备
    public func stopScan() {
        guard let manager = centralManager else {
            assert(false, "Manager should initialize at first")
            return
        }
        guard manager.state == .poweredOn else {
            checkManagerState(state: manager.state)
            return
        }
        guard manager.isScanning else {
            NSLog("已经停止扫描")
            return
        }

        NSLog("停止扫描")
        manager.stopScan()
    }
    
    // MARK: 设备 连接/断连
    /// 连接设备
    ///
    /// - Parameter peripheral: 要连接的设备,如果为空，则不连接
    public func connect(to peripheral:CBPeripheral?) {
        guard let manager = centralManager else {
            assert(false, "Manager should initialize at first")
            return
        }
        guard let peri = peripheral else {
            assert(false,"Peripheral is invalid")
            return
        }
        guard manager.state == .poweredOn else {
            checkManagerState(state: manager.state)
            return
        }
        
        for connectedPeri in connectedPeripherals {
            if connectedPeri.isEqual(peri) {
                NSLog("该外设已经连接了")
                return
            }
        }
        manager.connect(peri, options: nil)
    }
    
    /// 断开外设的蓝牙连接
    ///
    /// - Parameter peripheral: 外设，如果外设为空，则断开所有连接
    public func disconnect(peripheral:BLEPeripheral?) {
        guard let manager = centralManager else {
            assert(false, "Manager should initialize at first")
            return
        }
        guard manager.state == .poweredOn else {
            checkManagerState(state: manager.state)
            return
        }
        guard let peri = peripheral else {
            //如果没有选定设备的话，断开所有设备的连接
            for peri in connectedPeripherals {
                manager.cancelPeripheralConnection(peri.peripheral)
            }
            return
        }
        
        manager.cancelPeripheralConnection(peri.peripheral)
    }
}

// MARK: - 蓝牙中心控制器协议 CBCentralManagerDelegate
extension BLEServer : CBCentralManagerDelegate {
    
    /// 当前的蓝牙状态发生改变
    ///
    /// - Parameter central: 蓝牙中心管理器
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        checkManagerState(state: central.state)
    }
    
    /// 扫描到设备的时候回调
    ///
    /// - Parameters:
    ///   - central: 蓝牙中心管理器
    ///   - peripheral: 设备
    ///   - advertisementData: 广播值
    ///   - RSSI: 信号强度(一般为负数)
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        let peri = BLEPeripheral.init(with: peripheral)
        peri.advertisementData = advertisementData
        peri.rssi = RSSI
        let index = scannedPeripheral.lastIndex { (p1:BLEPeripheral) -> Bool in
            return p1.isEqual(peri)
        }
        if let idx = index {
            scannedPeripheral[idx].rssi = RSSI
        } else {
            NSLog("新增了一个设备")
            scannedPeripheral.append(peri)
        }

        //回到主线程
        DispatchQueue.main.async {
            self.delegate?.BLEUpdateScannedPeripheral(self.scannedPeripheral)
        }
    }
    
    /// 连接成功时回调
    ///
    /// - Parameters:
    ///   - central: 蓝牙中心管理器
    ///   - peripheral: 连接到的设备
    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        
    }
    
    /// 连接失败时回调
    ///
    /// - Parameters:
    ///   - central: 蓝牙中心管理器
    ///   - peripheral: 连接失败的设备
    ///   - error: 连接失败原因
    func centralManager(_ central: CBCentralManager,
                        didFailToConnect peripheral: CBPeripheral,
                        error: Error?) {
        
    }
    
    /// 断开连接时回调
    ///
    /// - Parameters:
    ///   - central: 蓝牙中心管理器
    ///   - peripheral: 断开连接的设备
    ///   - error: 连接失败的原因
    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {
        
    }

    /// 关于蓝牙中心的状态恢复功能
    ///
    /// - Parameters:
    ///   - central: 蓝牙中心管理器
    ///   - dict: 蓝牙或者App中断的时候保存的一些值
    func centralManager(_ central: CBCentralManager,
                        willRestoreState dict: [String : Any]) {
        
    }

}
