vcl 4.0;

import directors;    # load the directors

backend server1 {
    .host = "178.63.11.215:80";
}
backend server2 {
    .host = "z.overpass-api.de:443";
}

sub vcl_init {
    new bar = directors.round_robin();
    bar.add_backend(server1);
    bar.add_backend(server2);
}

sub vcl_recv {
    # send all traffic to the bar director:
    set req.backend_hint = bar.backend();
}