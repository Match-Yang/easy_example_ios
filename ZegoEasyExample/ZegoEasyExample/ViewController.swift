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
    
    var userID: String?
    var fcmToken: String?
    var callData: [AnyHashable : Any]?
    
    @IBOutlet weak var callUserIDTextField: UITextField!
    
    @IBOutlet weak var getUserIDLabel: UILabel! {
        didSet {
            getUserIDLabel.isUserInteractionEnabled = true
            let tapClick: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(getUserIDLabelClick))
            getUserIDLabel.addGestureRecognizer(tapClick)
        }
    }
    
    @objc func getUserIDLabelClick() {
        userID = "\(Int(arc4random() % 999999))"
        getUserIDLabel.text = userID
        sendFcmToken()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func sendFcmToken() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        guard let userID = userID,
              let fcmToken = appDelegate.fcmToken
        else {
            return
        }
        var request = FcmTokenRequest()
        request.userID = userID
        request.token = fcmToken
        NetworkManager.shareManage.send(request) { requestStatus in
            if requestStatus?.ret != 0 {
                print("send fcm token fail!")
            }
        }
    }
    
    @IBAction func callUser(_ sender: UIButton) {
        guard let userID = userID,
              let callUserID = callUserIDTextField.text
        else {
            print("userID & callUserID is nil")
            return
        }
        var request = CallUserRequest()
        request.targetUserID = callUserID
        request.callerUserID = userID
        request.callerUserName = "asdasd"
        request.callerIconUrl = "qwe"
        request.roomID = "001"
        request.callType = "Voice"
        NetworkManager.shareManage.send(request) { requestStatus in
            if requestStatus?.ret == 0 {
                let roomID = "001"
                let user = ZegoUser(userID:userID, userName:("\(userID)Test"))
                let token = self.generateToken(userID: user.userID)
                let option: ZegoMediaOptions = [.autoPlayAudio, .publishLocalAudio]
                ZegoExpressManager.shared.joinRoom(roomID: roomID, user: user, token: token, options: option)
                self.presentVC(.voice)
            }
        }
    }
    
    
    @IBAction func videoCallClick(_ sender: UIButton) {
        guard let userID = userID,
              let callUserID = callUserIDTextField.text
        else {
            print("userID & callUserID is nil")
            return
        }
        var request = CallUserRequest()
        request.targetUserID = callUserID
        request.callerUserID = userID
        request.callerUserName = "asdasd"
        request.callerIconUrl = "qwe"
        request.roomID = "001"
        request.callType = "Video"
        NetworkManager.shareManage.send(request) { requestStatus in
            if requestStatus?.ret == 0 {
                // join room
                let roomID = "001"
                let user = ZegoUser(userID:userID, userName:("\(userID)Test"))
                let token = self.generateToken(userID: user.userID)
                let option: ZegoMediaOptions = [.autoPlayVideo, .autoPlayAudio, .publishLocalAudio, .publishLocalVideo]
                ZegoExpressManager.shared.joinRoom(roomID: roomID, user: user, token: token, options: option)
                self.presentVC(.video)
            }
        }
    }
    
    
    func presentVC(_ callType: CallType){
        let callVC = CallViewController.loadCallVC(callType)
        self.modalPresentationStyle = .fullScreen
        callVC.modalPresentationStyle = .fullScreen
        
        // set handler
        ZegoExpressManager.shared.handler = callVC
        self.present(callVC, animated: true, completion: nil)
    }
    
    // !!! When your app is ready to go live, remember not to generate the Token on your client; Otherwise, there is a risk of the ServerSecret being exposed!!!
    func generateToken(userID: String) -> String {
        let tokenResult = ZegoToken.generate(AppCenter.appID, userID: userID, secret: AppCenter.serverSecret)
        return tokenResult.token
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        callUserIDTextField.endEditing(true)
    }
}

extension ViewController: CallAcceptTipViewDelegate {
    func tipViewDeclineCall(callType: CallType) {
        
    }
    
    func tipViewAcceptCall(callType: CallType) {
        guard let userID = userID else { return }
        let roomID = "001"
        let user = ZegoUser(userID:userID, userName:("\(userID)Test"))
        let token = self.generateToken(userID: user.userID)
        var option: ZegoMediaOptions?
        if callType == .video {
            option = [.autoPlayVideo, .autoPlayAudio, .publishLocalAudio, .publishLocalVideo]
        } else {
            option = [.autoPlayAudio, .publishLocalAudio]
        }
        ZegoExpressManager.shared.joinRoom(roomID: roomID, user: user, token: token, options: option)
        self.presentVC(callType)
    }
    
    func tipViewDidClik(callType: CallType) {
        
    }
}

