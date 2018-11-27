//
//  MemeDetailViewController.swift
//  MemeMeToo
//
//  Created by Steve Brylka on 11/20/18.
//  Copyright © 2018 Steve Brylka. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {
    
    var meme: Meme!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imageView.image = meme.memedImage
    }
}
