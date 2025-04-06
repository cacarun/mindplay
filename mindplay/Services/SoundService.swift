//
//  SoundService.swift
//  mindplay
//
//  Created for MindPlay app.
//

import Foundation
import AVFoundation

class SoundService {
    static let shared = SoundService()
    
    private var audioPlayers: [URL: AVAudioPlayer] = [:]
    
    private init() {}
    
    func playSound(named fileName: String, withExtension fileExtension: String = "mp3") {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            print("Could not find sound file: \(fileName).\(fileExtension)")
            return
        }
        
        if let audioPlayer = audioPlayers[url] {
            audioPlayer.currentTime = 0
            audioPlayer.play()
            return
        }
        
        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.prepareToPlay()
            audioPlayers[url] = audioPlayer
            audioPlayer.play()
        } catch {
            print("Could not play sound file: \(error.localizedDescription)")
        }
    }
}
