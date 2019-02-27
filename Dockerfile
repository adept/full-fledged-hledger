FROM haskell:latest

COPY --from=dastapov/hledger:latest /usr/bin/hledger* /usr/bin/

COPY ./01-getting-started/export/export.hs /tmp

# Precompile all packages needed for export.hs
RUN /tmp/export.hs -v && rm /tmp/export.hs

# This is where the data dir would be mounted to
RUN mkdir full-fledged-hledger
WORKDIR full-fledged-hledger
VOLUME full-fledged-hledger

CMD ["bash"]
