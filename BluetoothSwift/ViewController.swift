//
//  ViewController.swift
//  BluetoothSwift
//
//  Created by Devine.He on 2019/1/21.
//  Copyright © 2019 okinrefiend. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    var scannedDevices:Array<BLEPeripheral> = []

    private let tableView: UITableView = {
        let tableView:UITableView = UITableView.init(frame: CGRect.zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraint()
        
        BLEServer.sharedServer.delegate = self
    }

    //MARK: setupView & Constraint
    func setupView() {
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        let rightBarItem = UIBarButtonItem.init(barButtonSystemItem: .refresh,
                                                target: self,
                                                action: #selector(refreshBtnClick))
        navigationItem.rightBarButtonItem = rightBarItem
    }
    
    func setupConstraint() {
        tableView.snp.makeConstraints { (make) in
            make.trailing.equalTo(view)
            make.leading.equalTo(view)
            make.top.equalTo(view)
            make.bottom.equalTo(view)
        }
    }
}

extension ViewController {
    @objc func refreshBtnClick() {
        BLEServer.sharedServer.scanPeripherals(for: 5)
    }
}

extension ViewController:BLEServerDelegate {
    func BLEPeripheralStateUpdate() {
        
    }
    
    func BLEUpdateScannedPeripheral(_ scannedPeripheral: Array<BLEPeripheral>) {
        self.scannedDevices = scannedPeripheral
        
        tableView.reloadData()
    }
    
    func BLEBecomeAvailable(_ isFirst: Bool) {
        
    }
    
    func BLEIsNotAvailable(errorType: BLEStateErrorType, errorMsg: String) {
        NSLog("\(errorMsg)")
    }
    
}

// MARK: - UITableViewDelegate,UITableViewDataSource
extension ViewController:UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scannedDevices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseId = "deviceListReuseId"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId) ?? UITableViewCell.init(style: .value1, reuseIdentifier: reuseId)
        let peri = scannedDevices[indexPath.row]
        cell.textLabel?.text = peri.name
        cell.detailTextLabel?.text = peri.rssi == 127 ? "--":peri.rssi.stringValue
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Scanned"
    }

}

