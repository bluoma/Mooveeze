//
//  MoviesViewController.swift
//  Mooveeze
//
//  Created by Bill on 10/6/16.
//  Copyright © 2016 Bill. All rights reserved.
//

import UIKit
import AFNetworking

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, JsonDownloaderDelegate {

    @IBOutlet weak var moviesTableView: UITableView!
    var jsonDownloader = JsonDownloader()
    var downloadTaskDict: [String:URLSessionDataTask] = [:]
    var nowPlayingArray: [MovieSummaryDTO] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        jsonDownloader.delegate = self
        
        let currentlyPlayingUrlString = theMovieDbSecureBaseUrl + theMovieDbNowPlayingPath + "?" + theMovieDbApiKeyParam
        
        cancelJsonDownloadTask(urlString: currentlyPlayingUrlString)
        if let task: URLSessionDataTask = jsonDownloader.doDownload(urlString: currentlyPlayingUrlString) {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            downloadTaskDict[currentlyPlayingUrlString] = task
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancelAllJsonDownloadTasks()
    }


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        //NowPlayingSummaryToDetailPushSegue
        
        dlog("segue: \(segue.identifier) sender: \(sender)")
        
        if let segueId = segue.identifier, segueId == "NowPlayingSummaryToDetailPushSegue" {
            let movieSummary: MovieSummaryDTO = sender as! MovieSummaryDTO
            let destVc = segue.destination as! MovieDetailViewController
            destVc.movieSummary = movieSummary
        }
    }
    

    
    //MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return nowPlayingArray.count
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieSummaryCell") as! MovieSummaryTableViewCell
        let movieSummary: MovieSummaryDTO = nowPlayingArray[indexPath.row]
        cell.movieTitleLabel.text = movieSummary.title
        cell.movieOverviewLabel.text = movieSummary.title
        
        if movieSummary.posterPath.characters.count > 0  {
            let imageUrlString = theMovieDbSecureBaseImageUrl + "/" + poster_sizes[0] + movieSummary.posterPath
            let imageUrl = URL(string: imageUrlString)!
            let defaultImage = UIImage(named: "default_movie_thumbnail.png")
            cell.movieThumbnailImageView.setImageWith(_:imageUrl, placeholderImage: defaultImage)
        }
        else {
            let defaultImage = UIImage(named: "default_movie_thumbnail.png")
            cell.movieThumbnailImageView.image = defaultImage
        }
        return cell
        
    }
    
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 96.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        dlog("row: \(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: true)
        
        let movieSummary: MovieSummaryDTO = nowPlayingArray[indexPath.row]
        
        self.performSegue(withIdentifier: "NowPlayingSummaryToDetailPushSegue", sender: movieSummary)
    }
    

    //MARK: - JsonDownloader
    func jsonDownloaderDidFinish(downloader: JsonDownloader, json: [String:AnyObject]?, response: HTTPURLResponse, error: NSError?)
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false

        if error != nil {
            dlog("err: \(error)")
        }
        else {
            dlog("got json")
            
            if let jsonObj: [String:AnyObject]  = json,
                let results: [AnyObject] = jsonObj["results"] as? [AnyObject] {
                var resultsArray: [MovieSummaryDTO] = []
                
                for movieObj in results {
                    let movieDict: NSDictionary = movieObj as! NSDictionary
                    let movieDto: MovieSummaryDTO = MovieSummaryDTO(jsonDict: movieDict)
                    dlog("movieDTO: \(movieDto)")
                    resultsArray.append(movieDto)
                }
                nowPlayingArray = resultsArray
                moviesTableView.reloadData()
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


}
