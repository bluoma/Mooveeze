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
    var endpointPath: String = theMovieDbNowPlayingPath
    var isNetworkErrorShowing: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        jsonDownloader.delegate = self
        
        let currentlyPlayingUrlString = theMovieDbSecureBaseUrl + endpointPath + "?" + theMovieDbApiKeyParam
        
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
        cell.movieOverviewLabel.text = movieSummary.overview
        cell.movieOverviewLabel.sizeToFit()
        let indexPath = IndexPath(row: 0, section: 0)
        let maxOverviewLabelHeight = self.tableView(self.moviesTableView, heightForRowAt: indexPath) - cell.movieTitleLabel.frame.size.height + 3
        if cell.movieOverviewLabel.frame.size.height > maxOverviewLabelHeight {
            cell.movieOverviewLabel.frame.size.height = maxOverviewLabelHeight
        }
        
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
    
    /*
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        dlog("")
        return "Now Network Error   X (close)"
    }
    */
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        dlog("isNetworkErrorShowing: \(isNetworkErrorShowing)")
        if isNetworkErrorShowing {
            
            let v = UITableViewHeaderFooterView()
            v.textLabel?.text = "Now Network Error   X (close)"
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            //tapRecognizer.delegate = self
            tapRecognizer.numberOfTapsRequired = 1
            tapRecognizer.numberOfTouchesRequired = 1
            v.addGestureRecognizer(tapRecognizer)
            return v
        }
        return nil
    }
    
    func handleTap(gestureRecognizer: UIGestureRecognizer)
    {
        dlog("Header Tapped")
        isNetworkErrorShowing = !isNetworkErrorShowing
        moviesTableView.reloadData()
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
    

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        dlog("");
        if isNetworkErrorShowing {
            return 44.0;
        }
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        dlog("")
    }
    
    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        dlog("")
    }
    
    
    //MARK: - JsonDownloader
    func jsonDownloaderDidFinish(downloader: JsonDownloader, json: [String:AnyObject]?, response: HTTPURLResponse, error: NSError?)
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false

        if error != nil {
            dlog("err: \(error)")
            isNetworkErrorShowing = true
            moviesTableView.reloadData()
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
                isNetworkErrorShowing = false
                moviesTableView.reloadData()
            }
            else {
                dlog("no json")
                isNetworkErrorShowing = true
                moviesTableView.reloadData()
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
