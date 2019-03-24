// ----------------------
// Based on: https://www.gabethecoder.com/swift-http-requests/
//

import Foundation

public extension String {
    func toDate(withFormat format: String = "yyyy-MM-dd'T'HH:mm:ssZ") -> Date? {
        let dateFormatter = DateFormatter()
        //        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tehran")
        //        dateFormatter.locale = Locale(identifier: "fa-IR")
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: self)
        
        return date
    }
}

public struct BuildsListResponse: Decodable {
    let data: [Build]
    let paging: Paging
}

public struct Build: Decodable {
    public let abortReason, commitHash, triggeredAt, finishedAt, environmentPrepareFinishedAt, startedOnWorkerAt: String?
    public let slug, branch, commitMessage: String
    public let buildNumber, status: Int
    public let triggeredWorkflow: String
}

public struct Paging: Decodable {
    let next: String
    let pageItemLimit, totalItemCount: Int
}

public enum APIError: Error {
    case noAccessToken
    case unauthorized
    case notFound
    case uncategorised(String)
}

public func sendRequest(url: String, completion: @escaping (Data?, APIError?) -> Void) throws {
    guard let urlObj = URL(string: url) else {
        return completion(nil, APIError.uncategorised("URL Error"))
    }
    var request = URLRequest(url: urlObj)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    guard let accessToken = ProcessInfo.processInfo.environment["BITRISE_ACCESS_TOKEN"] else {
        return completion(nil, APIError.noAccessToken)
    }
    request.setValue("token \(accessToken)", forHTTPHeaderField: "Authorization")

    URLSession.shared.dataTask(with: request) { data, response, error in
        if error != nil {
            return completion(nil, APIError.uncategorised("Network Error: \(error!)"))
        } else {
            guard let response = response as? HTTPURLResponse else {
                return completion(nil, APIError.uncategorised("No Response defined"))
            }
            if !(200 ... 299).contains(response.statusCode) {
                switch response.statusCode {
                case 401:
                    return completion(nil, APIError.unauthorized)
                default:
                    return completion(nil, APIError.uncategorised("Non success status code: \(response.statusCode)"))
                }
            }

            return completion(data, nil)
        }
    }.resume()
}

public func fetchBuildStatsFor(appID: String) -> ([Build], APIError?) {
    let sem = DispatchSemaphore(value: 0)
    var builds: [Build] = []

    var retErr: APIError?
    do {
        try sendRequest(url: "https://api.bitrise.io/v0.1/apps/\(appID)/builds") { data, err in
            defer { sem.signal() }

            if err != nil {
                retErr = err
                return
            }

            if let unwrappedData = data {
                let dataStr = String(bytes: unwrappedData, encoding: String.Encoding.utf8)
                print("dataStr: \(dataStr!)")

                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let respObj = try decoder.decode(BuildsListResponse.self, from: unwrappedData)
                    builds.append(contentsOf: respObj.data)
                } catch {
                    retErr = APIError.uncategorised("Failed to decode: \(error)")
                    return
                }
            } else {
                retErr = APIError.uncategorised("data was nil")
                return
            }
        }
        // This line will wait until the semaphore has been signaled
        sem.wait()
    } catch {
        return (builds, APIError.uncategorised("Exception: \(error)"))
    }

    return (builds, retErr)
}
