{yfy, cfy} = require 'cfy'

{
  gexport
  gexport_module
} = require 'libs_common/gexport'

export getUrlParameters = ->
  url = window.location.href
  hash = url.lastIndexOf('#')
  if hash != -1
    url = url.slice(0, hash)
  map = {}
  parts = url.replace(/[?&]+([^=&]+)=([^&]*)/gi, (m,key,value) ->
    #map[key] = decodeURI(value).split('+').join(' ').split('%2C').join(',') # for whatever reason this seems necessary?
    map[key] = decodeURIComponent(value).split('+').join(' ') # for whatever reason this seems necessary?
  )
  return map

export once_available = yfy (selector, callback) ->
  current_result = document.querySelector(selector)
  if current_result != null
    callback current_result
  else
    setTimeout ->
      once_available selector, callback
    , 100

export once_available_multiselect = yfy (selector, callback) ->
  current_result = document.querySelectorAll(selector)
  if current_result.length > 0
    callback current_result
  else
    setTimeout ->
      once_available_multiselect selector, callback
    , 100


export once_document_available = yfy (callback) ->
  if document.body?
    callback()
  else
    setTimeout ->
      once_document_available(callback)
    , 100

export once_true = yfy (condition, callback) ->
  if condition()
    callback()
  else
    setTimeout ->
      once_true(condition, callback)
    , 100

export sleep = cfy (time) ->*
  sleep_base = (msecs, callback) ->
    setTimeout(callback, msecs)
  yield yfy(sleep_base)(time)

export run_only_one_at_a_time = (func) ->
  # func is assumed to take 1 argument (finished callback) for the time being
  is_running = false
  return ->
    if is_running
      return
    is_running := true
    func ->
      # finished
      is_running := false

#export add_toolbar_notification = ->
#  chrome.browserAction.setBadgeText {text: '1'}
#  chrome.browserAction.setBadgeBackgroundColor {color: '#3498DB'}

export on_url_change = (func) ->
  prev_url = window.location.href
  chrome.runtime.onMessage.addListener (msg, sender, sendResponse) ->
    {type, data} = msg
    if type == 'navigation_occurred'
      if data.url != prev_url
        prev_url = data.url
        func()

export create_shadow_div = ->
  shadow_div_host = document.createElement('div')
  shadow_root = shadow_div_host.attachShadow({mode: 'open'})
  #shadow_root = shadow_div_host.createShadowRoot()
  shadow_div = document.createElement('div')
  shadow_div.style.fontFamily = '"HelveticaNeue-Light", "Helvetica Neue Light", "Helvetica Neue", Helvetica, Arial, "Lucida Grande", sans-serif'
  shadow_div.style.position = 'fixed'
  shadow_div.style.zIndex = Number.MAX_SAFE_INTEGER
  shadow_root.appendChild(shadow_div)
  document.body.appendChild(shadow_div_host)
  return shadow_div

gexport_module 'common_libs', -> eval(it)
