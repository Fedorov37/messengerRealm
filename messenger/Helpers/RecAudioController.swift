//
//  RecAudioController.swift
//  messenger
//
//  Created by Администратор on 24.05.2022.
//

import Foundation
import AVFoundation
var audioPlayer: AVAudioPlayer?

enum audioSessionMode {
    case record
    case play
}

class RecAudioController: NSObject, AVAudioRecorderDelegate {
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var isAudioRecordingGranted: Bool!
    var audioFilePath: URL?
    
    override init() {
        super.init()
        checkForRecordPermission()
    }
    
    func checkForRecordPermission() {
        let session = AVAudioSession.sharedInstance()
        switch session.recordPermission {
        case .granted:
            isAudioRecordingGranted = true
        case .denied:
            isAudioRecordingGranted = false
        case .undetermined:
            session.requestRecordPermission { [weak self] isAllowed in
                self?.isAudioRecordingGranted = isAllowed
            }
        @unknown default: break
        }
    }
    
    func setupRecorder() {
        if isAudioRecordingGranted {
            recordingSession = AVAudioSession.sharedInstance()
            
            do {
                try recordingSession.setCategory(.playAndRecord, mode: .default)
                try recordingSession.setActive(true)
            } catch {
                print("Error setting up audio recording session", error.localizedDescription)
            }
        }
    }
    
    func startRecording(fileName: String) {
        let audioFileName = getDocumentURL().appendingPathComponent(fileName + ".m4a", isDirectory:  false)
        self.audioFilePath = audioFileName
        setupRecorder()
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFileName, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
        } catch {
            print("Error recording", error.localizedDescription)
            finishRecording()
        }
    }
    
    func finishRecording() {
        if audioRecorder != nil {
            audioRecorder.stop()
            audioRecorder = nil
        }
    }
    
    func getDocumentURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    }
    
}

extension Date {
    func longDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        return dateFormatter.string(from: self)
    }
    
    func stringDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMMyyyyHHmmss"
        
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter.string(from: self)
    }
    
    func time() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self)
    }
    
    func interval(ofComponent comp: Calendar.Component, to date: Date) -> Float {
        let currentCalendar = Calendar.current
        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: date),
              let start = currentCalendar.ordinality(of: comp, in: .era, for: self)
        else { return 0.0 }
        
        return Float(end - start)
    }
}
