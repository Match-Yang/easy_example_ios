//
//  ZegoExpressManager.swift
//  ZegoExpressDemo
//
//  Created by Larry on 2022/3/26.
//

import Foundation
import ZegoExpressEngine

class ZegoParticipant: NSObject {
    let userID: String
    var name: String = ""
    var streamID: String = ""
    var renderView: UIView = UIView()
    var camera: Bool = false
    var mic: Bool = false
    var network: ZegoStreamQualityLevel = .excellent
    
    init(userID: String, name: String = "") {
        self.userID = userID
        self.name = name
        super.init()
    }
    
}

struct ZegoMediaOptions: OptionSet {
    let rawValue: Int
    static let autoPlayAudio = ZegoMediaOptions(rawValue: 1)
    static let autoPlayVideo = ZegoMediaOptions(rawValue: 2)
    static let publishLocalAudio = ZegoMediaOptions(rawValue: 4)
    static let publishLocalVideo = ZegoMediaOptions(rawValue: 8)
}

enum ZegoDeviceUpdateType {
    case cameraOpen
    case cameraClose
    case micUnmute
    case micMute
}

protocol ZegoExpressManagerHandler: AnyObject {
    
    func onRoomUserUpdate(udpateType: ZegoUpdateType, userList: [String], roomID: String)
    
    func onRoomUserDeviceUpdate(updateType: ZegoDeviceUpdateType, userID: String, roomID: String)
    
    func onRoomTokenWillExpire(_ remainTimeInSecond: Int32, roomID: String)
    
}

class ZegoExpressManager : NSObject {
    // key is UserID, value is participant model
    var participantDic: Dictionary<String, ZegoParticipant> = Dictionary()
    // key is streamID, value is participant model
    weak var handler: ZegoExpressManagerHandler?
    var localParticipant: ZegoParticipant?
    
    private var streamDic: Dictionary<String, ZegoParticipant> = Dictionary()
    private var roomID: String = ""
    private var mediaOption: ZegoMediaOptions = [.autoPlayAudio, .autoPlayVideo]
    
    static let shared = ZegoExpressManager()
    
    private override init() {
        super.init()
    }
    
    func createEngine(appID: UInt32) {
        let profile = ZegoEngineProfile()
        profile.appID = appID
        // if your scenario is live,you can change to .live.
        // if your scenrio is communication , you can change to .communication
        profile.scenario = .general
        ZegoExpressEngine.createEngine(with: profile, eventHandler: self)
    }
    
    func joinRoom(roomID: String, user:ZegoUser, token: String, options: ZegoMediaOptions?) {
        participantDic.removeAll()
        streamDic.removeAll()
        if (token.count == 0) {
            print("Error: [joinRoom] token is empty, please enter a right token")
        }
        
        self.roomID = roomID
        
        let participant = ZegoParticipant(userID: user.userID, name: user.userName)
        participant.streamID = generateStreamID(userID: participant.userID, roomID: roomID)
        if let options = options {
            self.mediaOption = options
        }
        
        participantDic[participant.userID] = participant
        streamDic[participant.streamID] = participant
        localParticipant = participant
        
        
        let config = ZegoRoomConfig()
        config.token = token
        // if you need limit participant count, you can change the max member count
        config.maxMemberCount = 0
        config.isUserStatusNotify = true
        ZegoExpressEngine.shared().loginRoom(roomID, user: user, config: config)
        
        if (mediaOption.contains(.publishLocalAudio) || mediaOption.contains(.publishLocalVideo)) {
            ZegoExpressEngine.shared().startPublishingStream(participant.streamID)
            ZegoExpressEngine.shared().enableCamera(mediaOption.contains(.publishLocalVideo))
            ZegoExpressEngine.shared().muteMicrophone(!mediaOption.contains(.publishLocalAudio))
            participant.camera = mediaOption.contains(.publishLocalVideo)
            participant.mic = mediaOption.contains(.publishLocalAudio)
        }
    }
    
    func setLocalVideoView(renderView: UIView) {
        if (roomID.count == 0) {
            print("Error: [setVideoView] You need to join the room first and then set the videoView")
        }
        guard let userID = localParticipant?.userID else {
            print("Error: [setVideoView] please login room pre")
            return
        }
        
        let participant = participantDic[userID] ?? ZegoParticipant(userID: userID)
        participant.streamID = generateStreamID(userID: userID, roomID: roomID)
        participant.renderView = renderView
        participantDic[userID] = participant
        streamDic[participant.streamID] = participant
        ZegoExpressEngine.shared().startPreview(generateCanvas(rendView: renderView))
    }
    
    func setRemoteVideoView(userID: String, renderView: UIView) {
        if (roomID.count == 0) {
            print("Error: [setVideoView] You need to join the room first and then set the videoView")
        }
        if (userID.count == 0) {
            print("Error: [setVideoView] userID is empty, please enter a right userID")
        }
        let participant = participantDic[userID] ?? ZegoParticipant(userID: userID)
        participant.streamID = generateStreamID(userID: userID, roomID: roomID)
        participant.renderView = renderView
        participantDic[userID] = participant
        streamDic[participant.streamID] = participant
        playStream(streamID: participant.streamID)
    }
    
    func enableCamera(enable: Bool) {
        ZegoExpressEngine.shared().enableCamera(enable)
        localParticipant?.camera = enable
    }
    
    func enableMic(enable: Bool) {
        ZegoExpressEngine.shared().muteMicrophone(!enable)
        localParticipant?.mic = enable
    }
    
    func switchFrontCamera(isFront: Bool) {
        ZegoExpressEngine.shared().useFrontCamera(isFront)
    }
    
