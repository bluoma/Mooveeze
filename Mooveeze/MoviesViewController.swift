//
//  MoviesViewController.swift
//  Mooveeze
//
//  Created by Bill on 10/6/16.
//  Copyright © 2016 Bill. All rights reserved.
//

import UIKit

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, JsonDownloaderDelegate {

    @IBOutlet weak var moviesTableView: UITableView!
    var jsonDownloader = JsonDownloader()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        jsonDownloader.delegate = self

        
        let currentlyPlayingUrlString = theMovieDbSecureBaseUrl + theMovieDbNowPlayingPath + "?" + theMovieDbApiKeyParam
        jsonDownloader.doDownload(urlString: currentlyPlayingUrlString)
        
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

    
    //MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 0
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        return UITableViewCell()
    }
    
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        dlog("row: \(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: true)
    }
    

    //MARK: - JsonDownloader
    func jsonDownloaderDidFinish(downloader: JsonDownloader, json: Any?, response: HTTPURLResponse, error: NSError?)
    {
        dlog("json: \(json)")
        dlog("err: \(error)")
    }

}
