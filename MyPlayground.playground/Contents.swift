import UIKit
import AVFoundation



let url = apiRootUrl?.appending(path: "verses").appending(path: "by_chapter").appending(path: "\(2)")

let curUrl = url?.appending(queryItems: [URLQueryItem(name: "words", value: "true"),
                                        URLQueryItem(name: "page", value: "\(1)"),
                                        URLQueryItem(name: "per_page", value: "\(1)"),
                                        URLQueryItem(name: "word_fields", value: "text_uthmani,text_indopak,text_imlaei"),
                                        URLQueryItem(name: "audio", value: "\(recitationId)")])
print(curUrl)
//let task = Task{
//    let sharedItem = try await QuranSharedItem.getSharedItem()
//    let chapter = sharedItem.getChapter(for: 1)
//
//}


