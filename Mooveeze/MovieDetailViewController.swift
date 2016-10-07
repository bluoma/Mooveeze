//
//  MovieDetailViewController.swift
//  Mooveeze
//
//  Created by Bill on 10/7/16.
//  Copyright © 2016 Bill. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {

    @IBOutlet weak var backdropImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    
    var movieSummary: MovieSummaryDTO!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = movieSummary.title
        // Do any additional setup after loading the view.
        titleLabel.text = movieSummary.title
        overviewLabel.text = movieSummary.overview
        
        if movieSummary.posterPath.characters.count > 0  {
            let imageUrlString = theMovieDbSecureBaseImageUrl + "/" + poster_sizes[4] + movieSummary.posterPath
            let imageUrl = URL(string: imageUrlString)!
            let defaultImage = UIImage(named: "default_movie_thumbnail.png")
            backdropImageView.setImageWith(_:imageUrl, placeholderImage: defaultImage)
        }
        else {
            let defaultImage = UIImage(named: "default_movie_thumbnail.png")
            backdropImageView.image = defaultImage
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

}
