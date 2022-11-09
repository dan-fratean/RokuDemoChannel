function init()
  m.top.functionName = "retrieveJson"
end function

sub retrieveJson()
  response = httpGet(m.global.constants.jsonUrl)
  m.top.data = response
end sub
