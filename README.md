### Vala build scripts.

The repository is part of the [Compiler Explorer](https://godbolt.org/) project. It builds
the docker images used to build the various Vala compilers used on the site.


## Testing

```bash
mkdir /tmp/vala
docker build -t valabuilder .
docker run --rm -v/tmp/vala:/vala valabuilder ./build.sh 0.56.6 /vala
# results will be in /tmp/vala on the host machine
```
