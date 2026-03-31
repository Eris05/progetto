# 💬 Q&A Platform with AI Integration

> A full-stack web platform where users can ask questions and receive answers from employees — or from a pre-trained AI model via HuggingFace.

---

## 🚀 Overview

This platform provides two distinct authenticated experiences:

- **Users** — Submit questions and choose whether to receive a human reply or an AI-generated response
- **Employees** — Manage and respond to incoming questions via a private dashboard

The application is fully containerized and deployed on a live AWS EC2 instance.

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter (Dart) |
| Backend | Spring Boot (Java) — REST API |
| Database | PostgreSQL |
| AI Integration | HuggingFace pre-trained model |
| Containerization | Docker Engine · Docker Compose · Dockerfile |
| Deployment | AWS EC2 (Linux) |

---

## ✨ Key Features

- Role-based authentication (User / Employee)
- Private dashboards per role
- AI-powered auto-response via HuggingFace API
- RESTful API architecture
- Fully dockerized multi-container setup (frontend, backend, DB)
- Production deploy on AWS EC2 Linux instance

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│              AWS EC2 (Linux)            │
│                                         │
│  ┌──────────┐   ┌──────────────────┐   │
│  │ Flutter  │──▶│  Spring Boot API │   │
│  │ Frontend │   │  (REST)          │   │
│  └──────────┘   └────────┬─────────┘   │
│                          │             │
│              ┌───────────┴──────────┐  │
│              │     PostgreSQL DB    │  │
│              └──────────────────────┘  │
│                          │             │
│              ┌───────────┴──────────┐  │
│              │  HuggingFace Model   │  │
│              │  (AI Auto-response)  │  │
│              └──────────────────────┘  │
│                                         │
│  Orchestrated with Docker Compose       │
└─────────────────────────────────────────┘
```

---

## 🐳 Run Locally

```bash
# Clone the repository
git clone https://github.com/Eris05/progetto.git
cd progetto

# Start all services
docker-compose up --build
```

The app will be available at `http://localhost:8080`

---

## 📁 Project Structure

```
progetto/
├── backend/          # Spring Boot REST API
├── frontend/         # Flutter web app
├── docker-compose.yml
├── Dockerfile
└── README.md
```

---


Il progetto per poter essere eseguito in locale ha bisogno della creazione di un file .env da inserire nella directory "progetto-main".
Il file .env necessita dei seguenti valori:
JWT_SECRET_KEY=...
HUGGINGFACE_API_TOKEN=...
Il JWT_SECRET_KEY deve essere di 32 bit.

Per visionare il funzionamento lato dipendente, entrare con credenziali di test riportate qui di seguito:
email: dipendente@example.com
password: dipendente
