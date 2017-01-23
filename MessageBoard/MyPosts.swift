//
//  MyPosts.swift
//  MessageBoard
//
//  Created by Ampe on 10/15/16.
//  Copyright © 2016 Ampe. All rights reserved.


import UIKit
import Parse
import HidingNavigationBar
import ReachabilitySwift

class MyPosts : UIViewController , UITableViewDelegate , UITableViewDataSource , HidingNavigationBarManagerDelegate {
    
    @IBOutlet weak var animationTarget: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectedCellLabel: UILabel!
    
    var transition = QZCircleSegue()
    var location = CLLocation()
    var refresher = UIRefreshControl()
    
    var hidingNavBarManager: HidingNavigationBarManager?
    var parentNavigationController : UINavigationController?
    
    var imageFile : PFFile!
    var category : String!
    var mainText : String!
    var mainLocation : String!
    var mainTime : String!
    var mainScore : String!
    var mainColor : String!
    var mainUpVote : CGFloat!
    var mainDownVote : CGFloat!
    var mainID : String!
    var mainOriginalPoster : String!

    var imageName = [PFFile]()
    var postID = [String]()
    var text = [String]()
    var place = [String]()
    var comments = [Int]()
    var color = [Int]()
    var time = [Date]()
    var score = [Int]()
    var userLike = [NSArray]()
    var userDislike = [NSArray]()
    var originalPoster = [String]()
    
    var direction = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = UniversalVariables.blue
        self.refresher.tintColor = UIColor.white
        
        self.tableView.estimatedRowHeight = 60
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
        hidingNavBarManager = HidingNavigationBarManager(viewController: self, scrollView: tableView)
        hidingNavBarManager?.delegate = self
        
        refresher.addTarget(self, action: #selector(self.loadPosts), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress))
        self.view.addGestureRecognizer(longPressRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hidingNavBarManager?.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let img = UIImage()
        self.navigationController?.navigationBar.shadowImage = img
        self.navigationController?.navigationBar.setBackgroundImage(img, for: UIBarMetrics.default)
        loadPosts()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        hidingNavBarManager?.viewDidLayoutSubviews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hidingNavBarManager?.viewWillDisappear(animated)
    }
    
    func loadPosts() {
        
        let reachability = Reachability()!
        if reachability.currentReachabilityStatus == .notReachable {
            Warning().noConnection()
            self.refresher.endRefreshing()
        }
        else {
            let query = PFQuery(className: "Posts")
            let current = PFUser.current()?.objectId!
            query.limit = 100
            query.whereKey("userID", equalTo: current!)
            query.addDescendingOrder("createdAt")
            
            query.findObjectsInBackground (block: { (objects:[PFObject]?, error: Error?) -> Void in
                
                self.imageName.removeAll(keepingCapacity: false)
                self.originalPoster.removeAll(keepingCapacity: false)
                self.postID.removeAll(keepingCapacity: false)
                self.text.removeAll(keepingCapacity: false)
                self.place.removeAll(keepingCapacity: false)
                self.comments.removeAll(keepingCapacity:false)
                self.color.removeAll(keepingCapacity: false)
                self.time.removeAll(keepingCapacity: false)
                self.score.removeAll(keepingCapacity: false)
                self.userLike.removeAll(keepingCapacity: false)
                self.userDislike.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    self.imageName.append(object.value(forKey: "image") as! PFFile)
                    self.originalPoster.append(object.value(forKey: "userID") as! String)
                    self.postID.append(object.value(forKey: "objectId") as! String)
                    self.text.append(object.value(forKey: "text") as! String)
                    self.place.append(object.value(forKey: "city") as! String)
                    self.comments.append(object.value(forKey: "comments") as! Int)
                    self.color.append(object.value(forKey: "color") as! Int)
                    self.score.append(object.value(forKey: "score") as! Int)
                    self.userLike.append(object.value(forKey: "userLike") as! NSArray)
                    self.userDislike.append(object.value(forKey: "userDislike") as! NSArray)
                    self.time.append(object.createdAt!)
                }
                self.tableView?.reloadData()
                self.refresher.endRefreshing()
            })
        }
    }
    
