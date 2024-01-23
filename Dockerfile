FROM 84codes/crystal:master-ubuntu-jammy AS build

# Install Dependencies
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq && apt-get install -y librocksdb-dev build-essential
RUN cp /usr/lib/librocksdb.so /usr/lib/librocksdb.so.8.11

WORKDIR /app
COPY . /app

ENV PATH /app/bin:$PATH
ENV LD_LIBRARY_PATH /usr/lib:$LD_LIBRARY_PATH

# Build Caster
RUN shards build caster --release -Dpreview_mt

CMD [ "caster" ]

EXPOSE 1491
