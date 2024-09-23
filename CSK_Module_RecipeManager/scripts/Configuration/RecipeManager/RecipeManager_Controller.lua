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

Script.serveEvent('CSK_RecipeManager.OnNewStatusModuleVersion', 'RecipeManager_OnNewStatusModuleVersion')
Script.serveEvent('CSK_RecipeManager.OnNewStatusCSKStyle', 'RecipeManager_OnNewStatusCSKStyle')
Script.serveEvent('CSK_RecipeManager.OnNewStatusModuleIsActive', 'RecipeManager_OnNewStatusModuleIsActive')

Script.serveEvent('CSK_RecipeManager.OnNewStatusRecipeList', 'RecipeManager_OnNewStatusRecipeList')
Script.serveEvent('CSK_RecipeManager.OnNewStatusRecipeName', 'RecipeManager_OnNewStatusRecipeName')
Script.serveEvent('CSK_RecipeManager.OnNewStatusRecipeSelected', 'RecipeManager_OnNewStatusRecipeSelected')
Script.serveEvent('CSK_RecipeManager.OnNewStatusRegisteredEvent', 'RecipeManager_OnNewStatusRegisteredEvent')
Script.serveEvent('CSK_RecipeManager.OnNewStatusLoadSelectedRecipe', 'RecipeManager_OnNewStatusLoadSelectedRecipe')

Script.serveEvent('CSK_RecipeManager.OnNewStatusRecipeModuleName', 'RecipeManager_OnNewStatusRecipeModuleName')
Script.serveEvent('CSK_RecipeManager.OnNewStatusRecipeInstanceID', 'RecipeManager_OnNewStatusRecipeInstanceID')
Script.serveEvent('CSK_RecipeManager.OnNewStatusRecipeParameterName', 'RecipeManager_OnNewStatusRecipeParameterName')

Script.serveEvent('CSK_RecipeManager.OnNewStatusSelectedRecipe', 'RecipeManager_OnNewStatusSelectedRecipe')
Script.serveEvent('CSK_RecipeManager.OnNewStatusRecipeTable', 'RecipeManager_OnNewStatusRecipeTable')

Script.serveEvent('CSK_RecipeManager.OnNewStatusRecipeSuccessfullyLoaded', 'RecipeManager_OnNewStatusRecipeSuccessfullyLoaded')

Script.serveEvent('CSK_RecipeManager.OnNewStatusFlowConfigPriority', 'RecipeManager_OnNewStatusFlowConfigPriority')
Script.serveEvent("CSK_RecipeManager.OnNewStatusLoadParameterOnReboot", "RecipeManager_OnNewStatusLoadParameterOnReboot")
Script.serveEvent("CSK_RecipeManager.OnPersistentDataModuleAvailable", "RecipeManager_OnPersistentDataModuleAvailable")
Script.serveEvent("CSK_RecipeManager.OnNewParameterName", "RecipeManager_OnNewParameterName")
Script.serveEvent("CSK_RecipeManager.OnDataLoadedOnReboot", "RecipeManager_OnDataLoadedOnReboot")

Script.serveEvent('CSK_RecipeManager.OnUserLevelOperatorActive', 'RecipeManager_OnUserLevelOperatorActive')
Script.serveEvent('CSK_RecipeManager.OnUserLevelMaintenanceActive', 'RecipeManager_OnUserLevelMaintenanceActive')
Script.serveEvent('CSK_RecipeManager.OnUserLevelServiceActive', 'RecipeManager_OnUserLevelServiceActive')
Script.serveEvent('CSK_RecipeManager.OnUserLevelAdminActive', 'RecipeManager_OnUserLevelAdminActive')

