FROM haskell:8.6.5

COPY --from=dastapov/hledger:1.17 /usr/bin/hledger* /usr/bin/

COPY ./01-getting-started/export/export.hs /tmp

# Precompile all packages needed for export.hs
RUN /tmp/export.hs -v && rm -r /tmp/export.hs /root/.stack/indices && chmod -R g+rX,o+rX /root /root/.stack/

RUN apt-get update && apt-get install --yes patchutils && rm -rf /var/lib/apt/lists

# This is where the data dir would be mounted to
RUN mkdir full-fledged-hledger
WORKDIR full-fledged-hledger
VOLUME full-fledged-hledger

RUN mkdir /home/user && chmod 0777 /home/user
ENV HOME /home/user
RUN echo "cp -a /root/.stack /home/user" > /home/user/.bashrc

CMD ["bash"]
