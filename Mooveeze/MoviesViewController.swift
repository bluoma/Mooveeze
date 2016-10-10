//
//  MoviesViewController.swift
//  Mooveeze
//
//  Created by Bill on 10/6/16.
//  Copyright © 2016 Bill. All rights reserved.
//

import UIKit
import AFNetworking

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, JsonDownloaderDelegate {

    @IBOutlet weak var moviesTableView: UITableView!
    @IBOutlet weak var moviesSearchBar: UISearchBar!
    
    var jsonDownloader = JsonDownloader()
    var downloadTaskDict: [String:URLSessionDataTask] = [:]
    var moviesArray: [MovieSummaryDTO] = []
    var endpointPath: String = theMovieDbNowPlayingPath
    var isNetworkErrorShowing: Bool = false
    var header = UITableViewHeaderFooterView()
    var searchActive = false
    var filteredMoviesArray: [MovieSummaryDTO] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        header.addGestureRecognizer(tapRecognizer)
        
        jsonDownloader.delegate = self
        doDownload()
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
    {   if searchActive {
            return filteredMoviesArray.count
        }
        return moviesArray.count
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieSummaryCell") as! MovieSummaryTableViewCell
        var movieSummary: MovieSummaryDTO! = nil
        if searchActive {
            movieSummary = filteredMoviesArray[indexPath.row]
        }
        else {
            movieSummary = moviesArray[indexPath.row]
        }

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
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        dlog("isNetworkErrorShowing: \(isNetworkErrorShowing)")
        if isNetworkErrorShowing {
            return header
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
        
        var movieSummary: MovieSummaryDTO! = nil
        if searchActive {
            movieSummary = filteredMoviesArray[indexPath.row]
        }
        else {
            movieSummary = moviesArray[indexPath.row]
        }
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
        header.textLabel?.text = "Sorry, there was a network error"
        header.textLabel?.textColor = UIColor.red
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        header.textLabel?.textAlignment = NSTextAlignment.center
    }
    
    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        dlog("")
    }
    
    //MARK: - UISearchBarDelegate
    /*
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        dlog("")
        searchActive = true
    }
    */
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        dlog("searchText: \(searchText)")
        if searchText.characters.count == 0 {
            searchActive = false
            moviesTableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dlog("searchBarText: \(searchBar.text)")
        searchBar.endEditing(true)
        
        filteredMoviesArray = moviesArray.filter({ (movie) -> Bool in
            if let searchText = searchBar.text {
                let range = movie.overview.range(of: searchText, options: .caseInsensitive)
                return range != nil
            }
            return false
        })
        if (filteredMoviesArray.count == 0){
            searchActive = false;
        }
        else {
            searchActive = true;
        }
        moviesTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dlog("")
        searchBar.endEditing(true)
        searchActive = false
        moviesTableView.reloadData()
    }
    
    //MARK: - JsonDownloader
    
    func doDownload() {
        let currentlyPlayingUrlString = theMovieDbSecureBaseUrl + endpointPath + "?" + theMovieDbApiKeyParam
        cancelJsonDownloadTask(urlString: currentlyPlayingUrlString)
        if let task: URLSessionDataTask = jsonDownloader.doDownload(urlString: currentlyPlayingUrlString) {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            downloadTaskDict[currentlyPlayingUrlString] = task
        }

    }
    
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
                moviesArray = resultsArray
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
