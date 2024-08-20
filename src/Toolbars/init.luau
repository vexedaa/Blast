local BlastTypes = require(script.Parent.BlastTypes)

type Toolbar = BlastTypes.Toolbar
type Toolbar_Button = BlastTypes.Toolbar_Button

local Toolbars: { [string]: Toolbar } = {
    -- toolbar_name = {
    --     name = "toolbar_name";
    --     buttons = {
    --         button_name = {
    --             name = "button_name";
    --             icon = "rbxassetid://0";
    --             text = "n/a";
    --             tooltip = "none";
    --             togglesWidget = "<name of widget to open>";
    --         }
    --     }
    -- }
}

return Toolbars