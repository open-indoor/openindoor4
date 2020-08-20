map.openindoor.io {
    root * /openindoor
    file_server

    route /fonts/* {
    	uri strip_prefix /fonts
	    reverse_proxy {
            to http://fonts:80
        }
    }

}