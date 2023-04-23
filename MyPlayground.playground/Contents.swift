import UIKit
import AVFoundation



var arr: [Int] = []{
    didSet{
        print("didSet")
    }
}

arr.append(1)
arr.append(2)
arr.append(3)
arr.append(4)

