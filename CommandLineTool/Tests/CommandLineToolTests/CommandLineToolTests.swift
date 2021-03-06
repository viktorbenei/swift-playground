import class Foundation.Bundle
import XCTest

@testable import CommandLineToolCore

final class CommandLineToolTests: XCTestCase {
  func testExample() throws {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct
//        // results.
//
//        // Some of the APIs that we use below are available in macOS 10.13 and above.
//        guard #available(macOS 10.13, *) else {
//            return
//        }
//
//        let fooBinary = productsDirectory.appendingPathComponent("CommandLineTool")
//
//        let process = Process()
//        process.executableURL = fooBinary
//
//        let pipe = Pipe()
//        process.standardOutput = pipe
//
//        try process.run()
//        process.waitUntilExit()
//
//        let data = pipe.fileHandleForReading.readDataToEndOfFile()
//        let output = String(data: data, encoding: .utf8)
//
//        XCTAssertEqual(output, "Hello, world!\n")
  }

  func testStringToDate() throws {
    for aTC in [
      ("2019-03-20T18:07:31Z", Date(timeIntervalSince1970: 1_553_105_251)),
      ("1970-01-01T00:00:00Z", Date(timeIntervalSince1970: 0)),
    ] {
      XCTAssertEqual(aTC.1, aTC.0.toDate())
    }
  }

  /// Returns path to the built products directory.
  var productsDirectory: URL {
    #if os(macOS)
      for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
        return bundle.bundleURL.deletingLastPathComponent()
      }
      fatalError("couldn't find the products directory")
    #else
      return Bundle.main.bundleURL
    #endif
  }

  static var allTests = [
    ("testExample", testExample),
  ]
}
