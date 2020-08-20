map.openindoor.io {
    root * /openindoor
    file_server

    tls {
        ca https://acme-staging-v02.api.letsencrypt.org/directory
    }

    route /fonts/* {
    	uri strip_prefix /fonts
	    reverse_proxy {
            to http://fonts:80
        }
    }

}