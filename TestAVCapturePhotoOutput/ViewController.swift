//
//  ViewController.swift
//  TestAVCapturePhotoOutput
//
//  Created by M on 2017/01/09.
//  Copyright © 2017年 M. All rights reserved.
//

// GitHub に入れた
// 変更して commit

import UIKit
import AVFoundation


class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var input:AVCaptureDeviceInput!
    var output:AVCapturePhotoOutput!
    var session:AVCaptureSession!
    var preView:UIView!
    var camera:AVCaptureDevice!
    

    struct pageForwardButtonInCameraPage {
        static let pointInFrame:CGPoint = CGPoint(x:200, y:40)
        static let sizeInFrame:CGSize = CGSize(width: 100, height: 100)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ダブルタップ
        //let doubleTap = UITapGestureRecognizer(target: self, action: #selector(ViewController.tapDouble(_:))) //Swift2.2以前
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.tapDouble(sender:)))  //Swift3
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)

        // シングルタップ
        //let singleTap = UITapGestureRecognizer(target: self, action: #selector(ViewController.tapSingle(_:))) //Swift2.2以前
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.tapSingle(sender:)))  //Swift3
        singleTap.numberOfTapsRequired = 1
        //singleTap.numberOfTouchesRequired = 2  //こう書くと2本指じゃないとタップに反応しない
        
        //これを書かないとダブルタップ時にもシングルタップのアクションも実行される
        //singleTap.requireGestureRecognizerToFail(doubleTap)  //Swift2.2
        singleTap.require(toFail: doubleTap)  //Swift3
        
        view.addGestureRecognizer(singleTap)

//        // 画面タップでシャッターを切るための設定
//        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector(("tapped:")))
//        // デリゲートをセット
//        tapGesture.delegate = self;
//        // Viewに追加.
//        self.view.addGestureRecognizer(tapGesture)
        
    }
    
    
    // メモリ管理のため
    override func viewWillAppear(_ animated: Bool) {
        // スクリーン設定
        setupDisplay()
        // カメラの設定
        setupCamera()
    }
    
    // メモリ管理のため
    override func viewDidDisappear(_ animated: Bool) {
        // camera stop メモリ解放
        session.stopRunning()
        
        for output in session.outputs {
            session.removeOutput(output as? AVCaptureOutput)
        }
        
        for input in session.inputs {
            session.removeInput(input as? AVCaptureInput)
        }
        session = nil
        camera = nil
    }
    
    func setupDisplay(){
        //スクリーンの幅
        let screenWidth = UIScreen.main.bounds.size.width;
        //スクリーンの高さ
        let screenHeight = UIScreen.main.bounds.size.height;
        
        // プレビュー用のビューを生成
        //        preView = UIView(frame: CGRectMake(0.0, 0.0, screenWidth, screenHeight))
        preView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        
    }
    
    func setupCamera(){
        
        // セッション
        session = AVCaptureSession()
        
        //        for caputureDevice: Any in AVCaptureDevice.devices() {
        //            // 背面カメラを取得
        //            if (caputureDevice as AnyObject).position == AVCaptureDevicePosition.back {
        //                camera = caputureDevice as? AVCaptureDevice
        //            }
        //            // 前面カメラを取得
        //            //if caputureDevice.position == AVCaptureDevicePosition.Front {
        //            //    camera = caputureDevice as? AVCaptureDevice
        //            //}
        //        }
        
        camera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        // カメラからの入力データ
        do {
            input = try AVCaptureDeviceInput(device: camera) as AVCaptureDeviceInput
        } catch let error as NSError {
            print(error)
        }
        
        // 入力をセッションに追加
        if(session.canAddInput(input)) {
            session.addInput(input)
        }
        
        // 静止画出力のインスタンス生成
        output = AVCapturePhotoOutput()
        // 出力をセッションに追加
        if(session.canAddOutput(output)) {
            session.addOutput(output)
        }
        
        // セッションからプレビューを表示を
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        previewLayer?.frame = preView.frame
        
        //        previewLayer.videoGravity = AVLayerVideoGravityResize
        //        previewLayer.videoGravity = AVLayerVideoGravityResizeAspect
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        // レイヤーをViewに設定
        // これを外すとプレビューが無くなる、けれど撮影はできる
        self.view.layer.addSublayer(previewLayer!)
        
        // オーバーレイ画像
        let overlayLayer = CALayer()
        
        // 画面の横幅を取得
//        let screenWidth:CGFloat = view.frame.size.width
//        let screenHeight:CGFloat = view.frame.size.height
//        print("view.frame,size", view.frame,size)
        
        // 画像の中心を画面の中心に設定
//        let centerPoint = CGPoint(x:screenWidth/2, y:screenHeight/2)
//        print("centerPoint", centerPoint)
        
        // ドロップシャドウ
        overlayLayer.shadowOffset = CGSize(width: 2, height: 2)
        overlayLayer.shadowRadius = 5.0
        overlayLayer.shadowColor = UIColor.black.cgColor
        overlayLayer.shadowOpacity = 0.9
        
        //
        overlayLayer.frame = CGRect(x: 0, y: 0, width: 320, height: 568)
        
        //        overlayLayer.backgroundColor = UIColor.cyan.cgColor
        overlayLayer.bounds = CGRect(x: 0.5, y: 0.75, width: 100, height: 100)
        let uiImage:UIImage = UIImage(named:"DSC_3703.png")!
        overlayLayer.contents = uiImage.cgImage
        self.view.layer.addSublayer(overlayLayer)
        
        
        
        // ボタン画像
        let buttonLayer = CALayer()
        
//        // 画面の横幅を取得
//        let screenWidth:CGFloat = view.frame.size.width
//        let screenHeight:CGFloat = view.frame.size.height
//        print("view.frame,size", view.frame,size)
        
//        // 画像の中心を画面の中心に設定
//        let centerPoint = CGPoint(x:screenWidth/2, y:screenHeight/2)
//        print("centerPoint", centerPoint)
        
        // ドロップシャドウ
        buttonLayer.shadowOffset = CGSize(width: 2, height: 2)
        buttonLayer.shadowRadius = 5.0
        buttonLayer.shadowColor = UIColor.black.cgColor
        buttonLayer.shadowOpacity = 0.9
        
        //
        let buttonImage:UIImage = UIImage(named:"nextPageArrow.png")!
        buttonLayer.contents = buttonImage.cgImage
        
        buttonLayer.backgroundColor = UIColor.cyan.cgColor
        
        buttonLayer.borderColor = UIColor.blue.cgColor
        buttonLayer.borderWidth = 1.5


        // 画像を中心に表示するための座標を計算
//        let pointForCenter = getPointForCenter(imageSize: buttonImage.size, screenSize: view.frame.size)
//        buttonLayer.frame = CGRect(x: Int(pointForCenter.x), y: Int(pointForCenter.y) , width: (buttonImage.cgImage?.width)!, height: Int(buttonImage.size.height))
        
        // ボタン画像のframe と bounds 設定
        print("pointInFrame", pageForwardButtonInCameraPage.pointInFrame)
        print("sizeInFrame", pageForwardButtonInCameraPage.sizeInFrame)
//        buttonLayer.frame = CGRect(x: 0, y: 0 , width: (buttonImage.cgImage?.width)!, height: Int(buttonImage.size.height))
//        buttonLayer.frame = CGRect(x: 0, y: 0 , width: Int(view.frame.size.width), height: Int(view.frame.size.height)) // 画面全体のフレーム
//        buttonLayer.frame = CGRect(x: 200.0, y: 100.0 , width: 100.0, height: 100.0)            // デバイス内のフレームの位置とサイズ
        buttonLayer.frame = CGRect(x: pageForwardButtonInCameraPage.pointInFrame.x, y: pageForwardButtonInCameraPage.pointInFrame.y,
                                    width: pageForwardButtonInCameraPage.sizeInFrame.width,
                                    height: pageForwardButtonInCameraPage.sizeInFrame.height)              // デバイス内のフレームの位置とサイズ
        buttonLayer.bounds = CGRect(x: 0, y: 0,
                                    width: pageForwardButtonInCameraPage.sizeInFrame.width,
                                    height: pageForwardButtonInCameraPage.sizeInFrame.height)              // フレーム内の位置とサイズ
        
        self.view.layer.addSublayer(buttonLayer)

        session.startRunning()
    }
    
    
    // タップイベント.
