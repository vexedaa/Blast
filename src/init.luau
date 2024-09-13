--[=[
                                     
,---.|    ,---.,---.--.--     '| ,--.
|---.|    |---|`---.  |        | |  |
|   ||    |   |    |  |        | |  |
`---'`---'`   '`---'  `        `o`--'
                                          
A simple, easy-to-integrate plugin lifecycle springboard.
Made by Vexture in August 2024.

Disclaimer: Use this software at your own risk. I am not liable for any damage caused by using this software, financial or otherwise.
You have permission to use this software for commercial or personal use cases, provided that you credit me if you distribute it.
]=]

export type ButtonBundle = {button: PluginToolbarButton; data: {}; toolbar_name: string}

local Blast = {
    _Toolbars = require(script.Toolbars);
    _Widgets = require(script.Widgets);

    Toolbars = {};
    Buttons = {};
    Widgets = {};
    Connections = {};
    
    Resources = {};
    Types = require(script.BlastTypes);

    _toolbarsCreated = false;
    _widgetsCreated = false;

    _isButtonActive = {};

    _plugin = nil;

    _bindToClose = nil;
    _bindToCloseHandlers = {};

    _usePlaceWhitelist = false;
    _idWhitelist = {};

    ChangeHistoryService = game:GetService("ChangeHistoryService");
    Selection = game:GetService("Selection")
}

local BlastTypes = Blast.Types

function Blast.Init(_plugin: Plugin?)
    assert(_plugin ~= nil and _plugin.ClassName == "Plugin", "Cannot initialize Blast without `plugin`")

    if Blast._usePlaceWhitelist and not table.find(Blast._idWhitelist, game.PlaceId) then return end

    Blast._setPlugin(_plugin)
    Blast._createToolbars()
    Blast._createWidgets()
    Blast._setupBindToClose()
end

local function _addIdToWhitelist(id: number): boolean
    assert(id and (typeof(id) == "number"), `ID {id} is nil or an invalid type. Please provide a number argument.`)
    Blast._usePlaceWhitelist = true

    if table.find(Blast._idWhitelist, id) then return false end

    table.insert(Blast._idWhitelist, id)
    return true
end

function Blast.WhitelistPlace(id: number | {}): boolean
    assert(id and (typeof(id) == "number" or typeof(id) == "table"), `ID {id} is nil or an invalid type. Please provide a valid argument.`)
    if typeof(id) == "number" then
        return _addIdToWhitelist(id)
    elseif typeof(id) == "table" then
        for _, value in id do
            local result = _addIdToWhitelist(value)
            if not result then return false end
        end
    end
    return true
end

function Blast.SetPlugin(_plugin: Plugin)
    Blast._setPlugin(_plugin)
end

function Blast.SetResources(resources: Folder)
    Blast._setResources(resources)
end

function Blast._createToolbars()
    local toolbars = Blast._Toolbars
    for _, toolbar in toolbars do
        Blast:CreateToolbar(toolbar)
    end

    Blast._toolbarsCreated = true
end

function Blast._createWidgets()
    local widgets = Blast._Widgets
    for _, widget in widgets do
        Blast:CreateWidget(widget)
    end

    Blast._widgetsCreated = true
end

function Blast._setPlugin(_plugin: Plugin)
    if _plugin == nil then return end
    Blast._plugin = _plugin
end

function Blast._setResources(resources: Folder, replaces: boolean?): {}
    assert(resources and resources:IsA("Folder"), `Resources {resources} is not a folder, or does not exist.`)
    if replaces or replaces == nil then
        Blast.Resources = {}
    end
    for _, resource in resources:GetChildren() do
        Blast.Resources[resource.Name] = require(resource)
    end

    return Blast.Resources
end

function Blast._setupBindToClose()
    local plugin = Blast._plugin
    assert(plugin ~= nil and plugin.ClassName == "Plugin", `Invalid 'plugin' supplied: {plugin}`)
    Blast._bindToClose = function()
        for _, handler in Blast._bindToCloseHandlers do
            handler()
        end
    end

    Blast:BindToClose(function()
        for _, connection in Blast.Connections do
            connection:Disconnect()
        end
    end)

    plugin.Unloading:Connect(Blast._bindToClose)
end

function Blast:awaitToolbars()
    repeat
        task.wait()
    until self._toolbarsCreated == true
    return true
end

function Blast:awaitWidgets()
    repeat
        task.wait()
    until self._widgetsCreated == true
    return true
end

function Blast:GetPlugin()
    return Blast._plugin
end

function Blast:CanPluginRun()
    return table.find(Blast._idWhitelist, game.PlaceId) ~= nil or Blast._usePlaceWhitelist == false
end

function Blast:GetButton(toolbar_name: string, button_name: string): PluginToolbarButton
    self:AssertForButton(toolbar_name, button_name)
    
    local s, r = pcall(function()
        return self.Buttons[toolbar_name][button_name].button
    end)
    if s == false then
        error(`Button {button_name} does not exist in toolbar {toolbar_name}.`)
    end

    return r
end

function Blast:GetButtonBundle(toolbar_name: string, button_name: string): ButtonBundle
    self:AssertForButton(toolbar_name, button_name)
    
    local s, r = pcall(function()
        return self.Buttons[toolbar_name][button_name]
    end)
    if s == false then
        error(`Button {button_name} does not exist in toolbar {toolbar_name}.`)
    end

    return r
end

function Blast:GetToolbar(toolbar_name: string)
    return self.Toolbars[toolbar_name]
end

function Blast:GetWidget(widget_name: string)
    return self.Widgets[widget_name]
end

