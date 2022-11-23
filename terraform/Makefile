TERRAFORM=terraform
TFLINT=tflint

.PHONY: bootstrap
bootstrap:
	$(TERRAFORM) init

.PHONY: lint
lint:
	$(TERRAFORM) validate
	$(TFLINT)

.PHONY: dryrun
dryrun: lint
	$(TERRAFORM) plan | less -R

.PHONY: apply
apply: lint
	$(TERRAFORM) apply

.PHONY: destroy
destroy:
	$(TERRAFORM) destroy
