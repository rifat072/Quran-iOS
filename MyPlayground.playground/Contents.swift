import UIKit

let url = URL(string: "https://verses.quran.com/Alafasy/mp3/001001.mp3")

extension URL {
    
    func withScheme(_ scheme: String) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        components?.scheme = scheme
        return components?.url
    }
    
}
let cachingPlayerItemScheme = "cachingPlayerItemScheme"
let finetuneUrl = url?.withScheme(cachingPlayerItemScheme)


