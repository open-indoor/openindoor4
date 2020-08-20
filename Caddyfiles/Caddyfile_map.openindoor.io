map.openindoor.io {
    root * /openindoor
    file_server

    tls {
        ca https://acme-staging-v02.api.letsencrypt.org/directory
    }

    route /overpass/* {
    	uri strip_prefix /overpass
	    reverse_proxy {
            to http://www.overpass-api.de:80
        }
    }

    route /fonts/* {
    	uri strip_prefix /fonts
	    reverse_proxy {
            to http://fonts:80
        }
    }

}