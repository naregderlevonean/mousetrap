![Cheese](Cheese.png)





# mousetrap

A lightweight, native hot-corner and edge-action addon for **Hyprland 0.55+**, written entirely in Lua: leverages Hyprland's built-in Lua runtime to provide programmable actions for your screen edges and corners.




## Features

* **Native Integration**: Runs as a first-class Lua module within Hyprland.
* **Context-Aware**: Supports 8 interaction zones (4 corners and 4 edges).
* **Multi-Monitor & DPI Ready**: Automatically calculates logical coordinates based on individual monitor scales and transformations.
* **Low Latency**: Operates on a 16ms ticker loop for responsive triggering.
* **Configurable Dwell Time**: Use delays to prevent accidental triggers while moving your mouse across the screen edges.
* **Flick Gestures**: Detects fast cursor movements against edges for quick, intentional actions.




## Installation

Place the files into your Hyprland directory:

```text
.../mousetrap.lua
.../mousetrap/
    ├── init.lua
    ├── core.lua
    └── config.lua
```

Add the configuration to your main Hyprland Lua initialization script:

```lua
local mousetrap = require("...mousetrap.init").setup({
    geometry = {
        default = { corner = 4, edge = 2 },
        [ "eDP-1" ] = { corner = 60, edge = 10 },
    }
})

-- Cursor touches the edge
mousetrap.bind( "top-left", function() 
    hl.exec_cmd( "notify-send 'Mousetrap: Touching'" ) 
end) 

-- Holding at the edge for 2 seconds
mousetrap.bind( "top-right", function() 
    hl.exec_cmd( "notify-send 'Mousetrap: Delayed touch'" ) 
end, { delay = 2000 }) 

-- A quick flick against the edge
mousetrap.bind( "top", function() 
    hl.exec_cmd( "notify-send 'Mousetrap: Flick gesture'" ) 
end, { flick = 50 }) 

-- Initialize
addons.mousetrap = mousetrap 
addons.mousetrap.start()
```




## API Reference

| Method                            | Description                                           |
| :-------------------------------- | :---------------------------------------------------- |
| `setup(config)`                   | Initializes the addon with monitor geometry settings. |
| `bind(zone, callback, opts)`      | Binds a function to a specific screen corner or edge. |
| `start()`, `stop()` or `toggle()` | Controls the evaluation loop.                         |

#### Parameters

###### `setup(config)`

* **`config.geometry`** `(table)`: Map of monitor names to their thresholds.
	* `default`: Fallback configuration `(e.g., { corner = 4, edge = 2 })`.
	* `["MONITOR_NAME"]`: Monitor-specific overrides.

###### `bind(zone, callback, opts)`

* **`zone`** `(string)`: 
	* Corners: `"top-left"`, `"top-right"`, `"bottom-left"`, `"bottom-right"`
	* Edges: `"top"`, `"bottom"`, `"left"`, `"right"`
* **`callback`** `(function)`: Code to run on trigger. Automatically receives `(zone, monitor)`.
* **`opts.delay`** `(number, optional)`: Dwell time in milliseconds before firing (default: `0`).
* **`opts.flick`** `(number, optional)`: Minimum cursor speed required to trigger a flick gesture.



## License

This project is licensed under the GPL-3.0 License.
