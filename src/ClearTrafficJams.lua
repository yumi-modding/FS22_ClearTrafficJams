
ClearTrafficJams = {};

ClearTrafficJams.debug = false --true --
modDirectory = g_currentModDirectory
local ClearTrafficJams_mt = Class(ClearTrafficJams)

function ClearTrafficJams:new(mission, i18n, inputBinding, gui, soundManager, modDirectory, modName)
    if ClearTrafficJams.debug then print("ClearTrafficJams:new") end
    local self = setmetatable({}, ClearTrafficJams_mt)

    self.isServer = mission:getIsServer()
    self.isClient = mission:getIsClient()
    self.modDirectory = modDirectory
    self.modName = modName

    self.mission = mission

    return self
end

function ClearTrafficJams:delete()
    if ClearTrafficJams.debug then print("ClearTrafficJams:delete") end

end

-- @doc registerActionEvents need to be called regularly
function ClearTrafficJams:registerActionEvents()
    if ClearTrafficJams.debug then print("ClearTrafficJams:registerActionEvents()") end

    for _,actionName in pairs({ "ClearTrafficJams_RESET" }) do
        -- print("actionName "..actionName)
        local __, eventName, event, action = InputBinding.registerActionEvent(g_inputBinding, actionName, self, ClearTrafficJams.resetTraffic ,false ,true ,false ,true)
        if __ then
            g_inputBinding.events[eventName].displayIsVisible = false
        end
    end

end
-- Only needed for global action event 

-- @doc Switch directly to another worker
function ClearTrafficJams:resetTraffic(actionName, keyStatus)
    if ClearTrafficJams.debug then print("ContractorMod:resetTraffic") end
    if ClearTrafficJams.debug then print("actionName "..tostring(actionName)) end

    if (g_currentMission:getIsServer() or g_currentMission.isMasterUser) and g_currentMission:getIsClient() then
        if g_currentMission.missionInfo.trafficEnabled then
            if ClearTrafficJams.debug then print("setTrafficEnabled(false)") end
            g_currentMission:setTrafficEnabled(false)
            if ClearTrafficJams.debug then print("setTrafficEnabled(true)") end
            g_currentMission:setTrafficEnabled(true)
        else
            if ClearTrafficJams.debug then print("Traffic is disable: nothing to do") end
            g_currentMission:showBlinkingWarning(g_i18n:getText("warning_trafficDisable"), 2000)
        end
    else
        if ClearTrafficJams.debug then print("Only Admin user can reset traffic") end
        g_currentMission:showBlinkingWarning(g_i18n:getText("warning_masterUser"), 2000)
    end
end

---Called when the player clicks the Start button
function ClearTrafficJams:onMissionStart(mission)
    print("ClearTrafficJams:onMissionStart")


end

------------------------------------------------
--- Events from mission
------------------------------------------------
-- Mission is loading
function ClearTrafficJams:onMissionLoading()
    print("ClearTrafficJams:onMissionLoading")

end

---Mission was loaded (without vehicles and items)
function ClearTrafficJams:onMissionLoaded(mission)
    print("ClearTrafficJams:onMissionLoaded")

end

function ClearTrafficJams:update(dt)

end
