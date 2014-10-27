exports.Client =
class Client
  constructor: (client_options, @socket) ->
    {@worker_id, @organization_id, @user, @isa} = client_options
    @is_admin = @isa
    @join_rooms()
    @phone = @user.phone

  room: (postfix) ->
    "#{@worker_id}_#{postfix || @is_admin}"

  fio: () ->
    "#{@user.firstname} #{@user.lastname}"

  remove: () ->
    delete @worker_id
    delete @user
    @socket = null

  join_rooms: () ->
    @socket.join room for room in [@phone, @organization_room(), @worker_room(), @admin_room(), @worker_admin_room()]

  leave_rooms: () ->
    @socket.leave room for room in [@phone, @organization_room(), @worker_room(), @admin_room(), @worker_admin_room()]

  organization_room: (organization)->
    "Organization::#{organization || @organization_id}"

  worker_room: (worker) ->
    "#{@organization_room()}Worker::#{worker || @worker_id}"

  admin_room: (admin) ->
    "#{@organization_room()}IsAdmin::#{admin || @is_admin}"

  worker_admin_room: (worker, admin) ->
    "#{@organization_room()}Worker::#{worker || @worker_id}IsAdmin::#{admin || @is_admin}"

  equal: (other_client) ->
    other_client && @user && other_client.user && other_client.user.id == @user.id && other_client.worker_id == @user.id
