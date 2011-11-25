Skull = require 'Skull.io'
# _ = require 'underscore'
mongoose = require 'mongoose'
Schema = mongoose.Schema

User = require('./user').Model
# Step = mongoose.model 'Step'

exports.Schema = ProjectSchema = new Schema
  # sid:
  #   type: String
  #   required: true
  #   unique: true
  name:
    type: String
    required: true
    unique: false
  slug:
    type: String
    required: true
    lowercase: true
    trim: true
    unique: true
  # owner:
  #   type: User
  date:
    created:
      type: Date
      index: true
      default: Date.now
    # updated:
    #   type: Date
    #   index: true
    #   default: Date.now
  enabled:
    type: Boolean
    default: true
    
# method on update for updated field

# move out into Schema plugins possibly
slugGenerator = (options) ->
  options = options || {}
  key = options.key || 'name'

  return (schema)->
    schema.path(key).set (v)->
      @slug = v.toLowerCase().replace(/[^a-z0-9 -]/g, '').replace(/\s+/g, '-').replace(/-+/g, '-')
      return v

ProjectSchema.plugin slugGenerator()

exports.Model = Project = mongoose.model "Project", ProjectSchema

# Skull model
class exports.SkullModel extends Skull.Model
  name: '/projects'
  constructor: ->
    super
    
  create: (data, callback, socket) ->
    console.log(data)
    callback null, data
    @emit 'create', data, socket
    
  update: (data, callback, socket) ->
    callback null, data
    @emit 'update', data, socket
    
  delete: (data, callback, socket) ->
    callback null, data
    @emit 'delete', data, socket
    
  read: (filter, callback, socket) ->
    callback null, items
    @emit 'read', filter, socket