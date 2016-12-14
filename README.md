# move-half-distance-to-edge-of-line package

Move half the distance from the cursor to the edge of the line.


![screenshot](https://raw.githubusercontent.com/sinogono/move-half-distance-to-edge-of-line/master/docs/xxx.gif)


## Usage
type `ctrl-alt-right` to run `move-half-distance-to-edge-of-line:forward-move`.

### Keymap (Default)
``` cson
'atom-text-editor':
  'ctrl-alt-shift-right': 'move-half-distance-to-edge-of-line:forward-select'
  'ctrl-alt-right': 'move-half-distance-to-edge-of-line:forward-move'
  'ctrl-alt-shift-left': 'move-half-distance-to-edge-of-line:backward-select'
  'ctrl-alt-left': 'move-half-distance-to-edge-of-line:backward-move'
```
