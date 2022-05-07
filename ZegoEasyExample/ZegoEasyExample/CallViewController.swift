//
//  CallViewController.swift
//  ZegoExpressDemo
//
//  Created by Larry on 2022/3/26.
//

import UIKit
import ZegoToken
import ZegoExpressEngine
import Photos
import VideoToolbox

class CallViewController: UIViewController {
    
    public var isHost = false
    var recordingUrl: URL!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var micButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        // configUI
        micButton.setImage(UIImage(named: "call_mic_close"), for: .selected)
        micButton.setImage(UIImage(named: "call_mic_open"), for: .normal)
        cameraBtn.setImage(UIImage(named: "call_camera_close"), for: .selected)
        cameraBtn.setImage(UIImage(named: "call_camera_open"), for: .normal)
        
        
        if  !isHost {
            cameraBtn.isHidden = true
            micButton.isHidden = true
        }
        // set video view
        if(isHost){
            ZegoExpressManager.shared.setLocalVideoView(renderView: videoView)
        }
    }

    @IBAction func pressExitButton(_ sender: UIButton) {
        ZegoExpressManager.shared.leaveRoom()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pressCameraButton(_ sender: UIButton) {
        ZegoExpressManager.shared.enableCamera(enable: sender.isSelected)
        videoView.isHidden = !videoView.isHidden;
        sender.isSelected = !sender.isSelected
    }
    
    
    
    @IBAction func pressMicButton(_ sender: UIButton) {
        ZegoExpressManager.shared.enableMic(enable: sender.isSelected)
        sender.isSelected = !sender.isSelected
    }
}

extension CallViewController: ZegoExpressManagerHandler {
    func onRoomUserUpdate(udpateType: ZegoUpdateType, userList: [String], roomID: String) {
        for userID in userList {
            // set video view
            ZegoExpressManager.shared.setRemoteVideoView(userID:userID, renderView: videoView)
        }
    }
    
    func onRoomUserDeviceUpdate(updateType: ZegoDeviceUpdateType, userID: String, roomID: String) {
        if userID == ZegoExpressManager.shared.localParticipant?.userID {
            
        } else {
           
        }
    }
 
    func onRoomTokenWillExpire(_ remainTimeInSecond: Int32, roomID: String) {
        let token = generateToken(userID: ZegoExpressManager.shared.localParticipant?.userID ?? "")
        ZegoExpressEngine.shared().renewToken(token, roomID: roomID)
    }
    
    // !!! When your app is ready to go live, remember not to generate the Token on your client; Otherwise, there is a risk of the ServerSecret being exposed!!!
    func generateToken(userID: String) -> String {
        let tokenResult = ZegoToken.generate(AppCenter.appID, userID: userID, secret: AppCenter.serverSecret)
        return tokenResult.token
    }
 
}

