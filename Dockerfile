ARG PYTHON_VERSION
FROM python:${PYTHON_VERSION}-alpine3.22

# Update and upgrade system packages
RUN apk update && \
    apk add --upgrade apk-tools && \
    apk upgrade --available && \
    rm -rf /var/cache/apk/*

# Set working directory
WORKDIR /app

# Set env variable
ENV FILENAME=firmware.hex

# Copy requirements first (better Docker layer caching)
COPY requirements.txt .
# Declare PIP_VERSION after FROM to make it available in subsequent RUN instructions
ARG PIP_VERSION
# Upgrade pip and install requirements
RUN pip3 install --upgrade pip==${PIP_VERSION} && \
    pip3 install -r requirements.txt

# Default command
CMD [ "universal-silabs-flasher", "--verbose", "--help" ]