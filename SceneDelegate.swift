//
//  SceneDelegate.swift
//  Mixtapes
//
//  Created by Swanand Tanavade on 03/25/23.
//

import UIKit
import SwiftUI
import AVKit
import MediaPlayer

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let player = AVQueuePlayer()
    
    // These properties must be observable objects so their values can be used in the views as well as here in
    // scene view in "" for control center/lock screen skipping controls
    @ObservedObject var currentPlayerItems: CurrentPlayerItems = CurrentPlayerItems()
    @ObservedObject var currentSongName: CurrentSongName = CurrentSongName()
    @ObservedObject var isPlaying: IsPlaying = IsPlaying()


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Get the managed object context from the shared persistent container.
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        // Create the SwiftUI view and set the context as the value for the managedObjectContext environment keyPath.
        // Add `@Environment(\.managedObjectContext)` in the views that will need the context.
        let playerItemObserver = PlayerItemObserver(player: self.player)
        let playerStatusObserver = PlayerStatusObserver(player: self.player)
        self.setupRemoteTransportControls()

        // Get the singleton instance.
          let audioSession = AVAudioSession.sharedInstance()
          do {
              // Set the audio session category, mode, and options.
              try audioSession.setCategory(.playback,  options: [])
          } catch {
              print("Failed to set audio session category.")
          }

        let contentView = ContentView(queuePlayer: self.player, playerItemObserver: playerItemObserver, playerStatusObserver: playerStatusObserver, currentPlayerItems: self.currentPlayerItems,currentSongName: self.currentSongName,isPlaying: self.isPlaying).environment(\.managedObjectContext, context)

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }

    
    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()

        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            if self.player.rate == 0.0 {
                self.player.play()
                return .success
            }
            return .commandFailed
        }

        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if self.player.rate == 1.0 {
                self.player.pause()
                return .success
            }
            return .commandFailed
        }
        
        // Add handler for Skip Command
        commandCenter.nextTrackCommand.addTarget { [unowned self] event in
            
            if let item = self.player.currentItem {
                self.player.pause()
                item.seek(to: CMTime.zero, completionHandler: nil)
                self.player.advanceToNextItem()
                self.player.play()
                return .success
            }
            return .commandFailed
        }
        
        commandCenter.previousTrackCommand.addTarget { [unowned self] event in
            skipBack(currentPlayerItems: self.currentPlayerItems.items, currentSongName: self.currentSongName.name, queuePlayer: self.player, isPlaying: self.isPlaying.value)
            return .success
 
        }
    }
}

class CurrentPlayerItems: ObservableObject {
    @Published var items: [AVPlayerItem] = []
}
class CurrentSongName: ObservableObject {
    @Published var name: String = "Not Playing"
}
class IsPlaying: ObservableObject {
    @Published var value: Bool = false
}



