{ Disposable, Point, Range } = require 'atom'

module.exports =
class DocCharIndexView
  constructor: ->
    @viewUpdatePending = false

    @element = document.createElement('status-bar-doc-char-index')
    @element.classList.add('doc-char-index', 'inline-block')

    @activeItemSubscription = atom.workspace.onDidChangeActiveTextEditor (activeEditor) => @subscribeToActiveTextEditor()

    @subscribeToActiveTextEditor()


  destroy: ->
    @activeItemSubscription.dispose()
    @cursorSubscription?.dispose()
    @updateSubscription?.dispose()

  subscribeToActiveTextEditor: ->
    @cursorSubscription?.dispose()
    selectionsMarkerLayer = atom.workspace.getActiveTextEditor()?.selectionsMarkerLayer
    @cursorSubscription = selectionsMarkerLayer?.onDidUpdate(@scheduleUpdate.bind(this))
    @scheduleUpdate()


  getActiveTextEditor: ->
    atom.workspace.getActiveTextEditor()

  getCurrentIndex: ->
    if !@getActiveTextEditor()
      return ''

    selectionLength = @getActiveTextEditor().getSelectedText().length

    if selectionLength > 0
      selectionRange = @getActiveTextEditor().getSelectedBufferRange()
      lengthBeforeSel = @lengthBeforePoint(selectionRange.start)
      "#{lengthBeforeSel}:#{lengthBeforeSel+selectionLength}"
    else
      bufferPosition = @getActiveTextEditor().getCursorBufferPosition()
      @lengthBeforePoint(bufferPosition)

  lengthBeforePoint: (point) ->
    range = new Range(new Point(0, 0), point)
    @getActiveTextEditor().getTextInBufferRange(range).length

  scheduleUpdate: ->
    return if @viewUpdatePending

    @viewUpdatePending = true
    @updateSubscription = atom.views.updateDocument =>
      @viewUpdatePending = false

      index = @getCurrentIndex()
      if index != ""
        @element.textContent = "@#{index}"
        @element.classList.remove('hide')
      else
        @element.classList.add('hide')
