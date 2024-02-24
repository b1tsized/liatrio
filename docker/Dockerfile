FROM --platform=linux/x86_64 cgr.dev/chainguard/go AS builder
COPY ./app /app
RUN cd /app && go build -o go-liatrio .

FROM --platform=linux/x86_64 cgr.dev/chainguard/glibc-dynamic
COPY --from=builder /app/go-liatrio /usr/bin/
EXPOSE 5000/tcp
CMD ["/usr/bin/go-liatrio"]