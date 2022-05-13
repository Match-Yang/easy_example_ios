//
//  CallViewController.swift
//  ZegoExpressDemo
//
//  Created by Larry on 2022/3/26.
//

import UIKit
import ZegoToken
import ZegoExpressEngine

class CallViewController: UIViewController {

    @IBOutlet weak var localVideoView: UIView! {
        didSet {
            localVideoView.isHidden = callType == .video ? false : true
        }
    }
    @IBOutlet weak var remoteVideoView: UIView! {
        didSet {
            remoteVideoView.isHidden = callType == .video ? false : true
        }
    }
    @IBOutlet weak var cameraButton: UIButton! {
        didSet {
            cameraButton.isHidden = callType == .video ? false : true
        }
    }
    @IBOutlet weak var micButton: UIButton!
    
    var callType: CallType = .voice
    
    static func loadCallVC(_ callType: CallType) -> CallViewController {
        let callVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CallViewController") as! CallViewController
        callVC.callType = callType
        return callVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        // configUI
        cameraButton.setImage(UIImage(named: "call_camera_close_icon"), for: .selected)
        cameraButton.setImage(UIImage(named: "call_camera_open_icon"), for: .normal)
        micButton.setImage(UIImage(named: "call_mic_close"), for: .selected)
        micButton.setImage(UIImage(named: "call_mic_open"), for: .normal)
        
        // set video view
        if callType == .video {
            ZegoExpressManager.shared.setLocalVideoView(renderView: localVideoView)
        }
    }
    
    @IBAction func pressHangUpButton(_ sender: UIButton) {
        ZegoExpressManager.shared.leaveRoom()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pressCameraButton(_ sender: UIButton) {
        ZegoExpressManager.shared.enableCamera(enable: sender.isSelected)
        localVideoView.isHidden = !sender.isSelected
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func pressMicButton(_ sender: UIButton) {
        ZegoExpressManager.shared.enableMic(enable: sender.isSelected)
        sender.isSelected = !sender.isSelected
    }
}

extension CallViewController: ZegoExpressManagerHandler {
    func onRoomExtraInfoUpdate(_ roomExtraInfoList: [ZegoRoomExtraInfo], roomID: String) {
            
    }
    
    func onRoomStateUpdate(_ state: ZegoRoomState, errorCode: Int32, extendedData: [AnyHashable : Any]?, roomID: String) {
        
    }
    
    func onRoomUserUpdate(udpateType: ZegoUpdateType, userList: [String], roomID: String) {
        for userID in userList {
            // set video view
            if callType == .video {
                ZegoExpressManager.shared.setRemoteVideoView(userID:userID, renderView: remoteVideoView)
            }
        }
    }
    
    func onRoomUserDeviceUpdate(updateType: ZegoDeviceUpdateType, userID: String, roomID: String) {
        if callType == .video {
            if userID == ZegoExpressManager.shared.localParticipant?.userID {
                localVideoView.isHidden = updateType != .cameraOpen
            } else {
                remoteVideoView.isHidden = updateType != .cameraOpen
            }
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
