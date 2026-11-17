# Makefile - Comandos uteis para o stack FreeRADIUS

.PHONY: up down restart logs build clean test-auth status

## Sobe todos os servicos
up:
	docker compose up -d

## Derruba todos os servicos
down:
	docker compose down

## Reinicia todos os servicos
restart:
	docker compose restart

## Rebuild das imagens e sobe
build:
	docker compose build --no-cache
	docker compose up -d

## Mostra logs de todos os servicos
logs:
	docker compose logs -f

## Logs apenas do FreeRADIUS
logs-radius:
	docker compose logs -f freeradius

## Logs apenas do daloRADIUS
logs-dalo:
	docker compose logs -f daloradius

## Status dos containers
status:
	docker compose ps

## Teste de autenticacao (requer radtest instalado ou usa container)
test-auth:
	docker compose exec freeradius radtest testuser testpass123 127.0.0.1 0 testing123

## Acesso ao banco de dados
db-shell:
	docker compose exec db mysql -uradius -pradiusSecret123 radius

## Remove volumes (ATENCAO: apaga todos os dados!)
clean:
	docker compose down -v
	@echo "Volumes removidos!"

## Gera certificados auto-assinados para EAP-TLS
gen-certs:
	@echo "Gerando certificados..."
	docker compose exec freeradius bash -c "cd /etc/freeradius/3.0/certs && make"
	@echo "Certificados gerados em freeradius/certs/"
