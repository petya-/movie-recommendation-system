
let exec = require('child_process').exec;
exec('mongoimport -d recomendationSystems -c movies --type CSV --file ../ml-latest/movies.csv --headerline');
exec('mongoimport -d recomendationSystems -c ratings --type CSV --file ../ml-latest/ratings.csv --headerline');
exec('mongoimport -d recomendationSystems -c links --type CSV --file ../ml-latest/links.csv --headerline');

