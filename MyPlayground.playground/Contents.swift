import UIKit
import AVFoundation

let task = Task{
    let sharedItem = try await QuranSharedItem.getSharedItem()
    let chapter = sharedItem.getChapter(for: 1)
    let verses = try await chapter?.loadVerse(idx: 9)
    let audioFile = verses!.audio!.segments
    var list: [[Int]] = []
    for file in audioFile{
        list.append([file[1], file[2], file[3]])
    }
    list.sort { a, b in
        a.first! < b.first!
    }
    var listFinal: [[Float]] = []
    for file in list{
        listFinal.append([Float(file[1]), Float(file[2])])
    }
    guard let url = audioDownloadRootUrl?.appending(path: verses?.audio?.url ?? "") else {
        return
    }
    print(url)
    let asset = AVAsset(url: url)
    let playerItem = AVPlayerItem(asset: asset)
    let player = AVPlayer(playerItem: playerItem)
    
    let durationInt = listFinal.last!.last!
    let duration = asset.duration.seconds
    
    for i in 0..<listFinal.count{
        listFinal[i][0] /= Float(durationInt)
        listFinal[i][0] *= Float(duration)
        
        listFinal[i][1] /= Float(durationInt)
        listFinal[i][1] *= Float(duration)
    }
    print(listFinal)
    player.play()
    var idx = 0
    
    
    for i in 0...1000{
        Thread.sleep(forTimeInterval: 0.1)
        let time = Float(player.currentItem!.currentTime().seconds)
        if idx < listFinal.count{
            let start = listFinal[idx][0]
            let end = listFinal[idx][1]
            if time>=start && time<=end{
                print(start, end)
                idx+=1
            }
        } else {
            break
        }

    }
}


