# Stage 1: Use the latest stable Flutter SDK for building the Flutter web app
FROM ghcr.io/cirruslabs/flutter:3.24.3 AS build

# Set the working directory inside the container
WORKDIR /app

# Copy the pubspec.yaml for the Flutter sample app
COPY example/firebase-dart-admin-auth-sdk-sample-app/pubspec.yaml ./pubspec.yaml

# Copy the entire sample app source code (including lib, assets, and bin)
COPY example/firebase-dart-admin-auth-sdk-sample-app/ ./

# Copy the entire firebase_dart_admin_auth_sdk folder for dependency resolution
COPY firebase-dart-admin-auth-sdk ./firebase-dart-admin-auth-sdk/

# Copy the updated server Dart code from the new bin path
COPY example/firebase-dart-admin-auth-sdk-sample-app/bin/server.dart ./bin/server.dart

# Adjust the path in pubspec.yaml to reflect the Docker container's structure
RUN sed -i 's|../../firebase-dart-admin-auth-sdk|./firebase-dart-admin-auth-sdk|' pubspec.yaml \
    && cat pubspec.yaml

# Run `flutter pub get` to resolve dependencies for the Flutter app
RUN flutter pub get


# Clean any previous builds (uncomment if needed)
# RUN flutter clean

# Build the Flutter web app for release
RUN flutter build web --release

# Stage 2: Use the Dart SDK to serve the Flutter web app using Dart VM
FROM dart:stable AS runtime

# Set the working directory for the runtime image
WORKDIR /app

# Copy the pre-built web app from the build stage
COPY --from=build /app/build/web /app/build/web

# Ensure the bin directory exists and copy server.dart
COPY example/firebase-dart-admin-auth-sdk-sample-app/bin/server.dart ./bin/server.dart

# Expose the port (adjust if necessary)
EXPOSE 8080

# Run the Dart VM to serve the web app (using the server.dart as an entrypoint)
CMD ["dart", "run", "bin/server.dart"]
