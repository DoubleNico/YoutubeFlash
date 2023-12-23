import SwiftUI
import AVKit
import Photos

struct ContentView: View {
    enum FileType: String {
        case mp3
        case mp4
    }

    @State private var fileURL: String = ""
    @State private var videoName: String = "video"
    @State private var selectedFileType: FileType = .mp4

    var baseURL = "http://localhost:3000/download"

    var body: some View {
        VStack {
            Picker("File Type", selection: $selectedFileType) {
                Text("MP3").tag(FileType.mp3)
                Text("MP4").tag(FileType.mp4)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            TextField("Enter file URL", text: $fileURL)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("Enter file name", text: $videoName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Download and Play") {
                downloadAndPlayFile()
            }
        }
    }

    func downloadAndPlayFile() {
        guard URL(string: fileURL) != nil else {
            print("Invalid URL")
            return
        }

        var fileTypeExtension: String = ""
        switch selectedFileType {
        case .mp3:
            fileTypeExtension = "mp3"
        case .mp4:
            fileTypeExtension = "mp4"
        }

        let downloadURL = "\(baseURL)/\(fileTypeExtension)?URL=\(fileURL)&name=\(videoName)"

        guard let fullURL = URL(string: downloadURL) else {
            print("Invalid full URL")
            return
        }

        let task = URLSession.shared.dataTask(with: fullURL) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsDirectory.appendingPathComponent("\(videoName).\(fileTypeExtension)")

            do {
                try data.write(to: fileURL)
                if selectedFileType == .mp4 {
                    saveFileToLibrary(fileURL: fileURL)
                }
                if selectedFileType == .mp3 {

                    
                }
                DispatchQueue.main.async {
                    if selectedFileType == .mp4 {
                        let player = AVPlayer(url: fileURL)
                        let playerViewController = AVPlayerViewController()
                        playerViewController.player = player
                        UIApplication.shared.windows.first?.rootViewController?.present(playerViewController, animated: true) {
                            player.play()
                        }
                    } else {


                        let playerManager = AudioPlayerManager.shared
                        playerManager.play(url: fileURL)
                        print("MP3 file downloaded and saved.")
                    }
                }
            } catch {
                print("Error saving file: \(error.localizedDescription)")
            }
        }

        task.resume()
    }

    func saveFileToLibrary(fileURL: URL) {
        PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileURL)
        } completionHandler: { success, error in
            if success {
                print("File saved to Photos library")
            } else {
                print("Error saving file to Photos library: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class AudioPlayerManager {
    static let shared = AudioPlayerManager()
    
    var audioPlayer: AVAudioPlayer?
    
    func play(url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.delegate = audioPlayer.self as? any AVAudioPlayerDelegate
            audioPlayer?.play()
            print("sound is playing")
        } catch let error {
            print("Sound Play Error -> \(error)")
        }
    }
}

