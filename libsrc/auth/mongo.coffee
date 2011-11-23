mongoose = require 'mongoose'
https = require 'https'

Schema = mongoose.Schema
mongooseAuth = require('mongoose-auth')

UserSchema = new Schema
  "registered":
    "type" : Date
    "index" : true

module.exports = (app,config) ->
  
  loginRedirect = "/"
  loginFailRedirect = "/"
  
  # everyauth.debug = config.get 'debug'
  external = config.get 'auth'
  serverUri = config.get 'server:uri'
  
  UserSchema.plugin mongooseAuth, 
    debug: config.get 'debug'
    everymodule:
      everyauth:
        handleLogout: (req,res) ->
          delete req.session.user
          req.logout()
          # res.redirect();
          res.writeHead 303, 'Location': this.logoutRedirectPath()
          res.end()
        User: ->
          User
    password:
      everyauth:
        loginFormFieldName: 'login'
        passwordFormFieldName: 'password'
        getLoginPath: '/login'
        postLoginPath: '/login'
        loginView: 'user/login'
        # .authenticate( function (email, password) {
        #   //console.log(arguments);
        #   var promise = this.Promise();
        #   models.user.findByEmailPassword(email,password,promise);
        #   return promise
        # })
        loginSuccessRedirect: loginRedirect
        getRegisterPath: '/register'
        postRegisterPath: '/register'
        registerView: 'user/register'
    twitter:
      everyauth:
        myHostname: serverUri
        consumerKey: external.twitter.consumerKey
        consumerSecret: external.twitter.consumerSecret
        redirectPath: loginRedirect
    github:
      everyauth:
        myHostname: serverUri
        appId: external.github.appId
        appSecret: external.github.appSecret
        redirectPath: loginRedirect
    
    # TODO: implement facebook
    
  mongooseAuth.helpExpress app
  
  # Fetch and format data so we have an easy object with user data to work with.
  normalizeUserData = ->
    return (req, res, next) ->
      if ( !req.session?.user && req.session.auth?.loggedIn)
        # possibly se a switch here
        user = {}
        if (req.session.auth.github)
          user.image = 'http://1.gravatar.com/avatar/'+req.session.auth.github.user.gravatar_id+'?s=48'
          user.name = req.session.auth.github.user.name
          user.id = 'github-'+req.session.auth.github.user.id
          
        if (req.session.auth.twitter)
          user.image = req.session.auth.twitter.user.profile_image_url
          user.name = req.session.auth.twitter.user.name
          user.id = 'twitter-'+req.session.auth.twitter.user.id_str
         
        if (req.session.auth.facebook)
          user.image = req.session.auth.facebook.user.picture
          user.name = req.session.auth.facebook.user.name
          user.id = 'facebook-'+req.session.auth.facebook.user.id
   
          # Need to fetch the users image...
          https.get
            'host': 'graph.facebook.com'
            'path': '/me/picture?access_token='+req.session.auth.facebook.accessToken
          , (response) ->
            user.image = response.headers.location
            req.session.user = user
            next()
          .on 'error', (e) ->
            req.session.user = user
            next()
           
          return
         
        req.session.user = user
         
      next()
  
  mongoose.model 'User', UserSchema
  User = mongoose.model 'User'
  
  return{
    user: User
    normalizeUserData: normalizeUserData
    middleware: mongooseAuth.middleware
  }