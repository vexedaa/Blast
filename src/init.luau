--[=[
                                     
,---.|    ,---.,---.--.--     '| ,--.
|---.|    |---|`---.  |        | |  |
|   ||    |   |    |  |        | |  |
`---'`---'`   '`---'  `        `o`--'
                                          
A simple, easy-to-integrate plugin lifecycle springboard.
Made by Vexture in August 2024.

Disclaimer: Use this software at your own risk. I am not liable for any damage caused by using this software, financial or otherwise.
You have permission to use this software for commercial or personal use cases, provided that you credit the original author (me, Vexture), if you are distributing it.
]=]

export type ButtonBundle = {button: PluginToolbarButton; data: {}; toolbar_name: string}

local Blast = {
    _Toolbars = require(script.Toolbars);
    _Widgets = require(script.Widgets);

    Toolbars = {};
    Buttons = {};
    Widgets = {};
    
    Resources = {};
    Types = require(script.BlastTypes);

    _toolbarsCreated = false;
    _widgetsCreated = false;

    _isButtonActive = {};

    _plugin = nil;

    ChangeHistoryService = game:GetService("ChangeHistoryService");
    Selection = game:GetService("Selection")
}

local BlastTypes = Blast.Types

function Blast.Init(_plugin: Plugin?)
    assert(_plugin ~= nil and _plugin.ClassName == "Plugin", "Cannot initialize Blast without `plugin`")
    Blast._setPlugin(_plugin)
    Blast._createToolbars()
    Blast._createWidgets()
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

function Blast:GetButton(toolbar_name: string, button_name: string): PluginToolbarButton
    return self.Buttons[toolbar_name][button_name].button
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

local function _toggleButtonActive(button_data: any, callback: ((isButtonActive: boolean) -> any)?)
    local button = button_data.button
    button_data.toggleEvent = button.Click:Connect(function()
        local isButtonActive = Blast:IsButtonActive(button_data)
        isButtonActive = not isButtonActive

        Blast:SetButtonActive(button_data, isButtonActive)

        if callback then
            callback(isButtonActive)
        end
    end)
end

function Blast:AssertForButton(toolbar_name: string, button_name: string)
    assert(typeof(toolbar_name) == "string", "Must specify a toolbar")
    assert(typeof(button_name) == "string", "Must specify a button name")
    return true
end

function Blast:SetButtonActive(toolbar_name: string, button_name: string, active: boolean?): boolean?
    self:AssertForButton(toolbar_name, button_name)

    assert(active == nil or typeof(active) == "boolean", "Invalid toggle value")
    local button = self:GetButton(toolbar_name, button_name)
    assert(button and button.ClassName == "PluginToolbarButton", "Button not found")
    local button_lookup = Blast._buttonLookup(toolbar_name, button_name)
    
    if active == nil then
        active = not Blast._isButtonActive[button_lookup]
    end

    button.Enabled = not active
    button.Enabled = active
    button:SetActive(active)
    Blast._isButtonActive[button_lookup] = active

    return true
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

        self._isButtonActive[Blast._buttonLookup(name, button.name)] = {}
        
        task.spawn(function()
            if button_data.data.togglesWidget then
                local widget_data = Blast:GetWidget(button_data.data.togglesWidget)
                if not widget_data then
                    repeat
                        widget_data = Blast:GetWidget(button_data.data.togglesWidget)
                        task.wait()
                    until widget_data
                end
    
                _toggleButtonActive(button_data, function(isButtonActive: boolean)
                    widget_data.widget.Enabled = isButtonActive
                end)

                local initial_enabled = widget_data.widget.Enabled
                if initial_enabled then
                    Blast:SetButtonActive(button_data, initial_enabled)
                end

            end
        end)
    end

    local toolbar_packet = {toolbar = created_toolbar; data = toolbar_data}
    self.Toolbars[name] = toolbar_packet
    self.Buttons[name] = created_buttons


    return toolbar_packet, created_buttons
end

function Blast:CreateWidget(dock_widget_data: {name: string, widget: DockWidgetPluginGuiInfo})
    local widget =  self:GetPlugin():CreateDockWidgetPluginGui(dock_widget_data.name, dock_widget_data.widget)
    local packet = {widget = widget; data = dock_widget_data}
    self.Widgets[dock_widget_data.name] = packet
    return packet
end

return Blast