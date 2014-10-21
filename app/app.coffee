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
  constructor: (client_options, @socket) ->
    @worker_id = client_options.worker_id
    @organization_id = client_options.organization_id
    @user = client_options.user
    @is_admin = client_options.isa
    @socket.join(@.room())

  room: (postfix) ->
    "#{@organization_id}_#{@worker_id}_#{postfix || @is_admin}"

  fio: () ->
    "#{@user.firstname} #{@user.lastname}"

  remove: () ->
    delete @worker_id
    delete @user
    @socket = null

  equal: (other_client) ->
    other_client && @user && other_client.user && other_client.user.id == @user.id && other_client.worker_id == @user.id

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

  socket.on 'set worker', (worker_id) ->
    socket.current_client.worker_id = worker_id
    socket.join(socket.current_client.room())

  socket.on 'disconnect', () ->
    if socket.current_client
      console.log(socket.current_client.fio(), 'disconnected')
    current_clients = _.reject current_clients, (current_client) ->
      current_client.equal(socket.current_client)

  socket.on 'refresh event', (appointment_id)->
    socket.broadcast.to(socket.current_client.room(false)).emit('refresh_event', appointment_id)
    socket.broadcast.to(socket.current_client.room(true)).emit('refresh_event', appointment_id)


http.listen 8000, ->
  console.log('listening on 8000')
