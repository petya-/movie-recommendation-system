-- Create Database: lhrDB

CREATE DATABASE "movieSystem"
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

-- Connect to the database
\connect movieSystem

-- Add needed extensions

-- create extension cube;
-- create extension fuzzystrmatch;
-- create extension pg_trgm;
-- create extension pgcrypto;


-- Create tables

CREATE TABLE users (
    id SERIAL  NOT NULL PRIMARY KEY,
    email text UNIQUE,
    password text,
    firstname text,
    lastname text,
    enabled boolean DEFAULT TRUE,
    "createdAt" timestamp DEFAULT now(),
    "updatedAt" timestamp DEFAULT now()
);

-- CREATE TABLE access_tokens (
--     id SERIAL PRIMARY KEY,
--     ttl integer,
--     userId integer REFERENCES users NOT NULL,
--     createdAt timestamp DEFAULT now(),
--     updatedAt timestamp DEFAULT now()
-- );

-- CREATE TABLE genres (
--     id SERIAL PRIMARY KEY,
--     name text UNIQUE,
--     position integer,
--     createdAt timestamp DEFAULT now(),
--     updatedAt timestamp DEFAULT now()

-- );

CREATE TABLE movies (
    id SERIAL NOT NULL PRIMARY KEY,
    title text NOT NULL,
    genres text,
    "createdAt" timestamp DEFAULT now(),
    "updatedAt" timestamp DEFAULT now()
);
-- CREATE TABLE actors (
--     id SERIAL PRIMARY KEY,
--     name text,
--     createdAt timestamp DEFAULT now(),
--     updatedAt timestamp DEFAULT now()
-- );
-- CREATE TABLE movies_actors (
--     movie_id integer REFERENCES movies NOT NULL,
--     actor_id integer REFERENCES actors NOT NULL,
--     UNIQUE (movie_id, actor_id),
--     createdAt timestamp DEFAULT now(),
--     updatedAt timestamp DEFAULT now()
-- );
-- CREATE TABLE user_movies_lists (
--     id SERIAL PRIMARY KEY,
--     name text,
--     movie_id integer REFERENCES movies NOT NULL,
--     user_id integer REFERENCES users NOT NULL,
--     createdAt timestamp DEFAULT now(),
--     updatedAt timestamp DEFAULT now()
-- );
-- CREATE TABLE watched_movies (
--     id SERIAL PRIMARY KEY,
--     movie_id integer REFERENCES movies NOT NULL,
--     user_id integer REFERENCES actors NOT NULL,
--     createdAt timestamp DEFAULT now(),
--     updatedAt timestamp DEFAULT now()
-- );

CREATE TABLE ratings (
    id SERIAL PRIMARY KEY,
    rating double precision NOT NULL CHECK (rating BETWEEN 0. AND 5),
    "movieId" integer REFERENCES movies NOT NULL,
    "userId" integer REFERENCES users NOT NULL,
    timestamp integer,
    "createdAt" timestamp DEFAULT now(),
    "updatedAt" timestamp DEFAULT now()
);

CREATE TABLE links (
    id SERIAL PRIMARY KEY,
    "movieId" integer REFERENCES movies NOT NULL,
    "imdbId" integer,
    "tmdbId" integer,
    "createdAt" timestamp DEFAULT now(),
    "updatedAt" timestamp DEFAULT now()
);

CREATE TABLE tmp (
    "userId" integer,
    "movieId" integer,
    rating double precision,
    timestamp integer
);

-- -- Import data in table from csv
-- CREATE OR REPLACE FUNCTION importFromCSV( table text, filePath text )
-- RETURNS table(id integer) AS $$
-- BEGIN

--   RETURN QUERY EXECUTE
--   \COPY tmp("userId","movieId", rating, timestamp) FROM '/Users/petyabuchkova/Desktop/KEA/Databases/movieSystem/storage/ratings.csv' WITH CSV HEADER;

--   'SELECT u.id
--   FROM users u, (SELECT user_id FROM watched_movies WHERE movie_id = $1) wm
--   WHERE u.id = wm.user_id
--   AND u.id != $2'
--   USING movie_id, user_id;

-- END;
-- $$ LANGUAGE plpgsql;

-- Copy the data from the CSV files
-- You can cope by converting property types. We normalized the database. We needed to match keys

\COPY movies(id, title, genres) FROM '/Users/petyabuchkova/Desktop/KEA/Databases/movieSystem/storage/movies.csv' WITH CSV HEADER;
\COPY tmp("userId","movieId", rating, timestamp) FROM '/Users/petyabuchkova/Desktop/KEA/Databases/movieSystem/storage/ratings.csv' WITH CSV HEADER;



INSERT INTO users(id)
SELECT "userId" from tmp
ON CONFLICT DO NOTHING;

-- DELETE temp
DROP TABLE tmp;

-- Populate users before migrating other files
-- Replace the copy with a function
\COPY ratings("userId","movieId", rating, timestamp) FROM '/Users/petyabuchkova/Desktop/KEA/Databases/movieSystem/storage/ratings.csv' WITH CSV HEADER;
\COPY links("movieId","imdbId", "tmdbId") FROM '/Users/petyabuchkova/Desktop/KEA/Databases/movieSystem/storage/links.csv' WITH CSV HEADER;

-- Populate users

-- Create indexes
-- CREATE INDEX movies_actors_movie_id ON movies_actors (movie_id);
-- CREATE INDEX movies_actors_actor_id ON movies_actors (actor_id);
-- CREATE INDEX watched_movies_movie_id ON watched_movies (movie_id);
-- CREATE INDEX watched_movies_user_id ON watched_movies (user_id);
-- CREATE INDEX user_movies_lists_movie_id ON user_movies_lists (movie_id);
-- CREATE INDEX user_movies_lists_user_id ON user_movies_lists (user_id);
-- CREATE INDEX ratings_movie_id ON ratings (movie_id);
-- CREATE INDEX ratings_user_id ON ratings (user_id);
-- CREATE INDEX movies_title_pattern ON movies (lower(title) text_pattern_ops);
-- CREATE INDEX movies_title_trigram ON movies USING gist(title gist_trgm_ops);
-- CREATE INDEX movies_title_searchable ON movies USING gin(to_tsvector('english', title));
-- CREATE INDEX movies_genres_cube ON movies USING gist (genre);
