
let exec = require('child_process').exec
let command1 = 'mongoimport -d recomendationSystems -c movies --type CSV --file ml-latest/movies.csv --headerline'
let command2 = 'mongoimport -d recomendationSystems -c ratings --type CSV --file ml-latest/ratings.csv --headerline'
let command3 = 'mongoimport -d recomendationSystems -c links --type CSV --file ml-latest/links.csv --headerline'
exec(command1,command2,command3,  (err, stdout, stderr) => {
  child_process.execSync(command1[options]);
  child_process.execSync(command2[options]);
  child_process.execSync(command3[options]);
})

