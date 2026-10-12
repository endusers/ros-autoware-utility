ENV_DIR := ./docker/
SERVICE := ros-autoware-utility
PROJECT := rosenv

MAKEFLAGS += --no-print-directory

.PHONY: _check-env _update-env up-host up-bridge exec stop build \
        _compose-up _compose-exec _compose-stop _compose-build _compose-logs

_check-env:
	@cd $(ENV_DIR) && \
	set -a && . ./.env && set +a && \
	[ "$$RUNTIME_ENV" = "nvidia" ] || { echo "RUNTIME_ENV is invalid."; exit 1; }

_update-env:
	@cd $(ENV_DIR) && \
	sed -i -e 's/UID=.*$$/UID='`id -u`'/g' .env && \
	sed -i -e 's/GID=.*$$/GID='`id -g`'/g' .env

up-host:
	@cd $(ENV_DIR) && \
	export NETWORK_MODE=host && \
	sed -i -e "s/NETWORK_MODE=.*$$/NETWORK_MODE=$$NETWORK_MODE/g" .env
	@$(MAKE) _update-env
	@$(MAKE) _check-env
	@$(MAKE) _compose-up

up-bridge:
	@cd $(ENV_DIR) && \
	export NETWORK_MODE=bridge && \
	sed -i -e "s/NETWORK_MODE=.*$$/NETWORK_MODE=$$NETWORK_MODE/g" .env
	@$(MAKE) _update-env
	@$(MAKE) _check-env
	@$(MAKE) _compose-up

exec:
	@$(MAKE) _check-env
	@$(MAKE) _compose-exec

stop:
	@$(MAKE) _check-env
	@$(MAKE) _compose-stop

build:
	@$(MAKE) _update-env
	@$(MAKE) _check-env
	@$(MAKE) _compose-build

_compose-up:
	@cd $(ENV_DIR) && \
	set -a && . ./.env && set +a && \
	PWD=$$(pwd) docker compose -f compose.yml -f compose.$${NETWORK_MODE}.yml -p $(PROJECT) up
	# PWD=$$(pwd) docker compose -f compose.yml -f compose.$${NETWORK_MODE}.yml -p $(PROJECT) up -d

_compose-exec:
	@cd $(ENV_DIR) && \
	set -a && . ./.env && set +a && \
	PWD=$$(pwd) docker compose -f compose.yml -f compose.$${NETWORK_MODE}.yml -p $(PROJECT) exec $(SERVICE) /bin/bash

_compose-stop:
	@cd $(ENV_DIR) && \
	set -a && . ./.env && set +a && \
	PWD=$$(pwd) docker compose -f compose.yml -f compose.$${NETWORK_MODE}.yml -p $(PROJECT) stop

_compose-build:
	@cd $(ENV_DIR) && \
	set -a && . ./.env && set +a && \
	PWD=$$(pwd) docker compose -f compose.yml -f compose.$${NETWORK_MODE}.yml build
	# PWD=$$(pwd) docker compose -f compose.yml -f compose.$${NETWORK_MODE}.yml build --no-cache

_compose-logs:
	@cd $(ENV_DIR) && \
	set -a && . ./.env && set +a && \
	PWD=$$(pwd) docker compose -f compose.yml -f compose.$${NETWORK_MODE}.yml -p $(PROJECT) logs -f
