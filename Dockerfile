# ================================
# Build image
# ================================
FROM vapor/swift:latest as build
WORKDIR /build{{#fluent.db.is_sqlite}}

# Install sqlite3
RUN apt-get update -y \
	&& apt-get install -y libsqlite3-dev{{/fluent.db.is_sqlite}}

# First just resolve dependencies.
# This creates a cached layer that can be reused 
# as long as your Package.swift/Package.resolved
# files do not change.
COPY ./Package.* ./
RUN swift package resolve

# Copy entire repo into container
COPY . .

# Compile with optimizations
RUN swift build \
	--enable-test-discovery \
	-c release \
	-Xswiftc -g

# ================================
# Run image
# ================================
FROM vapor/ubuntu:18.04
WORKDIR /run

RUN adduser vapor

# Copy build artifacts
COPY --from=build --chown=vapor /build/.build/release /run
# Copy Swift runtime libraries
COPY --from=build /usr/lib/swift/ /usr/lib/swift/
# Uncomment the next line if you need to load resources from the `Public` directory
#COPY --from=build --chown=vapor /build/Public /run/Public

USER vapor

ENTRYPOINT ["./Run"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0"]
