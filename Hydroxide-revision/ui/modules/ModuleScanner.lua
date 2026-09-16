local ModuleScanner = {}
local Methods = import("modules/ModuleScanner")

if not hasMethods(Methods.RequiredMethods) then
    return ModuleScanner
end

local List, ListButton = import("ui/controls/List")
local MessageBox, MessageType = import("ui/controls/MessageBox")
local ContextMenu, ContextMenuButton = import("ui/controls/ContextMenu")

local Page = import("rbxassetid://11389137937").Base.Body.Pages.ModuleScanner
local Assets = import("rbxassetid://5042114982").ModuleScanner

local Query = Page.Query
local Search = Query.Search
local Refresh = Query.Refresh
local Results = Page.Results.Clip.Content

local moduleList = List.new(Results)
local moduleLogs = {}
local selectedLog

local pathContext = ContextMenuButton.new("rbxassetid://4891705738", "Get Module Path")
local decompileContext = ContextMenuButton.new("rbxassetid://4800244808", "Copy Decompiled Source")
moduleList:BindContextMenu(ContextMenu.new({ pathContext, decompileContext }))

pathContext:SetCallback(function()
    local selectedInstance = selectedLog.ModuleScript.Instance
    setClipboard(getInstancePath(selectedInstance))
    MessageBox.Show("Success", ("%s's path was copied to your clipboard."):format(selectedInstance.Name), MessageType.OK)
end)

decompileContext:SetCallback(function()
    local moduleScript = selectedLog.ModuleScript
    MessageBox.Show("Decompiling...", "Please wait, decompiling module source...", MessageType.OK)
    task.spawn(function()
        local source = moduleScript.GetSource()
        setClipboard(source)
        task.wait(0.1)
        MessageBox.Show("Success", "Decompiled source copied to clipboard.\n\nPaste it in a text editor to view.", MessageType.OK)
    end)
end)

-- Log Object

local Log = {}

function Log.new(moduleScript)
    local log = {}
    local moduleInstance = moduleScript.Instance
    local button = Assets.ModuleLog:Clone()
    local listButton = ListButton.new(button, moduleList)
    
    button.Name = moduleInstance.Name
    button:FindFirstChild("Name").Text = moduleInstance.Name
    button.Protos.Text = #moduleScript.Protos
    button.Constants.Text = #moduleScript.Constants

    listButton:SetRightCallback(function()
        selectedLog = log
    end)

    moduleLogs[moduleInstance] = log

    log.ModuleScript = moduleScript
    log.Button = listButton
    return log
end

-- UI Functionality

local function addModules(query)
    moduleList:Clear()
    moduleLogs = {}

    for _moduleInstance, moduleScript in pairs(Methods.Scan(query)) do
        Log.new(moduleScript)
    end

    moduleList:Recalculate()
end

Search.FocusLost:Connect(function(returned)
    if returned then
        addModules(Search.Text)
        Search.Text = ""
    end
end)

Refresh.MouseButton1Click:Connect(function()
    addModules()
end)

addModules()

return ModuleScanner
