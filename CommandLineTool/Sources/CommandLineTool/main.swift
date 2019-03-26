//
// Based on:
// - https://www.enekoalonso.com/articles/parsing-command-line-arguments-with-swift-package-manager-argument-parser
// - https://www.swiftbysundell.com/posts/building-a-command-line-tool-using-the-swift-package-manager
//

import CommandLineToolCore
import Foundation
import Utility

enum CLIError: Error {
    case missingInput(String)
}

// The first argument is always the executable, drop it
let arguments = Array(ProcessInfo.processInfo.arguments.dropFirst())

let parser = ArgumentParser(usage: "<options>", overview: "Build stats.")
let appID: OptionArgument<String> = parser.add(option: "--app", shortName: "-a", kind: String.self, usage: "App ID")
let buildCountArg: OptionArgument<String> = parser.add(option: "--build-count", kind: String.self, usage: "Max build count")
let fromDateArg: OptionArgument<String> = parser.add(option: "--from-date", kind: String.self, usage: "From Date")
let toDateArg: OptionArgument<String> = parser.add(option: "--to-date", kind: String.self, usage: "To Date")

let parsedArguments = try parser.parse(arguments)

func argOrDefault(arg: OptionArgument<String>, defaultValue: String) -> String {
    if let parg = parsedArguments.get(arg) {
        return parg
    }
    return defaultValue
}

guard let appID = parsedArguments.get(appID) else {
    print()
    print(" [!] No AppID provided")
    print()
    exit(1)
}

let (buildList, err) = fetchBuildStatsFor(appID: appID)
if err != nil {
    print("Error: \(err!)")
    exit(2)
}

// print("buildList: \(buildList)")

extension Build {
    func length() -> Int? {
        if finishedAt != nil, environmentPrepareFinishedAt != nil {
            let start = environmentPrepareFinishedAt!.toDate()
            let end = finishedAt!.toDate()

            return Int(end!.timeIntervalSince1970) - Int(start!.timeIntervalSince1970)
        }

        return nil
    }
}

struct BuildMetrics {
    let min, max, count: Int
    let avg: Double
}

func calculateMetrics(builds: [Build]) -> BuildMetrics {
    var min, max: Int?
    var count: Int = 0
    var sum: Int = 0

    for aBuild in builds {
        let aBuildLen = aBuild.length()
        guard let aBuildLength = aBuildLen else {
            continue
        }

        if min == nil || aBuildLength < min! {
            min = aBuildLength
        }

        if max == nil || aBuildLength > max! {
            max = aBuildLength
        }

        count += 1
        sum += aBuildLength
    }

    return BuildMetrics(min: min ?? 0, max: max ?? 0, count: count, avg: Double(sum) / Double(count))
}

print()
print("Metrics: \(calculateMetrics(builds: buildList))")
print()

print("--DONE--")
