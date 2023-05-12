//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import Foundation

extension Logger {
    func error(_ error: Error) {
        self.error(error: error)
        self.error(String(reflecting: error))
    }
    
    func verbose(_ error: Error) {
        self.verbose(String(reflecting: error))
    }
}
