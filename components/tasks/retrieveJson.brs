function init()
  m.top.functionName = "retrieveJson"
end function

sub retrieveJson()
  response = httpGet(m.global.constants.jsonUrl)

  if m.global.os15
    queue = CreateObject("roRenderThreadQueue")
    queue.PostMessage("JSON_READY", response)
  else
    m.top.data = response
  end if
end sub
