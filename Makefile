export GOOGLE_IDP_ID?=C03jzkjg6
export GOOGLE_SP_ID?=331336665121
export AZURE_TENANT_ID?=PLACEHOLDER
export AZURE_APP_ID_URI?=PLACEHOLDER
export TF_PLUGIN_CACHE_DIR=.terraform/cache
AWS_ACCOUNT_ID_MASTER=720160341120
ASSUME_ROLE=arn:aws:iam::${AWS_ACCOUNT_ID_MASTER}:role/DNXAccess

GOOGLE_AUTH_IMAGE=public.ecr.aws/dnxbrasil/oni-sso:latest
AZURE_AUTH_IMAGE=public.ecr.aws/dnxsolutions/docker-aws-azure-ad:latest
AWS_IMAGE=public.ecr.aws/dnxsolutions/aws-v2:2.4.27-dnx1
TERRAFORM_IMAGE=dnxsolutions/terraform:0.14.5-dnx1

RUN_GOOGLE_AUTH	  =docker run -it --rm -v $(PWD):/work $(GOOGLE_AUTH_IMAGE) auth-google -i ${GOOGLE_IDP_ID} -s ${GOOGLE_SP_ID} -o env
RUN_GOOGLE_ASSUME =docker run -it --rm -v $(PWD):/work $(GOOGLE_AUTH_IMAGE) assume-role -r ${ASSUME_ROLE} -o env
RUN_AZURE_AUTH 	  =docker run -it --rm --env-file=.env -v $(PWD)/.env.auth:/work/.env $(AZURE_AUTH_IMAGE)
RUN_AWS        	  =docker run -it --rm --env-file=.env.auth --env-file=.env -v $(PWD):/work --entrypoint "" $(AWS_IMAGE)
RUN_TERRAFORM  	  =docker run -it --rm --env-file=.env.auth --env-file=.env -v $(PWD):/work $(TERRAFORM_IMAGE)

env-%: # Check for specific environment variables
	@ if [ "${${*}}" = "" ]; then echo "Environment variable $* not set"; exit 1;fi

.env:
	cp .env.template .env

clean-dotenv:
	rm -f .env .env.auth

clean-oni-auth:
	rm -f .env.oni-auth

dnx-assume: clean-dotenv .env
	$(RUN_GOOGLE_ASSUME)

google-auth: clean-oni-auth .env
	$(RUN_GOOGLE_AUTH)

azure-auth: .env env-AZURE_TENANT_ID env-AZURE_APP_ID_URI
	echo > .env.auth
	$(RUN_AZURE_AUTH)

init: .env env-WORKSPACE env-TF_PLUGIN_CACHE_DIR
	$(RUN_TERRAFORM) init
	$(RUN_TERRAFORM) workspace new $(WORKSPACE) 2>/dev/null; true # ignore if workspace already exists
	$(RUN_TERRAFORM) workspace "select" $(WORKSPACE)
.PHONY: init

shell: .env
	docker run -it --rm --env-file=.env.auth --env-file=.env -v $(PWD):/work --entrypoint "/bin/bash" $(TERRAFORM_IMAGE)
.PHONY: shell

apply: .env env-WORKSPACE
	$(RUN_TERRAFORM) apply .terraform-plan-$(WORKSPACE)
.PHONY: apply

plan: .env env-WORKSPACE
	$(RUN_TERRAFORM) plan -out=.terraform-plan-$(WORKSPACE)
.PHONY: plan

refresh: .env env-WORKSPACE
	$(RUN_TERRAFORM) refresh
.PHONY: refresh