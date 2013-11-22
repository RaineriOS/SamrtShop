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
app.use("/media", express.static('/Users/macowner/Pictures/smartShop'));
app.use(app.router);
app.use(express.errorHandler());

// This queue is filled with shops to be checked if they exists in the db or not
var shopsInfoQueue = [];
// This queue is filled with shops which defienitly don't exist in db
var insertIntoShopsQueue = [];

// A function which is run every 1 sec in order to see anything new has been put inside the info queue
function emptyShopInfoQueue() {
	var numShops = shopsInfoQueue.length;
	for (var i=0; i<numShops; i++) {
		var newShopInfo = shopsInfoQueue[i];
		// call the exist function which checks the database
		checkShopExists.apply(null, newShopInfo);
	}
	shopsInfoQueue.splice(0, numShops);
}

// called every 2 secs in order to empty the insert queue and create new shops in the db
function emptyInsertIntoShopsQueue(name, lat, lng) {
	if(shopsInfoQueue.length == 0) {
		var recursiveCallBack = function () {
			var newShopInfo = insertIntoShopsQueue.pop();
			if (insertIntoShopsQueue.length == 0 && newShopInfo != undefined)
				insertIntoShops.apply(null, newShopInfo);
			else if (newShopInfo != undefined){
				newShopInfo.push(recursiveCallBack);
				insertIntoShops.apply(null, newShopInfo);
			}
		};
		recursiveCallBack();

	}
}

// Check if the shop exists in table or not
function checkShopExists(name, lat, lng) {
	var db = new sqlite3.Database(dbFile);
	db.serialize(function() {
		var stmt = db.prepare("SELECT * FROM shops WHERE name=? AND lat=? AND lng=?");
		stmt.all(name, lat, lng, function(err, rows) {
			if (rows == undefined || rows.length == 0 ) {
				insertIntoShopsQueue.push([name, lat, lng]);
			}
		});
		stmt.finalize();
	});
}

// The function which is used to insert into shops table
function insertIntoShops(name, lat, lng, callback) {
	var db = new sqlite3.Database(dbFile);
	var stmt = db.prepare("INSERT INTO shops (name, lat, lng) VALUES (?, ?, ?)");
	stmt.run([name, lat, lng], function () {
		if(callback)
			callback();
	});
	stmt.finalize();
	db.close();
}


// Intervals of updating the info queue and insert queues
setInterval(emptyShopInfoQueue, 1000);
setInterval(emptyInsertIntoShopsQueue, 2000);


function getShop(name, lat, lng, callback) {
	var db = new sqlite3.Database(dbFile);
	var stmt = db.prepare("SELECT * FROM shops WHERE name=? AND lat=? AND lng=?");
	stmt.all(name, lat, lng, function(err, rows) {
		if(callback)
			callback(err, rows);
	});
	stmt.finalize();
	db.close();
}

function insertIntoPosts(userID, shopID, imageName, content){
	var db = new sqlite3.Database(dbFile);
	var stmt = db.prepare("INSERT INTO posts (user_id, shop_id, image_name, content) VALUES (?, ?, ?, ?)");
	stmt.run([userID, shopID, imageName, content]);
	stmt.finalize();
	db.close();
}

app.post('/image', function (req, res){
	// console.log(req.body);
	// console.log(req.files);
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
	shopsInfoQueue.push([req.body.name, req.body.lat, req.body.lng]);
	res.json({saved:'success'});
});
// Create a new post - also when the shop detail is give,
// if the shop does not exist, create it.
app.post('/post', function (req, res){
	req.body = JSON.parse(req.body.body);
	getShop(req.body.name, req.body.lat, req.body.lng, function (err, rows){
		if (rows == undefined || rows.length == 0 ) {
			var db = new sqlite3.Database(dbFile);
			var stmt = db.prepare("INSERT INTO shops (name, lat, lng) VALUES (?, ?, ?)");
			stmt.run([req.body.name, req.body.lat, req.body.lng], function(){
				insertIntoPosts(req.body.user_id, this.lastID, imageName,
					req.body.content);
				res.json({saved:'success'});
			});
			stmt.finalize();
			db.close();
		} else {
			insertIntoPosts(req.body.user_id, rows[0].id, imageName,
					req.body.content);
			res.json({saved:'success'});
		}
	});
	var imagePathArr = req.files.recording.path.split("/");
	var imageName = imagePathArr[imagePathArr.length-1];
});

app.put('/post', function(req, res) {
	var db = new sqlite3.Database(dbFile);
	var stmt;
	if (req.body.field == "hot")
		stmt = db.prepare("UPDATE posts SET hot=hot+1 WHERE id = ? ");
	if (req.body.field == "cool")
		stmt = db.prepare("UPDATE posts SET cool=cool+1 WHERE id = ? ");
	if (req.body.field == "freezing")
		stmt = db.prepare("UPDATE posts SET freezing=freezing+1 WHERE id = ? ");
	stmt.run([req.body.id]);
	stmt.finalize();
	db.close();
	res.json({saved:'success'});
});

app.get('/post', function(req, res){
	var db = new sqlite3.Database(dbFile);
	db.all("SELECT posts.id, posts.user_id, posts.burning, posts.hot, posts.cool, posts.cold, posts.freezing, posts.image_name, posts.content, shops.name, shops.lat, shops.lng FROM posts INNER JOIN shops WHERE shops.id == posts.shop_id", function(err, rows) {
		// Turn the returned rows which are joined into obejcts which can 
		// represent objects of posts and shops
		var posts = [];
		for (var i=0; i<rows.length; i++) {
			var row = rows[i];
			var post = {
				id: row.id,
				user_id: row.user_id,
				burning: row.burning,
				hot: row.hot,
				cool: row.cool,
				cold: row.cold,
				freezing: row.freezing,
				image_name: row.image_name,
				content: row.content,
				shop: {
					id: row.shop_id,
					name: row.name,
					location: {
						lat: row.lat,
						lng: row.lng
					}
				}
			};
			posts.push(post);
		}
		res.json({results:posts});
		db.close();
	});
});

app.get('/user', function (req, res) {
	var db = new sqlite3.Database(dbFile);
	db.all("SELECT * FROM users", function(err, rows) {
		res.json({results:rows});
	});
	db.close();
});

app.listen(3000);
console.log('Listening on port 3000');
