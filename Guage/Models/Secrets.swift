//
//  Secrets.swift
//  Guage
//
//  Created by Jonathan Corpuz on 2026-01-27.
//

import Foundation

struct Secrets {
    static let awsRegion = "us-east-2"
    static let cognitoPoolId = "us-east-2:c3a6f0e5-336c-4ed9-be3f-0feddc1fa10e"
    static let dynamoTableName = "GuageUserData"
    
    static let partitionKey = "userId"
    static let sortKey = "itemId"
    static let carMetadataId = "CAR_METADATA"
}
