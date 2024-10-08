---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

--***************************************************************
-- Inside of this script, you will find the necessary functions,
-- variables and events to communicate with the RecipeManager_Model
--***************************************************************

--**************************************************************************
--************************ Start Global Scope ******************************
--**************************************************************************
local nameOfModule = 'CSK_RecipeManager'

-- Timer to update UI via events after page was loaded
local tmrRecipeManager = Timer.create()
tmrRecipeManager:setExpirationTime(300)
tmrRecipeManager:setPeriodic(false)

-- Reference to global handle
local recipeManager_Model

-- ************************ UI Events Start ********************************

-- Script.serveEvent("CSK_RecipeManager.OnNewEvent", "RecipeManager_OnNewEvent")
Script.serveEvent("CSK_RecipeManager.OnNewStatusLoadParameterOnReboot", "RecipeManager_OnNewStatusLoadParameterOnReboot")
Script.serveEvent("CSK_RecipeManager.OnPersistentDataModuleAvailable", "RecipeManager_OnPersistentDataModuleAvailable")
Script.serveEvent("CSK_RecipeManager.OnNewParameterName", "RecipeManager_OnNewParameterName")
Script.serveEvent("CSK_RecipeManager.OnDataLoadedOnReboot", "RecipeManager_OnDataLoadedOnReboot")

Script.serveEvent('CSK_RecipeManager.OnUserLevelOperatorActive', 'RecipeManager_OnUserLevelOperatorActive')
Script.serveEvent('CSK_RecipeManager.OnUserLevelMaintenanceActive', 'RecipeManager_OnUserLevelMaintenanceActive')
Script.serveEvent('CSK_RecipeManager.OnUserLevelServiceActive', 'RecipeManager_OnUserLevelServiceActive')
Script.serveEvent('CSK_RecipeManager.OnUserLevelAdminActive', 'RecipeManager_OnUserLevelAdminActive')

-- ...

-- ************************ UI Events End **********************************

--[[
--- Some internal code docu for local used function
local function functionName()
  -- Do something

end
]]

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

-- Functions to forward logged in user roles via CSK_UserManagement module (if available)
-- ***********************************************
--- Function to react on status change of Operator user level
---@param status boolean Status if Operator level is active
local function handleOnUserLevelOperatorActive(status)
  Script.notifyEvent("RecipeManager_OnUserLevelOperatorActive", status)
end

--- Function to react on status change of Maintenance user level
---@param status boolean Status if Maintenance level is active
local function handleOnUserLevelMaintenanceActive(status)
  Script.notifyEvent("RecipeManager_OnUserLevelMaintenanceActive", status)
end

--- Function to react on status change of Service user level
---@param status boolean Status if Service level is active
local function handleOnUserLevelServiceActive(status)
  Script.notifyEvent("RecipeManager_OnUserLevelServiceActive", status)
end

--- Function to react on status change of Admin user level
---@param status boolean Status if Admin level is active
local function handleOnUserLevelAdminActive(status)
  Script.notifyEvent("RecipeManager_OnUserLevelAdminActive", status)
end

--- Function to get access to the recipeManager_Model object
---@param handle handle Handle of recipeManager_Model object
local function setRecipeManager_Model_Handle(handle)
  recipeManager_Model = handle
  if recipeManager_Model.userManagementModuleAvailable then
    -- Register on events of CSK_UserManagement module if available
    Script.register('CSK_UserManagement.OnUserLevelOperatorActive', handleOnUserLevelOperatorActive)
    Script.register('CSK_UserManagement.OnUserLevelMaintenanceActive', handleOnUserLevelMaintenanceActive)
    Script.register('CSK_UserManagement.OnUserLevelServiceActive', handleOnUserLevelServiceActive)
    Script.register('CSK_UserManagement.OnUserLevelAdminActive', handleOnUserLevelAdminActive)
  end
  Script.releaseObject(handle)
end

--- Function to update user levels
local function updateUserLevel()
  if recipeManager_Model.userManagementModuleAvailable then
    -- Trigger CSK_UserManagement module to provide events regarding user role
    CSK_UserManagement.pageCalled()
  else
    -- If CSK_UserManagement is not active, show everything
    Script.notifyEvent("RecipeManager_OnUserLevelAdminActive", true)
    Script.notifyEvent("RecipeManager_OnUserLevelMaintenanceActive", true)
    Script.notifyEvent("RecipeManager_OnUserLevelServiceActive", true)
    Script.notifyEvent("RecipeManager_OnUserLevelOperatorActive", true)
  end
