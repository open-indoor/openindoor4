vcl 4.0;

import directors;

backend default {
    .host = "mbtiles-api";
}

sub vcl_recv {
    set req.backend_hint = default;
}

sub vcl_backend_response {
    set beresp.ttl = 60;
}