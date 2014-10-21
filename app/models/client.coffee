class Client
  constructor: (client_options, @socket) ->
    @worker_id = client_options.worker_id
    @organization_id = client_options.organization_id
    @user = client_options.user
    @is_admin = client_options.isa
    join_rooms()

  room: (postfix) ->
    # TODO ROOMS
    "#{@worker_id}_#{postfix || @is_admin}"

  fio: () ->
    "#{@user.firstname} #{@user.lastname}"

  remove: () ->
    delete @worker_id
    delete @user
    @socket = null

  join_rooms: () ->
    @socket.joins("")

  equal: (other_client) ->
    other_client && @user && other_client.user && other_client.user.id == @user.id && other_client.worker_id == @user.id
