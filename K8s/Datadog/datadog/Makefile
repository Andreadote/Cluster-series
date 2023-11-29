# Makefile to run terraform worflow

check:
	@echo "Running terraform checks"
	@terraform init
	@terraform validate
	@terraform fmt
plan: check
	@echo "Running terraform plan"
	@terraform init plan -out=tfplan
apply: check
	@echo "Running terraform apply"
	@terraform apply -auto-approve
destroy: check
	@echo "Running terraform destroy"
	@terraform destroy -auto-approve
	