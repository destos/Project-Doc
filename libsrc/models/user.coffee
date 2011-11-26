Skull = require 'Skull.io'
# _ = require 'underscore'
mongoose = require 'mongoose'
Schema = mongoose.Schema

exports.Schema = UserSchema = new Schema
  name:
    type: String
    trim: true
  userName:
    type: String
    required: false
    lowercase: true
    trim: true
    unique: true
  registered:
    type: Date
    index: true
    default: Date.now

# TODO: allow plugins to be run on Schema before model is regsitered

exports.Model = () ->
  mongoose.model 'User', UserSchema

# class exports.SkullModel extends Skull.Model
#   constructor: (@id) ->
#     @settings = 
#       id: 'user_' + @id
#       name: 'No name'
#       country: 'No country'
#       
#   read: (filter, callback, socket) ->
#     console.log 'Reading settings for user ', @id
#     callback null, @settings
#     
#   update: (data, callback, socket) ->
#     console.log 'Updating settings for user ', @id
#     @settings = data #don't do this. Always pluck the settings you need and validate them 
#     callback null, @settings
#     @emit 'update', @settings, socket
#     
# class UserSettings
#   settings: {} 
#   get: (sid) ->
#     existing = @settings[sid]
#     if not existing then existing = @settings[sid] = new UserSetting sid
#     existing

# class exports.App
# 
#   createServer: (app) ->
# 
#     userSettings = new UserSettings
# 
#     @io = io.listen app
# 
#     @io.configure =>
#       @io.set 'log level', 2
# 
#     @io.set 'authorization', (data, cb) ->
#       res = {}
#       express.cookieParser() data, res, -> 
#         # console.log 'Parsed cookies: %j', data.cookies
#         sid = data.cookies['connect.sid']
#         return cb("Not authorized", false) if not sid
#         console.log 'Authorized user ', sid
#         data.sid = sid
#         cb(null, true)
# 
#     @skullServer = new Skull.Server @io
# 
#     @global = @skullServer.of '/global'
#     @app = @skullServer.of '/app'
# 
#     # @app.addModel new ImageModel()          #Name is taken from ImageModel::name
#     @app.addModel '/steps', new StepModel() #Here we specify an explicit name
# 
#     #Holds settings for all users
#     @settingsHandler = @global.addModel '/mySettings', new Skull.SidModel
# 
#     @global.on 'connection', (socket) =>
#       console.log 'Connection to global from ', socket.id
#       usModel = userSettings.get socket.handshake.sid
#       if usModel
#         @settingsHandler.addModel socket, usModel 
#       else
#         console.log 'User settings not found. This should not happen.'
# 
#     @io.sockets.on 'connection', (socket) =>
#       console.log 'Socket connection from ', socket.id