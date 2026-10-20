# Stage 1: Build Flutter Web App
FROM google/cloud-builders/gke-deploy AS flutter_builder

RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable /flutter && \
    /flutter/bin/flutter config --no-analytics && \
    /flutter/bin/flutter precache

ENV PATH="/flutter/bin:${PATH}"

WORKDIR /app
COPY . .

RUN flutter clean && \
    flutter pub get && \
    flutter build web --release

# Stage 2: Serve with Nginx
FROM nginx:alpine

COPY --from=flutter_builder /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
