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
        
        let baseURl = "https://image.tmdb.org/t/p/w342"
        let posterPath = movie["poster_path"] as! String
        let imageUrl = NSURL(string: baseURl + posterPath)
        let placeholder = UIImage(named: "placeholder.png")
        
        posterImageView.setImageWithURL(imageUrl!, placeholderImage: placeholder)

        print(movie)

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
