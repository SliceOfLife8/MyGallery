//
//  Encryption.swift
//  MyGallery
//
//  Created by Christos Petimezas on 2/7/21.
//

import Foundation
import CommonCrypto

protocol Randomizer {
    static func randomIv() -> Data
    static func randomSalt() -> Data
    static func randomData(length: Int) -> Data
}

protocol Crypter {
    func encrypt(_ digest: Data) throws -> Data
    func decrypt(_ encrypted: Data) throws -> Data
}

struct Encryption {
    
    private var key: Data
    private var iv: Data
    
    public init(key: Data, iv: Data) throws {
        guard key.count == kCCKeySizeAES256 else {
            throw Error.badKeyLength
        }
        guard iv.count == kCCBlockSizeAES128 else {
            throw Error.badInputVectorLength
        }
        self.key = key
        self.iv = iv
    }
    
    enum Error: Swift.Error {
        case keyGeneration(status: Int)
        case cryptoFailed(status: CCCryptorStatus)
        case badKeyLength
        case badInputVectorLength
    }
    
    private func crypt(input: Data, operation: CCOperation) throws -> Data {
        var outLength = Int(0)
        var outBytes = [UInt8](repeating: 0, count: input.count + kCCBlockSizeAES128)
        var status: CCCryptorStatus = CCCryptorStatus(kCCSuccess)
        input.withUnsafeBytes { (encryptedBytes: UnsafeRawBufferPointer!) -> () in
            iv.withUnsafeBytes { (ivBytes: UnsafeRawBufferPointer!) in
                key.withUnsafeBytes { (keyBytes: UnsafeRawBufferPointer!) -> () in
                    status = CCCrypt(operation,
                                     CCAlgorithm(kCCAlgorithmAES128),                       // algorithm
                                     CCOptions(kCCOptionPKCS7Padding),                      // options
                                     keyBytes.bindMemory(to: UInt8.self).baseAddress,       // key
                                     key.count,                                             // keylength
                                     ivBytes.bindMemory(to: UInt8.self).baseAddress,        // iv
                                     encryptedBytes.bindMemory(to: UInt8.self).baseAddress, // dataIn
                                     input.count,                                           // dataInLength
                                     &outBytes,                                             // dataOut
                                     outBytes.count,                                        // dataOutAvailable
                                     &outLength)                                            // dataOutMoved
                }
            }
        }
        guard status == kCCSuccess else {
            throw Error.cryptoFailed(status: status)
        }
        return Data(bytes: outBytes, count: outLength)
    }
    
    static func createKey(password: Data, salt: Data) throws -> Data {
        let length = kCCKeySizeAES256
        var status = Int32(0)
        var derivedBytes = [UInt8](repeating: 0, count: length)
        password.withUnsafeBytes { (passwordBytes: UnsafeRawBufferPointer!) in
            salt.withUnsafeBytes { (saltBytes: UnsafeRawBufferPointer!) in
                status = CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2),                          // algorithm
                                              passwordBytes.bindMemory(to: CChar.self).baseAddress, // password
                                              password.count,                                       // passwordLen
                                              saltBytes.bindMemory(to: UInt8.self).baseAddress,     // salt
                                              salt.count,                                           // saltLen
                                              CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA1),           // prf
                                              10000,                                                // rounds
                                              &derivedBytes,                                        // derivedKey
                                              length)                                               // derivedKeyLen
            }
        }
        guard status == 0 else {
            throw Error.keyGeneration(status: Int(status))
        }
        return Data(bytes: derivedBytes, count: length)
    }
    
}

extension Encryption: Crypter {
    
    func encrypt(_ digest: Data) throws -> Data {
        return try crypt(input: digest, operation: CCOperation(kCCEncrypt))
    }
    
    func decrypt(_ encrypted: Data) throws -> Data {
        return try crypt(input: encrypted, operation: CCOperation(kCCDecrypt))
    }
    
}

extension Encryption: Randomizer {
    
    static func randomIv() -> Data {
        return randomData(length: kCCBlockSizeAES128)
    }
    
    static func randomSalt() -> Data {
        return randomData(length: 8)
    }
    
    static func randomData(length: Int) -> Data {
        var data = Data(count: length)
        let status = data.withUnsafeMutableBytes { (rawMutableBufferPointer: UnsafeMutableRawBufferPointer) -> Int32 in
            guard let rawBytes = rawMutableBufferPointer.bindMemory(to: UInt8.self).baseAddress else {
                return Int32(kCCMemoryFailure)
            }
            return SecRandomCopyBytes(kSecRandomDefault, length, rawBytes)
        }
        /// #Deprecated way
        //let status = data.withUnsafeMutableBytes { mutableBytes in
        //SecRandomCopyBytes(kSecRandomDefault, length, mutableBytes)
        //}
        assert(status == Int32(0))
        return data
    }
    
}
