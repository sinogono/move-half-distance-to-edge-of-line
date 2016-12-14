{CompositeDisposable, Point} = require 'atom'


module.exports = MoveHalfDistanceToEdgeOfLine =
  subscriptions: null
  editor: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'move-half-distance-to-edge-of-line:forward-select': => @run(true, true)
    @subscriptions.add atom.commands.add 'atom-workspace', 'move-half-distance-to-edge-of-line:forward-move': => @run(true, false)
    @subscriptions.add atom.commands.add 'atom-workspace', 'move-half-distance-to-edge-of-line:backward-select': => @run(false, true)
    @subscriptions.add atom.commands.add 'atom-workspace', 'move-half-distance-to-edge-of-line:backward-move': => @run(false, false)

  deactivate: ->
    @subscriptions.dispose()


  # https://github.com/atom/atom/blob/v1.12.7/src/cursor.coffee#L315
  getBufferColumns: (cursor) ->
    screenRow = cursor.getScreenRow()

    screenLineStart = @editor.clipScreenPosition([screenRow, 0], skipSoftWrapIndentation: true)
    screenLineEnd = [screenRow, Infinity]
    screenLineBufferRange = @editor.bufferRangeForScreenRange([screenLineStart, screenLineEnd])

    firstCharacterColumn = screenLineBufferRange.start.column
    @editor.scanInBufferRange /\S/, screenLineBufferRange, ({range, stop}) ->
      firstCharacterColumn = range.start.column
      stop()

    return {
      start: screenLineBufferRange.start.column
      firstCharacter: firstCharacterColumn
      selected: cursor.getBufferColumn()
      end: screenLineBufferRange.end.column
    }

  calcDestination: (cursor, forward) ->
    {start, firstCharacter, selected, end} = @getBufferColumns(cursor)

    if forward
      p = Math.max(firstCharacter, selected)
      step = p + Math.ceil((end - p) / 2)
    else
      step = firstCharacter + Math.floor((selected - firstCharacter) / 2)

    return new Point(cursor.getBufferRow(), step)

  moveTo: (forward, select) ->
    for cursor in @editor.getCursors()
      destination = @calcDestination(cursor, forward)

      if select
        cursor.selection.selectToBufferPosition(destination)
      else
        cursor.setBufferPosition(destination)

  run: (forward, select) ->
    @editor = atom.workspace.getActiveTextEditor()
    return if @editor == null

    @moveTo(forward, select)
