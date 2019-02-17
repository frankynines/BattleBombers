//
//  ViewController.swift
//  BattleBombs
//
//  Created by Franky Aguilar on 2/14/19.
//  Copyright © 2019 Franky Aguilar. All rights reserved.
//

import UIKit
import Foundation
import Celer
import QRCode
import Celer

class HomeViewController: UIViewController, CelerGroupClientCallback {
    
    @IBOutlet weak var ibo_qrCode:UIImageView?
    @IBOutlet weak var ibo_balance:UILabel?
    @IBOutlet weak var ibo_publicKey:UILabel?
    
    //Celer
    @IBOutlet weak var ibo_networkStatus:UILabel?
    @IBOutlet weak var ibo_networkBalance:UILabel?
    
    private let clientSideDepositAmount = "1"
    private let serverSideDepositAmount = "1"
    private let keystorePass = " "
    
    private var groupClient: CelerGroupClient? = nil
    private var stake: String = "0"
    
    private var celerGameID:String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ibo_networkStatus?.text = "Status: Not connected"
        do {
            if EtherWallet.account.hasAccount == false {
                try EtherWallet.account.generateAccount(password: keystorePass)
            }
            
            let qrCode = QRCode(EtherWallet.account.address!)
            self.ibo_publicKey?.text = EtherWallet.account.address!
            print(EtherWallet.account.address)
            ibo_qrCode?.image = qrCode!.image
            
            self.updateWalletBalance()
            
        } catch {
            print(error)
        }
        
    }
    
    func updateWalletBalance() {
        let balance = try? EtherWallet.balance.etherBalanceSync()
        self.ibo_balance?.text = balance
    }
    
    @IBAction func iba_initializeCeler() {
        let keystore = KeystoreHelper.shared.returnKeystore()
       
        CelerClientAPIHelper.shared.initCelerClient(
            keyStoreString: keystore,
            password: keystorePass
        ) { (done) in
            if done {
                self.joinCelerNetwork()
                
            } else {
                print("FAILED")
            }
        }
        self.iba_checkCelerBalance()
    }
    
    func joinCelerNetwork() {
        DispatchQueue.main.async {
            CelerClientAPIHelper.shared.joinCeler(
                clientSideDepositAmount: self.clientSideDepositAmount,
                serverSideDepositAmount: self.serverSideDepositAmount) { (done) in
                    if done {
                        self.ibo_networkStatus?.text = "Status: Connected"
                        self.iba_createCelerGame()
                    } else {
                        self.ibo_networkStatus?.text = "Status: ERROR"
                    }
            }
        }
       
    }
    
    @IBAction func iba_checkCelerBalance() {
        let networkBalance = CelerClientAPIHelper.shared.checkBalance()
        self.ibo_networkBalance?.text = networkBalance.0
        
    }
    
    
    
    @IBAction func iba_createCelerGame() {
        initializeGameClient()
        
        groupClient?.createGameFrom(userAddress: EtherWallet.account.address!, withStake: clientSideDepositAmount, forNumberOfPlayers: 2, errorHandler: { (error) in
                print(error)
        
        })

    }
    
    func  initializeGameClient() {
        let keystore = KeystoreHelper.shared.returnKeystore()
        groupClient = CelerGroupClient(
        serverAdress: "group-hack-ropsten.celer.app:10001",
        keystoreJSON: keystore,
        password:keystorePass) { error in
        
            DispatchQueue.main.async {
                print(error.localizedDescription)
            }
        }
        groupClient?.delegate = self as! CelerGroupClientCallback
    }
    
   func joinGame() {
    
        groupClient?.joinGame(
        userAddress: EtherWallet.account.address!,
        withGameCode: Int(self.celerGameID!)!,
        withStake: clientSideDepositAmount) { error in
        }
    }
    
    func onSuccess(_ response: CelerGroupResponse) {
        
        if (response.getUsers().components(separatedBy: ",").count == 2) {
            DispatchQueue.main.async {
                print(response)
            }
        } else {
            DispatchQueue.main.async {
                self.stake = response.getStake()
                self.celerGameID = String(response.getGameCode())
            }
        }
    }
    
    func onFailure(_ error: Error, _ description: String) {
        DispatchQueue.main.async {
            print("ERROR", error.localizedDescription)
        }
    }
    
}



