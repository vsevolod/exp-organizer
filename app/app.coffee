app = require('express')()
http = require('http').Server(app)
io = require('socket.io')(http)
_ = require 'underscore'

require './models/client'

current_clients = []
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
      socket.broadcast.of(socket.current_client.room(true)).emit('message', socket.current_client.fio(), 'connected!')
      current_clients.push(socket.current_client)

  socket.on 'set worker', (worker_id) ->
    socket.current_client.worker_id = worker_id
    socket.join(socket.current_client.room())

  socket.on 'disconnect', () ->
    if socket.current_client
      console.log(socket.current_client.fio(), 'disconnected')
    current_clients = _.reject current_clients, (current_client) ->
      current_client.equal(socket.current_client)

  socket.on 'refresh event', (appointment_id)->
    socket.broadcast.of(socket.current_client.organization_id).to(socket.current_client.room(false)).emit('refresh_event', appointment_id)
    socket.broadcast.of(socket.current_client.organization_id).to(socket.current_client.room(true)).emit('refresh_event', appointment_id)


http.listen 8000, ->
  console.log('listening on 8000')
