import UIKit

// Testing
let str = "Hello, playground"

print("The string: \(str).")

// ----------------------
// From: https://www.gabethecoder.com/swift-http-requests/
//

func testFn() {
    print("1")
    guard let url = URL(string: "https://api.bitrise.io") else { return print("URL Error") }
    print("2")
    
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        print("3")
        guard error == nil else { return print("Network Error: \(error)") }
        
        if data != nil {
            let data = String(bytes: data!, encoding: String.Encoding.utf8)
            print("data: \(data!)")
        } else {
            print("data was nil")
        }
    }
    task.resume()
    print("-")
}

testFn()
print("done")