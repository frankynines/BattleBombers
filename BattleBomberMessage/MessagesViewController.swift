//
//  MessagesViewController.swift
//  BattleBomberMessage
//
//  Created by Franky Aguilar on 2/14/19.
//  Copyright © 2019 Franky Aguilar. All rights reserved.
//

import UIKit
import Messages
import Celer
import QRCode
import SpriteKit

class MessagesViewController: MSMessagesAppViewController, GameSceneProtocol ,CelerGroupClientCallback {
   
    @IBOutlet weak var ibo_qrCode:UIImageView?
    @IBOutlet weak var ibo_publicKey:UILabel?

    var ibo_explosion:UIImageView?
    var gameScene:GameScene?
    var currentPlayer = "1"
    private var stake: String = "0"
    private let keystorePass = " "

    @IBOutlet var ibo_spriteView:SKView?
    var session:MSSession?
    
    @IBOutlet var ibo_networkStatus:UILabel?
    @IBOutlet var ibo_gameID:UILabel?

    var gameSessionID:String?
    var gameJoin: Bool = false
    var playerAddress:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupWallet()

        if let scene = GameScene(fileNamed: "GameScene") {
            self.gameScene = scene
            self.gameScene?.protocolDelegate = self
            self.ibo_spriteView?.presentScene(scene)
        }
        
        print("View Did Load")
        //self.iba_initializeCeler()
        
    }
    
    override func willBecomeActive(with conversation: MSConversation) {

        if let messageURL = conversation.selectedMessage?.url {
            self.session = conversation.selectedMessage?.session
            print(messageURL)
            self.gameJoin = true
            self.playerAddress = self.getQueryStringParameter(url: messageURL.absoluteString, param: "publicAddress")
            self.gameScene?.loadGameState(loadState: messageURL.absoluteString)
           // self.iba_initializeCeler()
        } else {
            //
        }
    }
    func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
//    @IBAction func iba_checkCelerBalance() {
//        let networkBalance = CelerClientAPIHelper.shared.checkBalance()
//    }
    
    func setupWallet() {
        do {
            if EtherWallet.account.hasAccount == false {
                try EtherWallet.account.generateAccount(password: keystorePass)
            }
            
            let qrCode = QRCode(EtherWallet.account.address!)
            self.ibo_publicKey?.text = EtherWallet.account.address!
            ibo_qrCode?.image = qrCode!.image
            self.updateBalance()
        } catch {
            print(error)
        }
    }
    
    func updateBalance() {
        let balance = try? EtherWallet.balance.etherBalanceSync()
        self.ibo_networkStatus?.text = balance
    }

    func prepareUrl(state: [String:Any]) -> URL {
        var urlComponents = URLComponents()
        
        urlComponents.queryItems = []
        let item = URLQueryItem(
            name: "publicAddress",
            value:EtherWallet.account.address!)
        urlComponents.queryItems?.append(item)
        
        for item in state {

            let item = URLQueryItem(name: item.key, value:(item.value as! String))
            urlComponents.queryItems?.append(item)
        }
        return urlComponents.url!
    }
    
    func iba_submitMove() {
        if !(self.session != nil) {
            self.session = MSSession()
        }
        let savedStateArray = self.gameScene?.saveGameStates()
        let gameURL = prepareUrl(state:savedStateArray!)
        let layout = MSMessageTemplateLayout()
        layout.image = UIImage(named: "bomb.png")
        layout.caption = "Let's play battle bombers"
        layout.subcaption = "Can you find the Bufficorn?"
        let message = MSMessage(session: session!)
        message.url = gameURL
        message.layout = layout

        self.activeConversation!.insert(message) { error in
            if let error = error {
                print(error)
            }
        }
        self.dismiss()
    }
    
    func did_FinishSettingUpGame() {
        print("GAME READY")
        self.iba_submitMove()
    }
    
    func did_loseGame() {
        print("MOVE FINISH")
        let alert = UIAlertController(title: "You Lost - 0.1 ETH", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action) in
            EtherWallet.transaction.sendEther(to: self.playerAddress!, amount: "0.1", password: " ", completion: { (stunt) in
                //
            })
        }))
        self.present(alert, animated: true) {
            self.sendMessageWithSummary(string: "I Lost, Heres your Eth!")
            print("I lost")
        }
    }
    
    func did_WinGame() {
        let alert = UIAlertController(title: "You Won!", message: "You found the Bufficorn", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action) in
            self.sendMessageWithSummary(string: "I won, Pay Up!")
            print("I won")
        }))
        self.present(alert, animated: true) {
        
        }
    }
    
    func sendMessageWithSummary(string:String) {
        let layout = MSMessageTemplateLayout()
        
        let message = MSMessage(session: session!)
        message.layout = layout
        message.summaryText = string
        print("sumtext", message);
        
self.presentationStyle = 
//        self.dismiss()
    }

    //CELER GOODIES
    private var groupClient: CelerGroupClient? = nil

    //01
    func iba_initializeCeler() {
        let keystore = KeystoreHelper.shared.returnKeystore()
        
        CelerClientAPIHelper.shared.initCelerClient(
            keyStoreString: keystore,
            password: keystorePass
        ) { (done) in
            if done {
                self.joinCelerNetwork()
            } else {
                self.ibo_networkStatus?.text = "FAILED"
            }
        }
    }
    //02
    func joinCelerNetwork() {
            CelerClientAPIHelper.shared.joinCeler(
                clientSideDepositAmount: "0.1",
                serverSideDepositAmount: "0.1") { (done) in
                    if done {
                        self.ibo_networkStatus?.text = "Status: Connected"
                        self.createCelerGame()
                    } else {
                        self.ibo_networkStatus?.text = "Status: ERROR"
                    }
            }
    }
    //03
    func createCelerGame() {
        
        self.initializeGameClient { (done) in
            //
            groupClient?.createGameFrom(userAddress: EtherWallet.account.address!, withStake: "0.1", forNumberOfPlayers: 2, errorHandler: { (error) in
                print(error)
            })
        }
        
    }
    //04
    func  initializeGameClient(completion: (_ results: Bool) ->()) {
        let keystore = KeystoreHelper.shared.returnKeystore()
        
        groupClient = CelerGroupClient(
            serverAdress: "group-hack-ropsten.celer.app:10001",
            keystoreJSON: keystore,
            password:keystorePass) { error in
                
                DispatchQueue.main.async {
                    print(error.localizedDescription)
                }
        }
        groupClient?.delegate = self
    }
    
    
    func joinGame() {
        
//        groupClient?.joinGame(
//            userAddress: EtherWallet.account.address!,
//            withGameCode: Int(self.joinGameSessionID!)!,
//            withStake: "0.1") { error in
//        }
    }
    
    func onSuccess(_ response: CelerGroupResponse) {
        
        if (response.getUsers().components(separatedBy: ",").count == 2) {
            DispatchQueue.main.async {
                print(response)
            }
        } else {
            DispatchQueue.main.async {
                self.stake = response.getStake()
                self.gameSessionID = String(response.getGameCode())
                self.ibo_gameID?.text = String(response.getGameCode())
                if (self.gameJoin) {
                    //self.ibo_gameID?.text = self.joinGameSessionID
                    //self.joinGame()
                }
            }
        }
    }
    
    func onFailure(_ error: Error, _ description: String) {
        DispatchQueue.main.async {
            print("ERROR", error.localizedDescription)
        }
    }

}
