
user_agent <- paste("refoqa", utils::packageVersion("refoqa"))

uris <- list(
  aircraft = list(
    list = '/v2/ems-systems/%s/assets/aircraft',	#(ems-system_id)
    info = '/v2/ems-systems/%s/assets/aircraft/%s'#(ems-system_id, aircraft_id)
  ),
  airport = list(
    list = '/v2/ems-systems/%s/assets/airports',		#(ems-system_id)
    info = '/v2/ems-systems/%s/assets/airports/%s'		#(ems-system_id, airport_id)
  ),
  analytic = list(
    search   = '/v2/ems-systems/%s/analytics',    # (emsSystemId)
    search_f = '/v2/ems-systems/%s/flights/%s/analytics', # (emsSystemId, flightId)
    group    = '/v2/ems-systems/%s/analytic-groups',    # (emsSystemId)
    group_f  = '/v2/ems-systems/%s/flights/%s/analytic-groups', # (emsSystemId, flightId)
    query    = '/v2/ems-systems/%s/flights/%s/analytics/query', # (emsSystemId, flightId)
    metadata = '/v2/ems-systems/%s/flights/%s/analytics/metadata' # (emsSystemId, flightId)
  ),
  database = list(
    group = '/v2/ems-systems/%s/database-groups',			#(ems-system_id)
    field_group = '/v2/ems-systems/%s/databases/%s/field-groups',	#(ems-system_id, data_src_id)
    field = '/v2/ems-systems/%s/databases/%s/fields/%s', #(ems-system_id, database_id, field_id)
    query = '/v2/ems-systems/%s/databases/%s/query',
    open_asyncq	= '/v2/ems-systems/%s/databases/%s/async-query', #(ems-system_id, database_id)
    get_asyncq = '/v2/ems-systems/%s/databases/%s/async-query/%s/read/%s/%s', #(ems-system_id, database_id, async_query_id, start_row, end_row)
    close_asyncq = '/v2/ems-systems/%s/databases/%s/async-query/%s',
    create = '/v2/ems-systems/%s/databases/%s/create', # (emsSystemId, databaseId)
    delete = '/v2/ems-systems/%s/databases/%s/delete' # (emsSystemId, databaseId)
  ),
  ems_sys = list(
    list = '/v2/ems-systems',
    ping = '/v2/ems-systems/%s/ping', 	# (ems-system_id)
    info = '/v2/ems-systems/%s/info'	# (ems-system_id)
  ),
  fleet = list(
    list = '/v2/ems-systems/%s/assets/fleets', 	#(ems-system_id)
    info = '/v2/ems-systems/%s/assets/fleets/%s'	#(ems-system_id, fleet_id)
  ),
  flt_phase = list(
    list = '/v2/ems-systems/%s/assets/flight-phases', 		#(ems-system_id)
    info = '/v2/ems-systems/%s/assets/flight-phases/%s' 	#(ems-system_id, flt_phase_id)
  ),
  profile = list(
    profile_groups = '/v2/ems-systems/%s/profile-groups',
    profiles = '/v2/ems-systems/%s/profiles',
    glossary = '/v2/ems-systems/%s/profiles/%s/glossary',
    events = '/v2/ems-systems/%s/profiles/%s/events'
  ),
  sys = list(
    auth = '/token'
  )
)
