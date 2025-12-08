//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

@testable import Authenticator
import XCTest

class AuthFactorArrayExtensionTests: XCTestCase {
    
    // MARK: - containsPassword Tests
    
    func testContainsPassword_withPasswordSRP_shouldReturnTrue() {
        let factors: [AuthFactor] = [.emailOtp, .password(srp: true), .smsOtp]
        XCTAssertTrue(factors.containsPassword)
    }
    
    func testContainsPassword_withPasswordNonSRP_shouldReturnTrue() {
        let factors: [AuthFactor] = [.emailOtp, .password(srp: false), .smsOtp]
        XCTAssertTrue(factors.containsPassword)
    }
    
    func testContainsPassword_withoutPassword_shouldReturnFalse() {
        let factors: [AuthFactor] = [.emailOtp, .smsOtp, .webAuthn]
        XCTAssertFalse(factors.containsPassword)
    }
    
    func testContainsPassword_emptyArray_shouldReturnFalse() {
        let factors: [AuthFactor] = []
        XCTAssertFalse(factors.containsPassword)
    }
    
    // MARK: - preferredPasswordFactor Tests
    
    func testPreferredPasswordFactor_withBothPasswordTypes_shouldPreferSRP() {
        let factors: [AuthFactor] = [.password(srp: false), .password(srp: true), .emailOtp]
        let preferred = factors.preferredPasswordFactor
        
        XCTAssertNotNil(preferred)
        if case .password(let srp) = preferred {
            XCTAssertTrue(srp, "Should prefer password with SRP")
        } else {
            XCTFail("Expected password factor")
        }
    }
    
    func testPreferredPasswordFactor_withOnlyNonSRP_shouldReturnNonSRP() {
        let factors: [AuthFactor] = [.password(srp: false), .emailOtp]
        let preferred = factors.preferredPasswordFactor
        
        XCTAssertNotNil(preferred)
        if case .password(let srp) = preferred {
            XCTAssertFalse(srp, "Should return non-SRP password when SRP not available")
        } else {
            XCTFail("Expected password factor")
        }
    }
    
    func testPreferredPasswordFactor_withOnlySRP_shouldReturnSRP() {
        let factors: [AuthFactor] = [.password(srp: true), .emailOtp]
        let preferred = factors.preferredPasswordFactor
        
        XCTAssertNotNil(preferred)
        if case .password(let srp) = preferred {
            XCTAssertTrue(srp, "Should return SRP password")
        } else {
            XCTFail("Expected password factor")
        }
    }
    
    func testPreferredPasswordFactor_withNoPassword_shouldReturnNil() {
        let factors: [AuthFactor] = [.emailOtp, .smsOtp, .webAuthn]
        XCTAssertNil(factors.preferredPasswordFactor)
    }
    
    // MARK: - nonPasswordFactors Tests
    
    func testNonPasswordFactors_shouldExcludePassword() {
        let factors: [AuthFactor] = [.password(srp: true), .emailOtp, .smsOtp, .webAuthn]
        let nonPassword = factors.nonPasswordFactors
        
        XCTAssertEqual(nonPassword.count, 3)
        XCTAssertFalse(nonPassword.contains(where: { $0.isPassword }))
    }
    
    func testNonPasswordFactors_shouldBeSortedByPriority() {
        // Input in random order
        let factors: [AuthFactor] = [.emailOtp, .password(srp: true), .smsOtp, .webAuthn]
        let nonPassword = factors.nonPasswordFactors
        
        // Expected order: WebAuthn (1), SMS (2), Email (3)
        XCTAssertEqual(nonPassword.count, 3)
        XCTAssertEqual(nonPassword[0], .webAuthn)
        XCTAssertEqual(nonPassword[1], .smsOtp)
        XCTAssertEqual(nonPassword[2], .emailOtp)
    }
    
    func testNonPasswordFactors_withOnlyPassword_shouldReturnEmpty() {
        let factors: [AuthFactor] = [.password(srp: true), .password(srp: false)]
        let nonPassword = factors.nonPasswordFactors
        
        XCTAssertTrue(nonPassword.isEmpty)
    }
    
    // MARK: - isPassword Tests
    
    func testIsPassword_withPasswordSRP_shouldReturnTrue() {
        let factor = AuthFactor.password(srp: true)
        XCTAssertTrue(factor.isPassword)
    }
    
    func testIsPassword_withPasswordNonSRP_shouldReturnTrue() {
        let factor = AuthFactor.password(srp: false)
        XCTAssertTrue(factor.isPassword)
    }
    
    func testIsPassword_withEmailOtp_shouldReturnFalse() {
        let factor = AuthFactor.emailOtp
        XCTAssertFalse(factor.isPassword)
    }
    
    func testIsPassword_withSmsOtp_shouldReturnFalse() {
        let factor = AuthFactor.smsOtp
        XCTAssertFalse(factor.isPassword)
    }
    
    func testIsPassword_withWebAuthn_shouldReturnFalse() {
        let factor = AuthFactor.webAuthn
        XCTAssertFalse(factor.isPassword)
    }
    
    // MARK: - isPasswordWithSRP Tests
    
    func testIsPasswordWithSRP_withSRP_shouldReturnTrue() {
        let factor = AuthFactor.password(srp: true)
        XCTAssertTrue(factor.isPasswordWithSRP)
    }
    
    func testIsPasswordWithSRP_withoutSRP_shouldReturnFalse() {
        let factor = AuthFactor.password(srp: false)
        XCTAssertFalse(factor.isPasswordWithSRP)
    }
    
    func testIsPasswordWithSRP_withNonPassword_shouldReturnFalse() {
        XCTAssertFalse(AuthFactor.emailOtp.isPasswordWithSRP)
        XCTAssertFalse(AuthFactor.smsOtp.isPasswordWithSRP)
        XCTAssertFalse(AuthFactor.webAuthn.isPasswordWithSRP)
    }
    
    // MARK: - displayPriority Tests
    
    func testDisplayPriority_webAuthnShouldBeFirst() {
        XCTAssertEqual(AuthFactor.webAuthn.displayPriority, 1)
    }
    
    func testDisplayPriority_smsShouldBeSecond() {
        XCTAssertEqual(AuthFactor.smsOtp.displayPriority, 2)
    }
    
    func testDisplayPriority_emailShouldBeThird() {
        XCTAssertEqual(AuthFactor.emailOtp.displayPriority, 3)
    }
    
    func testDisplayPriority_passwordShouldBeLast() {
        XCTAssertEqual(AuthFactor.password(srp: true).displayPriority, 4)
        XCTAssertEqual(AuthFactor.password(srp: false).displayPriority, 4)
    }
}
