FROM jasonrivers/nagios:latest

# Copy custom LetsDraw monitoring configurations into Nagios conf.d directory
COPY etc/objects/letsdraw.cfg /opt/nagios/etc/conf.d/letsdraw.cfg

# Expose Nagios Web Interface Port
EXPOSE 80
