import UIKit

let url = URL(string: "https://verses.quran.com/Alafasy/mp3/001001.mp3")

let fileUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appending(path: url!.relativePath)
fileUrl?.las


