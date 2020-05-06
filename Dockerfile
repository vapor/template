# ================================
# Build image
# ================================
FROM swift:5.2-bionic as build
WORKDIR /build{{#fluent.db.is_sqlite}}

# Install sqlite3
RUN apt-get update -y \
	&& apt-get install -y libsqlite3-dev \
	&& rm -rf /var/lib/apt/lists/*{{/fluent.db.is_sqlite}}

# First just resolve dependencies.
# This creates a cached layer that can be reused
# as long as your Package.swift/Package.resolved
# files do not change.
COPY ./Package.* ./
RUN swift package resolve

# Copy entire repo into container
COPY . .

# Compile with optimizations
RUN swift build --enable-test-discovery -c release

# ================================
# Run image
# ================================
FROM swift:5.2-bionic-slim

RUN useradd --user-group --create-home --home-dir /app vapor

WORKDIR /app

# Copy build artifacts
COPY --from=build --chown=vapor /build/.build/release .
# Uncomment the next line if you need to load resources from the `Public` directory
#COPY --from=build --chown=vapor /build/Public ./Public

USER vapor

ENTRYPOINT ["./Run"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]
