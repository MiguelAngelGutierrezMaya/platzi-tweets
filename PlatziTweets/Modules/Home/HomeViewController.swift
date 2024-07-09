//
//  HomeViewController.swift
//  PlatziTweets
//
//  Created by Keybe on 1/05/23.
//

import UIKit
import Simple_Networking
import SVProgressHUD
import NotificationBannerSwift
import AVKit

class HomeViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    private let cellId: String = "TweetTableViewCell"
    private var dataSource: PostQueryResponse = PostQueryResponse(posts: [Post]())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getPost()
    }
    
    private func setupUI() {
        // 1 Asign data source
        // 2 Register cell
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)
    }
    
    private func getPost() {
        // 1. Show loading to users
        SVProgressHUD.show()
        
        // 2. Consume the service
        SN.get(endpoint: Endpoints.posts) {(response: SNResultWithEntity<PostQueryResponse, ErrorApiResponse>)
            in
            SVProgressHUD.dismiss()
            switch response {
            case .success(let posts):
                self.dataSource = posts
                self.tableView.reloadData()
            case .error(let error):
                NotificationBanner(
                    subtitle: "Error = \(error.localizedDescription)",
                    style: .danger
                ).show()
            case .errorResult(let errorResponse):
                NotificationBanner(
                    subtitle: "Error = \(errorResponse.errorType.message)",
                    style: .danger
                ).show()
            }
        }
    }
    
    private func deletePostAt(indexPath: IndexPath) {
        // 1. Load user looading
        SVProgressHUD.show()
        
        // 2. Get Id From post that we will delete
        let postId = dataSource.posts[indexPath.row].id
        
        // 3. Prepare url to delete
        let endpoint = "\(Endpoints.posts)?id=\(postId)"
        
        // 4. Make request for delete
        SN.delete(endpoint: endpoint) {(response: SNResultWithEntity<Post, ErrorApiResponse>) in
            SVProgressHUD.dismiss()
            switch response {
            case .success:
                // 1. Delete post from datasource
                self.dataSource.posts.remove(at: indexPath.row)
                // 2. Delete cell from table
                self.tableView.deleteRows(at: [indexPath], with: .left)
                
            case .error(let error):
                NotificationBanner(
                    subtitle: "Error = \(error.localizedDescription)",
                    style: .danger
                ).show()
            case .errorResult(let errorResponse):
                NotificationBanner(
                    subtitle: "Error = \(errorResponse.errorType.message)",
                    style: .danger
                ).show()
            }
        }
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, _) in
            self.deletePostAt(indexPath: indexPath)
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeActions
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return dataSource.posts[indexPath.row].author.email == "miguel.gutierrez2@keybe.ai"
    }
    
    //func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    //    let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (_, _) in
    //    }
    
    //let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, _)  in
    // Here we delete the tweeet
    //}
    //return [deleteAction]
    
    //    return [deleteAction]
    //}
}

// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    // Total cell numbers
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.posts.count
    }
    
    // Configure cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        if let cell = cell as? TweetTableViewCell {
            // configure the cell
            cell.setupCellWith(post: dataSource.posts[indexPath.row])
            cell.needsToShowVideoPlayer = { url in
                // Here we need to present the video player
                let avPlayer = AVPlayer(url: url)
                let avPlayerController = AVPlayerViewController()
                avPlayerController.player = avPlayer
                
                self.present(avPlayerController, animated: true) {
                    avPlayerController.player?.play()
                }
            }
        }
        
        return cell
    }
}

// MARK: - Navigation
extension HomeViewController {
    // This method will call when we make transition to other view controller (Only Storyboard)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 1 Validate if the segue is correct
        if segue.identifier == "showMap",
           // 2 Get the destination view controller
           let mapViewController = segue.destination as? MapViewController {
            // 3 Send data to destination
            mapViewController.posts = dataSource.posts.filter { Post in
                return Post.hasLocation
            }
        }
    }
}
