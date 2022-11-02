//
//  CallViewController.swift
//  ZegoExpressDemo
//
//  Created by Larry on 2022/3/26.
//

import UIKit
import ZegoExpressEngine

class CallViewController: UIViewController {

    @IBOutlet weak var localVideoView: UIView!
    @IBOutlet weak var remoteVideoView: UIView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var micButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        // configUI
        cameraButton.setImage(UIImage(named: "call_camera_close_icon"), for: .selected)
        cameraButton.setImage(UIImage(named: "call_camera_open_icon"), for: .normal)
        micButton.setImage(UIImage(named: "call_mic_close"), for: .selected)
        micButton.setImage(UIImage(named: "call_mic_open"), for: .normal)
        
        // set video view
        ZegoExpressManager.shared.setLocalVideoView(renderView: localVideoView)
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
            ZegoExpressManager.shared.setRemoteVideoView(userID:userID, renderView: remoteVideoView)
        }
    }

    func onRoomUserDeviceUpdate(updateType: ZegoDeviceUpdateType, userID: String, roomID: String) {
        if (updateType == .micMute || updateType == .micUnmute){
            return
        }

        if userID == ZegoExpressManager.shared.localParticipant?.userID {
            localVideoView.isHidden = updateType != .cameraOpen
        } else {
            remoteVideoView.isHidden = updateType != .cameraOpen
        }
    }

}
