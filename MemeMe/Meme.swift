//
//  Meme.swift
//  MemeMe
//
//  Created by Steve Brylka on 10/3/18.
//  Copyright © 2018 Steve Brylka. All rights reserved.
//

import Foundation
import UIKit

// MARK: Structs >>>

struct Meme {
    var topText: String
    var bottomText: String
    var originalImage: UIImage?
    var memedImage: UIImage?
    
    // Get count of memes
    static func count() -> Int {
        return getMemeStorage().memes.count
    }
    
    // Meme Storage Locaiton
    static func getMemeStorage() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
}
