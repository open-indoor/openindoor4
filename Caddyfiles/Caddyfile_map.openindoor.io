map.openindoor.io {
    root * /openindoor
    file_server

    tls {
        ca https://acme-staging-v02.api.letsencrypt.org/directory
    }

    route /overpass/* {
    	uri strip_prefix /overpass
        redir http://www.overpass-api.de:80{uri}
    }

    route /fonts/* {
    	uri strip_prefix /fonts
	    reverse_proxy {
            to http://fonts:80
        }
    }

}