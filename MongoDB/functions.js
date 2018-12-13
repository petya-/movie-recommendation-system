function getMoviesByGenre(movieID) {
    var movie = db.movies.findOne({'movieId': movieID}, { _id : 0, genres : 1 })
    if (movie.genres) {
        return db.movies.find({'genres': movie.genres })
    } else {
        throw Error('Movie has no genres')
    }
}

function getMoviesByRating(userID) {
    var ratedMovies = db.ratings.find({'userId': userID}, { _id : 0, movieId : 1 });
    var movieId = []
    ratedMovies.forEach(val => {
        movieId.push(val.movieId);
    });
    return db.movies.find({'movieId': {$nin: movieId}})
}

function searchMovie(movieName) {
    
}

function addReview(userID, movieID, text ) {
    db.reviews.insert({
        'userId': userID,
        'movieId': movieID,
        'review_text': text,
        'timestamp':  $currentDate
    })
}