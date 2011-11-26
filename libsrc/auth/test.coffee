mongoose = require 'mongoose'
https = require 'https'

Schema = mongoose.Schema
mongooseAuth = require('mongoose-auth')

UserSchema = new Schema({})

module.exports = (app,config) ->
  
  loginRedirect = "/"
  
  external = config.get 'auth'
  serverUri = config.get 'server:uri'
  
  UserSchema.plugin mongooseAuth, 
    everymodule:
      everyauth:
        handleLogout: (req,res) ->
          delete req.session.user
          req.logout()
          res.redirect this.logoutRedirectPath(), 303 
          res.end()
        User: ->
          User
    twitter:
      everyauth:
        myHostname: serverUri
        consumerKey: external.twitter.consumerKey
        consumerSecret: external.twitter.consumerSecret
        redirectPath: loginRedirect
  
  mongoose.model('User', UserSchema)
  User = mongoose.model('User')
  
  mongooseAuth.helpExpress app
  
  # Fetch and format data so we have an easy object with user data to work with.
  normalizeUserData = ->
    return (req, res, next) ->
      if ( !req.session?.user && req.session.auth?.loggedIn)
        # possibly se a switch here
        user = {}
          
        if (req.session.auth.twitter)
          user.image = req.session.auth.twitter.user.profile_image_url
          user.name = req.session.auth.twitter.user.name
          user.id = 'twitter-'+req.session.auth.twitter.user.id_str
         
        req.session.user = user
         
      next()
  
  return{
    user: User
    normalizeUserData: normalizeUserData
    middleware: mongooseAuth.middleware
  }