    func leaveRoom() {
        participantDic.removeAll()
        streamDic.removeAll()
        ZegoExpressEngine.shared().logoutRoom()
    }
    
    private func playStream(streamID: String) {
        if (mediaOption.contains(.autoPlayVideo) || mediaOption.contains(.autoPlayAudio)) {
            let participant = streamDic[streamID]
            ZegoExpressEngine.shared().startPlayingStream(streamID, canvas: generateCanvas(rendView: participant?.renderView))
            if (!mediaOption.contains(.autoPlayAudio)) {
                ZegoExpressEngine.shared().mutePlayStreamAudio(true, streamID: streamID)
            }
            if (!mediaOption.contains(.autoPlayVideo)) {
                ZegoExpressEngine.shared().mutePlayStreamVideo(true, streamID: streamID)
            }
            print("Error: [playStream] \(streamID)")
        }
    }
    
    private func generateStreamID(userID: String, roomID: String) -> String {
        if (userID.count == 0) {
            print("Error: [generateStreamID] userID is empty, please enter a right userID")
        }
        if (roomID.count == 0) {
            print("Error: [generateStreamID] roomID is empty, please enter a right roomID")
        }
        
        // The streamID can use any character.
        // For the convenience of query, roomID + UserID + suffix is used here.
        let streamID = roomID + userID + "_main"
        return streamID
    }
    
    private func generateCanvas(rendView: UIView?) -> ZegoCanvas? {
        guard let rendView = rendView else {
            return nil
        }

        let canvas = ZegoCanvas(view: rendView)
        canvas.viewMode = .aspectFill
        return canvas
    }
}

extension ZegoExpressManager: ZegoEventHandler {
    func onRoomStreamUpdate(_ updateType: ZegoUpdateType, streamList: [ZegoStream], roomID: String) {
        for stream in streamList {
            if updateType == .add {
                playStream(streamID: stream.streamID)
            } else {
                ZegoExpressEngine.shared().stopPlayingStream(stream.streamID)
            }
        }
    }
    
    func onRoomUserUpdate(_ updateType: ZegoUpdateType, userList: [ZegoUser], roomID: String) {
        var userIDList = [String]()
        print("[onRoomUserUpdate]: state:\(updateType.rawValue) userList:\(userList.description)")
        for user in userList {
            userIDList.append(user.userID)
            if updateType == .add {
                let participant = ZegoParticipant(userID: user.userID, name: user.userName)
                participant.streamID = generateStreamID(userID: participant.userID, roomID: roomID)
                participantDic[participant.userID] = participant
                streamDic[participant.streamID] = participant
            } else {
                if let participant = participantDic[user.userID] {
                    participantDic.removeValue(forKey: user.userID)
                    streamDic.removeValue(forKey: participant.streamID)
                }
            }
        }
        
        handler?.onRoomUserUpdate(udpateType: updateType, userList: userIDList, roomID: roomID)
    }
    
    func onRemoteCameraStateUpdate(_ state: ZegoRemoteDeviceState, streamID: String) {
        if let participant = streamDic[streamID] {
            participant.camera = state == .open
            let type: ZegoDeviceUpdateType = state == .open ? .cameraOpen : .cameraClose
            handler?.onRoomUserDeviceUpdate(updateType: type, userID: participant.userID, roomID: roomID)
        }
    }
    
    func onRemoteMicStateUpdate(_ state: ZegoRemoteDeviceState, streamID: String) {
        if let participant = streamDic[streamID] {
            participant.mic = state == .open
            let type: ZegoDeviceUpdateType = state == .open ? .micUnmute : .micMute
            handler?.onRoomUserDeviceUpdate(updateType: type, userID: participant.userID, roomID: roomID)
        }
    }
    
    func onRoomStateUpdate(_ state: ZegoRoomState, errorCode: Int32, extendedData: [AnyHashable : Any]?, roomID: String) {
        processLog(methodName: "onRoomStateUpdate", state: Int32(state.rawValue), errorCode: errorCode)
    }
    
    func onPublisherStateUpdate(_ state: ZegoPublisherState, errorCode: Int32, extendedData: [AnyHashable : Any]?, streamID: String) {
        processLog(methodName: "onPublisherStateUpdate", state: Int32(state.rawValue), errorCode: errorCode)
    }
    
    func onPlayerStateUpdate(_ state: ZegoPlayerState, errorCode: Int32, extendedData: [AnyHashable : Any]?, streamID: String) {
        processLog(methodName: "onPublisherStateUpdate", state: Int32(state.rawValue), errorCode: errorCode)
    }
    
    func onNetworkQuality(_ userID: String, upstreamQuality: ZegoStreamQualityLevel, downstreamQuality: ZegoStreamQualityLevel) {
        guard let participant = participantDic[userID] else {
            return
        }
        if (userID == localParticipant?.userID) {
            participant.network = downstreamQuality
        } else {
            participant.network = upstreamQuality
        }
    }
    
    func onRoomTokenWillExpire(_ remainTimeInSecond: Int32, roomID: String) {
        handler?.onRoomTokenWillExpire(remainTimeInSecond, roomID: roomID)
    }
    
    private func processLog(methodName: String, state: Int32, errorCode: Int32) {
        var description = ""
        if (errorCode != 0) {
            description = "=======\n You can view the exact cause of the error through the link below \n https://docs.zegocloud.com/article/5547?w=\(errorCode)\n======="
        }
        print("[\(methodName)]: state:\(state) errorCode:\(errorCode)\n\(description)")
    }
}
