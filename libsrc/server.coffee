# Server requirements
express = require 'express'
path = require 'path'
mongoose = require 'mongoose'

config = require './config'

SessionStore = require('connect-mongoose')(express)

# Create server
app = module.exports = express.createServer()

root = path.resolve __dirname + "/../"

# Static directories
public = root + '/public'
publicsrc = root + '/publicsrc'

auth = require('./auth/mongo')(app,config)

app.configure( ->
  app.set 'views', path.resolve __dirname + '/../views'
  app.set 'view engine', 'jade'
  app.set 'view options', {layout: true}
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser()
    
  app.use express.session({
    secret: config.get('session:key') || 'suparsecret'
    store: new SessionStore()
  })
  
  # authentication middleware
  app.use auth.middleware()
  app.use auth.normalizeUserData()
  
  app.use express.compiler(
    src: publicsrc
    dest: public
    enable: ['coffeescript']
  )
  
  # app.use app.router
  app.use express.static path.resolve __dirname + '/../public'
  
)

# console.log(config.get('db:mongo'))
mongoose.connect('mongodb://localhost/proj-doc');

mongoose.connection.on 'open', ->
  console.log('mongo connection open')

app.configure 'development', ->
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }))

app.configure 'production', ->
  app.use express.errorHandler()
  
app.dynamicHelpers {
  session: (req, res) ->
    console.log(req.session)
    return req.session
  auth: (req,res) ->
    return req.session.auth || {}
}

app.get '/', (req, res) ->
  console.log 'Connect.sid ', req.cookies['connect.sid']
  res.render('home', {
    title: 'ORLY'
  })

# steps app
Steps = require('./steps')
steps = new Steps.App
steps.createServer app

# Catch uncaught exceptions
process.on 'uncaughtException', (err) ->
  console.log('\u0007') #ringy dingy
  console.error err
  console.log err.stack
  
app.listen( process.env.PORT || config.get "server:port" || 9000 )
console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env)

