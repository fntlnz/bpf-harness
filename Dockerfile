FROM docker.io/alpine:3.13 as builder

ARG LIBS_REF=master

RUN apk update
RUN apk add gcc g++ musl cmake cmake make git autoconf pkgconf linux-headers zlib-static  zlib-dev libelf-static elfutils-dev

RUN git clone https://github.com/falcosecurity/libs.git /falco-libs
RUN cd /falco-libs && git checkout $LIBS_REF

ADD . /harness
RUN mkdir /harness/build
WORKDIR /harness/build

RUN cmake -D FALCOSECURITY_LIBS_SOURCE_DIR=/falco-libs -DUSE_BUNDLED_LIBELF=False -DUSE_BUNDLED_ZLIB=False -DBUILD_STATIC=True ..
RUN make

FROM scratch
COPY --from=builder /harness/build/tests/runner /runner
CMD ["/runner"]
