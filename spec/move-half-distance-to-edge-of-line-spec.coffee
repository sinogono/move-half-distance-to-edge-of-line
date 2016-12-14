{Point, Range} = require 'atom'
MoveHalfDistanceToEdgeOfLine = require '../lib/move-half-distance-to-edge-of-line'


describe "MoveHalfDistanceToEdgeOfLine", ->

  describe "calcDestination", ->
    editor = null

    beforeEach ->
      editor = atom.workspace.buildTextEditor()

    setDefault = (text, beforePoint) ->
      editor.setText(text)
      editor.setCursorBufferPosition(beforePoint)

    proc = (forward) ->
      MoveHalfDistanceToEdgeOfLine.editor = editor
      cursor = editor.getLastCursor()
      destination = MoveHalfDistanceToEdgeOfLine.calcDestination(cursor, forward)
      return destination

    describe "basic", ->
      it "forward", ->
        text = "0123456789"
        beforePoint = new Point(0, 0)
        forward = true
        afterPoint = new Point(0, 5)

        setDefault(text, beforePoint)
        result = proc(forward)
        expect(result).toEqual(afterPoint)

      it "backward", ->
        text = "0123456789"
        beforePoint = new Point(10, 0)
        forward = false
        afterPoint = new Point(0, 5)

        setDefault(text, beforePoint)
        result = proc(forward)
        expect(result).toEqual(afterPoint)

    describe "text length", ->
      it "odd && forward", ->
        text = "012"
        beforePoint = new Point(0, 0)
        forward = true
        afterPoint = new Point(0, 2)

        setDefault(text, beforePoint)
        result = proc(forward)
        expect(result).toEqual(afterPoint)

      it "odd && backward", ->
        text = "012"
        beforePoint = new Point(0, 3)
        forward = false
        afterPoint = new Point(0, 1)

        setDefault(text, beforePoint)
        result = proc(forward)
        expect(result).toEqual(afterPoint)

      it "even && forward", ->
        text = "0123"
        beforePoint = new Point(0, 0)
        forward = true
        afterPoint = new Point(0, 2)

        setDefault(text, beforePoint)
        result = proc(forward)
        expect(result).toEqual(afterPoint)

      it "even && backward", ->
        text = "0123"
        beforePoint = new Point(0, 4)
        forward = false
        afterPoint = new Point(0, 2)

        setDefault(text, beforePoint)
        result = proc(forward)
        expect(result).toEqual(afterPoint)

    describe "text structure", ->
      it "indent (space) && forward", ->
        text = "  2345"
        beforePoint = new Point(0, 0)
        forward = true
        afterPoint = new Point(0, 4)

        setDefault(text, beforePoint)
        result = proc(forward)
        expect(result).toEqual(afterPoint)

      it "indent (space) && backward", ->
        text = "  2345"
        beforePoint = new Point(0, 6)
        forward = false
        afterPoint = new Point(0, 4)

        setDefault(text, beforePoint)
        result = proc(forward)
        expect(result).toEqual(afterPoint)

      it "indent (tab) && forward", ->
        text = "\t\t2345"
        beforePoint = new Point(0, 0)
        forward = true
        afterPoint = new Point(0, 4)

        setDefault(text, beforePoint)
        result = proc(forward)
        expect(result).toEqual(afterPoint)

      it "indent (tab) && backward", ->
        text = "\t\t2345"
        beforePoint = new Point(0, 6)
        forward = false
        afterPoint = new Point(0, 4)

        setDefault(text, beforePoint)
        result = proc(forward)
        expect(result).toEqual(afterPoint)

      it "blank && forward", ->
        text = ""
        beforePoint = new Point(0, 0)
        forward = true
        afterPoint = new Point(0, 0)

        setDefault(text, beforePoint)
        result = proc(forward)
        expect(result).toEqual(afterPoint)

      it "blank && backward", ->
        text = ""
        beforePoint = new Point(0, 0)
        forward = false
        afterPoint = new Point(0, 0)

        setDefault(text, beforePoint)
        result = proc(forward)
        expect(result).toEqual(afterPoint)

      it "multi language && forward", ->
        text = "012abcあいうアイウ有井雨"
        beforePoint = new Point(0, 0)
        forward = true
        afterPoint = new Point(0, 8)

        setDefault(text, beforePoint)
        result = proc(forward)
        expect(result).toEqual(afterPoint)

      it "multi language && backward", ->
        text = "012abcあいうアイウ有居雨"
        beforePoint = new Point(0, 15)
        forward = false
        afterPoint = new Point(0, 7)

        setDefault(text, beforePoint)
        result = proc(forward)
        expect(result).toEqual(afterPoint)

    describe "folding and soft-wrapping", ->
      it "folding && forward", ->
        text = "0123456789"
        beforePoint = new Point(0, 0)
        foldingRange = new Range([0, 1], [0, 6])  # "0...6789"
        forward = true
        afterPoint = new Point(0, 5)

        setDefault(text, beforePoint)
        editor.foldBufferRange(foldingRange)
        result = proc(forward)
        expect(result).toEqual(afterPoint)

      it "folding && backward", ->
        text = "0123456789"
        beforePoint = new Point(0, 10)
        foldingRange = new Range([0, 4], [0, 9])  # "0123...9"
        forward = false
        afterPoint = new Point(0, 5)

        setDefault(text, beforePoint)
        editor.foldBufferRange(foldingRange)
        result = proc(forward)
        expect(result).toEqual(afterPoint)

  describe "moveTo", ->
    editor = null

    beforeEach ->
      editor = atom.workspace.buildTextEditor()

    setDefault = (text, beforeRanges) ->
      editor.setText(text)
      editor.setSelectedBufferRanges(beforeRanges)

    proc = (forward, select) ->
      MoveHalfDistanceToEdgeOfLine.editor = editor
      MoveHalfDistanceToEdgeOfLine.moveTo(forward, select)

    it 'forward && select', ->
      text = "0123456789\n0123456789"
      beforeRanges = [
        new Range([0, 0], [0, 0]),
        new Range([1, 0], [1, 0]),
      ]
      forward = true
      select = true
      afterRanges = [
        new Range([0, 0], [0, 5]),
        new Range([1, 0], [1, 5]),
      ]

      setDefault(text, beforeRanges)
      proc(forward, select)
      for cursor, i in editor.getCursorsOrderedByBufferPosition()
        result = cursor.selection.getBufferRange()
        expected = afterRanges[i]
        expect(result).toEqual(expected)

    it 'forward && unselect', ->
      text = "0123456789\n0123456789"
      beforeRanges = [
        new Range([0, 0], [0, 0]),
        new Range([1, 0], [1, 0]),
      ]
      forward = true
      select = false
      afterRanges = [
        new Range([0, 5], [0, 5]),
        new Range([1, 5], [1, 5]),
      ]

      setDefault(text, beforeRanges)
      proc(forward, select)
      for cursor, i in editor.getCursorsOrderedByBufferPosition()
        result = cursor.selection.getBufferRange()
        expected = afterRanges[i]
        expect(result).toEqual(expected)

    it 'backward && select', ->
      text = "0123456789\n0123456789"
      beforeRanges = [
        new Range([0, 10], [0, 10]),
        new Range([1, 10], [1, 10]),
      ]
      forward = false
      select = true
      afterRanges = [
        new Range([0, 5], [0, 10]),
        new Range([1, 5], [1, 10]),
      ]

      setDefault(text, beforeRanges)
      proc(forward, select)
      for cursor, i in editor.getCursorsOrderedByBufferPosition()
        result = cursor.selection.getBufferRange()
        expected = afterRanges[i]
        expect(result).toEqual(expected)

    it 'backward && unselect', ->
      text = "0123456789\n0123456789"
      beforeRanges = [
        new Range([0, 10], [0, 10]),
        new Range([1, 10], [1, 10]),
      ]
      forward = false
      select = false
      afterRanges = [
        new Range([0, 5], [0, 5]),
        new Range([1, 5], [1, 5]),
      ]

      setDefault(text, beforeRanges)
      proc(forward, select)
      for cursor, i in editor.getCursorsOrderedByBufferPosition()
        result = cursor.selection.getBufferRange()
        expected = afterRanges[i]
        expect(result).toEqual(expected)
