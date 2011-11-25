io = require 'socket.io'
Skull = require 'Skull.io'
express = require 'express'

class exports.SkullServer
  # registerNameSpace: () ->
  #   return null
  # registerModel: () ->
  #   return null
  createServer: (app)->
    
    @io = io.listen app
    
    @io.configure =>
      @io.set 'log level', 2
 
    @io.set 'authorization', (data, cb) ->
      res = {}
      express.cookieParser() data, res, -> 
        # console.log 'Parsed cookies: %j', data.cookies
        sid = data.cookies['connect.sid']
        return cb("Not authorized", false) if not sid
        console.log 'Authorized user ', sid
        data.sid = sid
        cb(null, true)
    
    @skullServer = new Skull.Server @io
    
    # TODO: loop through namespaces and add
    # @global = @skullServer.of '/global'
    # @app = @skullServer.of '/app'
    # 
    # #TODO: loop through models and add to proper namespace
    # # @app.addModel new ImageModel()          #Name is taken from ImageModel::name
    # @app.addModel '/steps', new StepModel() #Here we specify an explicit name
    # 
    # #Holds settings for all users
    # @settingsHandler = @global.addModel '/mySettings', new Skull.SidModel
    # 
    # @global.on 'connection', (socket) =>
    #   console.log 'Connection to global from ', socket.id
    #   usModel = userSettings.get socket.handshake.sid
    #   if usModel
    #     @settingsHandler.addModel socket, usModel 
    #   else
    #     console.log 'User settings not found. This should not happen.'
    
    @io.sockets.on 'connection', (socket) =>
      console.log 'Socket connection from ', socket.id
    
    @skullServer