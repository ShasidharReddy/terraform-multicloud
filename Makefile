SHELL := /bin/bash

.PHONY: deploy destroy validate fmt docs tag

deploy:
@bash scripts/deploy.sh

destroy:
@bash scripts/destroy.sh

validate:
@bash scripts/validate.sh

fmt:
@terraform fmt -recursive

docs:
@echo "Documentation target placeholder"

tag:
@test -n "$(version)" || (echo "Usage: make tag version=v1.1.0" && exit 1)
@git tag -a $(version) -m "$(version)"
