//
//  ViewController.swift
//  Back to batch
//
//  Created by Ajin on 24/01/24.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    var player = AVAudioPlayer()
    let audioPath = Bundle.main.path(forResource: "sheep", ofType: "mp3")
    var timer = Timer()
    
    @IBOutlet weak var playerPosition: UISlider!
    @IBOutlet weak var volume: UISlider!
    
    @IBAction func stop(_ sender: UIBarButtonItem) {
        player.stop()
        timer.invalidate()
        playerPosition.value = 0
        createPlayer()
        
    }
    @IBAction func pause(_ sender: UIBarButtonItem) {
        player.pause()
        timer.invalidate()
    }
    @IBAction func play(_ sender: UIBarButtonItem) {
        player.play()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.updatePlayerPos), userInfo: nil, repeats: true)
        
    }
    @IBAction func volumeChanged(_ sender: UISlider) {
        player.volume = volume.value
    }
    @IBAction func playerSweeped(_ sender: UISlider) {
        player.currentTime = TimeInterval(playerPosition.value)
    }
    
    @objc func updatePlayerPos(){
        playerPosition.value = Float(player.currentTime)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        createPlayer()
    }


    func createPlayer(){
        do{
            try player = AVAudioPlayer(contentsOf: URL(filePath: audioPath!))
            playerPosition.maximumValue = Float(player.duration)
        }catch{
            
        }
    }
}

