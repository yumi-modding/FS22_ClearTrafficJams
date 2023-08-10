
ClearTrafficJams = {};

ClearTrafficJams.debug = true --false --
modDirectory = g_currentModDirectory
local ClearTrafficJams_mt = Class(ClearTrafficJams)

-- TODO: Tests
-- Traffic On | Goto Job 1st launch | DisableForWorkers Yes 
-- Traffic On | Goto Job next launch

-- Traffic Off | Goto Job 1st launch
-- Traffic Off | Goto Job next launch

-- Traffic On | Goto Job 1st launch | DisableForWorkers No 
-- Traffic On | Goto Job next launch
--
--

function ClearTrafficJams:new(mission, i18n, inputBinding, gui, soundManager, modDirectory, modName)
    if ClearTrafficJams.debug then print("ClearTrafficJams:new") end
    local self = setmetatable({}, ClearTrafficJams_mt)

    self.isServer = mission:getIsServer()
    self.isClient = mission:getIsClient()
    self.modDirectory = modDirectory
    self.modName = modName

    self.mission = mission

    self.disableTrafficForWorkers = nil
    self.trafficWasDisable = false

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

function ClearTrafficJams.registerEventListeners(vehicleType)
    if ClearTrafficJams.debug then print("ClearTrafficJams:registerEventListeners()") end
    
	SpecializationUtil.registerEventListener(vehicleType, "onAIDriveableStart", AIDrivable)
	SpecializationUtil.registerEventListener(vehicleType, "onAIDriveableEnd", AIDrivable)

end

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
    if ClearTrafficJams.debug then print("ClearTrafficJams:onMissionStart") end


end

------------------------------------------------
--- Events from mission
------------------------------------------------
-- Mission is loading
function ClearTrafficJams:onMissionLoading()
    if ClearTrafficJams.debug then print("ClearTrafficJams:onMissionLoading") end

end

---Mission was loaded (without vehicles and items)
function ClearTrafficJams:onMissionLoaded(mission)
    if ClearTrafficJams.debug then print("ClearTrafficJams:onMissionLoaded") end

end

function ClearTrafficJams:update(dt)

end

-- Acivate beacon when AI driving but not during fieldWork
function ClearTrafficJams:updateAILights(isWorking)
    -- if ClearTrafficJams.debug then print("ClearTrafficJams:updateAILights") end
	local spec = self.spec_lights

    spec:setBeaconLightsVisibility(not isWorking)
    -- if ClearTrafficJams.debug then print("setBeaconLightsVisibility "..(isWorking and 'Off' or 'On')) end
end

function ClearTrafficJams:setTrafficForWorkers()
    local function disableTraffic(yes)
        if yes then
            g_cleartrafficjams.disableTrafficForWorkers = true
            print("disable traffic")
        else
            g_cleartrafficjams.disableTrafficForWorkers = false
            print("keep traffic")
        end
    end
    -- TODO: Test user is Admin ?
    g_gui:showYesNoDialog({
        text = g_i18n:getText("ui_disableTrafficForWorkers"),
        callback = disableTraffic,
        yesButton = g_i18n:getText("button_yes"),
        noButton = g_i18n:getText("button_no")
    })
end


function AIDrivable:onAIDriveableStart()
    if ClearTrafficJams.debug then print("AIDrivable:onAIDriveableStart") end
    
    if g_currentMission.missionInfo.trafficEnabled then
        if g_cleartrafficjams.disableTrafficForWorkers == nil then
            ClearTrafficJams:setTrafficForWorkers()
        end

        if g_cleartrafficjams.disableTrafficForWorkers then
            if ClearTrafficJams.debug then print("setTrafficEnabled(false)") end
            g_currentMission:setTrafficEnabled(false)
        end
    else
        g_cleartrafficjams.trafficWasDisable = true
    end
end

-- set back traffic
function AIDrivable:onAIDriveableEnd()
    if ClearTrafficJams.debug then print("AIDrivable:onAIDriveableEnd") end
    
    if g_cleartrafficjams.disableTrafficForWorkers and not g_cleartrafficjams.trafficWasDisable then
        if ClearTrafficJams.debug then print("setTrafficEnabled(true)") end
        g_currentMission:setTrafficEnabled(true)
    end
end
