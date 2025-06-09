# Usa un'immagine base con Flutter preinstallato
FROM ghcr.io/cirruslabs/flutter:latest AS build

# Imposta la directory di lavoro all'interno del container
WORKDIR /app

# Copia il file pubspec.yaml e pubspec.lock per installare le dipendenze
COPY pubspec.yaml pubspec.lock ./

# Scarica le dipendenze senza generare la cartella completa dei pacchetti
RUN flutter pub get

# Copia tutto il codice sorgente
COPY . .

# Compila l'app Flutter per il web
RUN flutter build web

# Usa un'immagine leggera per servire l'app
FROM nginx:alpine

# Copia i file compilati nella directory di Nginx
COPY --from=build /app/build/web /usr/share/nginx/html

# Espone la porta 80
EXPOSE 80

# Avvia Nginx
CMD ["nginx", "-g", "daemon off;"]
