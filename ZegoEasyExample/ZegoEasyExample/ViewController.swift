//
//  ViewController.swift
//  ZegoEasyExample
//
//  Created by Larry on 2022/4/8.
//

import UIKit
import ZegoExpressEngine
import ZegoToken

class ViewController: UIViewController {
    
    @IBOutlet weak var tipsLabel: UILabel!
    @IBOutlet weak var userIDTextField: UITextField!
    @IBOutlet weak var roomIDTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userIDTextField.text = "uid\(Int(arc4random()))"
        roomIDTextField.text = "roomid\(Int(UInt32.random(in: 0...1000)))"
        // Do any additional setup after loading the view.
    }

    
    @IBAction func pressProducerJoinButton(_ sender: UIButton) {
        let isProducer = true
        joinRoom(isProducer)
    }
    
    @IBAction func pressDirectorJoinButton(_ sender: UIButton) {
        let isProducer = false
        joinRoom(isProducer)
    }
    
    func joinRoom(_ isProducer: Bool){
        if userIDTextField.text?.count == 0 {
            tipsLabel.text = "Please enter a userID"
            return
        }
        
        if roomIDTextField.text?.count == 0 {
            tipsLabel.text = "Please enter a userID"
            return
        }
        
        // join room
        let roomID = roomIDTextField.text ?? ""
        let userID = userIDTextField.text ?? ""
        let user = ZegoUser(userID:userID, userName:("\(userID)Test"))
        let token = generateToken(userID: user.userID)
        if(isProducer){
            let option: ZegoMediaOptions = [ .autoPlayAudio, .publishLocalAudio, .publishLocalVideo, .custom_isProducer]
            ZegoExpressManager.shared.joinRoom(roomID: roomID, user: user, token: token, options: option)
        }else{
            let option: ZegoMediaOptions = [.autoPlayVideo, .autoPlayAudio, .publishLocalAudio]
            ZegoExpressManager.shared.joinRoom(roomID: roomID, user: user, token: token, options: option)
        }
        presentVideo(isProducer)
    }
    func presentVideo(_ isProducer: Bool){
        let callVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CallViewController") as! CallViewController
        self.modalPresentationStyle = .fullScreen
        callVC.modalPresentationStyle = .fullScreen
        callVC.isProducer = isProducer
        
        // set handler
        ZegoExpressManager.shared.handler = callVC
        self.present(callVC, animated: true, completion: nil)
    }
    
    // !!! When your app is ready to go live, remember not to generate the Token on your client; Otherwise, there is a risk of the ServerSecret being exposed!!!
    func generateToken(userID: String) -> String {
        let tokenResult = ZegoToken.generate(AppCenter.appID, userID: userID, secret: AppCenter.serverSecret)
        return tokenResult.token
    }
}

