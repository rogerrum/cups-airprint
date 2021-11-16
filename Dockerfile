
FROM ubuntu

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install \
      cups-daemon \
      cups-client \
      cups-pdf \
      brother-lpr-drivers-extra brother-cups-wrapper-extra \
      avahi-daemon \
      libnss-mdns \
      whois \
      curl \
      inotify-tools \
      libpng16-16 \
      python3-cups \
      samba-client \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*


COPY airprint/ /opt/airprint/


COPY healthcheck.sh /
COPY start-cups.sh /root/
RUN chmod +x /healthcheck.sh /root/start-cups.sh
HEALTHCHECK --interval=10s --timeout=3s CMD /healthcheck.sh

ENV TZ="GMT" \
    CUPS_ADMIN_USER="admin" \
    CUPS_ADMIN_PASSWORD="secr3t" \
    CUPS_WEBINTERFACE="yes" \
    CUPS_SHARE_PRINTERS="yes" \
    CUPS_REMOTE_ADMIN="yes" \
    CUPS_ENV_DEBUG="yes" \
    # defaults to $(hostname -i)
#    CUPS_IP="" \
    CUPS_ACCESS_LOGLEVEL="config" \
    # example: lpadmin -p Epson-RX520 -D 'my RX520' -m 'gutenprint.5.3://escp2-rx620/expert' -v smb://user:pass@host/Epson-RX520"
    CUPS_LPADMIN_PRINTER1=""

# This will use port 631
EXPOSE 631

# Baked-in config file changes
RUN sed -i 's/Listen localhost:631/Listen 0.0.0.0:631/' /etc/cups/cupsd.conf && \
	sed -i 's/Browsing Off/Browsing On/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/>/<Location \/>\n  Allow All/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/admin>/<Location \/admin>\n  Allow All\n  Require user @SYSTEM/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/admin\/conf>/<Location \/admin\/conf>\n  Allow All/' /etc/cups/cupsd.conf && \
	echo "ServerAlias *" >> /etc/cups/cupsd.conf && \
	echo "DefaultEncryption Never" >> /etc/cups/cupsd.conf

ENTRYPOINT ["/root/start-cups.sh"]
