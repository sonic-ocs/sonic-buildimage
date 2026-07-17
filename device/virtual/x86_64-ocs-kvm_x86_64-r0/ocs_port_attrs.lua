-- KEYS - rif IDs
-- ARGV[1] - counters db index
-- ARGV[2] - counters table name
-- ARGV[3] - poll time interval
-- return log

local logtable = {}
local updates = {}
local valid_names = {}   -- set of names that must remain in state DB, others will be deleted

local function logit(msg)
    logtable[#logtable + 1] = tostring(msg)
end

local function hex_decode(str)
    return (str:gsub("\\x(%x%x)", function(hex)
        return string.char(tonumber(hex, 16))
    end))
end

local counters_db = ARGV[1]
local counters_table_name = ARGV[2]
local state_db = "6"
local vid_table_name = "COUNTERS_OCS_PORT_NAME_MAP"
local state_table_name = "OCS_PORT_TABLE"

-- Phase 1: Read everything from counters DB and build update list + valid set
redis.call('SELECT', counters_db)

for i = 1, #KEYS do
    local vid = KEYS[i]
    local obj_name = redis.call('HGET', vid_table_name, vid)
    if obj_name then
        valid_names[obj_name] = true

        local counter_key = counters_table_name .. ':' .. vid

        local connector_type = ""
        local tmp = redis.call('HGET', counter_key, 'SAI_OCS_PORT_ATTR_CONNECTOR_TYPE')
        if tmp then
            connector_type = hex_decode(tmp)
        end

        local connector_pin = ""
        tmp = redis.call('HGET', counter_key, 'SAI_OCS_PORT_ATTR_CONNECTOR_PIN')
        if tmp then
            connector_pin = hex_decode(tmp)
        end

        local target_simplex_port_id = ""
        tmp = redis.call('HGET', counter_key, 'SAI_OCS_PORT_ATTR_TARGET_SIMPLEX_PORT_ID')
        if tmp then
            target_simplex_port_id = hex_decode(tmp)
        end

        local oper_status = redis.call('HGET', counter_key, 'SAI_OCS_PORT_ATTR_OPER_STATUS')
        if oper_status then
            oper_status = string.lower(oper_status:gsub("SAI_OCS_PORT_OPER_STATUS_", ""))
        else
            oper_status = ""
        end

        updates[#updates + 1] = { obj_name, connector_type, connector_pin, target_simplex_port_id, oper_status }
    end
end

-- Phase 2: Switch to state DB, delete stale rows, then write updates
redis.call('SELECT', state_db)

-- Delete anything not in valid_names
local existing = redis.call('KEYS', state_table_name .. '|*')
local prefix_len = #state_table_name + 2  -- +1 for '|' and +1 for 1-based Lua indexing

for i = 1, #existing do
    local k = existing[i]
    local name = string.sub(k, prefix_len)  -- extract the part after "OCS_PORT_TABLE|"
    if not valid_names[name] then
        redis.call('DEL', k)
    end
end

-- Now write fresh/updated rows
for i = 1, #updates do
    local data = updates[i]
    redis.call('HMSET', state_table_name .. '|' .. data[1],
               'connector_type', data[2],
               'connector_pin', data[3],
               'target_simplex_port_id', data[4],
               'oper_status', data[5])
end

return logtable
