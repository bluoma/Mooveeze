//
//  MovieDetailViewController.swift
//  Mooveeze
//
//  Created by Bill on 10/7/16.
//  Copyright © 2016 Bill. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var backdropImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var bottomContainerView: UIView!
    
    
    
    var movieSummary: MovieSummaryDTO!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.title = movieSummary.title
        titleLabel.text = movieSummary.title
        overviewLabel.text = movieSummary.overview
        overviewLabel.sizeToFit()
        
        contentScrollView.contentSize = CGSize(width: contentScrollView.frame.size.width, height: bottomContainerView.frame.origin.y + bottomContainerView.frame.size.height)
        
        if movieSummary.posterPath.characters.count > 0  {
            let imageUrlString = theMovieDbSecureBaseImageUrl + "/" + poster_sizes[4] + movieSummary.posterPath
            if let imageUrl = URL(string: imageUrlString) {
                let defaultImage = UIImage(named: "default_poster_image.png")
                let urlRequest: URLRequest = URLRequest(url:imageUrl)
                
                backdropImageView.setImageWith(_:urlRequest, placeholderImage: nil,
                    success: { (request: URLRequest, response:HTTPURLResponse?, image: UIImage) -> Void in
                        if (response != nil) {
                            self.backdropImageView.alpha = 0.0;
                            self.backdropImageView.image = image
                            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                                self.backdropImageView.alpha = 1.0
                            })
                        }
                        else {
                            self.backdropImageView.image = image
                        }
                        
                    },
                    failure: { (request: URLRequest, response: HTTPURLResponse?, error: Error) -> Void in
                        dlog("image fetch failed: \(error) for indexPath: \(imageUrlString)")
                        self.backdropImageView.image = defaultImage
                })
            }
            else {
                dlog("bad url for image: \(imageUrlString)")
                let defaultImage = UIImage(named: "default_poster_image.png")
                self.backdropImageView.image = defaultImage
            }
        }
        else {
            dlog("no url for posterPath: \(movieSummary.posterPath)")
            let defaultImage = UIImage(named: "default_poster_image.png")
            self.backdropImageView.image = defaultImage
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

        
    //MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //dlog("contentSize: \(scrollView.contentSize), contentOffset: \(scrollView.contentOffset)")
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        dlog("contentSize: \(scrollView.contentSize), contentOffset: \(scrollView.contentOffset)")
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        dlog("contentSize: \(scrollView.contentSize), contentOffset: \(scrollView.contentOffset)")
    }
    
}
