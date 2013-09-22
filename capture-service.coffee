fs      = require('fs')
webpage = require('webpage')

CaptureService = ({@html, @selector}) ->
  console.log '[capture]\tinitialize...'

  @page = webpage.create()
  @page.viewportSize = @MACBOOK_AIR_VIEWPORT_SIZE

  @filepath = "/tmp/capture/#{Math.random().toString(36)}"
  @renderOptions =
    format:  'jpg'
    quality: 0.9

  console.log '[capture]\tinitialize done'

CaptureService::MACBOOK_AIR_VIEWPORT_SIZE = width: 1440, height: 900
CaptureService::DEFAULT_CLIP_RECT         = width: 1440, height: 900, top: 0, left: 0

CaptureService.validates = (s) -> !!s.html

CaptureService::clipRect = ->
  if !!@selector
    @page.evaluate ((selector) -> document.querySelector(selector).getClientRects()[0]), @selector
  else
    @DEFAULT_CLIP_RECT

CaptureService::capture = (callback) ->
  console.log "[capture]\thtml: #{@html}\tselector: #{@selector}\tpath:#{@filepath}..."

  @page.open("data:text/html;encoding=UTF-8,#{encodeURIComponent @html}").then =>
    @page.clipRect = @clipRect()
    @page.render(@filepath, @renderOptions)
    @page.close()

    console.log "[capture]\thtml: #{@html}\tselector: #{@selector}\tpath:#{@filepath} done"
    callback?()

CaptureService::remove = ->
  console.log "[capture]\tremove #{@filepath}..."

  fs.remove(@filepath) if fs.exists(@filepath)

  console.log "[capture]\tremove #{@filepath} done"

exports.CaptureService = CaptureService
