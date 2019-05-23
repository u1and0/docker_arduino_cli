# Usage:
# Upload blink LED (13pin) 1 sec
# ```
# $ docker run --rm\
#     --device /dev/ttyACM0:/dev/ttyACM0\
#     u1and0/arduino-cli\
#     arduino-cli upload -p /dev/ttyACM0 --fqbn arduino:avr:uno Arduino/blink
# ```

FROM golang:1.11.9-alpine3.9 AS go_official
Run apk add git &&\
    go get -u github.com/arduino/arduino-cli

FROM frolvlad/alpine-glibc
RUN apk add ca-certificates python
WORKDIR /root
COPY --from=go_official /go/bin/arduino-cli /usr/bin/arduino-cli
ENV USER root
RUN echo 'sketchbook_path: "${HOME}/Arduino"' > /usr/bin/arduino-cli.yaml &&\
    echo 'arduino_data: "${HOME}/.arduino15"' >> /usr/bin/arduino-cli.yaml
RUN arduino-cli core update-index --debug &&\
    arduino-cli core install arduino:avr &&\
    arduino-cli board listall &&\
    arduino-cli sketch new blink --debug
COPY blink.ino /root/Arduino/blink/blink.ino
RUN arduino-cli compile --fqbn arduino:avr:uno Arduino/blink

LABEL maintainer="u1and0 <e01.ando60@gmail.com>"\
      description="arduino-cli env"\
      version="v0.0.0"
