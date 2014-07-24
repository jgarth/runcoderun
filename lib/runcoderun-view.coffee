path = require 'path'
{$, $$, ScrollView} = require 'atom'

sys = require('sys')
exec = require('child_process').exec
fs = require('fs')

module.exports =
class RunCodeRunView extends ScrollView
  filePath: null
  filename: null
  editorId: null

  @content: ->
    @div class: 'vertical runcoderun'

  initialize: ({@editorId, filePath}) ->

  editorForId: (editorId) ->
    for editor in atom.workspace.getEditors()
      return editor if editor.id?.toString() is editorId.toString()
    null

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  getTitle: ->
    "Run '#{@filename}'"

  getFilenameFromPath: (path) ->
    path.split('/').pop()

  enforcePermissions: (path) ->
    original_mode = fs.statSync(@filePath).mode.toString(8)
    unless original_mode.substr(3,1) is "7"
      fs.chmodSync @filePath, original_mode.substr(0,3) + "7" + original_mode.substr(4,2)

  runCode: ->
    if @editorId?
      @filePath = @editorForId(@editorId).getPath()

    @isTempFile = false

    # If there's no file because the user hasn't saved
    # the editor's content yet, write to a tempfile.
    unless @filePath?
      @isTempFile = true
      @filePath = "/tmp/atom-run-tmp-#{@generate_fake_short_uuid()}"

      try
        fs.writeFileSync @filePath, @editorForId(@editorId).getText(), {mode: 493}
      catch error
        stderr = error
    else
      # Check if file is executable, if not, make it executable.
      @enforcePermissions @filePath

    # Update title
    @filename = @getFilenameFromPath(@filePath)
    @trigger 'title-changed'

    # Run file
    exec "'#{@filePath}'", {cwd: atom.project.getRootDirectory().path}, (error, stdout, stderr) =>
      # "Map" execution error to stderr
      stderr += error if error?
      # Render output
      @render(stdout, stderr)
      # Delete tempfile if necessary
      fs.unlink(@filePath) if @isTempFile

  getUri: ->
    "runcoderun://editor/#{@editorId}"

  # Render colorized exec output
  render: (stdout, stderr) ->
    filename = @filename

    @html $$ ->
      @h2 "Running '#{filename}'"
      @pre "#{stderr}", class: 'stderr'
      @pre "#{stdout}"

  # TODO: find out how to specify node module dependencies and replace this
  generate_fake_short_uuid: ->
    Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1)