-- ************************ UI Events End **********************************

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

  Script.notifyEvent("RecipeManager_OnNewStatusModuleVersion", recipeManager_Model.version)
  Script.notifyEvent("RecipeManager_OnNewStatusCSKStyle", recipeManager_Model.styleForUI)
  Script.notifyEvent("RecipeManager_OnNewStatusModuleIsActive", true)

  updateUserLevel()

  Script.notifyEvent("RecipeManager_OnNewStatusRecipeList", recipeManager_Model.helperFuncs.createJsonList(recipeManager_Model.parameters.recipes))--recipeManager_Model.recipeList)
  Script.notifyEvent("RecipeManager_OnNewStatusRecipeName", recipeManager_Model.newName)
  Script.notifyEvent("RecipeManager_OnNewStatusSelectedRecipe", recipeManager_Model.parameters.selectedRecipe)
  Script.notifyEvent("RecipeManager_OnNewStatusRegisteredEvent", recipeManager_Model.parameters.registeredEvent)

  if recipeManager_Model.parameters.selectedRecipe ~= '' then
    Script.notifyEvent("RecipeManager_OnNewStatusRecipeSelected", true)
  else
    Script.notifyEvent("RecipeManager_OnNewStatusRecipeSelected", false)
  end
  Script.notifyEvent("RecipeManager_OnNewStatusLoadSelectedRecipe", recipeManager_Model.parameters.startRecipeOnLoad)

  Script.notifyEvent("RecipeManager_OnNewStatusRecipeModuleName", recipeManager_Model.moduleName)
  Script.notifyEvent("RecipeManager_OnNewStatusRecipeInstanceID", recipeManager_Model.instanceNo)
  Script.notifyEvent("RecipeManager_OnNewStatusRecipeParameterName", recipeManager_Model.parameterName)

  Script.notifyEvent("RecipeManager_OnNewStatusRecipeTable", recipeManager_Model.helperFuncs.createJsonRecipeList(recipeManager_Model.parameters.recipes[recipeManager_Model.parameters.selectedRecipe], recipeManager_Model.selectedRow))

  Script.notifyEvent("RecipeManager_OnNewStatusFlowConfigPriority", recipeManager_Model.parameters.flowConfigPriority)
  Script.notifyEvent("RecipeManager_OnNewStatusLoadParameterOnReboot", recipeManager_Model.parameterLoadOnReboot)
  Script.notifyEvent("RecipeManager_OnPersistentDataModuleAvailable", recipeManager_Model.persistentModuleAvailable)
  Script.notifyEvent("RecipeManager_OnNewParameterName", recipeManager_Model.parametersName)

end
Timer.register(tmrRecipeManager, "OnExpired", handleOnExpiredTmrRecipeManager)

-- ********************* UI Setting / Submit Functions Start ********************

local function pageCalled()
  updateUserLevel() -- try to hide user specific content asap
  tmrRecipeManager:start()
  return ''
end
Script.serveFunction("CSK_RecipeManager.pageCalled", pageCalled)

local function addRecipe(name)
  if not recipeManager_Model.parameters.recipes[name] then
    _G.logger:fine(nameOfModule .. ": Add recipe: " .. tostring(name))
    recipeManager_Model.parameters.recipes[name] = {}
    recipeManager_Model.parameters.selectedRecipe = name
  else
    _G.logger:info(nameOfModule .. ": Recipe '" .. tostring(name) .. "' already exists.")
  end
  handleOnExpiredTmrRecipeManager()
end
Script.serveFunction('CSK_RecipeManager.addRecipe', addRecipe)

local function addRecipeViaUI()
  addRecipe(recipeManager_Model.newName)
end
Script.serveFunction('CSK_RecipeManager.addRecipeViaUI', addRecipeViaUI)

local function deleteRecipe(name)
  _G.logger:fine(nameOfModule .. ": Delete recipe: " .. tostring(name))
  recipeManager_Model.parameters.recipes[name] = nil
  recipeManager_Model.parameters.selectedRecipe = ''
  handleOnExpiredTmrRecipeManager()
end
Script.serveFunction('CSK_RecipeManager.deleteRecipe', deleteRecipe)

local function deleteRecipeViaUI()
  deleteRecipe(recipeManager_Model.parameters.selectedRecipe)
