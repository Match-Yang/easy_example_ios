//
//  LiveRoomVC.swift
//  ZegoEasyExample
//
//  Created by zego on 2022/5/9.
//

import UIKit
import ZegoExpressEngine

enum LiveMembersType: Int {
    case host
    case speaker
    case listener
}

class LiveRoomVC: UIViewController {
    
    @IBOutlet weak var hostPreviewView: UIView!
    @IBOutlet weak var speakerPreviewView: UIView! {
        didSet {
            speakerPreviewView.isHidden = true
        }
    }
    
    @IBOutlet weak var handUpButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton! {
        didSet {
            cameraButton.setImage(UIImage.init(named: "call_camera_open_icon"), for: .selected)
            cameraButton.setImage(UIImage.init(named: "call_camera_close_icon"), for: .normal)
            cameraButton.isSelected = ZegoExpressManager.shared.localParticipant?.camera ?? false
        }
    }
    @IBOutlet weak var micButton: UIButton! {
        didSet {
            micButton.setImage(UIImage(named: "call_mic_open"), for: .selected)
            micButton.setImage(UIImage(named: "call_mic_close"), for: .normal)
            micButton.isSelected = ZegoExpressManager.shared.localParticipant?.mic ?? false
        }
    }
    
    @IBOutlet weak var takeSeatButton: UIButton! {
        didSet {
            takeSeatButton.isHidden = memberType == .host ? true : false
        }
    }
    
    @IBOutlet weak var bottomView: UIView! {
        didSet {
            bottomView.isHidden = memberType == .listener ? true : false
        }
    }
    
    
    var memberType: LiveMembersType = .host
    var hostID: String?
    var coHostID: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if memberType == .host {
            // set video view
            ZegoExpressManager.shared.setLocalVideoView(renderView: hostPreviewView)
        }
    }
    
    static func loadLiveRoomVC(_ memberType: LiveMembersType, hostID: String?) -> UIViewController {
        let liveRoomVC: LiveRoomVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LiveRoomVC") as! LiveRoomVC
        liveRoomVC.memberType = memberType
        liveRoomVC.hostID = hostID
        return liveRoomVC
    }
    
    @IBAction func handupClick(_ sender: UIButton) {
        if memberType == .speaker {
            ZegoExpressManager.shared.setRoomExtraInfo("coHostID", value: "")
        }
        ZegoExpressManager.shared.leaveRoom()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cameraClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        ZegoExpressManager.shared.enableCamera(enable: sender.isSelected)
    }
    
    @IBAction func micClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        ZegoExpressManager.shared.enableMic(enable: sender.isSelected)
    }
    
    @IBAction func takeSeatClick(_ sender: UIButton) {
        if memberType == .listener {
            if coHostID.count > 0 { return }
            memberType = .speaker
            ZegoExpressManager.shared.setRoomExtraInfo("coHostID", value: ZegoExpressManager.shared.localParticipant?.userID ?? "")
            ZegoExpressManager.shared.setLocalVideoView(renderView: speakerPreviewView)
            ZegoExpressManager.shared.enableCamera(enable: true)
            ZegoExpressManager.shared.enableMic(enable: true)
            cameraButton.isSelected = true
            micButton.isSelected = true
            speakerPreviewView.isHidden = false
        } else if memberType == .speaker {
            memberType = .listener
            ZegoExpressManager.shared.setRoomExtraInfo("coHostID", value:"")
            ZegoExpressManager.shared.enableCamera(enable: false)
            ZegoExpressManager.shared.enableMic(enable: false)
            speakerPreviewView.isHidden = true
        }
        bottomView.isHidden = memberType == .listener ? true : false
    }
    
    
}

extension LiveRoomVC: ZegoExpressManagerHandler {
    func onRoomUserUpdate(udpateType: ZegoUpdateType, userList: [String], roomID: String) {
        for userID in userList {
            // set video view
            if userID == hostID && memberType != .host {
                ZegoExpressManager.shared.setRemoteVideoView(userID: userID, renderView: hostPreviewView)
            }
        }
    }
    
    func onRoomUserDeviceUpdate(updateType: ZegoDeviceUpdateType, userID: String, roomID: String) {
        
    }
    
    func onRoomTokenWillExpire(_ remainTimeInSecond: Int32, roomID: String) {
        
    }
    
    func onRoomExtraInfoUpdate(_ roomExtraInfoList: [ZegoRoomExtraInfo], roomID: String) {
        for roomExtraInfo in roomExtraInfoList {
            if roomExtraInfo.key == "hostID" {
                hostID = roomExtraInfo.value
                if hostID == ZegoExpressManager.shared.localParticipant?.userID {
                    ZegoExpressManager.shared.setLocalVideoView(renderView: hostPreviewView)
                } else {
                    ZegoExpressManager.shared.setRemoteVideoView(userID: hostID ?? "", renderView: hostPreviewView)
                }
            } else if roomExtraInfo.key == "coHostID" {
                coHostID = roomExtraInfo.value
                if coHostID.count > 0 {
                    speakerPreviewView.isHidden = false
                    if coHostID == ZegoExpressManager.shared.localParticipant?.userID {
                        ZegoExpressManager.shared.setLocalVideoView(renderView: speakerPreviewView)
                    } else {
                        ZegoExpressManager.shared.setRemoteVideoView(userID: coHostID, renderView: speakerPreviewView)
                    }
                } else {
                    speakerPreviewView.isHidden = true
                }
            }
        }
    }
    
    func onRoomStateUpdate(_ state: ZegoRoomState, errorCode: Int32, extendedData: [AnyHashable : Any]?, roomID: String) {
        if state == .connected {
            if memberType == .host {
                ZegoExpressManager.shared.setRoomExtraInfo("hostID", value: ZegoExpressManager.shared.localParticipant?.userID ?? "")
            }
        }
    }
    
    
}
