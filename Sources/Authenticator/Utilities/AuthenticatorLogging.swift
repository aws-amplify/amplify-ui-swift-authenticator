//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify

protocol AuthenticatorLogging {
    static var log: Logger { get }
    var log: Logger { get }
}

extension AuthenticatorLogging {
    static var log: Logger {
        var category = String(describing: self)
        if let index = category.firstIndex(of: "<") {
            category = String(category.prefix(upTo: index))
        }

        return Amplify.Logging.logger(forCategory: category)
    }

    var log: Logger {
        type(of: self).log
    }
}
