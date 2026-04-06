ARG GLEAM_VERSION=v1.15.2

FROM ghcr.io/gleam-lang/gleam:${GLEAM_VERSION}-erlang-alpine AS builder

COPY ./front_end /build/front_end
COPY ./back_end /build/back_end

RUN cd /build/front_end && gleam deps download
RUN cd /build/back_end && gleam deps download

RUN cd /build/front_end \
  && gleam clean \
  && gleam run -m lustre/dev build --minify --outdir=../back_end/priv/static

RUN cd /build/back_end \
  && gleam export erlang-shipment

FROM ghcr.io/gleam-lang/gleam:${GLEAM_VERSION}-erlang-alpine

COPY --from=builder /build/back_end/build/erlang-shipment /app

WORKDIR /app
RUN echo -e '#!/bin/sh\nexec ./entrypoint.sh "$@"' > ./start.sh \
  && chmod +x ./start.sh

ENV HOST=0.0.0.0
ENV PORT=3000

EXPOSE $PORT

CMD ["./start.sh", "run"]
