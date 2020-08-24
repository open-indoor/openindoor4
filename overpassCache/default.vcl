vcl 4.0;

import directors;    # load the directors

backend server1 {
    .host = "178.63.11.215";
    .probe = {
        .url = "/";
        .timeout = 5s;
        .interval = 5s;
        .window = 5;
        .threshold = 3;
    }
}
backend server2 {
    .host = "z.overpass-api.de";
    .probe = {
        .url = "/";
        .timeout = 5s;
        .interval = 5s;
        .window = 5;
        .threshold = 3;
    }
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