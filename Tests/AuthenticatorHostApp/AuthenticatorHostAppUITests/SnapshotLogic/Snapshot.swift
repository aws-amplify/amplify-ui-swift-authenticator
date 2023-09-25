//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import UIKit
import XCTest

struct Snapshot {

    public func captureAndVerifySnapshot(
        for newImage: UIImage,
        named name: String? = nil,
        snapshotDirectory: String? = nil,
        timeout: TimeInterval = 5,
        file: StaticString = #file,
        testName: String = #function,
        line: UInt = #line
    ) -> (didSucceed: Bool, message: String?, attachments: [XCTAttachment]) {

        do {
            let fileUrl = URL(fileURLWithPath: "\(file)", isDirectory: false)
            let fileName = fileUrl.deletingPathExtension().lastPathComponent

            let snapshotDirectoryUrl =
            snapshotDirectory.map { URL(fileURLWithPath: $0, isDirectory: true) }
            ?? fileUrl
                .deletingLastPathComponent()
                .appendingPathComponent("__Snapshots__")
                .appendingPathComponent(fileName)

            let identifier: String
            if let name = name {
                identifier = sanitizePathComponent(name)
            } else {
                let counter = counterQueue.sync { () -> Int in
                    let key = snapshotDirectoryUrl.appendingPathComponent(testName)
                    counterMap[key, default: 0] += 1
                    return counterMap[key]!
                }
                identifier = String(counter)
            }

            let testName = sanitizePathComponent(testName)
            let snapshotFileUrl =
            snapshotDirectoryUrl
                .appendingPathComponent("\(testName).\(identifier)")
                .appendingPathExtension("png")
            let fileManager = FileManager.default
            try fileManager.createDirectory(at: snapshotDirectoryUrl, withIntermediateDirectories: true)

            guard fileManager.fileExists(atPath: snapshotFileUrl.path) else {

                try newImage.pngData()?.write(to: snapshotFileUrl)

                if ProcessInfo.processInfo.environment.keys.contains("__XCODE_BUILT_PRODUCTS_DIR_PATHS") {
                    XCTContext.runActivity(named: "Attached Recorded Snapshot") { activity in
                        let attachment = XCTAttachment(contentsOfFile: snapshotFileUrl)
                        activity.add(attachment)
                    }
                }

                print("File written at \(snapshotFileUrl.absoluteString)")
                return (didSucceed: false, message: "Re-run test, image saved to directory", attachments: [])
            }

            print("file already exists, please assert")

            guard let fileData = fileManager.contents(atPath: snapshotFileUrl.path),
                  let oldImage = UIImage(data: fileData) else {
                return (didSucceed: false, message: "Unable to get already existing file in data format", attachments: [])
            }

            var attachments: [XCTAttachment] = []
            var message: String? = nil
            do {
                let didSucceed = try ImageDiff.compare(oldImage, newImage)
                return (didSucceed: didSucceed, message: nil, attachments: attachments)
            } catch {
                message = error.localizedDescription
            }

            let oldAttachment = XCTAttachment(image: oldImage)
            oldAttachment.name = "Reference Image"
            attachments.append(oldAttachment)

            let newAttachment = XCTAttachment(image: newImage)
            newAttachment.name = "Failure Image"
            attachments.append(newAttachment)

            return (didSucceed: false, message: message, attachments: attachments)
        } catch {
            return (didSucceed: false, message: error.localizedDescription, attachments: [])
        }
    }


    // MARK: - Private
    func sanitizePathComponent(_ string: String) -> String {
        return string
            .replacingOccurrences(of: "\\W+", with: "-", options: .regularExpression)
            .replacingOccurrences(of: "^-|-$", with: "", options: .regularExpression)
    }

}