function Blast:GetResource(resource_name: string)
    local find_resource = self.Resources[resource_name]
    assert(not not find_resource, `Resource {resource_name} does not exist.`)
    return find_resource
end

local function _toggleButtonActive(toolbar_name, button_name, callback)
    local isButtonActive = Blast:IsButtonActive(toolbar_name, button_name)
    isButtonActive = not isButtonActive

    Blast:SetButtonActive(toolbar_name, button_name, isButtonActive)

    if callback then
        callback(isButtonActive)
    end
end

local function _hookButtonToggleEvent(toolbar_name: string, button_name: string, callback: ((isButtonActive: boolean) -> any)?)
    local button = Blast:GetButton(toolbar_name, button_name)
    local button_bundle = Blast:GetButtonBundle(toolbar_name, button_name)
    button_bundle.toggleEvent = button.Click:Connect(function()
        _toggleButtonActive(toolbar_name, button_name, callback)
    end)
end



function Blast:AssertForButton(toolbar_name: string, button_name: string)
    assert(typeof(toolbar_name) == "string", "Must specify a toolbar")
    assert(typeof(button_name) == "string", "Must specify a button name")
    return true
end

function Blast:SetButtonEnabled(toolbar_name: string, button_name: string, enabled: boolean?): boolean?
    self:AssertForButton(toolbar_name, button_name)
    local button = self:GetButton(toolbar_name, button_name)

    if enabled == nil then
        enabled = not button.Enabled
    end

    button.Enabled = not enabled
    button.Enabled = enabled

    return true
end

function Blast:SetButtonActive(toolbar_name: string, button_name: string, active: boolean?): boolean?
    self:AssertForButton(toolbar_name, button_name)

    assert(active == nil or typeof(active) == "boolean", "Invalid toggle value")
    local button = self:GetButton(toolbar_name, button_name)
    assert(button and button.ClassName == "PluginToolbarButton", "Button not found")
    local button_lookup = Blast._buttonLookup(toolbar_name, button_name)
    local enabled = button.Enabled
    button.Enabled = false
    
    if active == nil then
        active = not Blast._isButtonActive[button_lookup]
    end

    button:SetActive(active)
    button.Enabled = enabled
    Blast._isButtonActive[button_lookup] = active

    return true
end

function Blast:SuspendButton(toolbar_name: string, button_name: string)
    self:SetButtonEnabled(toolbar_name, button_name, false)
    self:SetButtonActive(toolbar_name, button_name, false)
end

function Blast:ReviveButton(toolbar_name: string, button_name: string)
    self:SetButtonEnabled(toolbar_name, button_name, true)
    self:SetButtonActive(toolbar_name, button_name, false)
end

function Blast:IsButtonActive(toolbar_name: string, button_name: string): boolean
    self:AssertForButton(toolbar_name, button_name)

    local isButtonActive = Blast._isButtonActive[Blast._buttonLookup(toolbar_name, button_name)]
    if isButtonActive == nil then
        isButtonActive = false
    end

    return isButtonActive
end

function Blast._buttonLookup(toolbar_name: string, button_name: string): string
    return `{toolbar_name}-{button_name}`
end

function Blast:CreateToolbar(toolbar_data: {name: string, buttons: { [string]: BlastTypes.Toolbar_Button }})
    local name = toolbar_data.name
    local buttons = toolbar_data.buttons

    local created_toolbar = self:GetPlugin():CreateToolbar(name)

    local created_buttons = {}
    
    for _, button in buttons do
        local created_button = created_toolbar:CreateButton(button.name, button.tooltip or "", button.icon or "", button.text)
        local button_data = {button = created_button; data = button; toolbar_name = name}
        created_buttons[button.name] = button_data

        self._isButtonActive[Blast._buttonLookup(name, button.name)] = false -- Inactive by default
        created_button.Enabled = true
        
        local toolbar_packet = {toolbar = created_toolbar; data = toolbar_data}
        self.Toolbars[name] = toolbar_packet
        self.Buttons[name] = created_buttons
        
        task.spawn(function()
            if button_data.data.togglesWidget then
                local widget_data = Blast:GetWidget(button_data.data.togglesWidget)
                if not widget_data then
                    repeat
                        widget_data = Blast:GetWidget(button_data.data.togglesWidget)
                        task.wait()
                    until widget_data
                end
    
                _hookButtonToggleEvent(name, button.name, function(isButtonActive: boolean)
                    widget_data.widget.Enabled = isButtonActive
                end)

                local initial_enabled = widget_data.widget.Enabled
                if initial_enabled then
                    Blast:SetButtonActive(name, button.name, initial_enabled)
                end

                widget_data.widget:BindToClose(function()
                    widget_data.widget.Enabled = false
                    _toggleButtonActive(name, button.name)
                end)
                
            else
                _hookButtonToggleEvent(name, button.name)
                Blast:SetButtonActive(name, button.name, false)
            end
        end)
    end



    return created_toolbar, created_buttons
end

function Blast:CreateWidget(dock_widget_data: {name: string, widget: DockWidgetPluginGuiInfo, gui: GuiObject})
    local widget =  self:GetPlugin():CreateDockWidgetPluginGui(dock_widget_data.name, dock_widget_data.widget)
    dock_widget_data.gui.Parent = widget
    local packet = {widget = widget; data = dock_widget_data}
    self.Widgets[dock_widget_data.name] = packet
    return packet
end

function Blast:BindToClose(callback: () -> any)
    local plugin = self._plugin
    assert(plugin ~= nil and plugin.ClassName == "Plugin", `Invalid 'plugin' supplied: {plugin}`)
    assert(callback and typeof(callback) == "function", `A callback must be provided to BindToClose.`)

    table.insert(self._bindToCloseHandlers, callback)
end

return Blast