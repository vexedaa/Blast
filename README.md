# Blast

<pre>
 ,---.|    ,---.,---.--.--     '| ,--.
 |---.|    |---|`---.  |        | |  |
 |   ||    |   |    |  |        | |  |
 `---'`---'`   '`---'  `        `o`--'

A simple, easy-to-integrate plugin lifecycle springboard for Roblox plugins.

Copyright (c) 2024 Vexture

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
 </pre>

## Features

### Creating toolbars, buttons & widgets

* Declaratively generate toolbars, buttons, and widgets with `Blast:CreateToolbar()` and `Blast:CreateWidget()`
* Configure toolbars and widgets through Blast's config files
* Configure buttons to open particular widgets
* Bind callbacks to run on plugin unload
* Manage button states with:
* * `Blast:SetButtonEnabled(toolbar_name: string, button_name, string, enabled: boolean)`
* * `Blast:SetButtonActivated(toolbar_name: string, button_name: string, enabled: boolean)`
* * `Blast:SuspendButton(toolbar_name: string, button_name: string)`
* * `Blast:ReviveButton(toolbar_name: string, button_name: string)`

This package is still in development. If you would like to use it in your own project, you can use GitHub submodules, or grab [Gitman](https://gitman.readthedocs.io/en/latest/)
and configure a `gitman.yml` file like this:

```yml
    location: # Choose a directory, or leave this blank to put Blast in the desired directory.
    sources:
        - repo: https://github.com/vexedaa/Blast
        name: Blast
        rev: master
        type: git
        sparse_paths:
            - "!.git/*"
            - "src/*"
            - "!src"
```

Then, run `gitman install`. If you want to update Blast, run `gitman update`. If you have any local changes, add `--force` to the end of your command.