    func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            
            let longPress = longPressGestureRecognizer as UILongPressGestureRecognizer
            let locationInView = longPress.location(in: tableView)
            var indexPath = tableView.indexPathForRow(at: locationInView)!
            
            if (imageName[indexPath.row].name.contains("aaaaupload.jpg") || imageName[indexPath.row].name.contains("aaaacapture.jpg")) {
                if (imageName[indexPath.row].name.contains("aaaaupload.jpg")) {
                    UniversalVariables.type = "upload"
                    UniversalVariables.imageFile = imageName[indexPath.row]
                    performSegue(withIdentifier: "segueThree", sender: self)
                }
                if (imageName[indexPath.row].name.contains("aaaacapture.jpg")) {
                    UniversalVariables.type = "capture"
                    UniversalVariables.imageFile = imageName[indexPath.row]
                    performSegue(withIdentifier: "segueThree", sender: self)
                }
                else {
                }
            }
            else {
            }
        }
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        hidingNavBarManager?.shouldScrollToTop()
        return true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "mypostcell", for: indexPath) as! MyPostsTableViewCell
        
        cell.imageLabel.isHidden = true
        
        let userObjectId = PFUser.current()?.objectId as String?
        let likeContained = self.userLike[indexPath.row].contains(userObjectId!)
        let dislikeContained = self.userDislike[indexPath.row].contains(userObjectId!)
        
        if (likeContained == true || dislikeContained == true) {
            if (likeContained == true && dislikeContained == false) {
                cell.upVote.isEnabled = false
                cell.downVote.isEnabled = false
                cell.upVote.alpha = 0.75
                cell.downVote.alpha = 0.25
            }
            else if (likeContained == false && dislikeContained == true) {
                cell.upVote.isEnabled = false
                cell.downVote.isEnabled = false
                cell.upVote.alpha = 0.25
                cell.downVote.alpha = 0.75
            }
            else {
            }
        }
        else {
            cell.upVote.isEnabled = true
            cell.downVote.isEnabled = true
        }
        
        let date = time[indexPath.row]
        let now = Date()
        let unitFlags = Set<Calendar.Component>([.second, .minute, .hour, .day])
        let difference = Calendar.current.dateComponents(unitFlags, from: date, to: now)
        
        if difference.second! <= 0 {
            cell.timeSince.text = "  " + "now"
        }
        if (difference.second! > 0 && difference.minute! == 0) {
            cell.timeSince.text = "  " + "\(difference.second!)s"
        }
        if (difference.minute! > 0 && difference.hour! == 0) {
            cell.timeSince.text = "  " + "\(difference.minute!)m"
        }
        if (difference.hour! > 0 && difference.day! == 0) {
            cell.timeSince.text = "  " + "\(difference.hour!)h"
        }
        if (difference.day! > 0) {
            cell.timeSince.text = "  " + "\(difference.day!)d"
        }
        
        if color[indexPath.row] == 1 {
            cell.mainView.backgroundColor = UniversalVariables.blue
        }
        if color[indexPath.row] == 2 {
            cell.mainView.backgroundColor = UniversalVariables.green
        }
        if color[indexPath.row] == 3 {
            cell.mainView.backgroundColor = UniversalVariables.purple
        }
        if color[indexPath.row] == 4 {
            cell.mainView.backgroundColor = UniversalVariables.orange
        }
        if (imageName[indexPath.row].name.contains("aaaaupload.jpg") || imageName[indexPath.row].name.contains("aaaacapture.jpg")) {
            cell.imageLabel.isHidden = false
        }
        else {
            
        }
        
        cell.originalPoster.text = self.originalPoster[indexPath.row]
        cell.postID.text = self.postID[indexPath.row]
        cell.postID.isHidden = true
        cell.postText.text = self.text[indexPath.row]
        cell.postLocation.text = "  " + self.place[indexPath.row]
        cell.commentNumber.text = "  " + "\(self.comments[indexPath.row])"
        cell.postScore.text = String(self.score[indexPath.row])
        
        cell.upVote.tag = indexPath.row
        cell.downVote.tag = indexPath.row
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.text.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow!
        let currentCell = tableView.cellForRow(at: indexPath)! as! MyPostsTableViewCell
        CommentVariables.commentParent = currentCell.postID.text
        
        imageFile = imageName[indexPath.row]
        mainOriginalPoster = currentCell.originalPoster.text
        mainID = currentCell.postID.text
        mainUpVote = currentCell.upVote.alpha
        mainDownVote = currentCell.downVote.alpha
        mainText = currentCell.postText.text
        mainLocation = currentCell.postLocation.text
        mainTime = currentCell.timeSince.text
        mainScore = currentCell.postScore.text
        PostVariables.postColor = currentCell.mainView.backgroundColor
        performSegue(withIdentifier: "myPostToComment", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "myPostToComment") {
            let viewController = segue.destination as! CommentTableView
            
            viewController.imageFile = imageFile
            viewController.mainOriginalPoster = mainOriginalPoster
            viewController.mainID = mainID
            viewController.mainUpVote = mainUpVote
            viewController.mainDownVote = mainDownVote
            viewController.mainText = mainText
            viewController.mainTime = mainTime
            viewController.mainLocation = mainLocation
            viewController.mainScore = mainScore
            if (imageFile.name.contains("aaaaupload.jpg") || imageFile.name.contains("aaaacapture.jpg")) {
                viewController.isImage = true
            }
            else {
                viewController.isImage = false
            }
        }
        
        else if (segue.identifier == "segueThree") {
            self.transition.animationChild = self.animationTarget
            self.transition.animationColor = UIColor.black
            let toViewController = segue.destination as! Image
            self.transition.fromViewController = self
            self.transition.toViewController = toViewController
            toViewController.transitioningDelegate = transition
            
        }
    }
    
    func hidingNavigationBarManagerDidChangeState(_ manager: HidingNavigationBarManager, toState state: HidingNavigationBarState) {
        
    }
    
    func hidingNavigationBarManagerDidUpdateScrollViewInsets(_ manager: HidingNavigationBarManager) {
        
    }
    
    @IBAction func upVotePressed(_ sender: AnyObject) {
        
        let buttonTag = sender.tag
        let current = PFUser.current()?.objectId
        let indexPath = IndexPath(row: buttonTag!, section: 0)
        let currentCell = tableView.cellForRow(at: indexPath)! as! MyPostsTableViewCell
        let currentPostID = currentCell.postID.text
        Database().postUpVoteToDatabase(postId: currentPostID!, userId: current!)
        let scoreOne = Int(currentCell.postScore.text!)
        let scoreTwo = scoreOne! + 1
        currentCell.postScore.text = String(scoreTwo)
        currentCell.upVote.isEnabled = false
        currentCell.upVote.alpha = 0.75
        currentCell.downVote.isEnabled = false
        currentCell.downVote.alpha = 0.25
        
    }
    
    @IBAction func downVotePressed(_ sender: AnyObject) {
        
        let buttonTag = sender.tag
        let current = PFUser.current()?.objectId
        let indexPath = IndexPath(row: buttonTag!, section: 0)
        let currentCell = tableView.cellForRow(at: indexPath)! as! MyPostsTableViewCell
        let currentPostID = currentCell.postID.text
        Database().postDownVoteToDatabase(postId: currentPostID!, userId: current!)
        let scoreOne = Int(currentCell.postScore.text!)
        let scoreTwo = scoreOne! - 1
        currentCell.postScore.text = String(scoreTwo)
        currentCell.upVote.isEnabled = false
        currentCell.upVote.alpha = 0.75
        currentCell.downVote.isEnabled = false
        currentCell.downVote.alpha = 0.25
        
    }
}

class MyPostsTableViewCell : UITableViewCell {
    
    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var originalPoster: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var postID: UILabel!
    @IBOutlet weak var postText: UILabel!
    @IBOutlet weak var postLocation: UILabel!
    @IBOutlet weak var commentNumber: UILabel!
    @IBOutlet weak var timeSince: UILabel!
    @IBOutlet weak var postScore: UILabel!
    @IBOutlet weak var upVote: UIButton!
    @IBOutlet weak var downVote: UIButton!
    
}
