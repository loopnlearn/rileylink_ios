//
//  GlucoseSensorDataGlucoseEvent.swift
//  RileyLink
//
//  Created by Timothy Mecklem on 10/16/16.
//  Copyright © 2016 Pete Schwamb. All rights reserved.
//

import Foundation

public struct GlucoseSensorDataGlucoseEvent : RelativeTimestampedGlucoseEvent {
    public let length: Int
    public let rawData: Data
    public let sgv: Int
    public var timestamp: DateComponents
    
    public init?(availableData: Data, pumpModel: PumpModel) {
        length = 1
        
        guard length <= availableData.count else {
            return nil
        }
        
        rawData = availableData.subdata(in: 0..<length)
        sgv = Int(UInt16(availableData[0]) * UInt16(2))
        timestamp = DateComponents()
    }
    
    public var dictionaryRepresentation: [String: Any] {
        return [
            "name": "GlucoseSensorData",
        ]
    }
}
