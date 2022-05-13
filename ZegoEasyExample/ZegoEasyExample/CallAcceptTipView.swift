//
//  CallAcceptTipView.swift
//  ZEGOCallDemo
//
//  Created by zego on 2022/1/12.
//

import UIKit

enum CallType: Int {
    /// voice: voice call
    case voice = 1
    /// video: video call
    case video = 2
}

protocol CallAcceptTipViewDelegate: AnyObject {
    func tipViewDeclineCall(callType: CallType)
    func tipViewAcceptCall(callType: CallType)
    func tipViewDidClik(callType: CallType)
}

class CallAcceptTipView: UIView {
    
    @IBOutlet weak var headImage: UIImageView! {
        didSet {
            headImage.layer.masksToBounds = true
            headImage.layer.cornerRadius = 21
        }
    }
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    
    var tipType: CallType = .voice
    weak var delegate: CallAcceptTipViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapClick: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(viewTap))
        self.addGestureRecognizer(tapClick)
    }
    
    static func showTip(_ type:CallType) -> CallAcceptTipView {
        return showTipView(type)
    }
    
    static func showTipView(_ type: CallType) -> CallAcceptTipView {
        let tipView: CallAcceptTipView = UINib(nibName: "CallAcceptTipView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! CallAcceptTipView
        let y = KeyWindow().safeAreaInsets.top
        tipView.frame = CGRect.init(x: 8, y: y + 8, width: UIScreen.main.bounds.size.width - 16, height: 80)
        tipView.userNameLabel.text = "用户1"
        tipView.layer.masksToBounds = true
        tipView.layer.cornerRadius = 8
        tipView.headImage.image = UIImage(named: "pic_head_1")
        tipView.tipType = type
        switch type {
        case .voice:
            tipView.messageLabel.text = "EasyExample Voice Call"
            tipView.acceptButton.setImage(UIImage(named: "call_accept_icon"), for: .normal)
        case .video:
            tipView.messageLabel.text = "EasyExample Video Call"
            tipView.acceptButton.setImage(UIImage(named: "call_accept_icon"), for: .normal)
        }
        tipView.show()
        return tipView
    }
        
    static func dismiss() {
        DispatchQueue.main.async {
            for subview in KeyWindow().subviews {
                if subview is CallAcceptTipView {
                    let view: CallAcceptTipView = subview as! CallAcceptTipView
                    view.removeFromSuperview()
                }
            }
        }
    }
    
    private func show()  {
        CallAcceptTipView.KeyWindow().addSubview(self)
    }
    
    
    @IBAction func declineButtonClick(_ sender: UIButton) {
        delegate?.tipViewDeclineCall(callType: tipType)
        CallAcceptTipView.dismiss()
    }
    
    @IBAction func acceptButtonClick(_ sender: UIButton) {
        delegate?.tipViewAcceptCall(callType: tipType)
        CallAcceptTipView.dismiss()
    }
    
    @objc func viewTap() {
        delegate?.tipViewDidClik(callType: tipType)
        CallAcceptTipView.dismiss()
    }
    
    static func KeyWindow() -> UIWindow {
        let window: UIWindow = UIApplication.shared.windows.filter({ $0.isKeyWindow }).last!
        return window
    }
    
}
