//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import UIKit

struct ImageDiff {

    private let imageContextColorSpace = CGColorSpace(name: CGColorSpace.sRGB)
    private let imageContextBitsPerComponent = 8
    private let imageContextBytesPerPixel = 4

    func compare(_ old: UIImage, _ new: UIImage) -> String? {
        compare(old, new, precision: 0.99, perceptualPrecision: 1)
    }

    private func compare(_ old: UIImage, _ new: UIImage, precision: Float, perceptualPrecision: Float) -> String? {
        guard let oldCgImage = old.cgImage else {
            return "Reference image could not be loaded."
        }
        guard let newCgImage = new.cgImage else {
            return "Newly-taken snapshot could not be loaded."
        }
        guard newCgImage.width != 0, newCgImage.height != 0 else {
            return "Newly-taken snapshot is empty."
        }
        guard oldCgImage.width == newCgImage.width, oldCgImage.height == newCgImage.height else {
            return "Newly-taken snapshot@\(new.size) does not match reference@\(old.size)."
        }
        let pixelCount = oldCgImage.width * oldCgImage.height
        let byteCount = imageContextBytesPerPixel * pixelCount
        var oldBytes = [UInt8](repeating: 0, count: byteCount)
        guard let oldData = context(for: oldCgImage, data: &oldBytes)?.data else {
            return "Reference image's data could not be loaded."
        }
        if let newContext = context(for: newCgImage), let newData = newContext.data {
            if memcmp(oldData, newData, byteCount) == 0 { return nil }
        }
        var newerBytes = [UInt8](repeating: 0, count: byteCount)
        guard
            let pngData = new.pngData(),
            let newerCgImage = UIImage(data: pngData)?.cgImage,
            let newerContext = context(for: newerCgImage, data: &newerBytes),
            let newerData = newerContext.data
        else {
            return "Newly-taken snapshot's data could not be loaded."
        }
        if memcmp(oldData, newerData, byteCount) == 0 { return nil }
        if precision >= 1, perceptualPrecision >= 1 {
            return "Newly-taken snapshot does not match reference."
        }
        if perceptualPrecision < 1, #available(iOS 11.0, tvOS 11.0, *) {
            return perceptuallyCompare(
                CIImage(cgImage: oldCgImage),
                CIImage(cgImage: newCgImage),
                pixelPrecision: precision,
                perceptualPrecision: perceptualPrecision
            )
        } else {
            let byteCountThreshold = Int((1 - precision) * Float(byteCount))
            var differentByteCount = 0
            for offset in 0..<byteCount {
                if oldBytes[offset] != newerBytes[offset] {
                    differentByteCount += 1
                }
            }
            if differentByteCount > byteCountThreshold {
                let actualPrecision = 1 - Float(differentByteCount) / Float(byteCount)
                return "Actual image precision \(actualPrecision) is less than required \(precision)"
            }
        }
        return nil
    }

    func perceptuallyCompare(
        _ old: CIImage, _ new: CIImage, pixelPrecision: Float, perceptualPrecision: Float
    ) -> String? {
        let deltaOutputImage = old.applyingFilter("CILabDeltaE", parameters: ["inputImage2": new])
        let thresholdOutputImage: CIImage
        do {
            thresholdOutputImage = try ThresholdImageProcessorKernel.apply(
                withExtent: new.extent,
                inputs: [deltaOutputImage],
                arguments: [
                    ThresholdImageProcessorKernel.inputThresholdKey: (1 - perceptualPrecision) * 100
                ]
            )
        } catch {
            return "Newly-taken snapshot's data could not be loaded. \(error)"
        }
        var averagePixel: Float = 0
        let context = CIContext(options: [.workingColorSpace: NSNull(), .outputColorSpace: NSNull()])
        context.render(
            thresholdOutputImage.applyingFilter(
                "CIAreaAverage", parameters: [kCIInputExtentKey: new.extent]),
            toBitmap: &averagePixel,
            rowBytes: MemoryLayout<Float>.size,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .Rf,
            colorSpace: nil
        )
        let actualPixelPrecision = 1 - averagePixel
        guard actualPixelPrecision < pixelPrecision else { return nil }
        var maximumDeltaE: Float = 0
        context.render(
            deltaOutputImage.applyingFilter("CIAreaMaximum", parameters: [kCIInputExtentKey: new.extent]),
            toBitmap: &maximumDeltaE,
            rowBytes: MemoryLayout<Float>.size,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .Rf,
            colorSpace: nil
        )
        let actualPerceptualPrecision = 1 - maximumDeltaE / 100
        if pixelPrecision < 1 {
            return """
        Actual image precision \(actualPixelPrecision) is less than required \(pixelPrecision)
        Actual perceptual precision \(actualPerceptualPrecision) is less than required \(perceptualPrecision)
        """
        } else {
            return "Actual perceptual precision \(actualPerceptualPrecision) is less than required \(perceptualPrecision)"
        }
    }

    private func context(for cgImage: CGImage, data: UnsafeMutableRawPointer? = nil) -> CGContext? {
        let bytesPerRow = cgImage.width * imageContextBytesPerPixel
        guard
            let colorSpace = imageContextColorSpace,
            let context = CGContext(
                data: data,
                width: cgImage.width,
                height: cgImage.height,
                bitsPerComponent: imageContextBitsPerComponent,
                bytesPerRow: bytesPerRow,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            )
        else { return nil }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
        return context
    }
}
