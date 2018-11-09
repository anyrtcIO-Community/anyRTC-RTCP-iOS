# anyRTC-RTCP-iOS

## 更新日志

2018年11月08日：</br>

修复观看实时直播几率崩溃问题

2018年11月08日：</br>

添加本地和远程的第一帧回调</br>

```
//本地视频第一帧
-(void)onRTCFirstLocalVideoFrame:(UIView*)videoView videoSize:(CGSize)size;

//远程视频第一帧
-(void)onRTCFirstRemoteVideoFrame:(UIView*)videoView videoSize:(CGSize)size;

//视频大小变化回调
- (void)onRTCVideoViewChanged:(UIView*)videoView didChangeVideoSize:(CGSize)size;
```

## 简介
anyRTC-RTCP-iOS实时直播，基于RTCPEngine SDK，实现快速实时直播，相比RTMPC更加快捷。</br>

## 安装
### 1、编译环境
Xcode 8以上</br>

### 2、运行环境
真机运行、iOS 8.0以上（建议最新）


## 导入SDK

### Cocoapods导入
```
pod 'RTCPEngine', '~> 1.0.8'
```
### 手动导入

1. 下载Demo，或者前往[anyRTC官网](https://www.anyrtc.io/resoure)下载SDK</br>
![list_directory](/image/list_directory.png)

2. 在Xcode中选择“Add files to 'Your project name'...”，将RTCPEngine.framework添加到你的工程目录中</br>

3.  打开General->Embedded Binaries中添加RTCPEngine.framework</br>


## 如何使用？

### 注册账号
登陆[AnyRTC官网](https://www.anyrtc.io/)

### 填写信息
创建应用，在管理中心获取开发者ID，AppID，AppKey，AppToken，替换AppDelegate.h中的相关信息

### 操作步骤：
1、一部手机开启直播，点击右上角复制按钮，将复制的内容发送给另一部手机；</br>

2、另一部手机复制，点击观看直播，粘贴复制的内容到输入框，开始观看直播。</br>

### 资源中心
 [更多详细方法使用，请查看API文档](https://www.anyrtc.io/resoure)

## 项目展示
![RTCP](/image/RTCP.gif)
## 扫描二维码下载demo
![RTCP](/image/RTCP.png)


## 支持的系统平台
**iOS** 8.0及以上

## 支持的CPU架构
**iOS** armv7 、arm64。  支持bitcode
## ipv6
苹果2016年6月新政策规定新上架app必须支持ipv6-only。该库已经适配
## Android版anyRTC-RTCP
[anyRTC-Meeting-Android](https://github.com/AnyRTC/anyRTC-RTCP-Android)
## 网页版anyRTC-RTCP
[anyRTC-RTCP-Web](https://www.anyrtc.io/demo/rtcp)


## 技术支持
anyRTC官方网址：https://www.anyrtc.io </br>
QQ技术交流群：554714720 </br>
联系电话:021-65650071-816 </br>
Email:hi@dync.cc </br>
## 关于直播
本公司有一整套直播解决方案，特别针对移动端。本公司开发者平台[www.anyrtc.io](http://www.anyrtc.io)。除了基于RTMP协议的直播系统外，我公司还有基于WebRTC的时时交互直播系统、P2P呼叫系统、会议系统等。快捷集成SDK，便可让你的应用拥有时时通话功能。欢迎您的来电~
## License

RTCPEngine is available under the MIT license. See the LICENSE file for more info.

