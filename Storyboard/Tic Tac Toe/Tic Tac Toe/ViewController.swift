//
//  ViewController.swift
//  Tic Tac Toe
//
//  Created by Ajin on 20/01/24.
//

import UIKit

class ViewController: UIViewController {

    var activePlayer: Int = 1
    var gameState = [0,0,0,0,0,0,0,0,0,0]
    let winningCombination = [[0,1,2], [3,4,5], [6,7,8], [0,3,6], [1,4,7], [2,5,8], [0,4,8], [2,4,6]]
    var activeGame = true
    
    
    @IBOutlet weak var WinningView: UIView!
    @IBOutlet weak var winningStatus: UILabel!
    @IBOutlet weak var playAgainBtn: UIButton!
    
    @IBAction func playAgain(_ sender: UIButton) {
        self.activeGame = true
        activePlayer = 1
        gameState = [0,0,0,0,0,0,0,0,0,0]
        for i in 1...9{
            if let button = view.viewWithTag(i) as? UIButton{
                button.configuration?.image = nil
            }
        }
        self.winningStatus.isHidden = true
        self.playAgainBtn.isHidden = true
        self.WinningView.isHidden = true
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        let pos = sender.tag - 1
        if gameState[pos] == 0 && activeGame{
            gameState[pos] = activePlayer
            if self.activePlayer == 1{
                sender.setImage(UIImage(named: "nought"), for: [])
                self.activePlayer = 2
            }else{
                sender.setImage(UIImage(named: "cross"), for: [])
                self.activePlayer = 1
            }
        }
        
        for combination in winningCombination{
            if gameState[combination[0]] != 0 && gameState[combination[0]] == gameState[combination[1]] && gameState[combination[0]] == gameState[combination[2]]{
                activeGame = false
                
                self.winningStatus.isHidden = false
                self.playAgainBtn.isHidden = false
                self.WinningView.isHidden = false
                
                if gameState[combination[0]] == 1{
                    self.winningStatus.text = "Nought won"
                }else{
                    self.winningStatus.text = "Cross won"
                }
                
                UIView.animate(withDuration: 2) {
                    self.winningStatus.alpha = 1
                    self.playAgainBtn.alpha = 1
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.winningStatus.isHidden = true
        self.playAgainBtn.isHidden = true
        self.WinningView.isHidden = true
        self.WinningView.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        self.WinningView.layer.borderWidth = 5.0
        self.winningStatus.text = ""
        self.winningStatus.alpha = 0
        self.playAgainBtn.alpha = 0
    }


}

