DocCharIndexView = require('./doc-char-index-view');

module.exports =
  activate: ->
    @docCharIndexView = new DocCharIndexView();

  consumeStatusBar: (statusBar) ->
    @statusBarTile = statusBar.addLeftTile(item: @docCharIndexView.element, priority: 1);

  deactivate: ->
    @docCharIndexView?.destroy()

    @statusBarTile?.destroy()
    @statusBarTile = null
