.PHONY: fmt fmt-check validate

TF_DIRS := modules/cloud-sql-postgres modules/gke-platform modules/network modules/workload-project live/platform/root live/platform/identity live/platform/network live/platform/security live/platform/compute live/platform/data live/platform/services live/platform/workloads live/workloads/scan-service/dev live/workloads/scan-service/test live/workloads/scan-service/prod live/workloads/web-ui/dev live/workloads/web-ui/test live/workloads/web-ui/prod

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
