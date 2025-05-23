# SM Assistant Backend (MVP)

## Uruchomienie bazy lokalnie

### Krok 1: Wymagania
- Docker Desktop
- Git
- (opcjonalnie) pgAdmin lub DBeaver do podglądu bazy

### Krok 2: Uruchomienie
```bash
git clone <repo>
cd sm-assistant-backend
docker compose up --build
```

Baza zostanie uruchomiona lokalnie na porcie 5432.
Login: `sm_admin`, Hasło: `supersecure`, Baza: `sm_assistant`

### Uwaga o bezpieczeństwie

Plik `.env` NIE powinien trafiać na produkcję ani do repozytorium.

#### Zalecenia:
- Lokalnie dodaj `.env` do `.gitignore`
- Na produkcji używaj zmiennych środowisk z menedżera sekretów (np. Docker secrets, AWS/GCP Secret Manager, Railway Variables)
