FROM node:20-alpine

RUN apk add --no-cache zip

WORKDIR /app

RUN npm install --no-audit --no-fund \
      brs-engine@2.2.0 \
      brs-scenegraph@0.2.0

RUN mkdir -p /public/assets && \
    cp node_modules/brs-engine/lib/brs.api.js        /public/ && \
    cp node_modules/brs-engine/lib/brs.worker.js     /public/ && \
    cp node_modules/brs-scenegraph/lib/brs-sg.js     /public/ && \
    cp node_modules/brs-scenegraph/assets/common.zip /public/assets/common.zip

COPY web/ /public/
COPY serve.js entrypoint.sh build.sh /app/
RUN chmod +x /app/entrypoint.sh /app/build.sh

EXPOSE 6502
ENTRYPOINT ["/app/entrypoint.sh"]
