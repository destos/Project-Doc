# working on mongo

mongoose = require 'mongoose'

User = require './models/user'
Project = require './models/project'

mongoose.connect('mongodb://localhost/proj-doc');

mongoose.connection.on 'open', ->
  console.log('mongo connection open')

# project = new Project.Model

class title
  verbs: 
    [   
      ["go to", "goes to", "going to", "went to", "gone to"]
      ["look at", "looks at", "looking at", "looked at", "looked at"]
      ["choose", "chooses", "choosing", "chose", "chosen"]
    ]
  tenses:
    [
      {name:"Present", singular:1, plural:0, format:"%subject %verb %complement"}
      {name:"Past", singular:3, plural:3, format:"%subject %verb %complement"}
      {name:"Present Continues", singular:2, plural:2, format:"%subject %be %verb %complement"}
    ]
  subjects:
    [
      {name:"I", be:"am", singular:0}
      {name:"You", be:"are", singular:0}
      {name:"He", be:"is", singular:1}
    ]
  complementsForVerbs:
    [
      ["cinema", "Egypt", "home", "concert"]
      ["for a map", "them", "the stars", "the lake"]
      ["a book for reading", "a dvd for tonight"]
    ]
  generate: () ->
    index = Math.floor(@verbs.length * Math.random())
    tense = @tenses.random()
    subject = @subjects.random()
    verb = @verbs[index]
    complement = @complementsForVerbs[index]
    tense.format
      .replace("%subject", subject.name).replace("%be", subject.be)
      .replace("%verb", verb[ if subject.singular then tense.singular else tense.plural])
      .replace("%complement", complement.random())
    
Array.prototype.random = ()->
  @[Math.floor(Math.random() * @.length)]

titleGenerator = new title
# console.log(titleGenerator.generate())

# add some projects

for num in [1...10]
  do (num) ->
    name = titleGenerator.generate()
    console.log('creating project with name:',name)
    new Project.Model
      name: name
    .save (err)->
      if !err
        console.log('saved:',name)
      else
        console.log(err)
      