FROM telegraf:1.16.2
RUN apt update && apt install -y mtr && apt install -y htop

ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]
CMD ["telegraf"]
