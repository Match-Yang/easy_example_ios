//
//  HomeVC.swift
//  ZegoEasyExample
//
//  Created by zego on 2022/5/9.
//

import UIKit
import ZegoExpressEngine
import ZegoToken

class HomeVC: UIViewController {
    
    @IBOutlet weak var roomIDTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    @IBAction func joinLiveAsHostClick(_ sender: UIButton) {
        // join room
        joinRoom(true)
        presentLiveVC(true, hostID: ZegoExpressManager.shared.localParticipant?.userID)
        
    }
    
    @IBAction func joinLiveAsAudienceClick(_ sender: UIButton) {
        // join room
        joinRoom(false)
        presentLiveVC(false, hostID: nil)
    }
    
    func joinRoom(_ isHost: Bool) {
        let roomID = roomIDTextField.text ?? ""
        let userID = generateUserID()
        let user = ZegoUser(userID:userID, userName:("\(userID)Test"))
        let token = generateToken(userID: user.userID)
        let option: ZegoMediaOptions = isHost ? [.autoPlayVideo, .autoPlayAudio, .publishLocalAudio, .publishLocalVideo] : [.autoPlayVideo, .autoPlayAudio]
        ZegoExpressManager.shared.joinRoom(roomID: roomID, user: user, token: token, options: option)
    }
    
    func presentLiveVC(_ isHost: Bool, hostID: String?){
        let liveVC: LiveRoomVC = LiveRoomVC.loadLiveRoomVC(isHost ? .host : .listener, hostID: hostID) as! LiveRoomVC
        self.modalPresentationStyle = .fullScreen
        liveVC.modalPresentationStyle = .fullScreen
        
        // set handler
        ZegoExpressManager.shared.handler = liveVC
        self.present(liveVC, animated: true, completion: nil)
    }
    
    // !!! When your app is ready to go live, remember not to generate the Token on your client; Otherwise, there is a risk of the ServerSecret being exposed!!!
    func generateToken(userID: String) -> String {
        let tokenResult = ZegoToken.generate(AppCenter.appID, userID: userID, secret: AppCenter.serverSecret)
        return tokenResult.token
    }
    
    func generateUserID() -> String {
        let timeInterval:TimeInterval = Date().timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        return String(format: "%d", timeStamp)
    }

}
