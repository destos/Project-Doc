Skull = require 'Skull.io'
# _ = require 'underscore'
mongoose = require 'mongoose'
Schema = mongoose.Schema

# User = require('./user').Model

# Create steps
StepSchema = new Schema
  title:
    type: String
    required: true
    unique: false
  parts: [String]
  images: [String]

exports.StepModel = mongoose.model "Step", StepSchema

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
  owner:
    type: Schema.ObjectId
    required: true
    ref: 'User'
  description:
    type: String
    required: true
  steps:
    [
      type: Schema.ObjectId
      ref: 'Step'
    ]
  date:
    created:
      type: Date
      index: true
      default: Date.now
    updated:
      type: Date
      index: true
  enabled:
    type: Boolean
    default: true
# 

# pre save
ProjectSchema.pre 'save', (next) ->
  # updated field gets now time
  this.date.updated = Date.now()
  next()
  
# TODO method to set owner

# TODO Find by slug

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