end
Script.serveFunction('CSK_RecipeManager.deleteRecipeViaUI', deleteRecipeViaUI)

local function setRecipeName(name)
  _G.logger:fine(nameOfModule .. ": Set recipe name: " .. tostring(name))
  recipeManager_Model.newName = name
end
Script.serveFunction('CSK_RecipeManager.setRecipeName', setRecipeName)

local function updateRecipeConfig()

  if recipeManager_Model.selectedRow ~= '' and recipeManager_Model.parameters.recipes[recipeManager_Model.parameters.selectedRecipe][recipeManager_Model.selectedRow] then
    recipeManager_Model.parameters.recipes[recipeManager_Model.parameters.selectedRecipe][recipeManager_Model.selectedRow]['moduleName'] = recipeManager_Model.moduleName
    recipeManager_Model.parameters.recipes[recipeManager_Model.parameters.selectedRecipe][recipeManager_Model.selectedRow]['instanceNo'] = recipeManager_Model.instanceNo
    recipeManager_Model.parameters.recipes[recipeManager_Model.parameters.selectedRecipe][recipeManager_Model.selectedRow]['parameterName'] = recipeManager_Model.parameterName
  else
    local recipe = {}
    recipe.moduleName = recipeManager_Model.moduleName
    recipe.instanceNo = recipeManager_Model.instanceNo
    recipe.parameterName = recipeManager_Model.parameterName
    table.insert(recipeManager_Model.parameters.recipes[recipeManager_Model.parameters.selectedRecipe], recipe)
  end
  handleOnExpiredTmrRecipeManager()
end
Script.serveFunction('CSK_RecipeManager.updateRecipeConfig', updateRecipeConfig)

local function selectRecipe(name)
  _G.logger:fine(nameOfModule .. ": Select recipe: " .. tostring(name))
  recipeManager_Model.parameters.selectedRecipe = name
  recipeManager_Model.newName = name
  handleOnExpiredTmrRecipeManager()
end
Script.serveFunction('CSK_RecipeManager.selectRecipe', selectRecipe)

local function setLoadRecipeWithParameterLoaded(status)
  _G.logger:fine(nameOfModule .. ": Set status to load recipe with loading of parameters: " .. tostring(status))
  recipeManager_Model.parameters.startRecipeOnLoad = status
end
Script.serveFunction('CSK_RecipeManager.setLoadRecipeWithParameterLoaded', setLoadRecipeWithParameterLoaded)

local function setRecipeModuleName(name)
  _G.logger:fine(nameOfModule .. ": Set recipe name: " .. tostring(name))
  recipeManager_Model.moduleName = name
end
Script.serveFunction('CSK_RecipeManager.setRecipeModuleName', setRecipeModuleName)

local function setRecipeParameterName(name)
  _G.logger:fine(nameOfModule .. ": Set recipe parameter name: " .. tostring(name))
  recipeManager_Model.parameterName = name
end
Script.serveFunction('CSK_RecipeManager.setRecipeParameterName', setRecipeParameterName)

local function setRecipeInstance(instanceNo)
  _G.logger:fine(nameOfModule .. ": Set recipe instance: " .. tostring(instanceNo))
  recipeManager_Model.instanceNo = instanceNo
end
Script.serveFunction('CSK_RecipeManager.setRecipeInstance', setRecipeInstance)

--- Function to check if selection in UIs DynamicTable can find related pattern
---@param selection string Full text of selection
---@param pattern string Pattern to search for
---@param findEnd bool Find end after pattern
---@return string? Success if pattern was found or even postfix after pattern till next quotation marks if findEnd was set to TRUE
local function checkSelection(selection, pattern, findEnd)
  if selection ~= "" then
    local _, pos = string.find(selection, pattern)
    if pos == nil then
      return nil
    else
      if findEnd then
        pos = tonumber(pos)
        local endPos = string.find(selection, '"', pos+1)
        if endPos then
          local tempSelection = string.sub(selection, pos+1, endPos-1)
          if tempSelection ~= nil and tempSelection ~= '-' then
            return tempSelection
          end
        else
          return nil
        end
      else
        return 'true'
      end
    end
  end
  return nil
