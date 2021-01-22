//
//  ViewController.swift
//  ExampleOfiOSAudioEffector
//
//  Created by TokyoYoshida on 2021/01/22.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    var audioRecorder: AVAudioRecorder!

    var audioEngine: AVAudioEngine!
    var audioFile: AVAudioFile!
    var audioPlayerNode: AVAudioPlayerNode!

    override func viewDidLoad() {
        func initAudioRecorder() {
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setCategory(.playAndRecord, mode: .default)
                try session.setActive(true)

                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 2,
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                ]

                audioRecorder = try AVAudioRecorder(url: getAudioFileUrl(), settings: settings)
            } catch let error {
                fatalError(error.localizedDescription)
            }
        }
        super.viewDidLoad()

        initAudioRecorder()
    }

    @IBAction func tappedRecordButton(_ sender: Any) {
        if !audioRecorder.isRecording {
            audioRecorder.record()
            recordButton.setTitle("Stop", for: .normal)
        } else {
            audioRecorder.stop()
            recordButton.setTitle("Record", for: .normal)
        }
    }
    
    @IBAction func tappedPlayButton(_ sender: Any) {
        func initPlayer() {
            do {
                audioEngine = AVAudioEngine()
                audioFile = try AVAudioFile(forReading: getAudioFileUrl())
                audioPlayerNode = AVAudioPlayerNode()
                
                audioEngine.attach(audioPlayerNode)
                audioEngine.connect(audioPlayerNode, to: audioEngine.outputNode, format: audioFile.processingFormat)
            } catch let error {
                fatalError(error.localizedDescription)
            }
        }
        func doStart() throws {
            audioPlayerNode.scheduleFile(audioFile, at: nil, completionCallbackType: .dataPlayedBack) {_ in
                DispatchQueue.main.async {
                    doStop(true)
                }
            }

            try audioEngine.start()
            audioPlayerNode.play()
            playButton.setTitle("Stop", for: .normal)
        }
        func doStop(_ skipPlayerStop: Bool) {
            if !skipPlayerStop {
                audioPlayerNode.stop()
            }
            playButton.setTitle("Play", for: .normal)
        }
        initPlayer()
        do {
            if playButton.titleLabel?.text == "Play" {
                doStop(false)
                try doStart()
            } else {
                doStop(false)
            }
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }

    func getAudioFileUrl() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDirect = paths[0]
        let audioUrl = docsDirect.appendingPathComponent("recording.m4a")

        return audioUrl
    }
}

