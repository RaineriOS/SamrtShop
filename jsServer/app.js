var express = require('express');
var sqlite3 = require('sqlite3').verbose();
var dbFile = 'smartShop.sqlite3';
var db = new sqlite3.Database(dbFile);
db.serialize(function() {
	db.run("CREATE TABLE IF NOT EXISTS posts (id INTEGER PRIMARY KEY AUTOINCREMENT , user_id INTEGER, shop_id INTEGER, burning INTEGER DEFAULT 0, hot INTEGER DEFAULT 0, cool INTEGER DEFAULT 0, cold INTEGER DEFAULT 0, freezing INTEGER DEFAULT 0, image_name TEXT, content TEXT)");
	db.run("CREATE TABLE IF NOT EXISTS shops (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, lat REAL, lng REAL)");
	db.run("CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, username TEXT, current_lat REAL, current_lng REAL)");
	db.close();
});
db = null;
var app = express();

app.use(express.logger('dev'));
// app.use(express.json());
// app.use(express.urlencoded());
// app.use(express.multipart());
app.use(express.bodyParser({ keepExtensions: true, uploadDir: '/Users/macowner/Pictures/smartShop' }));
app.use(app.router);
app.use(express.errorHandler());

app.post('/image', function (req, res){
	console.log(req.body);
	console.log(req.files);
	res.json({saved:'success'});
});
// Create new user
app.post('/user', function (req, res){
	var db = new sqlite3.Database(dbFile);
	var stmt = db.prepare("INSERT INTO users (name, username, current_lat, current_lng) VALUES (?, ?, ?, ?)");
	stmt.run([req.body.name, req.body.username,
			  req.body.current_lat, req.body.current_lng]);
	stmt.finalize();
	db.close();
	res.json({saved:'success'});
});

//app.param('username', /^(\w+)$/);

app.get('/user/:username', function(req, res){
	var db = new sqlite3.Database(dbFile);

	var stmt = db.prepare("SELECT * FROM users WHERE username=?");
	stmt.all(req.params.username, function(err, rows) {
		res.json(rows);
	});
	stmt.finalize();
	db.close();
});


// Create new shop
app.post('/shop', function (req, res){
	var db = new sqlite3.Database(dbFile);
	var stmt = db.prepare("INSERT INTO shops (name, lat, lng) VALUES (?, ?, ?)");
	stmt.run([req.body.name, req.body.lat, req.body.lng]);
	stmt.finalize();
	db.close();
	res.json({saved:'success'});
});

app.post('/post', function (req, res){
	// console.log(req.body);
	var db = new sqlite3.Database(dbFile);
	var stmt = db.prepare("INSERT INTO posts (user_id, shop_id, image_name, content) VALUES (?, ?, ?, ?)");
	stmt.run([req.body.user_id, req.body.shop_id,
			  req.body.image_name, req.body.content]);
	stmt.finalize();
	db.close();
	res.json({saved:'success'});
});

app.get('/post', function(req, res){
	var db = new sqlite3.Database(dbFile);
	db.all("SELECT * FROM posts", function(err, rows) {
		res.json(rows);
		db.close();
	});
});

app.listen(3000);
console.log('Listening on port 3000');
