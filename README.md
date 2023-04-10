### Vala build scripts.

The repository is part of the [Compiler Explorer](https://godbolt.org/) project. It builds
the docker images used to build the various Vala compilers used on the site.


## Testing

```bash
docker build -t valabuilder .
docker run valabuilder ./build.sh 0.56.6