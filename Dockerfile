dockerfile_content = """# ================================
# Build stage
# ================================
FROM swift:5.9-jammy as build

# Update OS and install necessary build dependencies
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# 1. Resolve dependencies first to utilize Docker build cache
COPY ./Package.* ./
RUN swift package resolve

# 2. Copy the rest of the source code
COPY . .

# 3. Build the Vapor application in release mode
RUN swift build -c release

# 4. Prepare a staging area and copy the compiled executable
WORKDIR /staging
RUN cp "$(swift build --package-path /build -c release --show-bin-path)/App" ./

# ================================
# Run stage (Production Image)
# ================================
# Menggunakan versi slim agar image lebih ringan namun tetap memiliki Swift runtime
FROM swift:5.9-jammy-slim

# Install SSL certificates (wajib untuk koneksi Neon DB & MQTT) dan Timezone
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get -q install -y ca-certificates tzdata \
    && rm -r /var/lib/apt/lists/*

# Keamanan: Buat user khusus (non-root) untuk menjalankan aplikasi
RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app vapor

WORKDIR /app

# Copy file executable 'App' dari tahap build sebelumnya
COPY --from=build --chown=vapor:vapor /staging/App .

# Pindah ke user vapor
USER vapor:vapor

# Expose port yang akan digunakan oleh Render
EXPOSE 8080

# Jalankan aplikasi Vapor dan pastikan binding ke 0.0.0.0 agar bisa diakses internet
ENTRYPOINT ["./App"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]
"""

with open("Dockerfile", "w") as f:
    f.write(dockerfile_content)

print("File generated")