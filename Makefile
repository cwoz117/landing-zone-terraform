.PHONY: fmt fmt-check validate

TF_DIRS := modules/workload-project live/platform/root live/platform/identity live/platform/security live/platform/workloads

fmt:
	terraform fmt -recursive

fmt-check:
	terraform fmt -recursive -check -diff

validate: fmt-check
	@set -e; for dir in $(TF_DIRS); do \
		echo "Validating $$dir"; \
		terraform -chdir=$$dir init -backend=false -input=false >/dev/null; \
		terraform -chdir=$$dir validate; \
	done
