FROM alpine AS builder

ENV HatH_VERSION 1.6.1
ENV HatH_SHA256 b8889b2c35593004be061064fcb6d690ff8cbda9564d89f706f7e3ceaf828726
ARG TARGETPLATFORM

RUN apk --no-cache add unzip \
    && mkdir -p /hath \
    && cd /hath \
    && wget https://repo.e-hentai.org/hath/HentaiAtHome_$HatH_VERSION.zip -O hath.zip \
    && echo -n ""$HatH_SHA256"  hath.zip" | sha256sum -c \
    && unzip hath.zip \
    && mkdir -p /hath/data \
    && mkdir -p /hath/download

RUN DOCKER_ARCH=$(case ${TARGETPLATFORM:-linux/amd64} in \
        "linux/amd64")   echo "linux-64"  ;; \
        "linux/arm/v7")  echo "linux-arm32-v7a"   ;; \
        "linux/arm64")   echo "linux-arm64-v8a" ;; \
        *)               echo ""        ;; esac) \
    && echo "DOCKER_ARCH=$DOCKER_ARCH" \
    && wget -O go-mmproxy "https://github.com/HoshinoNeko/go-mmproxy/releases/download/master/go-mmproxy-${DOCKER_ARCH}"

FROM eclipse-temurin:11-jre-jammy AS release

ENV HatH_ARGS --cache-dir=/hath/data/cache --data-dir=/hath/data/data --download-dir=/hath/download --log-dir=/hath/data/log --temp-dir=/hath/data/temp

COPY --from=builder /hath /hath
COPY build/start.sh /hath/start.sh
WORKDIR /hath

RUN apt-get update \
    && apt-get install -y sqlite iproute2 \
    && rm -rf /var/lib/apt/lists/* \
    && chmod +x /hath/start.sh \
    && chmod +x /hath/go-mmproxy

CMD ["/hath/start.sh"]
