FROM node:16 as node
FROM ruby:2.5

WORKDIR /workspace

COPY --from=node /usr/local/bin/ /usr/local/bin/
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
