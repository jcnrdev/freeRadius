FROM freeradius/freeradius-server:latest-3.2

LABEL maintainer="infra@empresa.com"
LABEL description="FreeRADIUS 3.2 com suporte a SQL (MariaDB)"

RUN apt-get update && apt-get install -y --no-install-recommends \
    default-mysql-client \
    netcat-openbsd \
    python3 \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN sed -i 's/\r$//' /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE 1812/udp 1813/udp 3799/udp

ENTRYPOINT ["/entrypoint.sh"]
CMD ["freeradius", "-X"]
