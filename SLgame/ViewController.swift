//
//  ViewController.swift
//  SLgame
//
//  Created by Alisha on 2021/5/31.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
  
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageWinImageView: UIImageView!
    @IBOutlet weak var messageLoseImageView: UIImageView!
    @IBOutlet weak var diceButton: UIButton!
    @IBOutlet weak var replayBtn: UIButton!

    
    let containerWidth = UIScreen.main.bounds.maxX
    let squareWidth = UIScreen.main.bounds.maxX/5
    let pcImageView = UIImageView(image: UIImage(named: "badPusheen1"))
    let userImageView = UIImageView(image: UIImage(named: "nicePusheen1"))
    
    var squaresArray = [UIView]()
    var board = [Int](repeating: 0, count: 31)
    var diceRoll = 0
    var finalSquare = 25
    var userSquare = 0
    var pcSquare = 0
    var diceNumber = 0
    
    let player = AVPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //上樓梯或被蛇攻擊滑落
        board[3] = +8
        board[6] = +11
        board[9] = +9
        board[10] = +2
        board[14] = -10
        board[19] = -11
        board[22] = -2
        board[24] = -8
        
        //設定背景
        view.backgroundColor = UIColor(red: 255/255, green: 193/255, blue: 255/255, alpha: 1)
        
        //裝載地圖的UiView
        let container = UIView(frame: CGRect(x: 0, y: 80, width: containerWidth, height: containerWidth))
        container.backgroundColor = .clear
        view.addSubview(container)
        
        //設定地圖
        let mapImage = UIImageView(image: UIImage(named: "SnakesAndLadders"))
        mapImage.frame = container.bounds
        container.addSubview(mapImage)
        
        //讓messageLose的位置和messageWin一樣（因為只有messageWin設定autoLayout）
        messageLoseImageView.frame = messageWinImageView.frame
        
        //出發地點
        let departureSquare = UIView(frame: CGRect(x: 0, y: containerWidth, width: squareWidth, height: squareWidth))
        squaresArray.append(departureSquare)
        container.addSubview(departureSquare)

        //pc出發地點
        pcImageView.frame = departureSquare.frame
        pcImageView.frame.origin.x = squareWidth
        pcImageView.frame.size.height = squareWidth/3*2
        container.addSubview(pcImageView)
        
        //user出發地點
        userImageView.frame = departureSquare.frame
        userImageView.frame.size.height = squareWidth/3*2
        container.addSubview(userImageView)
        
        //隱藏終點訊息
        messageLabel.isHidden = true
        messageWinImageView.isHidden = true
        messageLoseImageView.isHidden = true

        //獲勝訊息圖動畫
        var messageWinImages = [UIImage]()
        for i in 1...4 {
            messageWinImages.append(UIImage(named: "HappyPusheen\(i)")!)
        }
        messageWinImageView.animationImages = messageWinImages
        
        
        //骰子動畫
        var diceImages = [UIImage]()
        for i in 1...6 {
            diceImages.append(UIImage(systemName: "die.face.\(i).fill")!)
        }
        diceButton.imageView?.tintColor = .black
        diceButton.imageView?.animationImages = diceImages
        diceButton.imageView?.animationDuration = 1
        diceButton.imageView?.animationRepeatCount = 2
        diceButton.imageView?.image = diceImages.last
        
        
        
        for line1 in 0...4 {
            let square = UIView(frame: CGRect(x: CGFloat(line1)*squareWidth, y: 4*squareWidth, width: squareWidth, height: squareWidth))
            squaresArray.append(square)
            container.addSubview(square)
        }
        for line2 in 0...4 {
            let square = UIView(frame: CGRect(x: CGFloat(4-line2)*squareWidth, y: 3*squareWidth, width: squareWidth, height: squareWidth))
            squaresArray.append(square)
            container.addSubview(square)
        }
        for line3 in 0...4 {
            let square = UIView(frame: CGRect(x: CGFloat(line3)*squareWidth, y: 2*squareWidth, width: squareWidth, height: squareWidth))
            squaresArray.append(square)
            container.addSubview(square)
        }
        for line4 in 0...4 {
            let square = UIView(frame: CGRect(x: CGFloat(4-line4)*squareWidth, y: 1*squareWidth, width: squareWidth, height: squareWidth))
            squaresArray.append(square)
            container.addSubview(square)
        }
        for line5 in 0...4 {
            let square = UIView(frame: CGRect(x: CGFloat(line5)*squareWidth, y: 0*squareWidth, width: squareWidth, height: squareWidth))
            squaresArray.append(square)
            container.addSubview(square)
        }

    }
    
    @IBAction func pressDice(_ sender: UIButton) {
        
        diceRoll += 1
        print("骰子丟第 \(diceRoll) 次")

        //丟出隨機骰子，決定這一輪要走幾步
        self.diceNumber = Int.random(in: 1...6)
        print("骰子數目：\(diceNumber)")
        
        //播放骰子動畫
        diceButton.imageView?.startAnimating()
        
        //等待骰子動畫
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.diceButton.setImage(UIImage(systemName: "die.face.\(self.diceNumber).fill"), for: .normal)
        }
        
        //判斷現在是哪一個玩家
        let currentPlayerIsUser: Bool = diceRoll % 2 != 0
        
        if currentPlayerIsUser {
            
            DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                self.moveUser(thisRunEnd: self.userSquare + self.diceNumber, goToEnd: false)
                
            }
 
            
        }
        
        else {
            
            DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                self.movePC(thisRunEnd: self.pcSquare + self.diceNumber, goToEnd: false)
                
            }
            
        }
    }
    
    //user移動的func
    func moveUser(thisRunEnd: Int, goToEnd: Bool){

        //判斷是否是這一輪的終點
        if goToEnd {
            self.userSquare = self.userSquare + self.board[self.userSquare]
        } else {
            self.userSquare += 1
        }
        
        //移動
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 1, delay: 0, options: .curveLinear) {
            
            self.userTurnAround()
            
            if self.userSquare < 25 {
                self.userImageView.center = self.squaresArray[self.userSquare].center
                print("User所在格子：\(self.userSquare)")
                print("位置:\(self.userImageView.frame)")
            }
            
            //等於２５格就贏了
            if self.userSquare == 25 {
                self.userSquare = 25
                print("User在終點了")
                self.userImageView.center = self.squaresArray[25].center
                self.whichOneWin()
            }
  
        } completion: { (_) in
            
            //當user所在格子數小於這一輪的終點會持續移動
            if self.userSquare < thisRunEnd {
                self.moveUser(thisRunEnd: thisRunEnd, goToEnd: false)
            }
            else{
                //來到這一輪的終點，開始爬樓梯或是被蛇攻擊
                if self.board[self.userSquare] != 0 {
                    switch self.userSquare {
                    case 3,6,9,10:
                        self.playMusicUp()
                    case 14,19,22,24:
                        self.playMusicDown()
                    default:
                        print("default")
                    }
                    self.moveUser(thisRunEnd: self.board[thisRunEnd], goToEnd: true)
                }
            }
        }
    }
    
    //pc移動的func
    func movePC(thisRunEnd: Int, goToEnd: Bool){

        //判斷是否是這一輪的終點
        if goToEnd {
            self.pcSquare = self.pcSquare + self.board[self.pcSquare]
        } else {
            self.pcSquare += 1
        }
        
        //移動
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 1, delay: 0, options: .curveLinear) {
            self.pcTurnAround()
            
            if self.pcSquare < 25 {
                self.pcImageView.center = self.squaresArray[self.pcSquare].center
                print("PC所在格子：\(self.pcSquare)")
                print("位置:\(self.pcImageView.frame)")
            }
            
            //等於２５格就贏了
            if self.pcSquare == 25 {
                self.pcSquare = 25
                print("PC在終點了")
                self.pcImageView.center = self.squaresArray[25].center
                self.whichOneWin()
            }

        } completion: { (_) in
            
            //當user所在格子數小於這一輪的終點會持續移動
            if self.pcSquare < thisRunEnd {
                self.movePC(thisRunEnd: thisRunEnd, goToEnd: false)
            }
            else{
                //來到這一輪的終點，開始爬樓梯或是被蛇攻擊
                if self.board[self.pcSquare] != 0 {
                    switch self.pcSquare {
                    case 3,6,9,10:
                        self.playMusicUp()
                    case 14,19,22,24:
                        self.playMusicDown()
                    default:
                        print("default")
                    }
                    self.movePC(thisRunEnd: self.board[thisRunEnd], goToEnd: true)
                }
            }
        }
    }
    
    func playMusicUp() {
        let fileUrl = Bundle.main.url(forResource: "smb_1-up", withExtension: "wav")!
        var soundID: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(fileUrl as CFURL, &soundID)
        AudioServicesPlayAlertSound(soundID)
    }
    
    func playMusicDown() {
        let fileUrl = Bundle.main.url(forResource: "smb_bowserfalls", withExtension: "wav")!
        var soundID: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(fileUrl as CFURL, &soundID)
        AudioServicesPlayAlertSound(soundID)
    }
    
    func whichOneWin() {
        if self.userSquare == 25 {
            Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(winMessage), userInfo: nil, repeats: false)
        }
        if self.pcSquare == 25 {
            Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(loseMessage), userInfo: nil, repeats: false)
        }
    }
    
    @objc func winMessage() {
        diceButton.isHidden = true
        messageLabel.isHidden = false
        self.messageLabel.text = "Congratulation!"
        self.messageWinImageView.startAnimating()
        self.messageWinImageView.isHidden = false
        //音樂
        let fileUrl = Bundle.main.url(forResource: "smb_stage_clear", withExtension: "wav")!
        var soundID: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(fileUrl as CFURL, &soundID)
        AudioServicesPlayAlertSound(soundID)
    }
    
    @objc func loseMessage() {
        diceButton.isHidden = true
        messageLabel.isHidden = false
        messageLabel.text = "You Lose... >_<"
        messageLoseImageView.isHidden = false
        //音樂
        let fileUrl = Bundle.main.url(forResource: "smb_gameover", withExtension: "wav")!
        var soundID: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(fileUrl as CFURL, &soundID)
        AudioServicesPlayAlertSound(soundID)
    }
    
    //user的圖片翻轉
    func userTurnAround() {
        switch userSquare {
        case 6...10,16...20:
            userImageView.image = UIImage(named: "nicePusheen2")
        default:
            userImageView.image = UIImage(named: "nicePusheen1")
        }
    }
    
    //pc的圖片翻轉
    func pcTurnAround() {
        switch pcSquare {
        case 6...10,16...20:
            pcImageView.image = UIImage(named: "badPusheen2")
        default:
            pcImageView.image = UIImage(named: "badPusheen1")
        }
    }

    @IBAction func rePlay(_ sender: Any) {
        diceButton.isHidden = false
        diceButton.isEnabled = true
        messageLabel.isHidden = true
        messageWinImageView.isHidden = true
        messageLoseImageView.isHidden = true
        diceRoll = 0
        userSquare = 0
        pcSquare = 0
        userImageView.image = UIImage(named: "nicePusheen1")
        pcImageView.image = UIImage(named: "badPusheen1")
        userImageView.center = squaresArray[userSquare].center
        pcImageView.center = squaresArray[userSquare].center
        pcImageView.frame.origin.x = squareWidth
    }

}

