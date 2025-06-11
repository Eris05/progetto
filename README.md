Il progetto per poter essere eseguito in locale ha bisogno della creazione di un file .env da inserire nella directory "progetto-main".
Il file .env necessita dei seguenti valori:
JWT_SECRET_KEY=...
HUGGINGFACE_API_TOKEN=...

Il JWT_SECRET_KEY deve essere di 32 bit.
Successivamente alla creazione del file .env, posizionarsi da terminale nella cartella progetto e mandare in esecuzione i seguenti comandi:
docker-compose build e successivamente 
docker-compose up -d

Aprire un browser e digitare http://localhost:63569 per visionare il sito in locale.
Registrarsi come utente, con un email valida.
Per visionare il funzionamento lato dipendente, entrare con credenziali di test riportate qui di seguito:
email: dipendente@example.com
password: dipendente
