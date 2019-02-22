//
//  ViewController.swift
//  BattleBombers
//
//  Created by Franky Aguilar on 2/21/19.
//  Copyright © 2019 Franky Aguilar. All rights reserved.
//

import UIKit
import QRCode

class ViewController: UIViewController {
    
    @IBOutlet var ibo_qrImage:UIImageView?
    @IBOutlet weak var ibo_balance:UILabel?
    @IBOutlet weak var ibo_publicKey:UILabel?
    var keystorePass = "Password"
    

    override func viewDidLoad() {
        super.viewDidLoad()
        

        do {
            if EtherWallet.account.hasAccount == false {
                try EtherWallet.account.generateAccount(password: keystorePass)
            }
            
            let qrCode = QRCode(EtherWallet.account.address!)
            self.ibo_publicKey?.text = EtherWallet.account.address!
            print(EtherWallet.account.address!)
            ibo_qrImage?.image = qrCode!.image
            
            self.iba_updateWalletBalance()
            
        } catch {
            print(error)
        }
    }
    
    func iba_updateWalletBalance() {
        let balance = try? EtherWallet.balance.etherBalanceSync()
        self.ibo_balance?.text = balance
    }
    
    @IBAction func iba_sendETH() {
        
        do {
             let tx = try EtherWallet.transaction.sendEtherSync(
                toAddress: "0x6E0671CF0CD4245cdEE202ed658f9fCf6093d38d",
                amount: "0.001",
                password: keystorePass)
            print(tx)
        } catch {
            print(error)
        }
        
       
        
    }


}

