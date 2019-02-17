//
//  SharedStorageHelper.swift
//  BattleBombs
//
//  Created by Franky Aguilar on 2/15/19.
//  Copyright © 2019 Franky Aguilar. All rights reserved.
//

import Foundation
import Web3swift
import EthereumAddress
import SwiftKeychainWrapper

class KeystoreHelper {
    public static let shared = KeystoreHelper()
   
    init() {
    }
    
    func returnKeystore() -> String {
        
        let fileManager = FileManager.default
        let userDir = KeystoreHelper.shared.sharedContainerURL().path.appending("/keystore")

        do {
            
            let keystore = try fileManager.contentsOfDirectory(atPath: userDir).first
            let fileName = keystore
            let fullPathToKeystore = userDir.appending("/\(fileName!)")
            
            do {
                let raw = try String(contentsOf: URL(fileURLWithPath: fullPathToKeystore, isDirectory: false), encoding: .utf8)
                return raw.replacingOccurrences(of: "0x", with: "")
            } catch {
                print(error.localizedDescription)
                return ""
            }
        } catch {
            print(error.localizedDescription)
            return ""
        }
        
    }
   
    func sharedContainerURL() -> URL {
        let appGroupIdentifier = "group.Keystore"
        let fileManager = FileManager.default
        guard let groupURL = fileManager.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
                fatalError("Cannot Establish App Group")
        }
        
        let storagePathUrl = groupURL.appendingPathComponent("SharedKeystore")
        return storagePathUrl
    }
    
    func appGroupContainerURL() throws -> URL{
        let fileManager = FileManager.default
        
        let storagePath = self.sharedContainerURL()
        
        if !fileManager.fileExists(atPath: storagePath.path) {
            do {
                try fileManager.createDirectory(atPath: storagePath.path,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
            } catch {
                print(error)
                fatalError("error creating filepath")
            }
        }
        
        return storagePath
    }
    
    

}
