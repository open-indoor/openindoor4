vcl 4.0;

import directors;    # load the directors

backend server1 {
    .host = "a.tile.openstreetmap.org";
}
backend server2 {
    .host = "b.tile.openstreetmap.org";
}
backend server3 {
    .host = "c.tile.openstreetmap.org";
}

sub vcl_init {
    new bar = directors.round_robin();
    bar.add_backend(server1);
    bar.add_backend(server2);
    bar.add_backend(server3);
}

sub vcl_backend_response {
    set beresp.ttl = 4w;
}

sub vcl_recv {
    # send all traffic to the bar director:
    set req.backend_hint = bar.backend();
    set req.http.user-agent = "${API_DOMAIN_NAME} 4.0.0 contact contact@openindoor.io";
    set req.http.X-Saved-Origin = req.http.Origin;
    unset req.http.Origin;
}


  