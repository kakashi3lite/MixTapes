//
//  PlayerItemOberver.swift
//  Mixtapes
//
//  Created by Swanand Tanavade on 03/25/23.
//

import Foundation
import Combine
import AVKit
import MediaPlayer


class PlayerItemObserver {

    @Published var currentItem: AVPlayerItem?
    private var itemObservation: AnyCancellable?

    init(player: AVPlayer) {
    // publishes the current AVPlayerItem in the AVPlayer so it can be updated in the views when the current song changes
        
        itemObservation = player.publisher(for: \.currentItem).sink { item in
            self.currentItem = item
            var nowPlayingInfo = [String : Any]()
            nowPlayingInfo[MPMediaItemPropertyTitle] = getItemName(playerItem: item)
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            
        }
    }
}