end

local function selectTableRow(selection)
  local tempSelection = checkSelection(selection, '"DTC_ID":"', true)
  if tempSelection then
    local isSelected = checkSelection(selection, '"selected":true', false)
    if isSelected then
      _G.logger:fine(nameOfModule .. ": Selected ID " .. tostring(tempSelection))
      recipeManager_Model.selectedRow = tonumber(tempSelection)

      recipeManager_Model.moduleName = recipeManager_Model.parameters.recipes[recipeManager_Model.parameters.selectedRecipe][recipeManager_Model.selectedRow]['moduleName']
      recipeManager_Model.parameterName = recipeManager_Model.parameters.recipes[recipeManager_Model.parameters.selectedRecipe][recipeManager_Model.selectedRow]['parameterName']
      recipeManager_Model.instanceNo = recipeManager_Model.parameters.recipes[recipeManager_Model.parameters.selectedRecipe][recipeManager_Model.selectedRow]['instanceNo']
    else
      recipeManager_Model.selectedRow = ''
    end
    handleOnExpiredTmrRecipeManager()
  end
end
Script.serveFunction('CSK_RecipeManager.selectTableRowInUI', selectTableRow)

local function deleteRecipeOrderID(orderID)
  _G.logger:fine(nameOfModule .. ": Delete recipe ID: " .. tostring(orderID))
  table.remove(recipeManager_Model.parameters.recipes[recipeManager_Model.parameters.selectedRecipe], orderID)
  handleOnExpiredTmrRecipeManager()
end
Script.serveFunction('CSK_RecipeManager.deleteRecipeOrderID', deleteRecipeOrderID)

local function deleteRecipeOrderIDViaUI()
  if recipeManager_Model.selectedRow ~= '' then
    deleteRecipeOrderID(recipeManager_Model.selectedRow)
  end
end
Script.serveFunction('CSK_RecipeManager.deleteRecipeOrderIDViaUI', deleteRecipeOrderIDViaUI)

local function moveTableRowUp()
  if recipeManager_Model.selectedRow ~= '' and recipeManager_Model.selectedRow ~= 1 then

    local tempDataName = recipeManager_Model.parameters.recipes[recipeManager_Model.parameters.selectedRecipe][recipeManager_Model.selectedRow]
    table.insert(recipeManager_Model.parameters.recipes[recipeManager_Model.parameters.selectedRecipe], recipeManager_Model.selectedRow-1, tempDataName)
    table.remove(recipeManager_Model.parameters.recipes[recipeManager_Model.parameters.selectedRecipe], recipeManager_Model.selectedRow+1)
    collectgarbage()

    recipeManager_Model.selectedRow = recipeManager_Model.selectedRow-1
  end
  handleOnExpiredTmrRecipeManager()
end
Script.serveFunction('CSK_RecipeManager.moveTableRowUp', moveTableRowUp)

local function moveTableRowDown()
  if recipeManager_Model.selectedRow ~= '' and recipeManager_Model.selectedRow ~= #recipeManager_Model.parameters.recipes[recipeManager_Model.parameters.selectedRecipe] then

    local tempDataName = recipeManager_Model.parameters.recipes[recipeManager_Model.parameters.selectedRecipe][recipeManager_Model.selectedRow]
    table.remove(recipeManager_Model.parameters.recipes[recipeManager_Model.parameters.selectedRecipe], recipeManager_Model.selectedRow)
    table.insert(recipeManager_Model.parameters.recipes[recipeManager_Model.parameters.selectedRecipe], recipeManager_Model.selectedRow+1, tempDataName)
    collectgarbage()

    recipeManager_Model.selectedRow = recipeManager_Model.selectedRow+1
  end
  handleOnExpiredTmrRecipeManager()
