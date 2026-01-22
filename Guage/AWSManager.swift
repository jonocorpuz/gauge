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

/// Credential provider for authentication via AWS Cognito Identity Pools
///
/// Supply temporary AWS credentials to the client for DynamoDB table access
/// by exchanging public pool ID for temporary session key and token
///
/// Class name 'CognitoIdentityProvider' is standardized, do not change
final class CognitoIdentityProvider: AWSCredentialIdentityResolver, @unchecked Sendable {
    let client: CognitoIdentityClient
    let poolId: String

    /// Initializes identity provider
    ///
    /// Throws: error if 'CognitoIdentityProvider' fails
    /// ex. if given poolId/client is invalid
    init() throws {
        let config = try CognitoIdentityClient.CognitoIdentityClientConfiguration(region: myRegion)
        self.client = CognitoIdentityClient(config: config)
        self.poolId = myPoolId
    }

    /// Retrieves valid AWS credentials for current session
    ///
    /// Function invoked automatically by AWS SDK if current credentials
    /// expire or are missing (first implementation)
    ///
    /// Returns: 'AWSCredentialIdentity' object with access key, secret key, and session token
    /// Throws: 'NSError' if identity ID cannot be retrieved
    func getIdentity(identityProperties: Attributes?) async throws -> AWSCredentialIdentity {
        // 1. Retrieve Identity ID
        let idInput = GetIdInput(identityPoolId: poolId)
        let idOutput = try await client.getId(input: idInput)
        
        guard let identityId = idOutput.identityId else {
            throw NSError(domain: "AWS", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not find Identity ID"])
        }
        
        // 2. Exchange Identity ID for AWS Credentials
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

/// Manager for DynamoDB operations
///
/// Handles initialisation of DynamoDB client and provides function for saving and fetching
/// 'MaintenanceItem' objects. (New item logged or App open)
///
/// Handles data serialization and deserialization (conversion to JSON for DynamoDB Table)
class AWSManager: @unchecked Sendable {
    static let shared = AWSManager()
    var dbClient: DynamoDBClient? // DynamoDB client intance
    
    private init() { }

    /// Initializes and returns DynamoDB client
    ///
    /// Configures 'CognitoIdentityProvider' and 'DynamoDBClient' only when needed. If
    /// client already exists, returns instance immediately
    ///
    /// Returns: Configured 'DynamoDBClient'
    /// Throws: Error if client configuration fails
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
    
    /// Saves maintenance item to DynamoDB table
    ///
    /// Serializes provided 'MaintenanceItem' into DynamoDB 'AttributeValues' and
    /// adds item to table using 'PutItem' operation
    func save(_ item: MaintenanceItem) async throws {
        let client = try await getClient()
        let dynamoItem = makeDynamoItem(from: item)
        let input = PutItemInput(item: dynamoItem, tableName: myTableName)
        
        _ = try await client.putItem(input: input)
    }
    
    /// Retrieves all maintenance items associated with current user identity
    ///
    /// Performs query on DynamoDB table using Cognito Identity ID as the partition key
    ///
    /// Returns: Array of 'MaintenanceItem' objects
    /// Throws: Error if network request fails
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

    /// Serializes 'MaintenanceItem' into DynamoDB 'AttributeValue' dictionary
    ///
    /// Returns: Dictionary representation compatible with 'PutItemInput'
    private func makeDynamoItem(from item: MaintenanceItem) -> [String: DynamoDBClientTypes.AttributeValue] {
        // Map history array to DynamoDB maps
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
    
    /// Deserialize DynamoDB 'AttributeValue' dictionary into a 'MaintenanceItem'
    ///
    /// Unwraps expected field, if any field are missing, returns 'nil'
    ///
    /// Returns: 'MaintenanceItem' instance or 'nil' if fails
    private func makeLocalItem(from dbItem: [String: DynamoDBClientTypes.AttributeValue]) -> MaintenanceItem? {
        // 1. Extract Strings
        guard let titleAttr = dbItem["title"], case .s(let title) = titleAttr else { return nil }
        guard let idAttr = dbItem["itemId"], case .s(let idString) = idAttr else { return nil }
        guard let typeAttr = dbItem["type"], case .s(let typeString) = typeAttr else { return nil }
        
        // 2. Extract Numbers (AWS stores numbers as Strings, so we must convert to Int)
        guard let intervalAttr = dbItem["intervalMileage"], case .n(let intervalString) = intervalAttr
        else {
            return nil
        }
        
        let interval = Int(intervalString) ?? 0
        
        // 3. Convert UUID
        guard let uuid = UUID(uuidString: idString)
        else {
            return nil
        }
        
        // 4. Parse History Array
        var history: [MaintenanceEvent] = []
        
        if let historyAttr = dbItem["history"], case .l(let list) = historyAttr {
            for entry in list {
                if case .m(let map) = entry {
                    if let dAttr = map["date"], case .s(let dStr) = dAttr,
                       let mAttr = map["mileage"], case .n(let mStr) = mAttr,
                       let date = ISO8601DateFormatter().date(from: dStr) {
                        
                        let miles = Int(mStr) ?? 0
                        history.append(MaintenanceEvent(date: date, mileage: miles))
                    }
                }
            }
        }
        
        // Sort history (newest dates first)
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
