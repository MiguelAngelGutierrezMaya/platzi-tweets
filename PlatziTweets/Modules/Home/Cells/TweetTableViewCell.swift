//
//  TweetTableViewCell.swift
//  PlatziTweets
//
//  Created by Keybe on 1/05/23.
//

import UIKit
import Kingfisher

class TweetTableViewCell: UITableViewCell {
    // MARK: - IBOutlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var tweetImageView: UIImageView!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    // IMPORTANT NOTE
    // Cells never can invoke ViewControllers
    
    @IBAction func openVideoAction() {
        guard let videoUrl = videoUrl else {
            return
        }
        
        needsToShowVideoPlayer?(videoUrl)
    }
    
    // MARK: - Properties
    private var videoUrl: URL?
    var needsToShowVideoPlayer: ((_ url: URL) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupCellWith(post: Post) {
        nameLabel.text = post.author.names
        nickNameLabel.text = post.author.nickname
        messageLabel.text = post.text
        
        if post.hasImage {
            // configure image
            tweetImageView.isHidden = false
            tweetImageView.kf.setImage(with: URL(string: post.imageUrl ?? ""))
        } else {
            tweetImageView.isHidden = true
        }
        
        videoButton.isHidden = !post.hasVideo
        videoUrl = URL(string: post.videoUrl ?? "")
    }
    
}