end

--- Function to send all relevant values to UI on resume
local function handleOnExpiredTmrRecipeManager()

  updateUserLevel()

  -- Script.notifyEvent("RecipeManager_OnNewEvent", false)

  Script.notifyEvent("RecipeManager_OnNewStatusLoadParameterOnReboot", recipeManager_Model.parameterLoadOnReboot)
  Script.notifyEvent("RecipeManager_OnPersistentDataModuleAvailable", recipeManager_Model.persistentModuleAvailable)
  Script.notifyEvent("RecipeManager_OnNewParameterName", recipeManager_Model.parametersName)
  -- ...
end
Timer.register(tmrRecipeManager, "OnExpired", handleOnExpiredTmrRecipeManager)

-- ********************* UI Setting / Submit Functions Start ********************

local function pageCalled()
  updateUserLevel() -- try to hide user specific content asap
  tmrRecipeManager:start()
  return ''
end
Script.serveFunction("CSK_RecipeManager.pageCalled", pageCalled)

--[[
local function setSomething(value)
  _G.logger:info(nameOfModule .. ": Set new value = " .. value)
  recipeManager_Model.varA = value
end
Script.serveFunction("CSK_RecipeManager.setSomething", setSomething)
]]

-- *****************************************************************
-- Following function can be adapted for CSK_PersistentData module usage
-- *****************************************************************

local function setParameterName(name)
  _G.logger:info(nameOfModule .. ": Set parameter name: " .. tostring(name))
  recipeManager_Model.parametersName = name
end
Script.serveFunction("CSK_RecipeManager.setParameterName", setParameterName)

local function sendParameters()
  if recipeManager_Model.persistentModuleAvailable then
    CSK_PersistentData.addParameter(recipeManager_Model.helperFuncs.convertTable2Container(recipeManager_Model.parameters), recipeManager_Model.parametersName)
    CSK_PersistentData.setModuleParameterName(nameOfModule, recipeManager_Model.parametersName, recipeManager_Model.parameterLoadOnReboot)
    _G.logger:info(nameOfModule .. ": Send RecipeManager parameters with name '" .. recipeManager_Model.parametersName .. "' to CSK_PersistentData module.")
    CSK_PersistentData.saveData()
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
end
Script.serveFunction("CSK_RecipeManager.sendParameters", sendParameters)

local function loadParameters()
  if recipeManager_Model.persistentModuleAvailable then
    local data = CSK_PersistentData.getParameter(recipeManager_Model.parametersName)
    if data then
      _G.logger:info(nameOfModule .. ": Loaded parameters from CSK_PersistentData module.")
      recipeManager_Model.parameters = recipeManager_Model.helperFuncs.convertContainer2Table(data)
      -- If something needs to be configured/activated with new loaded data, place this here:
      -- ...
      -- ...

      CSK_RecipeManager.pageCalled()
    else
      _G.logger:warning(nameOfModule .. ": Loading parameters from CSK_PersistentData module did not work.")
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
end
Script.serveFunction("CSK_RecipeManager.loadParameters", loadParameters)

local function setLoadOnReboot(status)
  recipeManager_Model.parameterLoadOnReboot = status
  _G.logger:info(nameOfModule .. ": Set new status to load setting on reboot: " .. tostring(status))
end
Script.serveFunction("CSK_RecipeManager.setLoadOnReboot", setLoadOnReboot)

--- Function to react on initial load of persistent parameters
local function handleOnInitialDataLoaded()

  if string.sub(CSK_PersistentData.getVersion(), 1, 1) == '1' then

    _G.logger:warning(nameOfModule .. ': CSK_PersistentData module is too old and will not work. Please update CSK_PersistentData module.')

    recipeManager_Model.persistentModuleAvailable = false
  else

    local parameterName, loadOnReboot = CSK_PersistentData.getModuleParameterName(nameOfModule)

    if parameterName then
      recipeManager_Model.parametersName = parameterName
      recipeManager_Model.parameterLoadOnReboot = loadOnReboot
    end

    if recipeManager_Model.parameterLoadOnReboot then
      loadParameters()
    end
    Script.notifyEvent('RecipeManager_OnDataLoadedOnReboot')
  end
end
Script.register("CSK_PersistentData.OnInitialDataLoaded", handleOnInitialDataLoaded)

-- *************************************************
-- END of functions for CSK_PersistentData module usage
-- *************************************************

return setRecipeManager_Model_Handle

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************

