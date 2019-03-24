import UIKit

// Testing
let str = "Hello, playground"

print("The string: \(str).")

// ----------------------
// From: https://www.gabethecoder.com/swift-http-requests/
//

struct ResponseModel: Decodable {
    let message: String
}

func sendRequest (url: String, completion: @escaping (Data?) -> Void){
    guard let urlObj = URL(string: url) else {
        print("URL Error")
        return completion(nil)
    }
    URLSession.shared.dataTask(with: urlObj) { data, response, error in
        if error != nil {
            print("Network Error: \(error)")
            return completion(nil)
        } else {
            return completion(data)
        }
    }.resume()
}

func testFn() {
    sendRequest(url: "https://api.bitrise.io") { data in
        if let unwrappedData = data {
            let dataStr = String(bytes: unwrappedData, encoding: String.Encoding.utf8)
            print("dataStr: \(dataStr!)")
            
            guard let respObj = try? JSONDecoder().decode(ResponseModel.self, from: unwrappedData) else {
                print("Failed to decode")
                return
            }
            print("respObj: \(respObj)")
        } else {
            print("data was nil")
        }
    }
}

testFn()
print("--DONE--")
