local modDirectory = g_currentModDirectory
local modName = g_currentModName

source(modDirectory .. "src/ClearTrafficJams.lua")

local cleartrafficjams

local function isEnabled()
    -- Normally this code never runs if ClearTrafficJams was not active. However, in development mode
    -- this might not always hold true.
    return cleartrafficjams ~= nil
end

-- called after the map is async loaded from :load. has :loadMapData calls. NOTE: self.xmlFile is also deleted here. (Is map.xml)
local function loadedMission(mission, node)
    -- print("loadedMission(mission, superFunc, node)")
    if not isEnabled() then
        return
    end

    if mission.cancelLoading then
        return
    end

    cleartrafficjams:onMissionLoaded(mission)
end

local function load(mission)
    -- print("load(mission)")
    assert(cleartrafficjams == nil)

    cleartrafficjams = ClearTrafficJams:new(mission, g_i18n, g_inputBinding, g_gui, g_soundManager, modDirectory, modName)

    getfenv(0).g_cleartrafficjams = cleartrafficjams

    addModEventListener(cleartrafficjams)

end

-- Player clicked on start
local function startMission(mission)
    if not isEnabled() then return end

    cleartrafficjams:onMissionStart(mission)
end

local function unload()
    if not isEnabled() then return end

    removeModEventListener(cleartrafficjams)

    if cleartrafficjams ~= nil then
        cleartrafficjams:delete()
        cleartrafficjams = nil -- Allows garbage collecting
        getfenv(0).g_cleartrafficjams = nil
    end
end

local function init()
    -- print("init()")
    FSBaseMission.delete = Utils.appendedFunction(FSBaseMission.delete, unload)
    -- FSBaseMission.loadMapFinished = Utils.prependedFunction(FSBaseMission.loadMapFinished, loadedMap)

    Mission00.load = Utils.prependedFunction(Mission00.load, load)
    Mission00.loadMission00Finished = Utils.appendedFunction(Mission00.loadMission00Finished, loadedMission)
    Mission00.onStartMission = Utils.appendedFunction(Mission00.onStartMission, startMission)
    FSBaseMission.registerActionEvents = Utils.appendedFunction(FSBaseMission.registerActionEvents, ClearTrafficJams.registerActionEvents);

end

init()
