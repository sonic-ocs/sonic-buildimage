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

-- Decode sai_u8_list_t serialization format "count:v1,v2,v3,..." into a string.
local function u8list_decode(str)
    local colon = str:find(":")
    if not colon then return "" end
    local body = str:sub(colon + 1)
    local chars = {}
    for num in body:gmatch("(%d+)") do
        chars[#chars + 1] = string.char(tonumber(num))
    end
    return table.concat(chars)
end

local counters_db = ARGV[1]
local counters_table_name = ARGV[2]
local state_db = "6"
local vid_table_name = "COUNTERS_OCS_CROSS_CONNECT_NAME_MAP"
local state_table_name = "OCS_CROSS_CONNECT_TABLE"

-- Phase 1: Read everything from counters DB and build update list + valid set
redis.call('SELECT', counters_db)

for i = 1, #KEYS do
    local vid = KEYS[i]
    local obj_name = redis.call('HGET', vid_table_name, vid)
    if obj_name then
        valid_names[obj_name] = true

        local counter_key = counters_table_name .. ':' .. vid

        local physical_path = ""
        local tmp = redis.call('HGET', counter_key, 'SAI_OCS_CROSS_CONNECT_ATTR_PHYSICAL_PATH')
        if tmp then
            physical_path = u8list_decode(tmp)
        end

        local oper_status = redis.call('HGET', counter_key, 'SAI_OCS_CROSS_CONNECT_ATTR_OPER_STATUS')
        if oper_status then
            oper_status = string.lower(oper_status:gsub("SAI_OCS_CROSS_CONNECT_OPER_STATUS_", ""))
        else
            oper_status = ""
        end

        local insertion_loss = redis.call('HGET', counter_key, 'SAI_OCS_CROSS_CONNECT_ATTR_INSERTION_LOSS_DB')
        if insertion_loss then
            local val = tonumber(insertion_loss)
            if val then
                insertion_loss = string.format("%.2f", val / 100.0)
            else
                insertion_loss = "N/A"
            end
        else
            insertion_loss = "N/A"
        end

        updates[#updates + 1] = { obj_name, physical_path, oper_status, insertion_loss }
    end
end

-- Phase 2: Switch to state DB, delete stale rows, then write updates
redis.call('SELECT', state_db)

-- Delete anything not in valid_names
local existing = redis.call('KEYS', state_table_name .. '|*')
local prefix_len = #state_table_name + 2  -- +1 for '|' and +1 for 1-based Lua indexing

for i = 1, #existing do
    local k = existing[i]
    local name = string.sub(k, prefix_len)  -- extract the part after "OCS_CROSS_CONNECT_TABLE|"
    if not valid_names[name] then
        redis.call('DEL', k)
    end
end

-- Now write fresh/updated rows
for i = 1, #updates do
    local data = updates[i]
    redis.call('HMSET', state_table_name .. '|' .. data[1],
               'physical_path', data[2],
               'status',        data[3],
               'insertion_loss_dB', data[4])
end

return logtable
