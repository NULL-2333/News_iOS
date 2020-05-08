const express = require('express');
const app = express();
const XMLHttpRequest = require("xmlhttprequest").XMLHttpRequest;
const cors = require('cors');
const fetch = require('node-fetch')
const googleTrends = require('google-trends-api');
 
app.use(cors());

var guardian_news_api = "https://content.guardianapis.com/";
var g_home_api = "https://content.guardianapis.com/search?api-key=721208c3-5338-41a4-9d89-3ea1b4999892&section=(sport|business|technology|politics)&show-blocks=all"
var g_section_api = "https://content.guardianapis.com/[SECTION_NAME]?api-key=721208c3-5338-41a4-9d89-3ea1b4999892&show-blocks=all"
var g_search_article_api = 'https://content.guardianapis.com/[ARTICLE_ID]?api-key=721208c3-5338-41a4-9d89-3ea1b4999892&show-blocks=all'
var g_search_query_api = 'https://content.guardianapis.com/search?q=[QUERY_KEYWORD]&api-key=721208c3-5338-41a4-9d89-3ea1b4999892&show-blocks=all'
var g_topnews_api = "https://content.guardianapis.com/search?orderby=newest&show-fields=starRating,headline,thumbnail,short-url&api-key=721208c3-5338-41a4-9d89-3ea1b4999892"
var monthToString = ["Jan", "Feb", "Mar", "Apr", "May", "June", "July", "Aug", "Sept", "Oct", "Nov", "Dec"]

app.get('/', function (req, res) {
    res.send("Welcome to Node.js");
});
// guardian with section
app.get('/guardian', function (req, res) {
    var sectionName = req.query['section']
    res.setHeader('Content-Type', 'application/json; charset=utf8');
    var api_url = "https://content.guardianapis.com/" + sectionName + "?api-key=721208c3-5338-41a4-9d89-3ea1b4999892&show-blocks=all"
    fetch(api_url)
        .then((response) => {
            return response.json();
        })
        .then((jsonObj) => {
            var results = [];
            var jo = jsonObj.response.results;
            for(let i = 0; i < Math.min(10, jo.length); i++){
                var urlToImg = "NOIMAGE";
                if(jo[i].blocks === undefined || jo[i].blocks.main === undefined || jo[i].blocks.main.elements[0] === undefined 
                    || jo[i].blocks.main.elements[0].assets === undefined){
                    urlToImg = "NOIMAGE";
                }
                else if(jo[i].blocks.main.elements[0].assets.length > 0){
                    urlToImg = jo[i].blocks.main.elements[0].assets.slice(-1)[0].file
                }
                var time = jo[i].webPublicationDate.split("T")[0]
                var year = time.split("-")[0];
                var month = parseInt(time.split("-")[1]);
                var day = time.split("-")[2];
                var formatedTime = day + " " + monthToString[month - 1];
                var curTime = new Date();
                var oldTime = new Date(jo[i].webPublicationDate)
                var timeDiff = curTime.getTime() - oldTime.getTime();
                var secondDiff = timeDiff / 1000;
                var minuteDiff = secondDiff / 60;
                var hourDiff = minuteDiff / 60;
                var diff;
                if(hourDiff >= 1){
                    diff = Math.floor(hourDiff).toString() + "h ago";
                }
                else if(minuteDiff >= 1){
                    diff = Math.floor(minuteDiff).toString() + "m ago";
                }
                else{
                    diff = Math.floor(secondDiff).toString() + "s ago";
                }
                results.push({
                    id: jo[i].id,
                    title: jo[i].webTitle,
                    url: jo[i].webUrl,
                    urlToImg: urlToImg,
                    section: jo[i].sectionName.toLowerCase().replace(/( |^)[a-z]/g, (L) => L.toUpperCase()),
                    time: formatedTime,
                    timeDiff: diff
                });
            }
            res.send(results);
        });
});

// guardian with search
app.get('/guardian/search', function (req, res) {
    var q = req.query['q'];
    res.setHeader('Content-Type', 'application/json; charset=utf8');
    var api_url = 'https://content.guardianapis.com/search?q=' + q + '&api-key=721208c3-5338-41a4-9d89-3ea1b4999892&show-blocks=all'
    fetch(api_url)
        .then((response) => {
            return response.json();
        })
        .then((jsonObj) => {
            var results = [];
            var jo = jsonObj.response.results;
            for(let i = 0; i < Math.min(10, jo.length); i++){
                var urlToImg = "NOIMAGE";
                if(jo[i].blocks === undefined || jo[i].blocks.main === undefined || jo[i].blocks.main.elements[0] === undefined 
                    || jo[i].blocks.main.elements[0].assets === undefined){
                    urlToImg = "NOIMAGE";
                }
                else if(jo[i].blocks.main.elements[0].assets.length > 0){
                    urlToImg = jo[i].blocks.main.elements[0].assets.slice(-1)[0].file
                }
                var time = jo[i].webPublicationDate.split("T")[0]
                var year = time.split("-")[0];
                var month = parseInt(time.split("-")[1]);
                var day = time.split("-")[2];
                var formatedTime = day + " " + monthToString[month - 1];
                var curTime = new Date();
                var oldTime = new Date(jo[i].webPublicationDate)
                var timeDiff = curTime.getTime() - oldTime.getTime();
                var secondDiff = timeDiff / 1000;
                var minuteDiff = secondDiff / 60;
                var hourDiff = minuteDiff / 60;
                var diff;
                if(hourDiff >= 1){
                    diff = Math.floor(hourDiff).toString() + "h ago";
                }
                else if(minuteDiff >= 1){
                    diff = Math.floor(minuteDiff).toString() + "m ago";
                }
                else{
                    diff = Math.floor(secondDiff).toString() + "s ago";
                }
                results.push({
                    id: jo[i].id,
                    title: jo[i].webTitle,
                    url: jo[i].webUrl,
                    urlToImg: urlToImg,
                    section: jo[i].sectionName.toLowerCase().replace(/( |^)[a-z]/g, (L) => L.toUpperCase()),
                    time: formatedTime,
                    timeDiff: diff
                });
            }
            res.send(results);
        });
});

