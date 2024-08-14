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

-- Optionally check if specific API was loaded via
--[[
if _G.availableAPIs.specific then
-- ... doSomething ...
end
]]

--[[
-- Create parameters / instances for this module
recipeManager_Model.object = Image.create() -- Use any AppEngine CROWN
recipeManager_Model.counter = 1 -- Short docu of variable
recipeManager_Model.varA = 'value' -- Short docu of variable
--...
]]

-- Parameters to be saved permanently if wanted
recipeManager_Model.parameters = {}
--recipeManager_Model.parameters.paramA = 'paramA' -- Short docu of variable
--recipeManager_Model.parameters.paramB = 123 -- Short docu of variable
--...

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--[[
-- Some internal code docu for local used function to do something
---@param content auto Some info text if function is not already served
local function doSomething(content)
  _G.logger:info(nameOfModule .. ": Do something")
  recipeManager_Model.counter = recipeManager_Model.counter + 1
end
recipeManager_Model.doSomething = doSomething
]]

--*************************************************************************
--********************** End Function Scope *******************************
--*************************************************************************

return recipeManager_Model
