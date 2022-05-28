# ZEGOCLOUD easy example
<p align="center">
    <a href="https://github.com/ZEGOCLOUD/easy_example_android/releases"><img src="https://img.shields.io/github/downloads/ZEGOCLOUD/easy_example_android/total" alt="Platform"/></a>
    <a href="https://discord.gg/EtNRATttyp">
        <img src="https://img.shields.io/discord/980014613179555870?color=5865F2&logo=discord&logoColor=white" alt="ZEGOCLOUD"/>
    </a>
    <p>
    <p>Click the search button below to search documentation or error code</p>
    <a href="https://docs.zegocloud.com/">
        <img width="589" alt="image" src="https://user-images.githubusercontent.com/5242852/170823639-2a684b4c-0bad-445a-b04e-5d4b6912e900.png">
    </a>
    </p>
</p>

ZEGOCLOUD's easy example is a simple wrapper around our RTC product. You can refer to the sample code for quick integration.

## Getting started

### Prerequisites

* [Xcode 12 or later](https://developer.apple.com/xcode/download)
* [CocoaPods](https://guides.cocoapods.org/using/getting-started.html#installation)
* An iOS device or Simulator that is running on iOS 13.0 or later and supports audio and video. We recommend you use a real device.
* Create a project in [ZEGOCLOUD Admin Console](https://console.zegocloud.com/). For details, see [ZEGO Admin Console - Project management](https://docs.zegocloud.com/article/1271).

###  Install Pods
1. Clone the easy example Github repository. 
2. Open Terminal, navigate to the `ZegoEasyExample` folder where the `Podfile` is located, and run the `pod repo update` command.
3. Run the `pod install` command to install all dependencies that are needed.

### Modify the project configurations
![](media/16496764650900/16497329091614.png)
You need to modify `appID` and `serverSecret` to your own account, which can be obtained in the [ZEGO Admin Console](https://console.zegocloud.com/).

### Run the sample code

1. Connect the iOS device to your computer.

2. Open Xcode, click the **Any iOS Device** in the upper left corner, select the iOS device you are using.

3. Click the **Build** button in the upper left corner to run the sample code and experience the Live Audio Room service.

## Integrate the SDK into your own project

### Introduce SDK
1 add `ZegoExpressEngine` and `ZegoToken` SDK in your project 
2 Run the `pod install` command to install all dependencies that are needed.
```swift
target 'Your_Project_Name' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ZegoEasyExample
  pod 'ZegoExpressEngine'
  pod ‘ZegoToken’

end
```
### Copy the source code
Copy the `AppCenter.swift` and `ZegoExpressManager.swift` files to your project
![](media/16496764650900/16496772462634.png)

### Method call
The calling sequence of the SDK interface is as follows:
createEngine --> joinRoom --> setLocalVideoView/setRemoteVideoView --> leaveRoom

#### Create engine
Before using the SDK function, you need to create the SDK first. We recommend creating it when the application starts. The sample code is as follows:
```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // create engine
        ZegoExpressManager.shared.createEngine(appID: AppCenter.appID)
        return true
    }
```

#### Join room
When you want to communicate with audio and video, you need to call the join room interface first. According to your business scenario, you can set different audio and video controls through options, such as:

1. call scene：[.autoPlayVideo, .autoPlayAudio, .publishLocalAudio, .publishLocalVideo]
2. Live scene - host: [.autoPlayVideo, .autoPlayAudio, .publishLocalAudio, .publishLocalVideo]
3. Live scene - audience:[.autoPlayVideo, .autoPlayAudio]
4. Chat room - host:[.autoPlayAudio, .publishLocalAudio]
5. Chat room - audience:[.autoPlayAudio]

The following sample code is an example of a call scenario:
```swift
    @IBAction func joinLiveAsHostClick(_ sender: UIButton) {
        // host join room
        let roomID = "111"
        let user = ZegoUser(userID: "id\(Int(arc4random()))", userName: "Tim")
        let token = generateToken(userID: user.userID)
        let option: ZegoMediaOptions = [.autoPlayVideo, .autoPlayAudio, .publishLocalAudio, .publishLocalVideo]
        ZegoExpressManager.shared.joinRoom(roomID: roomID, user: user, token: token, options: option)
        presentLiveVC(true, hostID: user.userID)
    }
```


```swift
	@IBAction func joinLiveAsAudienceClick(_ sender: UIButton) {
		//audience  join room
    let roomID = "111"
    let user = ZegoUser(userID: "id\(Int(arc4random()))", userName: "Tom")
    let token = generateToken(userID: user.userID)
    let option: ZegoMediaOptions = [.autoPlayVideo, .autoPlayAudio]
    ZegoExpressManager.shared.joinRoom(roomID: roomID, user: user, token: token, options: option)
    presentLiveVC(false, hostID: nil)
  }
```
   

#### set room extraInfo

If you're the host, you need to set hostID

```swift
func onRoomStateUpdate(_ state: ZegoRoomState, errorCode: Int32, extendedData: [AnyHashable : Any]?, roomID: String) {
   if state == .connected {
      if memberType == .host {
        ZegoExpressManager.shared.setRoomExtraInfo("hostID", value: ZegoExpressManager.shared.localParticipant?.userID ?? "")
      }
   }
}
```



You need to send a mic message if you want a mic

```swift
@IBAction func takeSeatClick(_ sender: UIButton) {
  	  ZegoExpressManager.shared.setRoomExtraInfo("coHostID", value: 			  ZegoExpressManager.shared.localParticipant?.userID ?? "")
      ZegoExpressManager.shared.setLocalVideoView(renderView: speakerPreviewView)
      ZegoExpressManager.shared.enableCamera(enable: true)
      ZegoExpressManager.shared.enableMic(enable: true)
}
```



#### set video view

If your project needs to use the video communication function, you need to set the View for displaying the video, call `setLocalVideoView` for the local video, and call `setRemoteVideoView` for the remote video.

**setLocalVideoView:**

```swift
enum LiveMembersType: Int {
    case host
    case speaker
    case listener
}

var memberType: LiveMembersType = .host

override func viewDidLoad() {
     super.viewDidLoad()
     if memberType == .host {
        // set video view
        ZegoExpressManager.shared.setLocalVideoView(renderView: hostPreviewView)
     }
}
```

**setRemoteVideoView:**

```swift
func onRoomUserUpdate(udpateType: ZegoUpdateType, userList: [String], roomID: String) {
        for userID in userList {
            // set video view
            if userID == hostID && memberType != .host {
                ZegoExpressManager.shared.setRemoteVideoView(userID: userID, renderView: hostPreviewView)
        }
     }
 }
```



```swift
var hostID: String?
var coHostID: String = ""

func onRoomExtraInfoUpdate(_ roomExtraInfoList: [ZegoRoomExtraInfo], roomID: String) {
    for roomExtraInfo in roomExtraInfoList {
      if roomExtraInfo.key == "hostID" {
       if memberType != .host {
       hostID = roomExtraInfo.value
       ZegoExpressManager.shared.setRemoteVideoView(userID: hostID ?? "", renderView: hostPreviewView)
        }
      } else if roomExtraInfo.key == "coHostID" {
        coHostID = roomExtraInfo.value
        if coHostID.count > 0 {
          ZegoExpressManager.shared.setRemoteVideoView(userID: coHostID, renderView: speakerPreviewView)
        } 
      }
   }
}
```



#### leave room

When you want to leave the room, you can call the leaveroom interface.
```swift
@IBAction func pressLeaveRoomButton(_ sender: Any) {
    ZegoExpressManager.shared.leaveRoom()
    self.dismiss(animated: true, completion: nil)
}
```
