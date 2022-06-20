local os = require "os"

local M = {}

function M.scan_network(params)
    local cmd = "lua /usr/bin/nethosts.lua" --NETHOSTS FILE LOCATION IN A ROUTER
    if params.ipv4subnet ~= nil then            --CHECKS IP FROM PARAMS
        cmd = cmd .. " -i "..params.ipv4subnet
    end
    if params.ports then                        --CHECKS IF SCAN PORTS IS SELECTED FROM PARAMS
        cmd = cmd .. " --ports"
    end
    if params.range ~= nil and params.range ~= "" then --CHECKS IF USER SELECTED PORT RANGE 
        cmd = cmd .. " --range " .. params.range
    end
    cmd = cmd .." &> /tmp/network_scan.json &" --WRITES RESULTS TO THIS FILE
    os.execute(cmd)

    return {ok = true, message = "Scan started", command = cmd, params = params}
end

function M.get_results()
    local file = io.open("/tmp/network_scan.json", "r") --READS RESULT FILE
    if file == nil then
        return {ok = false, message = "Scan in progress"} --IF NOTHING THEN CONTINUOUS READING
    end
    local size = file:seek("end")
    if size == 0 then
        return {ok = false, message = "Scan in progress"}
    end
    local lines = {}
    for line in io.lines("/tmp/network_scan.json") do   --PUTS JSON DATA INTO LINES
        lines[#lines + 1] = line
    end
    file:close()
    return {ok = true, data = lines}    --RETURNS TO VUE
end

function M.stop_scan()  --IF STOP SCAN BUTTON IS PRESSED WHILE SCANING
    os.execute("pgrep -f \"lua nethosts\" | xargs kill -9") 
    os.execute("pidof nmap | xargs kill -9")
    return {ok = true, message = "Scan stopped"}
end

return M