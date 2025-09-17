ARG PYTHON_VERSION
FROM python:${PYTHON_VERSION}-alpine3.22
# Update and upgrade
RUN apk update && \
    apk add --upgrade apk-tools && \
    apk upgrade --available && \
    rm -rf /var/cache/apk/*
# Set env variable
ENV FILENAME firmware.hex
# Install requirements
COPY requirements.txt .
RUN pip3 install -r requirements.txt
CMD [ "universal-silabs-flasher", "--help" ]
