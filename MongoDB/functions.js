function getMoviesByAllGenre(movieID) {
    var movie = db.movies.findOne({'movieId': movieID}, { _id : 0, genres : 1 })
    if (movie.genres) {
        return db.movies.find({'genres': movie.genres })
    } else {
        throw Error('Movie has no genres')
    }
}

function getMoviesByOneGenre(movieID) {
    var movie = db.movies.findOne({'movieId': movieID}, { _id : 0, genres : 1 })
    if (movie.genres) {
        var genres = movie.genres.split('|');
        for (let index = 0; index < genres.length; index++) {
            return db.movies.find({'genres': {$regex: genres[index]} })
            
        }
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

function searchMovie() { 
    return db.movies.find({ title : {$regex: 'Powder'}})
    .explain("executionStats").executionStats
}

function titleIndex() {
    db.movies.dropIndex( { title : 1 });
}

function addReview(userID, movieID, text ) {
    if (userID, movieID, text) {
        db.reviews.insert({
            'userId': userID,
            'movieId': movieID,
            'review_text': text,
            'timestamp':  Date()
        })
    } else {
        throw Error('Some fields are missing')
    }
}


        function getReviewsForMovie(movieID) {
            return db.reviews.find({'movieId': movieID});
        }
