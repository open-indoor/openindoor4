map.openindoor.io {
    encode gzip
    root * /openindoor
    file_server

    route /overpass/* {
    	uri strip_prefix /overpass
	    reverse_proxy {
            to http://overpassCache:80
        }
    }

    route /rastertiles/* {
    	uri strip_prefix /rastertiles
	    reverse_proxy {
            to http://tileCache:80
        }
    }

    route /fonts/* {
    	uri strip_prefix /fonts
	    reverse_proxy {
            to http://fonts:80
        }
    }

}