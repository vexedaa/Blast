export type Toolbar_Button = {
    name: string;
    icon: string?;
    text: string?;
    tooltip: string;
    togglesWidget: string?
}
export type Toolbar = {
    [string]: {
        name: string;
        buttons: { [string]: Toolbar_Button }
    }
}

return nil