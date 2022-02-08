var fs = require('fs');
var file = fs.readFileSync('deploy_hardhat.log', 'utf8');
while (file.indexOf('Contract address:') != -1) {
 file = file.substring(file.indexOf('Contract address:'));
 file = file.substring(file.indexOf('0x'));
 var address = file.substring(0, file.indexOf("\n"));
 console.log(address);
}

