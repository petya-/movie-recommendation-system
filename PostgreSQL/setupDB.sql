
-- Create Database: movieSystem
CREATE DATABASE "movieSystem"
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

-- Connect to the database
\connect movieSystem

-- Create tables
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email text UNIQUE,
    password text,
    firstname text,
    lastname text,
    enabled boolean DEFAULT TRUE,
    createdAt timestamp DEFAULT now(),
    updatedAt timestamp DEFAULT now()
);

CREATE TABLE movies (
    id SERIAL PRIMARY KEY,
    title text NOT NULL,
    genres text NOT NULL,
    createdAt timestamp DEFAULT now(),
    updatedAt timestamp DEFAULT now()
);

CREATE TABLE ratings (
    id SERIAL PRIMARY KEY,
    rating decimal NOT NULL CHECK (rating BETWEEN 0. AND 5),
    movieId integer REFERENCES movies NOT NULL,
    userId integer REFERENCES users NOT NULL,
    timestamp integer,
    createdAt timestamp DEFAULT now(),
    updatedAt timestamp DEFAULT now()
);

CREATE TABLE links (
    id SERIAL PRIMARY KEY,
    movieId integer REFERENCES movies NOT NULL,
    imdbId integer,
    tmdbId integer,
    createdAt timestamp DEFAULT now(),
    updatedAt timestamp DEFAULT now()
);

CREATE TABLE tags (
    userId integer REFERENCES users NOT NULL,
    movieId integer REFERENCES movies NOT NULL,
    tag text,
    timestamp integer,
    createdAt timestamp DEFAULT now(),
    updatedAt timestamp DEFAULT now()
);

CREATE TABLE tmp (
    userId integer,
    movieId integer,
    rating text,
    timestamp integer
);

-- Copy the data from the CSV files into movies and tmp
\COPY movies(id, title, genres) FROM '/Users/petyabuchkova/Desktop/KEA/Databases/movieSystem/storage/movies.csv' WITH CSV HEADER;
\COPY tmp(userId,movieId, rating, timestamp) FROM '/Users/petyabuchkova/Desktop/KEA/Databases/movieSystem/storage/ratings.csv' WITH CSV HEADER;


-- Sync user ids with ratings
INSERT INTO users(id)
SELECT DISTINCT userId from tmp;

-- DROP temp table
DROP TABLE tmp;

-- Copy the data from the CSV files into ratings and links
\COPY ratings(userId, movieId, rating, timestamp) FROM '/Users/petyabuchkova/Desktop/KEA/Databases/movieSystem/storage/ratings.csv' WITH CSV HEADER;
\COPY links(movieId, imdbId, tmdbId) FROM '/Users/petyabuchkova/Desktop/KEA/Databases/movieSystem/storage/links.csv' WITH CSV HEADER;
\COPY tags(userId, movieId, tag, timestamp) FROM '/Users/petyabuchkova/Desktop/KEA/Databases/movieSystem/storage/tags.csv' WITH CSV HEADER;

-- Sync user ids with tags
INSERT INTO users(id)
SELECT DISTINCT userId FROM tags
ON CONFLICT (id) DO NOTHING;

-- Create indexes
CREATE INDEX movies_genre ON movies (genres);
CREATE INDEX movies_title ON movies (title);
CREATE INDEX ratings_user ON ratings (userId);
CREATE INDEX ratings_movie ON ratings (movieId);
CREATE INDEX links_movie ON links (movieId);

--------------------  Demonstrate basic CRUD functionality of new movies and ratings --------------------

-- Set movie id sequence
SELECT setval('movies_id_seq', (SELECT MAX(id) FROM "movies"));

-- Create movie
INSERT INTO movies (title, genres)
VALUES
    ('The French Connection','Documentary'),
    ('Blowup','Comedy|Action'),
    ('Breathless','Thriller'),
    ('Arlington Road','Comedy|Romance|Drama'),
    ('Point Break','Fiction|Comedy');
-- Get movie
SELECT title
FROM movies
WHERE title = 'Blowup';
-- Update movie
UPDATE movies
SET title = 'Blowup 2'
WHERE title = 'Blowup';
-- Delete movie
DELETE FROM movies
WHERE title = 'Blowup 2';

-- Create rating
INSERT INTO ratings (rating, movieId, userId, timestamp)
VALUES (4.5, 2, 14, 1234);
-- Get rating
SELECT rating
FROM ratings
WHERE rating = 4.5
AND movieId = 2
AND userId = 14;
-- Update rating
UPDATE ratings
SET rating = 3
WHERE rating = 4.5
AND userId = 14
AND movieId = 2;
-- Delete rating
DELETE FROM ratings
WHERE rating = 3
AND movieId = 2
AND userId = 14;


-- Recommend movies based on genres function
CREATE OR REPLACE FUNCTION find_same_genre_movies(movieId integer, limiter integer)
    RETURNS TABLE (title text, genres text)
AS $$
DECLARE genresArr text[] := (SELECT string_to_array(movies.genres, '|') FROM movies where id =  $1);
BEGIN
    RETURN query
    SELECT m.title, m.genres
    FROM movies AS m
    WHERE string_to_array(m.genres, '|') && genresArr
    AND m.id != $1
    LIMIT $2;
END;
$$
LANGUAGE plpgsql;

SELECT title, genres FROM movies WHERE id=10;
SELECT find_same_genre_movies(10, 7);

-- Recommend not rated movies to a user function
CREATE OR REPLACE FUNCTION find_non_rated_movies (userId integer, limiter integer)
    RETURNS TABLE (id integer, title text)
AS $$
DECLARE
 ratedMoviesIds integer[] := ARRAY(SELECT r.movieId FROM ratings as r WHERE r.userId = $1);
BEGIN
    RETURN query
    SELECT m.id, m.title
    FROM movies as m
    WHERE m.id <> ALL (ARRAY[ratedMoviesIds])
    LIMIT $2;
END;
$$
LANGUAGE plpgsql;

SELECT movieId FROM ratings WHERE userId = 6 LIMIT 5;
SELECT find_non_rated_movies(6, 10);

-- Search movies with input errors
CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE INDEX movies_title_trigram ON movies USING gist (title gist_trgm_ops);

CREATE OR REPLACE FUNCTION search_movie_by_title (movieTitle text)
  RETURNS TABLE (title text) AS $$
    BEGIN
        RETURN query
        SELECT m.title
        FROM movies as m
        WHERE m.title % movieTitle;
    END;
    $$ LANGUAGE plpgsql;

SELECT search_movie_by_title('Stanby');
SELECT search_movie_by_title('Ballerma');
SELECT search_movie_by_title('a hose of secrets expolre');

-- FUTURE IMPLEMENTATION --
-- Populate users table and apply constraint:
-- ALTER TABLE users ALTER COLUMN email SET UNIQUE NOT NULL;
-- ALTER TABLE users ALTER COLUMN password SET UNIQUE NOT NULL;
