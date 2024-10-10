FROM haskell:9.6.6 as builder

WORKDIR /usr/app

RUN apt-get update \
    && apt-get install -y --no-install-recommends git python3 python3-venv

RUN python3 -m venv /usr/app/venv
ENV PATH="/usr/app/venv/bin:$PATH"

RUN git clone https://gitlab.com/chrisberkhout/pricehist \
    && cd pricehist \
    && pip install --no-cache-dir .

FROM haskell:9.6.6

ENV RESOLVER lts-22.37

COPY --from=dastapov/hledger:1.40 /usr/bin/hledger* /usr/bin/

COPY ./01-getting-started/export/export.hs /tmp

# Precompile all packages needed for export.hs
RUN stack --resolver $RESOLVER --system-ghc script --package shake --package directory --package process /tmp/export.hs -- -v \
    && rm -r /tmp/export.* \
    && rm -rf /root/.stack/pantry \
    && chmod -R g+wrX,o+wrX /root

RUN apt-get update \
    && apt-get install --yes patchutils gawk csvtool fzf ripgrep parallel python3 \
    && rm -rf /var/lib/apt/lists \
    && cd /usr/bin/ \
    && curl -L https://github.com/lotabout/skim/releases/download/v0.8.1/skim-v0.8.1-x86_64-unknown-linux-gnu.tar.gz | tar xz \  
    && curl -L https://github.com/johnkerl/miller/releases/download/v6.13.0/miller-6.13.0-linux-386.tar.gz | tar xz

COPY --from=builder /usr/app/venv /usr/app/venv
ENV PATH="/usr/app/venv/bin:$PATH"

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
