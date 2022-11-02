//
//  ViewController.swift
//  ZegoEasyExample
//
//  Created by Larry on 2022/4/8.
//

import UIKit
import ZegoExpressEngine

class ViewController: UIViewController {
    
    @IBOutlet weak var tipsLabel: UILabel!
    @IBOutlet weak var userIDTextField: UITextField!
    @IBOutlet weak var roomIDTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userIDTextField.text = "id\(Int(arc4random()))"
        // Do any additional setup after loading the view.
    }
    
    @IBAction func pressJoinRoom(_ sender: UIButton) {
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
        let option: ZegoMediaOptions = [.autoPlayVideo, .autoPlayAudio, .publishLocalAudio, .publishLocalVideo]
        ZegoExpressManager.shared.joinRoom(roomID: roomID, user: user, options: option)
        
        presentVideoVC()
    }
    
    @IBAction func pressStartAudioCall(_ sender: UIButton) {
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
        let option: ZegoMediaOptions = [.autoPlayAudio, .publishLocalAudio]
        ZegoExpressManager.shared.joinRoom(roomID: roomID, user: user, options: option)
        
        presentAudioVC()
    }
    
    
    
    func presentVideoVC(){
        let callVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CallViewController") as! CallViewController
        self.modalPresentationStyle = .fullScreen
        callVC.modalPresentationStyle = .fullScreen
        
        // set handler
        ZegoExpressManager.shared.handler = callVC
        self.present(callVC, animated: true, completion: nil)
    }
    
    func presentAudioVC(){
        let audioCallVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AudioCallViewController") as! AudioCallViewController
        self.modalPresentationStyle = .fullScreen
        audioCallVC.modalPresentationStyle = .fullScreen
        
        // set handler
        ZegoExpressManager.shared.handler = audioCallVC
        self.present(audioCallVC, animated: true, completion: nil)
    }
}

