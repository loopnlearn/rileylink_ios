//
//  CommandResponseViewController.swift
//  OmniKitUI
//
//  Created by Pete Schwamb on 8/28/18.
//  Copyright © 2018 Pete Schwamb. All rights reserved.
//

import Foundation
import LoopKitUI
import OmniKit
import RileyLinkBLEKit

extension CommandResponseViewController {
    typealias T = CommandResponseViewController
    
    // Returns an appropriately formatted error string or "Succeeded" if no error
    private static func resultString(error: Error?) -> String {
        guard let error = error else {
            return LocalizedString("Succeeded", comment: "A message indicating a command succeeded")
        }

        let errorStrings: [String]
        if let error = error as? LocalizedError {
            errorStrings = [error.errorDescription, error.failureReason, error.recoverySuggestion].compactMap { $0 }
        } else {
            errorStrings = [error.localizedDescription].compactMap { $0 }
        }
        let errorText = errorStrings.joined(separator: ". ")

        if errorText.isEmpty {
            return String(describing: error)
        }
        return errorText + "."
    }

    static func changeTime(pumpManager: OmnipodPumpManager) -> T {
        return T { (completionHandler) -> String in
            pumpManager.setTime() { (error) in
                DispatchQueue.main.async {
                    completionHandler(resultString(error: error))
                }
            }
            return LocalizedString("Changing time…", comment: "Progress message for changing pod time.")
        }
    }
    
    private static func podStatusString(status: DetailedStatus) -> String {
        var result, str: String

        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .short
        if let timeStr = formatter.string(from: status.timeActive) {
            str = timeStr
        } else {
            str = String(format: LocalizedString("%1$@ minutes", comment: "The format string for minutes (1: number of minutes string)"), String(describing: Int(status.timeActive / 60)))
        }
        result = String(format: LocalizedString("Pod Active: %1$@\n", comment: "The format string for Pod Active: (1: formatted time)"), str)

        result += String(format: LocalizedString("Pod Progress Status: %1$@\n", comment: "The format string for Pod Progress Status: (1: pod progress string)"), String(describing: status.podProgressStatus))

        result += String(format: LocalizedString("Delivery Status: %1$@\n", comment: "The format string for Delivery Status: (1: delivery status string)"), String(describing: status.deliveryStatus))

        result += String(format: LocalizedString("Last Programming Seq Num: %1$@\n", comment: "The format string for last programming sequence number: (1: last programming sequence number)"), String(describing: status.lastProgrammingMessageSeqNum))

        result += String(format: LocalizedString("Bolus Not Delivered: %1$@ U\n", comment: "The format string for Bolus Not Delivered: (1: bolus not delivered string)"), status.bolusNotDelivered.twoDecimals)

        result += String(format: LocalizedString("Pulse Count: %1$d\n", comment: "The format string for Pulse Count (1: pulse count)"), Int(round(status.totalInsulinDelivered / Pod.pulseSize)))

        result += String(format: LocalizedString("Reservoir Level: %1$@ U\n", comment: "The format string for Reservoir Level: (1: reservoir level string)"), status.reservoirLevel == Pod.reservoirLevelAboveThresholdMagicNumber ? "50+" : status.reservoirLevel.twoDecimals)

        result += String(format: LocalizedString("Alerts: %1$@\n", comment: "The format string for Alerts: (1: the alerts string)"), alertString(alerts: status.unacknowledgedAlerts))

        if status.radioRSSI != 0 {
            result += String(format: LocalizedString("RSSI: %1$@\n", comment: "The format string for RSSI: (1: RSSI value)"), String(describing: status.radioRSSI))
            result += String(format: LocalizedString("Receiver Low Gain: %1$@\n", comment: "The format string for receiverLowGain: (1: receiverLowGain)"), String(describing: status.receiverLowGain))
        }

        if status.faultEventCode.faultType != .noFaults {
            // report the additional fault related information in a separate section
            result += String(format: LocalizedString("\n\nPod Fault Code %1$03d (0x%2$02X),", comment: "The format string for fault code in decimal and hex: (1: fault code for decimal display) (2: fault code for hex display)"), status.faultEventCode.rawValue, status.faultEventCode.rawValue)
            result += String(format: LocalizedString("\n  %1$@", comment: "The format code for the fault description: (1: fault description)"), status.faultEventCode.faultDescription)
            if let faultEventTimeSinceActivation = status.faultEventTimeSinceActivation, let faultTimeStr = formatter.string(from: faultEventTimeSinceActivation) {
                result += String(format: LocalizedString("\nFault Time: %1$@", comment: "The format string for fault time: (1: fault time string)"), faultTimeStr)
            }
            if let errorEventInfo = status.errorEventInfo {
                result += String(format: LocalizedString("\nFault Event Info: %1$03d (0x%2$02X),", comment: "The format string for fault event info: (1: fault event info)"), errorEventInfo.rawValue, errorEventInfo.rawValue)
                result += String(format: LocalizedString("\n  Insulin State Table Corrupted: %@", comment: "The format string for insulin state table corrupted: (1: insulin state corrupted)"), String(describing: errorEventInfo.insulinStateTableCorruption))
                result += String(format: LocalizedString("\n  Occlusion Type: %1$@", comment: "The format string for occlusion type: (1: occlusion type)"), String(describing: errorEventInfo.occlusionType))
                result += String(format: LocalizedString("\n  Immediate Bolus In Progress: %1$@", comment: "The format string for immediate bolus in progress: (1: immediate bolus in progress)"), String(describing: errorEventInfo.immediateBolusInProgress))
                result += String(format: LocalizedString("\n  Previous Pod Progress Status: %1$@", comment: "The format string for previous pod progress status: (1: previous pod progress status)"), String(describing: errorEventInfo.podProgressStatus))
            }
            if let refStr = status.pdmRef {
                result += "\n" + refStr
            }
        }

        return result
    }

