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

class MessagesViewController: MSMessagesAppViewController, GameSceneProtocol {
   
   
    @IBOutlet weak var ibo_qrCode:UIImageView?
    @IBOutlet weak var ibo_publicKey:UILabel?

    var ibo_explosion:UIImageView?
    var gameScene:GameScene?
    var currentPlayer = "1"
    
    @IBOutlet var ibo_spriteView:SKView?
    var session:MSSession?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.iba_createWallet()
        if let scene = GameScene(fileNamed: "GameScene") {
            // Set the scale mode to scale to fit the window
            self.gameScene = scene
            self.gameScene?.protocolDelegate = self
            self.ibo_spriteView?.presentScene(scene)
        }
    }
    
    func didChangeState() {
        print("Changed")
    }
    
    @IBAction func iba_createWallet() {
        do {
            if EtherWallet.account.hasAccount == false {
                try EtherWallet.account.generateAccount(password: "")
            }
            
            let qrCode = QRCode(EtherWallet.account.address!)
            self.ibo_publicKey?.text = EtherWallet.account.address!
            ibo_qrCode?.image = qrCode!.image
            
        } catch {
            print(error)
        }
    }
    
    @IBAction func iba_plantBomb(sender:UIButton){
        sender.setImage(UIImage(named: "plot_plant.png"), for: .normal)
    
    }
    
    func prepareUrl(state: [String:Any]) -> URL {
        var urlComponents = URLComponents()
        
        urlComponents.queryItems = []
        
        for item in state {

            let item = URLQueryItem(name: item.key, value:(item.value as! String))
            urlComponents.queryItems?.append(item)
        }
//        print("URL: ", urlComponents.url!)
        return urlComponents.url!
    }
    
    @IBAction func iba_submitMove() {
        let savedStateArray = self.gameScene?.saveGameStates()

        
        let gameURL = prepareUrl(state:savedStateArray!)
    
        let layout = MSMessageTemplateLayout()
        layout.image = UIImage(named: "bomb.png")
        layout.caption = "Let's play battle bombers"
        layout.subcaption = "Can you find the Bufficorn?"
        let message = MSMessage()
        message.url = gameURL
        message.layout = layout

        self.activeConversation!.insert(message) { error in
            if let error = error {
                print(error)
            }
        }

        self.dismiss()
    }
    
    func getScreenshot(scene: SKScene) -> UIImage {
        let snapshotView = self.ibo_spriteView!.snapshotView(afterScreenUpdates: true)
        let bounds = self.ibo_spriteView?.bounds
        
        UIGraphicsBeginImageContextWithOptions(bounds!.size, false, 0)
        snapshotView?.drawHierarchy(in: bounds!, afterScreenUpdates: true)
        let screenshotImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return screenshotImage;
    }
    
    func did_FinishSettingUpGame() {
        print("GAME READY")
        self.iba_submitMove()
    }
    
    func did_loseGame() {
        print("MOVE FINISH")
        let alert = UIAlertController(title: "You Lost", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action) in
            
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
        
        let message = MSMessage()
        message.layout = layout
        message.summaryText = string
        print("sumtext", message);
        
        self.activeConversation!.insert(message) { error in
            if let error = error {
                print(error)
            }
        }
        
        self.dismiss()
    }
    
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        
        if let messageURL = conversation.selectedMessage?.url {
            print(messageURL)
            self.gameScene?.loadGameState(loadState: messageURL.absoluteString)
        } else {
            
            //NEW GAME
        }
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
        // Called before the extension transitions to a new presentation style.
    
        // Use this method to prepare for the change in presentation style.
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
    
        // Use this method to finalize any behaviors associated with the change in presentation style.
    }

}
