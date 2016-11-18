#!/usr/bin/js
var fs     = require("fs");
var events = require('events');

// print process.argv
//process.argv.forEach(function (val, index, array) {
//    console.log(index + ': ' + val);
//});
if(0) {
    f  = '/tmp/metar.json';
    jq = 'response.data[0].METAR[0].temp_c[0]';
} else {
    f  = process.argv[2];
    jq = process.argv[3];
}

//console.log("F = " + f);
//console.log("Q = " + jq);

function loadJSON(file) {
    // @FIXME: failed reloads crash the program
    // At the moment we don't have a way of catching a bad reload and continuing
    // with the previous safe load (well we're part way there but not done)
    try {
        var data = fs.readFileSync(file);

        // JSON.parse doesn't like newlines
        // so we cleaned it up
        data = data.toString();
        data = data.replace(/(\n|\r)/gm,"");

        var json = JSON.parse(data);

        return(json);
    }
    catch(err) {
        console.error("File load error, " + file + "(" + err.message + ")");
        // process.exit(1);
        throw err;
    }
}

// @FIXED: Need to keep track of the state of all the zones, we now havs status.zones

j = loadJSON(f);

// need to deal with errors
console.log(eval("j."+jq));
/*
> console.log(j.response.data[0].METAR[0]);
{ raw_text: [ 'KTTN 171253Z 30005KT 10SM CLR 09/04 A3002 RMK AO2 SLP161 T00890044' ],
  station_id: [ 'KTTN' ],
  observation_time: [ '2016-11-17T12:53:00Z' ],
  latitude: [ '40.28' ],
  longitude: [ '-74.82' ],
  temp_c: [ '8.9' ],
  dewpoint_c: [ '4.4' ],
  wind_dir_degrees: [ '300' ],
  wind_speed_kt: [ '5' ],
  visibility_statute_mi: [ '10.0' ],
  altim_in_hg: [ '30.02067' ],
  sea_level_pressure_mb: [ '1016.1' ],
  quality_control_flags: [ { auto_station: [Object] } ],
  sky_condition: [ { '$': [Object] } ],
  flight_category: [ 'VFR' ],
  metar_type: [ 'METAR' ],
  elevation_m: [ '59.0' ] }
undefined
> console.log(j.response.data[0].METAR[0].temp_c);
[ '8.9' ]
undefined
> 

what I need is
$ readjson /tmp/metar.json response.data[0].METAR[0].temp_c
8.9
*/
