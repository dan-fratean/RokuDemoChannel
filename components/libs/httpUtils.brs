Function httpGet(url as String, authorization = "" as String) as Object
  port = CreateObject("roMessagePort")
  urlTransfer = createUrlTransfer(port, url, authorization)

  if (urlTransfer.AsyncGetToString()) then
    return getHttpResponseFromPort(port)
  else
    return {
      errorMessage: "Cannot send GET request."
    }
  end if
End Function

Function generateUrl(hostname as String, pathname as String) as String
  if (hostname.Right(1) = "/") then
    hostname = hostname.Left(hostname.Len() - 1)
  end if

  if (pathname.Left(1) = "/") then
    pathname = pathname.Right(pathname.Len() - 1)
  end if

  return hostname + "/" + pathname
End Function

Function createUrlTransfer(port as Object, url as String, authorization = "" as String)
  urlTransfer = CreateObject("roUrlTransfer")

  urlTransfer.SetMessagePort(port)
  urlTransfer.SetUrl(url)

  if (authorization <> "") urlTransfer.AddHeader("Authorization", authorization)

  urlTransfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
  urlTransfer.InitClientCertificates()

  return urlTransfer
End Function

Function getHttpResponseFromPort(port as Object) as Object
  while (true)
    msg = Wait(0, port)
    if (type(msg) = "roUrlEvent") then
      responseCode = msg.GetResponseCode()
      responseBody = msg.GetString()
      failureReason = msg.GetFailureReason()
      exit while
    end if
  end while

  if (responseCode <> 200) return {
    errorMessage: "Request failed with error " + responseCode.ToStr(),
    responseBody: responseBody,
    failureReason: failureReason
  }

  jsonObject = ParseJson(responseBody)

  if (jsonObject = Invalid) return {
    errorMessage: "Cannot parse response body",
    responseBody: responseBody
  }

  return jsonObject
End Function