//    func tapped(sender: UITapGestureRecognizer){
//        print("タップ")
//        //        takeStillPicture()
//    }
//    
    //    func takeStillPicture(){
    //
    //        // ビデオ出力に接続.
    //        if let connection:AVCaptureConnection? = output.connection(withMediaType: AVMediaTypeVideo){
    //            // ビデオ出力から画像を非同期で取得
    //            output.captureStillImageAsynchronously(from: connection, completionHandler: { (imageDataBuffer, error) -> Void in
    //
    //                // 取得画像のDataBufferをJpegに変換
    //                let imageData:NSData = AVCapturePhotoOutput.jpegStillImageNSDataRepresentation(imageDataBuffer) as NSData
    //
    //                // JpegからUIImageを作成.
    //                let image:UIImage = UIImage(data: imageData as Data)!
    //
    //                // アルバムに追加.
    //                UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
    //
    //            })
    //        }
    //    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// シングルタップ時に実行される
    func tapSingle(sender: UITapGestureRecognizer) {
        print("tapSingle")
        let tapPoint = sender.location(in: self.view)
        
        // タップされた領域が範囲内か
        if (tapPoint.x <= (pageForwardButtonInCameraPage.pointInFrame.x + pageForwardButtonInCameraPage.sizeInFrame.width)) &&
            (tapPoint.x >= pageForwardButtonInCameraPage.pointInFrame.x) &&
            (tapPoint.y <= (pageForwardButtonInCameraPage.pointInFrame.y + pageForwardButtonInCameraPage.sizeInFrame.height)) &&
            (tapPoint.y >= pageForwardButtonInCameraPage.pointInFrame.y) {
            print("Inside the region", tapPoint)
            
            let storyboard: UIStoryboard = self.storyboard!
            let nextView = storyboard.instantiateViewController(withIdentifier: "getCharacterPageID")
            self.present(nextView, animated: true, completion: nil)
            
        } else {
            print("Outside the region", tapPoint)
        }
    }
    
    /// ダブルタップ時に実行される
    func tapDouble(sender: UITapGestureRecognizer) {
        print("tapDouble")
    }
/////////////
    func getPointForCenter(imageSize: CGSize, screenSize: CGSize) -> CGPoint {
        var point:CGPoint = CGPoint.zero
        print("getPointForCenter imageSize", imageSize, "screenSize", screenSize)
        if(screenSize.width < imageSize.width) {
            point.x = 0
        } else {
            point.x = (abs(screenSize.width - imageSize.width))/2
        }
        
        point.y = (abs(screenSize.height - imageSize.height))/2
        print("getPointForCenter point", point)
        return point
    }
}