end
Script.serveFunction('CSK_RecipeManager.moveTableRowDown', moveTableRowDown)

local function loadRecipe(recipe)
  local totalSuccess = true
  _G.logger:fine(nameOfModule .. ": Load recipe: " .. tostring(recipe))
  if recipe then
    if recipeManager_Model.parameters.recipes[recipe] then
      for key, value in ipairs(recipeManager_Model.parameters.recipes[recipe]) do
        local tempModule = value['moduleName']
        local tempInstanceNo = value['instanceNo']
        local tempParameterName = value['parameterName']

        local instanceSelectionExists = Script.isServedAsFunction(value['moduleName'] .. '.setSelectedInstance')
        local setInstanceExists = Script.isServedAsFunction(value['moduleName'] .. '.setInstance')
        local instanceAmountExists = Script.isServedAsFunction(value['moduleName'] .. '.getInstancesAmount')
        local instanceAddExists = Script.isServedAsFunction(value['moduleName'] .. '.addInstance')
        local setParameterNameExists = Script.isServedAsFunction(value['moduleName'] .. '.setParameterName')
        local loadParametersExists = Script.isServedAsFunction(value['moduleName'] .. '.loadParameters')

        if setParameterNameExists and loadParametersExists then

          if value['instanceNo'] > 1 then
            if (instanceSelectionExists or setInstanceExists) and instanceAmountExists and instanceAddExists then
              --Check for amount if instance needs to be created
              local suc, amount = Script.callFunction(value['moduleName'] .. '.getInstancesAmount')
              while amount < value['instanceNo'] do
                Script.callFunction(value['moduleName'] .. '.addInstance')
                suc, amount = Script.callFunction(value['moduleName'] .. '.getInstancesAmount')
              end

              if instanceSelectionExists then
                Script.callFunction(value['moduleName'] .. '.setSelectedInstance', value['instanceNo'])
              elseif setInstanceExists then
                Script.callFunction(value['moduleName'] .. '.setInstance', value['instanceNo'])
              end
            else
              break
            end
          else
            if instanceSelectionExists then
              Script.callFunction(value['moduleName'] .. '.setSelectedInstance', 1)
            elseif setInstanceExists then
              Script.callFunction(value['moduleName'] .. '.setInstance', 1)
            end
          end

          Script.callFunction(value['moduleName'] .. '.setParameterName', value['parameterName'])
          local _, loadSuccess = Script.callFunction(value['moduleName'] .. '.loadParameters')
          if loadSuccess ~= true then
            _G.logger:warning("Something went wrong when trying to load parameter '" .. tostring(value['parameterName']) .. "' for Module " .. tostring(value['moduleName']))
            totalSuccess = false
          end

        else
          _G.logger:warning("Module '" .. value['moduleName'] .. '" does not support necessary persistent data functions.')
          totalSuccess = false
        end

      end
    else
      _G.logger:warning("Recipe '" .. recipe .. '" does not exist.')
      totalSuccess = false
    end
  else
    _G.logger:warning("No recipe received.")
    totalSuccess = false
  end
  Script.notifyEvent("RecipeManager_OnNewStatusRecipeSuccessfullyLoaded", totalSuccess)
  return totalSuccess
end
Script.serveFunction('CSK_RecipeManager.loadRecipe', loadRecipe)

local function loadRecipeViaUI()
  loadRecipe(recipeManager_Model.parameters.selectedRecipe)
end
Script.serveFunction('CSK_RecipeManager.loadRecipeViaUI', loadRecipeViaUI)

local function setRegisteredEvent(event)
  _G.logger:fine(nameOfModule .. ": Set registered event to: " .. tostring(event))
  Script.deregister(recipeManager_Model.parameters.registeredEvent, loadRecipe)

  recipeManager_Model.parameters.registeredEvent = event
  Script.register(recipeManager_Model.parameters.registeredEvent, loadRecipe)

  handleOnExpiredTmrRecipeManager()
