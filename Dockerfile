# Establece la imagen base de Flutter para la web
FROM cirrusci/flutter

# Copia el contenido de tu aplicación en la imagen
COPY . /app

# Establece el directorio de trabajo en /app
WORKDIR /app

# Instala las dependencias de tu aplicación Flutter
RUN flutter pub get

# Construye tu aplicación Flutter para producción
RUN flutter build web --release