app.get('/guardian/top', function(req, res){
    res.setHeader('Content-Type', 'application/json; charset=utf8');
    fetch(g_topnews_api)
        .then((response) => {
            return response.json();
        })
        .then((jsonObj) => {
            var results = [];
            var jo = jsonObj.response.results;
            for(let i = 0; i < Math.min(10, jo.length); i++){
                var urlToImg;
                if(jo[i].fields === undefined || jo[i].fields.thumbnail === undefined){
                    urlToImg = "NOIMAGE";
                }
                else{
                    urlToImg = jo[i].fields.thumbnail;
                }
                var time = jo[i].webPublicationDate.split("T")[0]
                var year = time.split("-")[0];
                var month = parseInt(time.split("-")[1]);
                var day = time.split("-")[2];
                var formatedTime = day + " " + monthToString[month - 1];
                var curTime = new Date();
                var oldTime = new Date(jo[i].webPublicationDate)
                var timeDiff = curTime.getTime() - oldTime.getTime();
                var secondDiff = timeDiff / 1000;
                var minuteDiff = secondDiff / 60;
                var hourDiff = minuteDiff / 60;
                var diff;
                if(hourDiff >= 1){
                    diff = Math.floor(hourDiff).toString() + "h ago";
                }
                else if(minuteDiff >= 1){
                    diff = Math.floor(minuteDiff).toString() + "m ago";
                }
                else{
                    diff = Math.floor(secondDiff).toString() + "s ago";
                }
                results.push({
                    id: jo[i].id,
                    title: jo[i].webTitle,
                    url: jo[i].webUrl,
                    urlToImg: urlToImg,
                    section: jo[i].sectionName.toLowerCase().replace(/( |^)[a-z]/g, (L) => L.toUpperCase()),
                    time: formatedTime,
                    timeDiff: diff
                });
            }
            res.send(results);
        });
})

app.get('/guardian/article', function(req, res){
    var article_id = req.query['id'];
    res.setHeader('Content-Type', 'application/json; charset=utf8');
    var url = "https://content.guardianapis.com/" + article_id + "?api-key=721208c3-5338-41a4-9d89-3ea1b4999892&show-blocks=all"
    fetch(url)
        .then((response) => {
            return response.json();
        })
        .then((jsonObj) => {
            var results;
            var jo = jsonObj.response.content;
            var urlToImg = "NOIMAGE";
            if(jo.blocks === undefined || jo.blocks.main === undefined || jo.blocks.main.elements[0] === undefined 
                || jo.blocks.main.elements[0].assets === undefined){
                urlToImg = urlToImg;
            }
            else if(jo.blocks.main.elements[0].assets.length > 0){
                urlToImg = jo.blocks.main.elements[0].assets.slice(-1)[0].file
            }
            var time = jo.webPublicationDate.split("T")[0]
            var year = time.split("-")[0];
            var month = parseInt(time.split("-")[1]);
            var day = time.split("-")[2];
            var formatedTime = day + " " + monthToString[month - 1] + " " + year;
            var description = "";
            if(jo.blocks === undefined || jo.blocks.body === undefined){
                description = "No Description";
            }
            else {
                var desLen = jo.blocks.body.length;
                for(i = 0; i < desLen; i++){
                    description += jo.blocks.body[i].bodyHtml;
                }
                description = description.replace(/iframe/g, "p");
            }
            results = {
                id: jo.id,
                title: jo.webTitle,
                url: jo.webUrl,
                urlToImg: urlToImg,
                section: jo.sectionName.toLowerCase().replace(/( |^)[a-z]/g, (L) => L.toUpperCase()),
                time: formatedTime,
                description: description
            };
            res.send(results);
        });
})

app.get('/guardian/trending', function(req, res) {
    res.setHeader('Content-Type', 'application/json; charset=utf8');
    var keyword = req.query['keyword'];
    googleTrends.interestOverTime({
        keyword: keyword,
        startTime: new Date('2019-06-01'),
        endTime: new Date()
    })
    .then(function(results){
        var jsonObj = JSON.parse(results).default.timelineData;
        var jsonLen = jsonObj.length
        var result = []
        for(i = 0; i < jsonLen; i++){
            result.push({
                x: i,
                y: jsonObj[i].value[0]
            });
        }
        res.send(result)
    })
    .catch(function(err){
        console.error(err);
    });
})
app.listen(8081, function(){
    console.log("http://localhost:8081");
})