//
//  PodDiagnosticsViewController.swift
//  OmniKit

//  Created by Joseph Moran on 11/24/23
//  Copyright © 2023 LoopKit Authors. All rights reserved.
//

import UIKit
import LoopKit
import LoopKitUI
import OmniKit

class PodDiagnosticsViewController: UITableViewController {

    let pumpManager: OmnipodPumpManager

    init(pumpManager: OmnipodPumpManager) {
        self.pumpManager = pumpManager
        super.init(style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = LocalizedString("Pod Diagnostics", comment: "Title of the pod diagnostic view controller")

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44

        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 55

        tableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(SettingsTableViewCell.self))
        tableView.register(TextButtonTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(TextButtonTableViewCell.self))
    }

    override func viewWillAppear(_ animated: Bool) {
        if clearsSelectionOnViewWillAppear {
            // Manually invoke the delegate for rows deselecting on appear
            for indexPath in tableView.indexPathsForSelectedRows ?? [] {
                _ = tableView(tableView, willDeselectRowAt: indexPath)
            }
        }
        
        super.viewWillAppear(animated)
    }

    private enum Diagnostics: Int, CaseIterable {
        case readPodStatus = 0
        case playTestBeeps
        case readActivationTime
        case readPulseLog
        case readPulseLogPlus
        case readTriggeredAlerts
        case pumpManagerDetails
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return Diagnostics.allCases.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(SettingsTableViewCell.self), for: indexPath)
        cell.accessoryType = .disclosureIndicator
        switch Diagnostics(rawValue: indexPath.row)! {
        case .readPodStatus:
            cell.textLabel?.text = LocalizedString("Read Pod Status", comment: "The title of the command to read the pod status")
        case .playTestBeeps:
            cell.textLabel?.text = LocalizedString("Play Test Beeps", comment: "The title of the command to play test beeps")
        case .readActivationTime:
            cell.textLabel?.text = LocalizedString("Read Activation Time", comment: "The title of the command to read activation time")
        case .readPulseLog:
            cell.textLabel?.text = LocalizedString("Read Pulse Log", comment: "The title of the command to read the pulse log")
        case .readPulseLogPlus:
            cell.textLabel?.text = LocalizedString("Read Pulse Log Plus", comment: "The title of the command to read pulse log plus")
        case .readTriggeredAlerts:
            cell.textLabel?.text = LocalizedString("Read Triggered Alerts", comment: "The title of the command to read triggered alerts")
        case .pumpManagerDetails:
            cell.textLabel?.text = LocalizedString("Pump Manager Details", comment: "The title of the command to display pump manager details")
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sender = tableView.cellForRow(at: indexPath)

        switch Diagnostics(rawValue: indexPath.row)! {
        case .readPodStatus:
            let vc = CommandResponseViewController.readPodStatus(pumpManager: pumpManager)
            vc.title = sender?.textLabel?.text
            show(vc, sender: indexPath)
        case .playTestBeeps:
            let vc = CommandResponseViewController.playTestBeeps(pumpManager: pumpManager)
            vc.title = sender?.textLabel?.text
            show(vc, sender: indexPath)
        case .readActivationTime:
            let vc = CommandResponseViewController.readActivationTime(pumpManager: pumpManager)
            vc.title = sender?.textLabel?.text
            show(vc, sender: indexPath)
        case .readPulseLog:
            let vc = CommandResponseViewController.readPulseLog(pumpManager: pumpManager)
            vc.title = sender?.textLabel?.text
            show(vc, sender: indexPath)
        case .readPulseLogPlus:
            let vc = CommandResponseViewController.readPulseLogPlus(pumpManager: pumpManager)
            vc.title = sender?.textLabel?.text
            show(vc, sender: indexPath)
        case .readTriggeredAlerts:
            let vc = CommandResponseViewController.readTriggeredAlerts(pumpManager: pumpManager)
            vc.title = sender?.textLabel?.text
            show(vc, sender: indexPath)
        case .pumpManagerDetails:
            let vc = CommandResponseViewController.pumpManagerDetails(pumpManager: pumpManager)
            vc.title = sender?.textLabel?.text
            show(vc, sender: indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        tableView.reloadRows(at: [indexPath], with: .fade)
        return indexPath
    }
}
