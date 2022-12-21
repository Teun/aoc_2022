const sol = require('./solution.js');
const fs = require('fs');
var input = fs.readFileSync('../input/17.txt');
var result = sol.part1(input);
console.log(result);
