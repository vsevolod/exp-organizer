app = require('express')()
http = require('http').Server(app)
io = require('socket.io')(http)
_ = require('underscore')
#pg = require('pg')
#redis = require("redis")
#client = redis.createClient()
#
#constring = "postgresql://vsevolod:vsevoloddb@127.0.0.1/organizer24_20141006"
#send_sql = (sql) ->
#  pg.connect constring, (err, client, done) ->
#    throw err if (err)
#    client.query sql, (err, res) ->
#      done()
#      throw err if (err)
#      console.log( res.rows[0] )
#send_sql('SELECT count(*) from appointments;')

current_clients = []
class Client
  constructor: (@organization_id, @user, @socket) ->
    @socket.room = @.room()

  room: () ->
    "Organization_#{@organization_id}"

  fio: () ->
    "#{@user.firstname} #{@user.lastname}"

  remove: () ->
    delete @organization_id
    delete @user
    @socket = null

  equal: (other_client) ->
    other_client && @user && other_client.user && other_client.user.id == @user.id && other_client.organization_id == @user.id

io.sockets.on 'connection', (socket) ->

  socket.on 'join', (organization_id, user) ->
    socket.client = new Client(organization_id, user, socket)
    old_client = _.find(current_clients, (current_client) ->
      current_client.equal(socket.client)
    )
    if old_client
      delete socket.client
      socket.client = old_client
    else
      console.log('User joined')
      socket.broadcast.emit('message', socket.client.fio(), "Присоединяется")
      current_clients.push(socket.client)


  socket.on 'disconnect', () ->
    current_clients = _.reject current_clients, (current_client) ->
      current_client.equal(socket.client)
    console.log('disconnected')

  socket.on 'refresh fullcalendar events', ->
    socket.broadcast.emit('refresh fullcalendar events')
    #socket.broadcast.to(user_id).emit('chat message', socket.nickname, msg)


http.listen 8000, ->
  console.log('listening on 8000')
