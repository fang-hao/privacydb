#!/usr/bin/coffee
express = require 'express'
mkdirp = require 'mkdirp'
fs = require 'fs'
app = express()
app.use express.bodyParser()

app.listen 3000

console.log process.cwd()

randomInt = (min, max) -> Math.floor(Math.random() * (max - min + 1)) + min
generateId = -> "" + new Date().getTime() + randomInt 10000000, 99999999

writeDocument = (path, id, data, callback) ->
  filename = "#{path}/#{id}.json"
  mkdirp path, (err) ->
    if err
      callback 'COLLECTION_ERROR'
    else
      fs.writeFile filename, JSON.stringify(data), callback

deleteDocument = (path, id, callback) ->
  filename = "#{path}/#{id}.json"
  fs.unlink filename, callback

app.post '/:collection', (req, res) ->
  collection = req.params.collection
  id = generateId()
  writeDocument collection, id, req.body, (err) ->
    res.send if err then err: err else err:null, id: id

app.put '/:collection/:id', (req, res) ->
  collection = req.params.collection
  id = req.params.id
  writeDocument collection, id, req.body, (err) ->
    res.send err: err

app.delete '/:collection/:id', (req, res) ->
  collection = req.params.collection
  id = req.params.id
  deleteDocument collection, id, (err) ->
    res.send err: err

app.get '/:collection/:id', (req, res) ->
  collection = req.params.collection
  id = req.params.id
  readDocument collection, id, (err, data) ->
    res.send if err then err: err else err: null, data: data

app.put '/:collection/_view/:view', (req, res) ->
  collection = req.params.collection
  view = req.params.view
  writeDocument "#{collection}/_view", view, req.body, (err) ->
    res.send err: err

