FROM julia:1.12.5-trixie

WORKDIR /app

COPY Project.toml Manifest.toml ./
RUN julia --project=. -e "using Pkg; Pkg.instantiate()"

COPY src/ ./src/
RUN julia --project=. -e "using Pkg; Pkg.precompile()"


EXPOSE 8080

HEALTHCHECK --interval=10s --timeout=5s --start-period=60s --retries=5 \
  CMD curl -f http://localhost:8080/healthz || exit 1

CMD ["julia", "--project=.", "src/main.jl"]
