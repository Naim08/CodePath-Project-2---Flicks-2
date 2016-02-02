//
//  DetailsViewController.swift
//  Flicks
//
//  Created by Md Miah on 2/1/16.
//  Copyright © 2016 Naim. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {

    @IBOutlet weak var infoView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var posterImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var overviewLabel: UILabel!
    
    var movie: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.height)
        
        let title = movie["title"] as? String
        titleLabel.text = title
        
        let overView = movie["overview"] as? String
        overviewLabel.text = overView
        overviewLabel.sizeToFit()
        
        let baseURl = "https://image.tmdb.org/t/p/w45"
        let largeUrl = "https://image.tmdb.org/t/p/original"
        
        let posterPath = movie["poster_path"] as! String
        let smallImageRequest = NSURLRequest(URL: NSURL(string: baseURl + posterPath)!)
        let largeImageRequest = NSURLRequest(URL: NSURL(string: largeUrl + posterPath)!)
        let placeholder = UIImage(named: "placeholder.png")
 
        posterImageView.contentMode = UIViewContentMode.ScaleAspectFill
        posterImageView.setImageWithURLRequest( smallImageRequest,
            placeholderImage: placeholder,
            success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                
                // smallImageResponse will be nil if the smallImage is already available
                // in cache (might want to do something smarter in that case).
                self.posterImageView.alpha = 0.0
                self.posterImageView.image = smallImage;
                
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    
                    self.posterImageView.alpha = 1.0
                    
                    }, completion: { (sucess) -> Void in
                        
                        // The AFNetworking ImageView Category only allows one request to be sent at a time
                        // per ImageView. This code must be in the completion block.
                        self.posterImageView.setImageWithURLRequest(
                            largeImageRequest,
                            placeholderImage: smallImage,
                            success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                
                               self.posterImageView.image = largeImage;
                                
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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
