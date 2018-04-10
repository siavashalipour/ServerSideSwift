import Foundation
import Kitura
import LoggerAPI
import Configuration
import CloudEnvironment
import KituraContracts
import Health
import MongoKitten

public let projectPath = ConfigurationManager.BasePath.project.path
public let health = Health()

public class App {
    let router = Router()
    let cloudEnv = CloudEnv()
    let dbService = MongoDataBaseService.init()
    
    public init() throws {
        // Run the metrics initializer
        initializeMetrics(router: router)
        
    }

    func postInit() throws {
        // Endpoints
        initializeHealthRoutes(app: self)
        let dbServiceCollection = dbService.getCollection()
        
        // register
        router.all("/register", middleware: BodyParser())
        router.post("/register") { request, response, next in
            guard let parsedBody = request.body else {
                next()
                return
            }
            switch parsedBody {
            case .json(let jsonBody):
                let jsonData = try JSONSerialization.data(withJSONObject: jsonBody, options: .prettyPrinted)
                let user = try JSONDecoder().decode(UserModel.self, from: jsonData)
                try dbServiceCollection?.append(user.createDocument())
                try response.send(user).end()
            default:
                break
            }
            next()
        }
        
        // get user
        router.get("user") { request, response, _ in
            let email = request.queryParameters[UserModelKeys.email] ?? ""
            let query: Query = [UserModelKeys.email: email]
            
            if let findDocument = try dbServiceCollection?.find(query) {
                let userDocument = findDocument.makeDocument()
                let user = UserModel.init(from: userDocument)
                try response.send(user).end()
            }
        }
        
        // update user
        router.all("/update", middleware: BodyParser())
        router.post("/update") { request, response, next in
            let email = request.queryParameters[UserModelKeys.email] ?? ""
            guard let parsedBody = request.body else {
                next()
                return
            }
            switch parsedBody {
            case .json(let jsonBody):
                let query: Query = [UserModelKeys.email: email]
                let jsonData = try JSONSerialization.data(withJSONObject: jsonBody, options: .prettyPrinted)
                let user = try JSONDecoder().decode(UserModel.self, from: jsonData)
                if let updatedUser = try dbServiceCollection?.findAndUpdate(query, with: user.createDocument(), upserting: nil, returnedDocument: Collection.ReturnedDocument.new, sortedBy: nil, projection: nil) {
                    try response.send(UserModel.init(from: updatedUser)).end()
                }
            default:
                break
            }
            next()
        }
        
        // delete user
        router.get("delete") { request, response, _ in
            let email = request.queryParameters[UserModelKeys.email] ?? ""
            try dbServiceCollection?.remove(UserModelKeys.email == email)
        }
    }

    public func run() throws {
        try postInit()
        Kitura.addHTTPServer(onPort: cloudEnv.port, with: router)
        Kitura.run()
        
    }
}
