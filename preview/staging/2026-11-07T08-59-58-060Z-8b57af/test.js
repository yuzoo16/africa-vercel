const d = require('./data/i18n/de-hubs.json');
console.log(d['southern-africa-safari'] ? 'yes' : 'no');
if(d['southern-africa-safari']) console.log(d['southern-africa-safari'].lead?.substring(0,80));
