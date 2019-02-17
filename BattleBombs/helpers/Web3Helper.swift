////
////  SharedStorageHelper.swift
////  BattleBombs
////
////  Created by Franky Aguilar on 2/15/19.
////  Copyright © 2019 Franky Aguilar. All rights reserved.
////
//
//import Foundation
//
//class Web3Helper {
//    public static let shared = Web3Helper()
//    let web3:Web3?
//    
//    let infuraURL = "https://ropsten.infura.io/v3/515c97cd80d74be4b77697ae4715d975"
//    
//    init() {
//        self.web3 = Web3(url: URL(string: "https://ropsten.infura.io/v3/515c97cd80d74be4b77697ae4715d975")!)
//    }
//    
//    func returnBalance(address:String) -> String{
//        guard let web3 = self.web3 else {
//            print("Web 3 Invalid")
//            return "ERROR"
//        }
//        
//        do {
//            let balanceResult =
//                try web3.eth.getBalance(address:
//                        Address(address, type: Address.AddressType.normal))
//            let format = Web3Utils.formatToEthereumUnits(balanceResult)
//            return format
//        } catch {
//            print(error)
//            return "0.00"
//        }
//            
//    }
//    
//    
//    
//}