    static func readPodStatus(pumpManager: OmnipodPumpManager) -> T {
        return T { (completionHandler) -> String in
            pumpManager.getDetailedStatus() { (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let status):
                        completionHandler(podStatusString(status: status))
                    case .failure(let error):
                        completionHandler(resultString(error: error))
                    }
                }
            }
            return LocalizedString("Read Pod Status…", comment: "Progress message for reading Pod status.")
        }
    }

    static func testingCommands(pumpManager: OmnipodPumpManager) -> T {
        return T { (completionHandler) -> String in
            pumpManager.testingCommands() { (error) in
                DispatchQueue.main.async {
                    completionHandler(resultString(error: error))
                }
            }
            return LocalizedString("Testing Commands…", comment: "Progress message for testing commands.")
        }
    }

    static func playTestBeeps(pumpManager: OmnipodPumpManager) -> T {
        return T { (completionHandler) -> String in
            pumpManager.playTestBeeps() { (error) in
                let response: String
                if let error = error {
                    response = resultString(error: error)
                } else {
                    response = LocalizedString("Play test beeps command sent successfully.\n\nIf you did not hear any beeps from your pod, the piezo speaker in your pod may be broken or disabled.", comment: "Success message for play test beeps.")
                }
                DispatchQueue.main.async {
                    completionHandler(response)
                }
            }
            return LocalizedString("Play Test Beeps…", comment: "Progress message for play test beeps.")
        }
    }

    static func readPulseLog(pumpManager: OmnipodPumpManager) -> T {
        return T { (completionHandler) -> String in
            pumpManager.readPulseLog() { (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let pulseLogString):
                        completionHandler(pulseLogString)
                    case .failure(let error):
                        completionHandler(resultString(error: error))
                    }
                }
            }
            return LocalizedString("Reading Pulse Log…", comment: "Progress message for reading pulse log.")
        }
    }
}

extension Double {
    var twoDecimals: String {
        return String(format: "%.2f", self)
    }
}

