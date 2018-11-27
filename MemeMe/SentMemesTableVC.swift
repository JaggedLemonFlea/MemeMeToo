//
//  SentMemesTableVC.swift
//  MemeMeToo
//
//  Created by Steve Brylka on 11/19/18.
//  Copyright © 2018 Steve Brylka. All rights reserved.
//

import UIKit

class SentMemesTableVC: UITableViewController {
    
    var memes: [Meme]! {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.memes
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemeCell", for: indexPath) as! SentMemesTableViewCell
        let meme = memes[indexPath.row]
        cell.memeLabel?.text = meme.topText + "..." + meme.bottomText
        cell.memeImageView?.image = meme.memedImage
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let meme = (UIApplication.shared.delegate as! AppDelegate).memes[(indexPath as NSIndexPath).row]
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "MemeDetailViewController", sender: meme)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MemeDetailViewController" {
            let memeDetailViewController = segue.destination as! MemeDetailViewController
            memeDetailViewController.meme = sender as? Meme
        }
    }
    
}
