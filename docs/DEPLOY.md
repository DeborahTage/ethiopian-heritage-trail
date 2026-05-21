# Production Deployment

## Architecture Overview
The system relies on Docker Compose to orchestrate:
1. Spring Boot Backend
2. React Web Dashboard (Nginx)
3. PostgreSQL 15
4. Redis 7

## Steps to Deploy

1. **Clone the Repository** on the target server.
2. **Configure Environments**: Use the `.env.example` to create `.env` bindings required by `docker-compose.prod.yml`.
    Ensure you specify:
    - `DB_USER`, `DB_PASSWORD`
    - `JWT_SECRET` (Use a strong secure random generation)
3. **Run Composer**:
    ```bash
    docker compose -f docker-compose.prod.yml up --build -d
    ```
4. **Validation**: Check that standard REST API responds on port `9002` / `80` reverse proxy, and ensure `Nginx` dashboard hosts React effectively on `80`.

## Continuous Integration
GitHub Actions automatically runs tests via `deploy.yml`. When commits merge to `main`, configure SSH actions to pipe output Docker containers to the production droplet.
