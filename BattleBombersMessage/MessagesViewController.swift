//
//  MessagesViewController.swift
//  BattleBombersMessage
//
//  Created by Franky Aguilar on 2/22/19.
//  Copyright © 2019 Franky Aguilar. All rights reserved.
//

import UIKit
import Messages
import QRCode
import SpriteKit

class MessagesViewController: MSMessagesAppViewController, GameSceneProtocol {
    
    @IBOutlet weak var ibo_qrCode:UIImageView?
    @IBOutlet weak var ibo_publicKey:UILabel?
    var keystorePass = "Password"
    
    var gameScene:GameScene?
    @IBOutlet var ibo_gameScene:SKView?
    @IBOutlet var ibo_gameInstructions:UILabel?
    @IBOutlet var ibo_actionView:UIView?
    @IBOutlet var ibo_actionButton:UIButton?
    
    var gameJoin: Bool = false
    var session:MSSession?
    
    var opponentAddress:String!
    var sessionURL:URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupWallet()
        
        if let scene = GameScene(fileNamed: "GameScene") {
            self.gameScene = scene
            self.gameScene?.protocolDelegate = self
            self.ibo_gameScene?.presentScene(scene)
        }
    }
    
    func setupWallet() {
        do {
            if EtherWallet.account.hasAccount == false {
                try EtherWallet.account.generateAccount(password: keystorePass)
            }
            
            let qrCode = QRCode(EtherWallet.account.address!)
            self.ibo_publicKey?.text = EtherWallet.account.address!
            ibo_qrCode?.image = qrCode!.image
        } catch {
            print(error)
        }
    }

    
    @IBAction func iba_gameAction(sender:UIButton) {
        switch sender.tag {
        case 0:
            self.requestPresentationStyle(.expanded)
            self.ibo_gameInstructions?.text = "Tap to Hide 4 Bombs"
        case 1:
            self.iba_submitMove()
        default:
            print("default")
        }
    }
    
    func did_FinishSettingUpGame() {
        self.requestPresentationStyle(.compact)
        self.ibo_actionButton!.setTitle("Send", for: .normal)
        self.ibo_actionButton!.tag = 1
    }
    
    func did_WinGame() {
        let alert = UIAlertController(title: "I won + 0.01 ETH", message: "Time to get paid", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action) in
            self.sendMessageWithSummary(string: "I Won, Pay Up!", won: true)
        }))
        self.present(alert, animated: true) { }
    }
    
    func did_loseGame() {
        
        let alert = UIAlertController(title: "You Lost - 0.01 ETH", message: "Better luck next time", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action) in
            
            do {
                let tx = try EtherWallet.transaction.sendEtherSync(
                    toAddress: self.opponentAddress,
                    amount: "0.01",
                    password: self.keystorePass)
                print(tx)
                self.sendMessageWithSummary(string: "I lost, heres your ETH", won: true)

            } catch {
                print(error)
            }
            
        }))
        self.present(alert, animated: true) { }
    }
    
    func resetGame() {
        self.ibo_actionButton!.setTitle("New Game", for: .normal)
        self.ibo_actionButton!.tag = 0
        self.ibo_actionButton?.isHidden = true
        self.gameJoin = false
        self.gameScene?.resetGame()
    }

    
    override func willBecomeActive(with conversation: MSConversation) {
        self.ibo_gameScene?.alpha = 0
        self.ibo_actionView?.alpha = 1
        
        if !self.gameJoin {
            self.ibo_actionButton!.setTitle("New Game", for: .normal)
            self.ibo_actionButton!.tag = 0
        }
        
        //RESUME GAME
        if let messageURL = conversation.selectedMessage?.url {
            print(messageURL)
            self.sessionURL = messageURL
            self.ibo_gameInstructions?.text = "Find the Bufficorn"
            self.session = conversation.selectedMessage?.session
            self.gameJoin = true
            self.opponentAddress = self.getQueryStringParameter(url: messageURL.absoluteString, param: "publicAddress")
            self.gameScene?.loadGameState(loadState: messageURL.absoluteString)
            
        } else {
            //
        }
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
    
    //SEND MESSAGE SUMMARY
    func sendMessageWithSummary(string:String, won: Bool) {
        self.requestPresentationStyle(.compact)
        self.resetGame()
        
        if won {
            
        } else {
            
        }
        
        let layout = MSMessageTemplateLayout()
        layout.caption = string
        layout.subcaption = "0.01 ETH"
        let message = MSMessage(session: self.session!)
        message.url = nil
        message.layout = layout
        message.summaryText = "Game Over"
        self.activeConversation!.insert(message) { error in
            if let error = error {
                print(error)
            }
        }
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
    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dissmises the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }
   
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
    
        // Use this to clean up state related to the deleted message.
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
//        if presentationStyle == MSMessagesAppPresentationStyle.expanded {
//            self.ibo_gameScene?.alpha = 1
//            self.ibo_actionView?.alpha = 0
//        }
//
        if presentationStyle == MSMessagesAppPresentationStyle.compact {
            self.ibo_gameScene?.alpha = 0
            self.ibo_actionView?.alpha = 1
        }
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        if presentationStyle == MSMessagesAppPresentationStyle.expanded {
            self.ibo_gameScene?.alpha = 1
            self.ibo_actionView?.alpha = 0
        }
        
        if presentationStyle == MSMessagesAppPresentationStyle.compact {
            self.ibo_gameScene?.alpha = 0
            self.ibo_actionView?.alpha = 1
        }
    }
    
    //HELPER
    func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }

}
