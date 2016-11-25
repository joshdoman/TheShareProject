var express = require('express'),
bodyParser = require('body-parser'),
app = express();
app.use(bodyParser.json());
// app.use(express.urlencoded());
app.use(bodyParser.urlencoded({
  extended: true
}));

var json = require('json');

var twilio = require('twilio'),
client = twilio('AC1acbcc7f6ef2e5df59f9fb992a96002d', '4e65a9376d401148d92ef63e9cad750b'),
cronJob = require('cron').CronJob;

var Firebase = require("firebase-admin");

var serviceAccount = require("/Users/joshdoman/Documents/Project/ShareNode/theshareproject-c9742-firebase-adminsdk-okgvy-9aabfde878.json");

Firebase.initializeApp({
  credential: Firebase.credential.cert(serviceAccount),
  databaseURL: "https://theshareproject-c9742.firebaseio.com"
});

var db = Firebase.database();
//var ref = db.ref("numbers");
var requests = db.ref("requests");
var users = db.ref("users");
var data = db.ref("data");
//var testData = db.ref("testdata");
var testData = db.ref("testdata2");

var requesting = false;

var numbers = [];

// ref.on("value", function(snapshot) {
//   //console.log(snapshot.val());
//   for(var k in snapshot.val()) numbers.push(snapshot.val()[k]);
//   console.log(numbers);
// }, function (errorObject) {
//   console.log("The read failed: " + errorObject.code);
// });

// ref.on("child_added", function(snapshot, prevChildKey) {
//   var num = snapshot.val();
//   numbers.push(num);
//   console.log(num);
// });

users.on("child_added", function(snapshot, prevChildKey) {
  console.log(snapshot.val());
  console.log(snapshot.val().number);
  numbers.push(snapshot.val().number);
});

function pushRequest(uid, username, location, item) {
  requests.child(uid).set({
    name: username,
    location: location,
    item: item
  });
  return;
}

//pushRequest("1232324324", "Alex2", "huntsman", "charger");

//var pretendDB = {'numbers': ["4046928439","2818414898"]};

app.post('/notify/all', function (req, res) {
  // get numbers from DB
  //const myNumbers = pretendDB.numbers; 
  //console.log("push"); 
  const myNumbers = numbers;
  // user requests the following
  const location = req.body.location;
  const item = req.body.item;
  const uid = req.body.uid;
  const username = req.body.username;
  const number = req.body.number;
  //console.log(number);
  // var numbers = req.body.numbers.split(",");
  
  pushRequest(uid, username, location, item);
  //pushRequest("Alex2", "huntsman", "charger");

  for( var i = 0; i < myNumbers.length; i++ ) {
    if(myNumbers[i] != number) {
      client.sendMessage( { to:myNumbers[i], from:'12482136765', body:'Hey! ' + username + ' needs ' + item + ' at ' + location}, function( err, data ) {
      if (err) {
        console.log("Error! " + err.message);
      } else {
        console.log( data.body );
      }
      
      });
    } else {
      console.log("sending message to requester");
    }
  }
  
  var resp = new twilio.TwimlResponse();
  resp.message('Thanks for subscribing!');
  res.writeHead(200, {
    'Content-Type':'text/xml'
  });
  res.end(resp.toString());
});

// app.get('/info', function (req, res) {
//   const resp = "This is an informational message";
//   const params = req.query;
//   const team = params["team"];
//   const month = params["month"];
//   console.log("You asked for team: " + team + " in month: " + month);
//   // res.writeHead(200, {
//   //   'Content-Type':'text/xml'
//   // });
//   res.send("You asked for team: " + team + " in month: " + month);
//   // console.log('test');
// });

requests.on("child_added", function(snapshot, prevChildKey) {
  console.log(snapshot.val().name);
  requesting = true;
});

requests.on("child_removed", function(snapshot) {
  requesting = false;
});


app.get('/info', function (req, res) {
  var resp = ""
  if (requesting) {
    resp = "requesting"
  }
  //console.log("Testing to see if we can get anything back from the server!");
  res.writeHead(200, {
    'Content-Type':'text/xml'
  });
  res.end(resp);
});

app.get('/getRequestInfo', function (req, res) {
    res.writeHead(200, {'Content-Type': "application/json"});
    testData.on("value", function(snapshot) {
      var requestDict = snapshot.val();
      //console.log("Item: " + requestDict.item)
      //console.log("Location: " + requestDict.location);
      //console.log(requestDict);
      var jsonDict = JSON.stringify(requestDict);
      console.log(jsonDict);
      console.log("request Dict: " + jsonDict);//TODO-- debugging output
      res.end(jsonDict);
    });
});

var server = app.listen(3000, function() {
  console.log('Listening on port 3000', server.address().port);
});

