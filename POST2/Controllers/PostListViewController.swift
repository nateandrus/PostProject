//
//  PostListViewController.swift
//  POST2
//
//  Created by Nathan Andrus on 2/4/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit

class PostListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var postListTableView: UITableView!
    
    let refreshControl = UIRefreshControl()
    
    let postlist = PostController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postListTableView.delegate = self
        postListTableView.dataSource = self
        self.postListTableView.estimatedRowHeight = 45
        postListTableView.rowHeight = UITableView.automaticDimension
        postListTableView.refreshControl = refreshControl
        postlist.fetchPosts {
            print(self.postlist.posts)
            self.reloadTableView()
        }
    }
    
    @IBAction func addPostButtonTapped(_ sender: UIBarButtonItem) {
        presentNewPostAlert()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postlist.posts.count 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
            let post = postlist.posts[indexPath.row]
            cell.textLabel?.text = post.text
            cell.detailTextLabel?.text = post.username
            return cell
    }
    
    @objc func refreshControlPulled() {
        refreshControl.addTarget(self, action: #selector(refreshControlPulled), for: .valueChanged)
        postlist.fetchPosts {
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                self.refreshControl.endRefreshing()
                self.reloadTableView()
            }
        }
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.postListTableView.reloadData()
            self.refreshControl.endRefreshing()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    func presentNewPostAlert() {
        var usernameTextfield: UITextField?
        var textTextfield: UITextField?
        let postAlertController = UIAlertController(title: "New Post", message: "Let's keep this civil", preferredStyle: .alert)
        postAlertController.addTextField { (textField) in
            textField.placeholder = "Username..."
            usernameTextfield = textField
        }
        postAlertController.addTextField { (textField) in
            textField.placeholder = "What do you have to say?.."
            textTextfield = textField
        }
        let cancelPost = UIAlertAction(title: "Cancel", style: .cancel)
        
        let addPostAction = UIAlertAction(title: "Add post", style: .default) { (_) in
            guard let usernameText = usernameTextfield?.text, !usernameText.isEmpty,
                     let postText = textTextfield?.text, !postText.isEmpty else { return }
            self.postlist.addNewPostWith(username: usernameText, text: postText, completion: {
                self.reloadTableView()
            })
        }
        postAlertController.addAction(cancelPost)
        postAlertController.addAction(addPostAction)
        
        present(postAlertController, animated: true, completion: nil)
    }
}

extension PostListViewController {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= postlist.posts.count - 1 {
            postlist.fetchPosts(reset: false) {
                self.reloadTableView()
            }
        }
    }
}