end
Script.serveFunction('CSK_RecipeManager.setRegisteredEvent', setRegisteredEvent)

local function getStatusModuleActive()
  return _G.availableAPIs.default and _G.availableAPIs.specific
end
Script.serveFunction('CSK_RecipeManager.getStatusModuleActive', getStatusModuleActive)

local function clearFlowConfigRelevantConfiguration()
  Script.deregister(recipeManager_Model.parameters.registeredEvent, loadRecipe)
end
Script.serveFunction('CSK_RecipeManager.clearFlowConfigRelevantConfiguration', clearFlowConfigRelevantConfiguration)

local function getParameters()
  return recipeManager_Model.helperFuncs.json.encode(recipeManager_Model.parameters)
end
Script.serveFunction('CSK_RecipeManager.getParameters', getParameters)

-- *****************************************************************
-- Following function can be adapted for CSK_PersistentData module usage
-- *****************************************************************

local function setParameterName(name)
  _G.logger:fine(nameOfModule .. ": Set parameter name: " .. tostring(name))
  recipeManager_Model.parametersName = name
end
Script.serveFunction("CSK_RecipeManager.setParameterName", setParameterName)

local function sendParameters(noDataSave)
  if recipeManager_Model.persistentModuleAvailable then
    CSK_PersistentData.addParameter(recipeManager_Model.helperFuncs.convertTable2Container(recipeManager_Model.parameters), recipeManager_Model.parametersName)
    CSK_PersistentData.setModuleParameterName(nameOfModule, recipeManager_Model.parametersName, recipeManager_Model.parameterLoadOnReboot)
    _G.logger:fine(nameOfModule .. ": Send RecipeManager parameters with name '" .. recipeManager_Model.parametersName .. "' to CSK_PersistentData module.")
    if not noDataSave then
      CSK_PersistentData.saveData()
    end
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

      Script.deregister(recipeManager_Model.parameters.registeredEvent, loadRecipe)
      recipeManager_Model.parameters = recipeManager_Model.helperFuncs.convertContainer2Table(data)

      -- If something needs to be configured/activated with new loaded data, place this here:
      if recipeManager_Model.parameters.registeredEvent ~= '' then
        setRegisteredEvent(recipeManager_Model.parameters.registeredEvent)
      end

      if recipeManager_Model.parameters.startRecipeOnLoad then
        loadRecipeViaUI()
      end

      CSK_RecipeManager.pageCalled()
      return true
    else
      _G.logger:warning(nameOfModule .. ": Loading parameters from CSK_PersistentData module did not work.")
      return false
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
    return false
  end
end
Script.serveFunction("CSK_RecipeManager.loadParameters", loadParameters)

local function setLoadOnReboot(status)
  recipeManager_Model.parameterLoadOnReboot = status
  _G.logger:info(nameOfModule .. ": Set new status to load setting on reboot: " .. tostring(status))
  Script.notifyEvent("RecipeManager_OnNewStatusLoadParameterOnReboot", status)
end
Script.serveFunction("CSK_RecipeManager.setLoadOnReboot", setLoadOnReboot)

local function setFlowConfigPriority(status)
  recipeManager_Model.parameters.flowConfigPriority = status
  _G.logger:fine(nameOfModule .. ": Set new status of FlowConfig priority: " .. tostring(status))
  Script.notifyEvent("RecipeManager_OnNewStatusFlowConfigPriority", recipeManager_Model.parameters.flowConfigPriority)
end
Script.serveFunction('CSK_RecipeManager.setFlowConfigPriority', setFlowConfigPriority)

--- Function to react on initial load of persistent parameters
local function handleOnInitialDataLoaded()

  if _G.availableAPIs.specific then
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
end
Script.register("CSK_PersistentData.OnInitialDataLoaded", handleOnInitialDataLoaded)

-- *************************************************
-- END of functions for CSK_PersistentData module usage
-- *************************************************

return setRecipeManager_Model_Handle

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************

