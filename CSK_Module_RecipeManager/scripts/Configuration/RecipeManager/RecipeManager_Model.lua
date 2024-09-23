---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter
--*****************************************************************
-- Inside of this script, you will find the module definition
-- including its parameters and functions
--*****************************************************************

--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************
local nameOfModule = 'CSK_RecipeManager'

local recipeManager_Model = {}

-- Check if CSK_UserManagement module can be used if wanted
recipeManager_Model.userManagementModuleAvailable = CSK_UserManagement ~= nil or false

-- Check if CSK_PersistentData module can be used if wanted
recipeManager_Model.persistentModuleAvailable = CSK_PersistentData ~= nil or false

-- Default values for persistent data
-- If available, following values will be updated from data of CSK_PersistentData module (check CSK_PersistentData module for this)
recipeManager_Model.parametersName = 'CSK_RecipeManager_Parameter' -- name of parameter dataset to be used for this module
recipeManager_Model.parameterLoadOnReboot = false -- Status if parameter dataset should be loaded on app/device reboot

-- Load script to communicate with the RecipeManager_Model interface and give access
-- to the RecipeManager_Model object.
-- Check / edit this script to see/edit functions which communicate with the UI
local setRecipeManager_ModelHandle = require('Configuration/RecipeManager/RecipeManager_Controller')
setRecipeManager_ModelHandle(recipeManager_Model)

--Loading helper functions if needed
recipeManager_Model.helperFuncs = require('Configuration/RecipeManager/helper/funcs')

-- Create parameters / instances for this module
recipeManager_Model.newName = 'RecipeName'
recipeManager_Model.recipeList = '' -- List of available recipes

recipeManager_Model.moduleName = '' -- Name of module to configure recipe parameter
recipeManager_Model.parameterName = '' -- Name of parameter to configure for module
recipeManager_Model.instanceNo = 1 -- Number of instance for parameter
recipeManager_Model.selectedRow = '' -- Selected row in recipe table in UI

recipeManager_Model.version = Engine.getCurrentAppVersion() -- Version of module
recipeManager_Model.styleForUI = 'None' -- Optional parameter to set UI style

-- Parameters to be saved permanently if wanted
recipeManager_Model.parameters = {}
recipeManager_Model.parameters.flowConfigPriority = CSK_FlowConfig ~= nil or false -- Status if FlowConfig should have priority for FlowConfig relevant configurations

recipeManager_Model.parameters.registeredEvent = '' -- Event to receive recipe to load from external source
recipeManager_Model.parameters.selectedRecipe = '' -- Recipe to use
recipeManager_Model.parameters.startRecipeOnLoad = false -- Status if selected recipe should be directly loaded if parameters were loaded
recipeManager_Model.parameters.recipes = {} -- Table to store different recipes

--[[
Recipe strucutre
recipeManager_Model.parameters.recipes[recipeName]
recipeManager_Model.parameters.recipes[recipeName][ID][moduleName]
recipeManager_Model.parameters.recipes[recipeName][ID][instanceNo]
recipeManager_Model.parameters.recipes[recipeName][ID][parameterName]

]]
--recipeManager_Model.parameters.recipeNames = {} -- Table to store names of recipes
--recipeManager_Model.parameters.recipes.moduleName = {} -- Name of module

--[[
  local orderPrio = {} -- Table with recipe in prio order
recipeManager_Model.parameters.recipes.moduleName.multiModule = false -- Status if module has mutliple instances
recipeManager_Model.parameters.recipes.instanceNo = {} -- Instance of module to configure
recipeManager_Model.parameters.recipes.moduleName.instance.parameterName = '' -- Name of parameter to use
]]

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--- Function to react on UI style change
local function handleOnStyleChanged(theme)
  recipeManager_Model.styleForUI = theme
  Script.notifyEvent("RecipeManager_OnNewStatusCSKStyle", recipeManager_Model.styleForUI)
end
Script.register('CSK_PersistentData.OnNewStatusCSKStyle', handleOnStyleChanged)

--*************************************************************************
--********************** End Function Scope *******************************
--*************************************************************************

return recipeManager_Model
