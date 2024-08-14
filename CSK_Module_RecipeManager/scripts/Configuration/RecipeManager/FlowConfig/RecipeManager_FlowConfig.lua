--*****************************************************************
-- Here you will find all the required content to provide specific
-- features of this module via the 'CSK FlowConfig'.
--*****************************************************************

require('Configuration.RecipeManager.FlowConfig.RecipeManager_OnRecipeLoaded')
require('Configuration.RecipeManager.FlowConfig.RecipeManager_LoadRecipe')

--- Function to react if FlowConfig was updated
local function handleOnClearOldFlow()
  if _G.availableAPIs.default and _G.availableAPIs.specific then
    if recipeManager_Model.parameters.flowConfigPriority then
      CSK_RecipeManager.clearFlowConfigRelevantConfiguration()
    end
  end
end
Script.register('CSK_FlowConfig.OnClearOldFlow', handleOnClearOldFlow)