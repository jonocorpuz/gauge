import Foundation
import AWSDynamoDB
import AWSClientRuntime
import AWSCognitoIdentity
import SmithyIdentity
import SmithyHTTPAPI
import Smithy

private let myRegion = "us-east-2"
private let myPoolId = "us-east-2:c3a6f0e5-336c-4ed9-be3f-0feddc1fa10e"
private let myTableName = "GuageUserData"

final class CognitoIdentityProvider: AWSCredentialIdentityResolver, @unchecked Sendable {
    let client: CognitoIdentityClient
    let poolId: String

    init() throws {
        let config = try CognitoIdentityClient.CognitoIdentityClientConfiguration(region: myRegion)
        self.client = CognitoIdentityClient(config: config)
        self.poolId = myPoolId
    }

    func getIdentity(identityProperties: Attributes?) async throws -> AWSCredentialIdentity {
        let idInput = GetIdInput(identityPoolId: poolId)
        let idOutput = try await client.getId(input: idInput)
        
        guard let identityId = idOutput.identityId else {
            throw NSError(domain: "AWS", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not find Identity ID"])
        }

        let credsInput = GetCredentialsForIdentityInput(identityId: identityId)
        let credsOutput = try await client.getCredentialsForIdentity(input: credsInput)
        
        guard let credentials = credsOutput.credentials,
              let accessKey = credentials.accessKeyId,
              let secretKey = credentials.secretKey,
              let token = credentials.sessionToken else {
              throw NSError(domain: "AWS", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cognito refused to give keys"])
        }

        return AWSCredentialIdentity(
            accessKey: accessKey,
            secret: secretKey,
            expiration: credentials.expiration,
            sessionToken: token
        )
    }
}

class AWSManager: @unchecked Sendable {
    static let shared = AWSManager()
    var dbClient: DynamoDBClient?
    
    private init() { }

    func getClient() async throws -> DynamoDBClient {
        if let existingClient = dbClient {
            return existingClient
        }
        
        else {
            let provider = try CognitoIdentityProvider()
            let config = try await DynamoDBClient.DynamoDBClientConfiguration(region: myRegion)
            config.awsCredentialIdentityResolver = provider
            
            let newClient = DynamoDBClient(config: config)
            self.dbClient = newClient
            return newClient
        }
    }
    
    func save(_ item: MaintenanceItem) async throws {
        let client = try await getClient()
        let dynamoItem = makeDynamoItem(from: item)
        let input = PutItemInput(item: dynamoItem, tableName: myTableName)
        
        _ = try await client.putItem(input: input)
    }
    
    func fetchAll() async throws -> [MaintenanceItem] {
        let client = try await getClient()
        
        let input = QueryInput(
            expressionAttributeValues: [":uid": .s(myPoolId)],
            keyConditionExpression: "userId = :uid",
            tableName: myTableName
        )
        
        let output = try await client.query(input: input)
        
        var finalItems: [MaintenanceItem] = []
        
        if let rawItems = output.items {
            for rawItem in rawItems {
                if let convertedItem = makeLocalItem(from: rawItem) {
                    finalItems.append(convertedItem)
                }
            }
        }
        
        return finalItems
    }

    private func makeDynamoItem(from item: MaintenanceItem) -> [String: DynamoDBClientTypes.AttributeValue] {
        var historyList: [DynamoDBClientTypes.AttributeValue] = []
        
        for event in item.history {
            let eventMap: [String: DynamoDBClientTypes.AttributeValue] = [
                "id": .s(event.id.uuidString),
                "date": .s(ISO8601DateFormatter().string(from: event.date)),
                "mileage": .n(String(event.mileage))
            ]
            historyList.append(.m(eventMap))
        }

        return [
            "userId": .s(myPoolId),               // Partition Key
            "itemId": .s(item.id.uuidString),     // Sort Key
            "title": .s(item.title),
            "intervalMileage": .n(String(item.intervalMileage)),
            "type": .s(item.type.rawValue),
            "history": .l(historyList)
        ]
    }
    
    private func makeLocalItem(from dbItem: [String: DynamoDBClientTypes.AttributeValue]) -> MaintenanceItem? {
        // 1. Extract Strings
        guard let titleAttr = dbItem["title"], case .s(let title) = titleAttr else { return nil }
        guard let idAttr = dbItem["itemId"], case .s(let idString) = idAttr else { return nil }
        guard let typeAttr = dbItem["type"], case .s(let typeString) = typeAttr else { return nil }
        
        // 2. Extract Numbers (AWS stores numbers as Strings, so we must convert to Int)
        guard let intervalAttr = dbItem["intervalMileage"], case .n(let intervalString) = intervalAttr else { return nil }
        let interval = Int(intervalString) ?? 0
        
        // 3. Convert UUID
        guard let uuid = UUID(uuidString: idString) else { return nil }
        
        // 4. Parse History Array
        var history: [MaintenanceEvent] = []
        
        if let historyAttr = dbItem["history"], case .l(let list) = historyAttr {
            for entry in list {
                // Check if the entry is a Map (Dictionary)
                if case .m(let map) = entry {
                    // Extract date and mileage from the map
                    if let dAttr = map["date"], case .s(let dStr) = dAttr,
                       let mAttr = map["mileage"], case .n(let mStr) = mAttr,
                       let date = ISO8601DateFormatter().date(from: dStr) {
                        
                        let miles = Int(mStr) ?? 0
                        history.append(MaintenanceEvent(date: date, mileage: miles))
                    }
                }
            }
        }
        
        // Sort history: Newest dates first
        history.sort(by: { $0.date > $1.date })
        
        return MaintenanceItem(
            id: uuid,
            title: title,
            intervalMileage: interval,
            type: EntryType(rawValue: typeString) ?? .maintenance,
            history: history
        )
    }
}
