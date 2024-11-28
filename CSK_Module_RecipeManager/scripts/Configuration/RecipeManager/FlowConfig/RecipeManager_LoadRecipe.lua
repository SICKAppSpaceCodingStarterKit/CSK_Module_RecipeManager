-- Block namespace
local BLOCK_NAMESPACE = 'RecipeManager_FC.LoadRecipe'
local nameOfModule = 'CSK_RecipeManager'

--*************************************************************
--*************************************************************

-- Required to keep track of already allocated resource
local instanceTable = {}

local function loadRecipe(handle, source)
  CSK_RecipeManager.setRegisteredEvent(source)
end
Script.serveFunction(BLOCK_NAMESPACE .. '.loadRecipe', loadRecipe)

--*************************************************************
--*************************************************************

local function create()

  if nil ~= instanceTable['Solo'] then
    _G.logger:warning(nameOfModule .. ": Instance already in use, please choose another one")
    return nil
  else
    -- Otherwise create handle and store the restriced resource
    local handle = Container.create()
    instanceTable['Solo'] = 'Solo'
    return handle
  end
end
Script.serveFunction(BLOCK_NAMESPACE .. '.create', create)

--- Function to reset instances if FlowConfig was cleared
local function handleOnClearOldFlow()
  Script.releaseObject(instanceTable)
  instanceTable = {}
end
Script.register('CSK_FlowConfig.OnClearOldFlow', handleOnClearOldFlow)
