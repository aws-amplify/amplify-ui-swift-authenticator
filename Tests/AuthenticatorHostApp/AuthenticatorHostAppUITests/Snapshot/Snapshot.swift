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
    ) -> (message: String, attachments: [XCTAttachment])? {

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
                return (message: "Re-run test, image saved to directory", attachments: [])
            }

            print("file already exists, please assert")

            guard let fileData = fileManager.contents(atPath: snapshotFileUrl.path),
                  let oldImage = UIImage(data: fileData) else {
                return (message: "Unable to get already existing file in data format", attachments: [])
            }

            guard let diffMessage = ImageDiff().compare(oldImage, newImage) else {
                return nil
            }

            let oldAttachment = XCTAttachment(image: oldImage)
            oldAttachment.name = "Reference Image"
            let newAttachment = XCTAttachment(image: newImage)
            newAttachment.name = "Failure Image"

            return (message: diffMessage, attachments: [oldAttachment, newAttachment])
        } catch {
            return (message: error.localizedDescription, attachments: [])
        }
    }


    // MARK: - Private
    func sanitizePathComponent(_ string: String) -> String {
        return string
            .replacingOccurrences(of: "\\W+", with: "-", options: .regularExpression)
            .replacingOccurrences(of: "^-|-$", with: "", options: .regularExpression)
    }

}
