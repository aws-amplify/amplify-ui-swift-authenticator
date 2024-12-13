//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import Foundation

extension AuthError {
    var isConnectivityError: Bool {
        guard let error = underlyingError as? NSError else {
            return false
        }

        let networkErrorCodes = [
            NSURLErrorCannotFindHost,
            NSURLErrorCannotConnectToHost,
            NSURLErrorNetworkConnectionLost,
            NSURLErrorDNSLookupFailed,
            NSURLErrorNotConnectedToInternet
        ]
        return networkErrorCodes.contains(where: { $0 == error.code })
    }
}
