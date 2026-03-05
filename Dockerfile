FROM haskell:9.10.3-bookworm as builder

WORKDIR /usr/app

RUN apt-get update \
    && apt-get install -y --no-install-recommends git python3 python3-venv

RUN python3 -m venv /usr/app/venv
ENV PATH="/usr/app/venv/bin:$PATH"

RUN git clone https://gitlab.com/chrisberkhout/pricehist \
    && cd pricehist \
    && pip install --no-cache-dir .

RUN curl --proto '=https' --tlsv1.2 -LsSf https://github.com/skim-rs/skim/releases/download/v3.6.2/skim-installer.sh | sh
RUN curl -L https://github.com/johnkerl/miller/releases/download/v6.17.0/miller-6.17.0-linux-386.tar.gz | tar xz --strip-components=1

FROM haskell:9.10.3-slim-bookworm

ENV RESOLVER lts-24.33

COPY --from=dastapov/hledger:1.51.2 /usr/bin/hledger* /usr/bin/
COPY --from=builder /usr/app/venv /usr/app/venv
COPY --from=builder /root/.cargo/bin/sk /usr/app/mlr /usr/bin/

COPY ./01-getting-started/export/export.hs /tmp

# Precompile all packages needed for export.hs
RUN hledger --version && mlr --version && sk --version \
    && stack --resolver $RESOLVER --system-ghc script --package shake --package directory --package process /tmp/export.hs -- -v \
    && rm -r /tmp/export.* \
    && rm -rf /root/.stack/pantry \
    && chmod -R g+wrX,o+wrX /root

RUN apt-get update \
    && apt-get install --yes patchutils gawk csvtool fzf ripgrep parallel python3 \
    && rm -rf /var/lib/apt/lists

ENV PATH="/usr/app/venv/bin::$PATH"

RUN adduser --system --ingroup root hledger

# This is where the data dir would be mounted to
RUN mkdir full-fledged-hledger
VOLUME /full-fledged-hledger

ENV STACK_ROOT /root/.stack
RUN echo "allow-different-user: true" >> /root/.stack/config.yaml

USER hledger
WORKDIR full-fledged-hledger
ENV LC_ALL C.UTF-8

CMD ["bash"]
