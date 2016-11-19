var express = require('express'),
bodyParser = require('body-parser'),
app = express();
app.use(bodyParser.json());
// app.use(express.urlencoded());
app.use(bodyParser.urlencoded({
  extended: true
}));

var twilio = require('twilio'),
client = twilio('AC1acbcc7f6ef2e5df59f9fb992a96002d', '4e65a9376d401148d92ef63e9cad750b'),
cronJob = require('cron').CronJob;

var pretendDB = {'numbers': ["4046928439","2818414898"]};

app.post('/notify/all', function (req, res) {
  // get numbers from DB
  const numbers = pretendDB.numbers;  
  
  // user requests the following
  const location = req.body.location;
  const item = req.body.item;
  const username = req.body.username;
  // var numbers = req.body.numbers.split(",");
  
  for( var i = 0; i < numbers.length; i++ ) {
    client.sendMessage( { to:numbers[i], from:'12482136765', body:'Hey! ' + username + ' needs ' + item + ' at ' + location}, function( err, data ) {
      if (err) {
        console.log("Error! " + err.message);
      } else {
        console.log( data.body );
      }
      
    });
  }
  
  var resp = new twilio.TwimlResponse();
  resp.message('Thanks for subscribing!');
  res.writeHead(200, {
    'Content-Type':'text/xml'
  });
  res.end(resp.toString());
  console.log('test');
});

app.get('/info', function (req, res) {
  const resp = "This is an informational message";
  const params = req.query;
  const team = params["team"];
  const month = params["month"];
  console.log("You asked for team: " + team + " in month: " + month);
  // res.writeHead(200, {
  //   'Content-Type':'text/xml'
  // });
  res.send("You asked for team: " + team + " in month: " + month);
  // console.log('test');
});

var server = app.listen(3000, function() {
  console.log('Listening on port 3000', server.address().port);
});

