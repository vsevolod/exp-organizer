app = require('express')()
logger = require 'morgan'
http = require('http').Server(app)
io = require('socket.io')(http)
_ = require 'underscore'
redis_client = require('redis').createClient()

# include other libraties
{Client} = require './models/client'

# configure
app.use(logger('dev'))
io_redis = require 'socket.io-redis'
io.adapter io_redis({host: 'localhost', port: 6379})

current_clients = []

# Socket.IO
io.sockets.on 'connection', (socket) ->

  socket.on 'join', (client_options) ->
    socket.current_client = new Client(client_options, socket)
    old_client = _.find(current_clients, (current_client) ->
      current_client.equal(socket.current_client)
    )
    if old_client
      delete socket.current_client
      socket.current_client = old_client
    else
      current_clients.push(socket.current_client)
      redis_client.set('phones', socket.current_client.phone)

  socket.on 'set worker', (worker_id) ->
    console.log(socket.current_client.fio(), 'change worker')
    socket.current_client.leave_rooms()
    socket.current_client.worker_id = worker_id
    socket.current_client.join_rooms()

  socket.on 'disconnect', () ->
    if socket.current_client
      console.log(socket.current_client.fio(), 'disconnected')
    current_clients = _.reject current_clients, (current_client) ->
      current_client.equal(socket.current_client)

  #socket.broadcast.of(socket.current_client.organization_id).to(socket.current_client.room(true)).emit('refresh_event', appointment_id)


http.listen 8000, ->
  console.log('listening on 8000')
