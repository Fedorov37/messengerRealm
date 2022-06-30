//
//  AudioController.swift
//  messenger
//
//  Created by Администратор on 28.05.2022.
//

import UIKit
import AVFoundation
import MessageKit


public enum PlayerState {

    case playing
    case pause
    case stopped
}

open class AudioController: NSObject, AVAudioPlayerDelegate {
    
    open var mp3Player: AVPlayer?
    
    var notificationObserverDidPlayToEndTime:NSObjectProtocol?
    var notificationObserverFailedToPlayToEndTime:NSObjectProtocol?
    var notificationObserverNewErrorLogEntry:NSObjectProtocol?
    

    open weak var playingCell: AudioMessageCell?

    open var playingMessage: MessageType?

    open private(set) var state: PlayerState = .stopped

    public weak var messageCollectionView: MessagesCollectionView?

    internal var progressTimer: Timer?

    // MARK: - Init Methods

    public init(messageCollectionView: MessagesCollectionView) {
        self.messageCollectionView = messageCollectionView
        super.init()
    }

    // MARK: - Methods

    open func configureAudioCell(_ cell: AudioMessageCell, message: MessageType) {
        if playingMessage?.messageId == message.messageId, let collectionView = messageCollectionView, let player = mp3Player {
            playingCell = cell
            let duration = Double(CMTimeGetSeconds((player.currentItem?.asset.duration)!))
            let currentTime = Double(CMTimeGetSeconds(player.currentTime()))

            cell.progressView.progress = (duration == 0) ? 0 : Float(currentTime/duration)
            
            if ((player.rate != 0) && (player.error == nil)) {
                cell.playButton.isSelected = true
            }
            else {
                cell.playButton.isSelected = false
            }
            guard let displayDelegate = collectionView.messagesDisplayDelegate else {
                fatalError("MessagesDisplayDelegate has not been set.")
            }
            cell.durationLabel.text = displayDelegate.audioProgressTextFormat(Float(currentTime), for: cell, in: collectionView)
        }
    }

    open func playSound(for message: MessageType, in audioCell: AudioMessageCell) {
        switch message.kind {
        case .audio(let item):
            playingCell = audioCell
            playingMessage = message
            
            let playerItem = AVPlayerItem(url: item.url)
            self.notificationObserverDidPlayToEndTime = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem, queue: nil) { notification in
                self.stopAnyOngoingPlaying()
            }
            
            self.notificationObserverFailedToPlayToEndTime = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: playerItem, queue: nil) { notification in
                self.stopAnyOngoingPlaying()
            }
                        
            self.notificationObserverNewErrorLogEntry = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemNewErrorLogEntry, object: playerItem, queue: nil) { notification in
                self.stopAnyOngoingPlaying()
            }
            
            if mp3Player != nil {
                self.stopAnyOngoingPlaying()
            }

            mp3Player = AVPlayer(playerItem:playerItem)
            mp3Player!.volume = 1.0
            mp3Player?.playImmediately(atRate: 1.0)
            mp3Player!.play()
            
            
            state = .playing
            audioCell.playButton.isSelected = true
            startProgressTimer()
            audioCell.delegate?.didStartAudio(in: audioCell)
        default:
            print("AudioPlayer failed play sound because given message kind is not Audio")
        }
    }

    open func pauseSound(for message: MessageType, in audioCell: AudioMessageCell) {
        mp3Player?.pause()
        state = .pause
        audioCell.playButton.isSelected = false
        progressTimer?.invalidate()
        if let cell = playingCell {
            cell.delegate?.didPauseAudio(in: cell)
        }
    }

    open func stopAnyOngoingPlaying() {
        guard let player = mp3Player, let collectionView = messageCollectionView else { return }
        player.seek(to: CMTime.zero)
        player.pause()

        state = .stopped
        if let cell = playingCell {
            cell.progressView.progress = 0.0
            cell.playButton.isSelected = false
            guard let displayDelegate = collectionView.messagesDisplayDelegate else {
                fatalError("MessagesDisplayDelegate has not been set.")
            }
            let duration = Double(CMTimeGetSeconds((player.currentItem?.asset.duration)!))
            cell.durationLabel.text = displayDelegate.audioProgressTextFormat(Float(duration), for: cell, in: collectionView)
            cell.delegate?.didStopAudio(in: cell)
        }
        progressTimer?.invalidate()
        progressTimer = nil
       
        if mp3Player != nil {
            mp3Player?.replaceCurrentItem(with: nil)
            mp3Player = nil
            
            NotificationCenter.default.removeObserver(notificationObserverDidPlayToEndTime!)
            NotificationCenter.default.removeObserver(notificationObserverFailedToPlayToEndTime!)
            NotificationCenter.default.removeObserver(notificationObserverNewErrorLogEntry!)
        }
        
        playingMessage = nil
        playingCell = nil
    }

    open func resumeSound() {
        guard let player = mp3Player, let cell = playingCell else {
            stopAnyOngoingPlaying()
            return
        }
        player.play()
        state = .playing
        startProgressTimer()
        cell.playButton.isSelected = true
        cell.delegate?.didStartAudio(in: cell)
    }

    // MARK: - Fire Methods
    @objc private func didFireProgressTimer(_ timer: Timer) {
        guard let player = mp3Player, let collectionView = messageCollectionView, let cell = playingCell else {
            return
        }
        if let playingCellIndexPath = collectionView.indexPath(for: cell) {
            let currentMessage = collectionView.messagesDataSource?.messageForItem(at: playingCellIndexPath, in: collectionView)
            if currentMessage != nil && currentMessage?.messageId == playingMessage?.messageId {
                let duration = Double(CMTimeGetSeconds((player.currentItem?.asset.duration)!))
                let currentTime = Double(CMTimeGetSeconds(player.currentTime()))

                cell.progressView.progress = (duration == 0) ? 0 : Float(currentTime/duration)
                guard let displayDelegate = collectionView.messagesDisplayDelegate else {
                    fatalError("MessagesDisplayDelegate has not been set.")
                }
                cell.durationLabel.text = displayDelegate.audioProgressTextFormat(Float(currentTime), for: cell, in: collectionView)
            } else {
                stopAnyOngoingPlaying()
            }
        }
    }

    // MARK: - Private Methods
    private func startProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
        progressTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(AudioController.didFireProgressTimer(_:)), userInfo: nil, repeats: true)
    }
}
