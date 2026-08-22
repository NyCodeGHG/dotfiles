import qs from 'querystring'

const TAILSCALE_CLIENT_ID = "76wkZkD9BCXbtVKZ7ap3Tc6tzL3rgDCmLFAf1ZT7";

function cleanLoginHint(request) {
  const params = qs.parse(request.variables.args || '')

  if (params["client_id"] != TAILSCALE_CLIENT_ID || !('login_hint' in params)) {
    request.internalRedirect('@authentik')
    return
  }

  delete params["login_hint"]
  const query = qs.stringify(params)
  request.return(302, query ? `${request.uri}?${query}` : request.uri)
}

export default { cleanLoginHint }
