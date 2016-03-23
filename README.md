![License MIT](https://img.shields.io/badge/license-MIT-blue.svg)

nginx-proxy sets up a container running nginx and [docker-gen][1].  docker-gen generates reverse proxy configs for nginx and reloads nginx when containers are started and stopped.

See [Automated Nginx Reverse Proxy for Docker][2] for why you might want to use this.

### Note

This repo initially forked from [jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy). But I was somehow uncomfortable with internals and rewrite configs. Now it based on nginx:alpine linux repo and uses s6 supervisor. Final image is very small.
But no tests and only basic functionality.

Moreover use it only for development! Again it is not for production! Because the container need to be in `host` network to access all other containers.

### Usage

To run it:

    $ docker run -d -p 80:80 --name front --net host -v /var/run/docker.sock:/tmp/docker.sock:ro vovkasm/nginx-proxy

Then start any containers you want proxied with an env var `VIRTUAL_HOST=subdomain.yourdomain.com`

    $ docker run -e VIRTUAL_HOST=proj1.dev.home  ...

The containers being proxied must [expose](https://docs.docker.com/reference/run/#expose-incoming-ports) the port to be proxied, either by using the `EXPOSE` directive in their `Dockerfile` or by using the `--expose` flag to `docker run` or `docker create`.

### DNS

Provided your DNS is setup to forward proj1.dev.home to the a host running nginx-proxy, the request will be routed to a container with the VIRTUAL_HOST env var set.

Many possibilites here:
 1. `/etc/hosts`
 2. `dnsmasq` on you main machine
 3. `dnsmasq` on router. Most advanced config.

In case you need to test from other devices, use `dnsmasq` on router. For ex.
 1. If you use docker-machine, add `bridged` adapter to default machine.
 2. Setup you `dhcp` on router to assign static `IP` for `MAC-address` of `bridged` adapter.
 3. Setup you router to resolve wildcard domain (ex. `*.dev.home`) to this `IP`.

### Multiple Ports

If your container exposes multiple ports, nginx-proxy will default to the service running on port 80.  If you need to specify a different port, you can set a VIRTUAL_PORT env var to select a different one.  If your container only exposes one port and it has a VIRTUAL_HOST env var set, that port will be selected.

### Multiple Hosts

If you need to support multiple virtual hosts for a container, you can separate each entry with commas.  For example, `foo.bar.com,baz.bar.com,bar.com` and each host will be setup the same.

### Wildcard Hosts

You can also use wildcards at the beginning and the end of host name, like `*.bar.com` or `foo.bar.*`. Or even a regular expression, which can be very useful in conjunction with a wildcard DNS service like [xip.io](http://xip.io), using `~^foo\.bar\..*\.xip\.io` will match `foo.bar.127.0.0.1.xip.io`, `foo.bar.10.0.2.2.xip.io` and all other given IPs. More information about this topic can be found in the nginx documentation about [`server_names`](http://nginx.org/en/docs/http/server_names.html).

#### Proxy-wide

To add settings on a proxy-wide basis, add your configuration file under `/etc/nginx/conf.d` using a name ending in `.conf`.

This can be done in a derived image by creating the file in a `RUN` command or by `COPY`ing the file into `conf.d`:

```Dockerfile
FROM jwilder/nginx-proxy
RUN { \
      echo 'server_tokens off;'; \
      echo 'client_max_body_size 100m;'; \
    } > /etc/nginx/conf.d/my_proxy.conf
```

Or it can be done by mounting in your custom configuration in your `docker run` command:

    $ docker run -d -p 80:80 --name front --net host -v /path/to/my_proxy.conf:/etc/nginx/conf.d/my_proxy.conf:ro -v /var/run/docker.sock:/tmp/docker.sock:ro vovkasm/nginx-proxy


[1]: https://github.com/jwilder/docker-gen
[2]: http://jasonwilder.com/blog/2014/03/25/automated-nginx-reverse-proxy-for-docker/
