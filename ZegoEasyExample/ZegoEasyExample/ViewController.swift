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
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    @IBAction func pressJoinRoom(_ sender: UIButton) {
        let roomID = "111"
        let user = ZegoUser(userID: "id\(Int(arc4random()))", userName: "larry")
        let token = generateToken(userID: user.userID)
        let option: ZegoMediaOptions = [.autoPlayVideo, .autoPlayAudio, .publishLocalAudio, .publishLocalVideo]
        self.presentVideoVC()
        ZegoExpressManager.shared.joinRoom(roomID: roomID, user: user, token: token, options: option)
    }
    
    func presentVideoVC(){
        let callVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CallViewController") as! CallViewController
        self.modalPresentationStyle = .fullScreen
        callVC.modalPresentationStyle = .fullScreen
        ZegoExpressManager.shared.handler = callVC
        self.present(callVC, animated: true, completion: nil)
    }
    
    // !!! When your app is ready to go live, remember not to generate the Token on your client; Otherwise, there is a risk of the ServerSecret being exposed!!!
    func generateToken(userID: String) -> String {
        let tokenResult = ZegoToken.generate(AppCenter.appID, userID: userID, secret: AppCenter.serverSecret)
        return tokenResult.token
    }
}

