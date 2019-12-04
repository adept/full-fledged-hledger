FROM haskell:8.6.5

COPY --from=dastapov/hledger:1.16.1 /usr/bin/hledger* /usr/bin/

COPY ./01-getting-started/export/export.hs /tmp

# Precompile all packages needed for export.hs
RUN /tmp/export.hs -v && rm /tmp/export.hs

# This is where the data dir would be mounted to
RUN mkdir full-fledged-hledger
WORKDIR full-fledged-hledger
VOLUME full-fledged-hledger

CMD ["bash"]
