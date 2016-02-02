//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Md Miah on 1/19/16.
//  Copyright © 2016 Naim. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD
import PKHUD


class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
   
   @IBOutlet weak var tableView: UITableView!
    let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var networkLabel: UILabel!
    
    
    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]?
    var endpoint: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        refreshControlAction(refreshControl)
       
        
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        //making api call
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    
    
    @IBAction func refreshNetwork(sender: UITapGestureRecognizer) {
        refreshControlAction(refreshControl)
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let filteredMovies = filteredMovies {
            return filteredMovies.count
        } else {
            return 0
        }
    }
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MoviesCell", forIndexPath: indexPath) as! MovieCell
        let movie = filteredMovies![indexPath.item]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
       
        let baseURl = "https://image.tmdb.org/t/p/w45"
        let largeUrl = "https://image.tmdb.org/t/p/original"
        
        let posterPath = movie["poster_path"] as! String
        let smallImageRequest = NSURLRequest(URL: NSURL(string: baseURl + posterPath)!)
        let largeImageRequest = NSURLRequest(URL: NSURL(string: largeUrl + posterPath)!)
        let placeholder = UIImage(named: "placeholder.png")
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.cellColorSelect()
        cell.selectedBackgroundView = backgroundView
        
        cell.posterView.setImageWithURLRequest( smallImageRequest,
            placeholderImage: placeholder,
            success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                
                // smallImageResponse will be nil if the smallImage is already available
                // in cache (might want to do something smarter in that case).
                cell.posterView.alpha = 0.0
                cell.posterView.image = smallImage;
                
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    
                    cell.posterView.alpha = 1.0
                    
                    }, completion: { (sucess) -> Void in
                        
                        // The AFNetworking ImageView Category only allows one request to be sent at a time
                        // per ImageView. This code must be in the completion block.
                        cell.posterView.setImageWithURLRequest(
                            largeImageRequest,
                            placeholderImage: smallImage,
                            success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                
                                cell.posterView.image = largeImage;
                                
                            },
                            failure: { (request, response, error) -> Void in
                                // do something for the failure condition of the large image request
                                // possibly setting the ImageView's image to a default image
                        })
                })
            },
            failure: { (request, response, error) -> Void in
                // do something for the failure condition
                // possibly try to get the large image
        })
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        cell.accessoryType = .None
        
        return cell
    }
    
    public func refreshControlAction(refreshControl: UIRefreshControl) {
       PKHUD.sharedHUD.show()
        let reachability: Reachability
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            print("Unable to create Reachability")
            return
        }
        reachability.whenReachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            self.networkLabel.hidden = true
            dispatch_async(dispatch_get_main_queue()) {
                if reachability.isReachableViaWiFi() {
                    print("Reachable via WiFi")
                } else {
                    print("Reachable via Cellular")
                }
            }
        }
        reachability.whenUnreachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            self.networkLabel.hidden = false
            dispatch_async(dispatch_get_main_queue()) {
                print("Not reachable")
            }
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            NSLog("response: \(responseDictionary)")
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            self.filteredMovies = self.movies
                            //reloading data
                            self.refreshControl.endRefreshing()
                            self.tableView.reloadData()
                    }
                }
                
                self.tableView.reloadData()
                
                // Tell the refreshControl to stop spinning
                refreshControl.endRefreshing()
                PKHUD.sharedHUD.hide()

        });
        task.resume()
    }
    

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredMovies = movies
        } else {
            filteredMovies = movies?.filter({ (movie: NSDictionary) -> Bool in
                if let title = movie["title"] as? String {
                    if title.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                        
                        return  true
                    } else {
                        return false
                    }
                }
                return false
            })
        }
        tableView.reloadData()
    }
    
    
    @IBAction func closeKeyboard(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        
        let detailViewController = segue.destinationViewController as! DetailsViewController
        detailViewController.movie = movie
        print("prepare")
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    
    
}
