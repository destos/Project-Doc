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

# models n junk 
Project = require './models/project'
ProjectModel = Project.Model

# User = require './models/user'
# UserModel = User.Model

mongoose.set 'debug', config.get('debug')

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
    # console.log(req.session)
    return req.session
  # auth: (req,res) ->
  #   return req.session.auth || {}
}

app.get '/', (req, res) ->
  console.log 'Connect.sid ', req.cookies['connect.sid']
  res.render('home', {
    title: 'ORLY'
  })

app.get '/project/new', (req,res) ->
  res.render 'project/new',
    locals:
      fields: {}
      errors: {}

app.post '/project/new', (req,res) ->
  newProject = new ProjectModel
    name: req.body.name
  newProject.save (err) ->
    if(err)
      console.log(err)
      res.render 'project/new',
        locals:
          fields: req.body
          errors: err.errors
    else
      res.redirect '/project/'+newProject.slug

app.get '/project/:slug', (req,res) ->
  ProjectModel.findOne {slug:req.params.slug}, (err,docs) ->
    console.log(arguments);
    if(err||docs == null)
      console.log(err);
      res.render 'project/none'
    else
      console.log(docs);
      res.render 'project/single',
        locals:
          project: docs

app.get '/projects', (req,res) ->
  ProjectModel.find {enabled: true}, (err,docs) ->
    res.render 'project/list',
      locals:
        projects: docs
  
# steps app
# Steps = require('./steps')
# steps = new Steps.App
# steps.createServer app

# Get Stuff Started on the skull side
# SkullServer = require './skull'
# skullServer = new SkullServer
# skullServer = skullServer.createServer app

# Namespaces
# global = skullServer.of '/global'

# Projects = require 'skullmodels/projects'

# attach models n junk
# global.addModel new StepModel() #Here we specify an explicit name


# Catch uncaught exceptions
process.on 'uncaughtException', (err) ->
  console.log('\u0007') #ringy dingy
  console.error err
  console.log err.stack

if(!module.parent)
  app.listen(process.env.PORT || config.get("server:port" || 9000));
  console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env);
  
exports.app