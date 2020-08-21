map.openindoor.io {
    encode gzip
    root * /openindoor
    file_server

    route /overpass/* {
    	uri strip_prefix /overpass
	    reverse_proxy {
            to https://www.overpass-api.de
        }
    }

    route /fonts/* {
    	uri strip_prefix /fonts
	    reverse_proxy {
            to http://fonts:80
        }
    }

}