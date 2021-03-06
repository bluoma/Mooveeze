//
//  MovieDetailViewController.swift
//  Mooveeze
//
//  Created by Bill on 10/7/16.
//  Copyright © 2016 Bill. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController, UIScrollViewDelegate, JsonDownloaderDelegate {

    @IBOutlet weak var backdropImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var bottomContainerView: UIView!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var runningTimeLabel: UILabel!

    var dateFormatter = DateFormatter()
    var movieSummary: MovieSummaryDTO!
    
    var jsonDownloader = JsonDownloader()
    var downloadTaskDict: [String:URLSessionDataTask] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.title = movieSummary.title
        
        titleLabel.text = ""
        runningTimeLabel.text = ""
        ratingLabel.text = ""
        genreLabel.text = ""
        runningTimeLabel.text = ""
        releaseDateLabel.text = ""
        
        overviewLabel.text = movieSummary.overview
        overviewLabel.sizeToFit()
        
        ratingLabel.text = String(movieSummary.voteAverage) + " / 10.00"
        if let releaseDate = movieSummary.releaseDate {
            dateFormatter.dateStyle = .medium
            releaseDateLabel.text = dateFormatter.string(from: releaseDate)
        }
        
        let bottomViewHeightDiff = bottomContainerView.frame.size.height - overviewLabel.frame.origin.y
        if overviewLabel.frame.size.height > bottomViewHeightDiff {
            bottomContainerView.frame.size.height += overviewLabel.frame.size.height - bottomViewHeightDiff + 16.0
        }
        
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
        
        
        if let movieDetails = movieSummary.movieDetail {
            displayMovieDetails(details: movieDetails)
        }
        else {
            jsonDownloader.delegate = self
            doDownload()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancelAllJsonDownloadTasks()
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
        dlog("overViewSize: \(overviewLabel.frame.size)")
    }
    
    
    //MARK: - JsonDownloader
    
    func doDownload() {
        let baseUrl = theMovieDbSecureBaseUrl + theMovieDbMovieDetailPath + "/"
        let movieDetailUrlString = baseUrl + String(movieSummary.movieId) + "?" + theMovieDbApiKeyParam
        cancelJsonDownloadTask(urlString: movieDetailUrlString)
        if let task: URLSessionDataTask = jsonDownloader.doDownload(urlString: movieDetailUrlString) {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            downloadTaskDict[movieDetailUrlString] = task
        }
        
    }
    
    func jsonDownloaderDidFinish(downloader: JsonDownloader, json: [String:AnyObject]?, response: HTTPURLResponse, error: NSError?)
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if error != nil {
            dlog("err: \(error)")
            
        }
        else {
                    
            if let jsonObj: [String:AnyObject] = json {
                dlog("jsonObj: \(type(of:jsonObj))")
                
                let movieDetail = MovieDetailDTO(jsonDict: jsonObj as NSDictionary)
                
                dlog("movieDetail: \(movieDetail)")
                
                self.movieSummary.movieDetail = movieDetail
                self.displayMovieDetails(details: movieDetail)
            }
            else {
                dlog("no json")
                
            }
        }
        if let urlString = response.url?.absoluteString {
            dlog("url from response: \(urlString)")
            downloadTaskDict[urlString] = nil
        }
    }
    
    func cancelJsonDownloadTask(urlString: String)
    {
        if let currentDowloadTask: URLSessionDataTask = downloadTaskDict[urlString] {
            currentDowloadTask.cancel()
            downloadTaskDict[urlString] = nil
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
    }
    
    func cancelAllJsonDownloadTasks()
    {
        for (_, task) in downloadTaskDict {
            task.cancel()
        }
        downloadTaskDict.removeAll()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func displayMovieDetails(details: MovieDetailDTO) -> Void {
        
        if details.runtime > 0 {
            let hours = details.runtime / 60
            let minutes = details.runtime % 60
            let runttimeString = "\(hours) hr \(minutes) min"
            runningTimeLabel.text = runttimeString
        }
        
        if details.tagline.characters.count > 0 {
            titleLabel.alpha = 0.0;
            titleLabel.text = details.tagline
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.titleLabel.alpha = 1.0
            })
        }
        if details.genres.count > 0 {
            genreLabel.text = details.genres.first
        }
    }
}
