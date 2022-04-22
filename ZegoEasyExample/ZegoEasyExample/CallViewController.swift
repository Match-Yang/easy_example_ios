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
    
    public var isProducer = false
    var recordingUrl: URL!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var micButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        // configUI
        micButton.setImage(UIImage(named: "call_mic_close"), for: .selected)
        micButton.setImage(UIImage(named: "call_mic_open"), for: .normal)
        
//        recordButton.setImage(UIImage(named: "waves"), for: .normal)

        if isProducer {
//            micButton.isHidden = true
        }else{
            recordButton.isHidden = true
        }
        // set video view
        if(isProducer){
            ZegoExpressManager.shared.setLocalVideoView(renderView: videoView)
        }
    }
    
    @IBAction func onTapGestureRecognizerInPreview(_ sender: UITapGestureRecognizer) {
        
        let  point = sender.location(in: sender.view)
        
        let  x = point.x / (sender.view?.bounds.size.width ?? 0.5);
        let  y = point.y / (sender.view?.bounds.size.height ?? 0.5);
        
        ZegoExpressManager.express.setCameraFocusPointInPreviewX(Float(x), y: Float(y), channel: .main)
        ZegoExpressManager.express.setCameraExposurePointInPreviewX(Float(x), y: Float(y), channel: .main)
    }
    
    @IBAction func pressExitButton(_ sender: UIButton) {
        ZegoExpressManager.shared.leaveRoom()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pressRecordButton(_ sender: UIButton) {
        if(!sender.isSelected){
            recordingUrl = self.getDocumentFilepath(for: "Zegorecording.mp4")
            ZegoExpressManager.shared.startRecording(filePath: recordingUrl.absoluteString.replacingOccurrences(of: "file://", with: ""))
        }else{
            ZegoExpressManager.shared.stopRecording()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.saveInPhotoLibrary(self.recordingUrl)
            }
        }
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
    

    
    
    func getDocumentFilepath(for fileName: String) -> URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let path = documentDirectory.appendingPathComponent(fileName)
        print("\(path.absoluteString)")
        
        return path
    }
    
    private func saveInPhotoLibrary(_ url:URL){
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }, completionHandler: {(completed,error) in
            if completed {
                do {
                    try FileManager.default.removeItem(at: url.absoluteURL)
                    print("File Deleted From Document Directory")
                } catch {
                    print(error.localizedDescription)
                }
                print("save complete! path : " + url.absoluteString)
            } else {
                print("save failed. Error -> \(error?.localizedDescription ?? "")")
            }
        })
    }
}

