//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import CoreImage.CIKernel
import MetalPerformanceShaders

// Copied from https://developer.apple.com/documentation/coreimage/ciimageprocessorkernel
@available(iOS 10.0, tvOS 10.0, macOS 10.13, *)
final class ThresholdImageProcessorKernel: CIImageProcessorKernel {
    static let inputThresholdKey = "thresholdValue"
    static let device = MTLCreateSystemDefaultDevice()

    override class func process(
        with inputs: [CIImageProcessorInput]?, arguments: [String: Any]?,
        output: CIImageProcessorOutput
    ) throws {
        guard
            let device = device,
            let commandBuffer = output.metalCommandBuffer,
            let input = inputs?.first,
            let sourceTexture = input.metalTexture,
            let destinationTexture = output.metalTexture,
            let thresholdValue = arguments?[inputThresholdKey] as? Float
        else {
            return
        }

        let threshold = MPSImageThresholdBinary(
            device: device,
            thresholdValue: thresholdValue,
            maximumValue: 1.0,
            linearGrayColorTransform: nil
        )

        threshold.encode(
            commandBuffer: commandBuffer,
            sourceTexture: sourceTexture,
            destinationTexture: destinationTexture
        )
    }
}
