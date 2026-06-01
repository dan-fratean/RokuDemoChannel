function init()
  constants = {
    jsonUrl: "", ' add json url here
  }

  m.global.addFields({constants: constants, os15: _isOS15()})
end function

' True only on Roku OS 15+ that actually provides roRenderThreadQueue.
' The version gate keeps older devices from probing an unknown class; the
' CreateObject check confirms the API really exists (emulators may report
' OS 15 without implementing it).
function _isOS15() as boolean
  di = CreateObject("roDeviceInfo")
  if di = invalid then return false
  v = di.GetOSVersion()
  if v = invalid or v.major = invalid or Val(v.major) < 15 then return false
  return CreateObject("roRenderThreadQueue") <> invalid
end function
