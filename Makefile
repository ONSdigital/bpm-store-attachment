# quit if envar not set for STAGE (TF_VAR_stage)
ifndef STAGE
$(error STAGE is not set)
endif

install:
	# Freshen the zip
	zip -g9 function.zip lambda_function.py
	terraform workspace select $(STAGE) terraform/ || terraform workspace new $(STAGE) terraform/
	TF_VAR_stage="$(STAGE)" terraform apply terraform/