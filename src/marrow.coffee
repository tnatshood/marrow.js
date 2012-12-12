fs = require 'fs'

window.Marrow = class Marrow
  ###
  # Constructor takes an fs path for now. Probably the html string later
  ###
  constructor: (@tmplStr) ->
    @domParse = new window.DOMParser()
    @tmpl = null

  ###
  ## Load a given file from the fs
  ###
  loadFile: (tmplPath, enc='utf-8') ->
    @tmplStr = fs.readFileSync tmplPath, enc

  ###
  # Or str
  ###
  loadStr: (@tmplStr) ->

  ###
  # Create a DOM object of the internal template string
  ###
  parse: ->
    !@tmplStr and throw Error('Need template to parse')

    @tmpl = @domParse.parseFromString @tmplStr, 'application/xml'

  ###
  # Debugging
  ###
  dumpDom: (node, cb, depth) ->
    !@tmpl and @parse()

    node ?= elems = @tmpl.getElementsByTagName('*')[0]
    depth ?= 0
    cb ?= console?.log depth, ' :: ', node.tagName

    node = node.firstChild
    while node
      depth++
      @dumpDom node, cb, depth
      node = node.nextSibling

  ###
  # Return a rendered string
  ###
  render: (ctx, tmplStr) ->
    !@tmplStr and @loadStr tmplStr
    @parse()

    elems = @tmpl.getElementsByTagName('*')
    for elem in elems
      attrs = elem.attributes
      for attr in attrs
        if attr.name.search('data-') == 0
          @handle elem, attr.name.split('-')[1..]..., attr.value

    return @tmplStr

  ###
  # JFDI
  ###

  cmdDict: {
    'bind': (target, vals) ->
      val = vals[0]
      target.innerHtml = val
  }

  # FIXME: This does not nest
  handle: ->
    argc = arguments.length
    if argc < 3
      throw Error 'Need command, at least one argument and target element', arguments
    argv = Array.prototype.slice.call arguments

    target = argv[0]
    cmd = argv[1]
    args = argv[2..argc - 1]

    @cmdDict[cmd] target, args

