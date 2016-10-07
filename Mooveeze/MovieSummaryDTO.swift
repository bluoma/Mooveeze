//
//  MovieSummaryDTO.swift
//  Mooveeze
//
//  Created by Bill on 10/7/16.
//  Copyright © 2016 Bill. All rights reserved.
//

import UIKit

class MovieSummaryDTO: NSObject {

    
    override init() {
        super.init()
    }
    
    convenience init(jsonDict: NSDictionary) {
        self.init()
        
        dlog("jsonDict: \(jsonDict)")
    }
    
    var movieId: Int = -1
    var title: String = ""
    var adult: Bool = false
    var overview: String = ""
    var releaseDate: String = ""
    var genreIds: [String] = []
    var originalTitle: String = ""
    var originalLanguage: String = ""
    var backdropPath: String = ""
    var popularity: Double = 0.0
    var posterPath: String = ""
    var voteCount: Int = 0
    var video: Bool = false
    var voteAverage: Double = 0.0
    
}


/*
 
 
{
    "poster_path": "\/z6BP8yLwck8mN9dtdYKkZ4XGa3D.jpg",
    "adult": false,
    "overview": "A big screen remake of John Sturges' classic western The Magnificent Seven, itself a remake of Akira Kurosawa's Seven Samurai. Seven gun men in the old west gradually come together to help a poor village against savage thieves.",
    "release_date": "2016-09-14",
    "genre_ids": [28, 12, 37],
    "id": 333484,
    "original_title": "The Magnificent Seven",
    "original_language": "en",
    "title": "The Magnificent Seven",
    "backdrop_path": "\/g54J9MnNLe7WJYVIvdWTeTIygAH.jpg",
    "popularity": 32.363999,
    "vote_count": 386,
    "video": false,
    "vote_average": 4.63
}
 
  */


