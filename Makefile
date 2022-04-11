include config.env

help:
	@echo ""
	@echo "Call comands as 'make <command>'".
	@echo "Command arguments specified in this help with UPPER_CAPS. Some required, some optional."
	@echo "Pass arguments as 'make <command> <ARG1>=\"<arg1_value>\" <ARG2>=\"<arg2_value>\"'"
	@echo ""
	@echo "Commands:"
	@echo "    help             Shows this help."
	@echo "    format           Format using black & isort. Display flake8 errors."
	@echo "    new-exp          Create new experiment folder from template. Req: EXP."
	@echo "    job              Triggers Azure ML job for experiment. Req: EXP; opt XARGS."
	@echo "    build-exp        Builds experiment environment Docker image. Req: EXP; opt XARGS."
	@echo "    local            Triggers local.py inside Docker environment. Req: EXP; opt: RUN_XARGS, XARGS."
	@echo "    jupyter          Spins jupyter lab inside Docker environment. Req: EXP; opt: RUN_XARGS, XARGS."
	@echo "    terminal         Spins terminal inside Docker environment. Req: EXP; opt: RUN_XARGS, XARGS."

check-exp-arg:
	@if [[ -z "$(EXP)" ]]; then { echo "You must pass EXP=<experiment_name> with this command"; exit 1; } fi

format:
	black .
	isort .
	flake8 .

new-exp: check-exp-arg
	unzip experiment_template.zip -d $(CODE_PATH)
	mv -f $(CODE_PATH)/experiment_template $(CODE_PATH)/$(EXP)

job: check-exp-arg
	cp -R $(CODE_PATH)/common $(CODE_PATH)/$(EXP);
	az ml job create -f $(CODE_PATH)/$(EXP)/azure-ml-job.yaml \
		--resource-group $(RESOURCE_GROUP) --workspace-name $(WORKSPACE) $(XARGS) || true
	rm -r $(CODE_PATH)/$(EXP)/common;

build-exp: check-exp-arg
	docker build --tag $(EXP):latest $(XARGS) $(CODE_PATH)/$(EXP)/docker

local: check-exp-arg
	@if [[ ! -f "$(CODE_PATH)/$(EXP)/local.py" ]]; then { echo "local.py missing for EXP=$(EXP)"; exit 1; } fi
	docker run --rm $(RUN_XARGS) \
		--mount type=bind,source="$(PWD)/data",target=$(DOCKER_WORKDIR)/data \
		--mount type=bind,source="$(PWD)/$(CODE_PATH)/$(EXP)",target=$(DOCKER_WORKDIR)/$(EXP) \
		--mount type=bind,source="$(PWD)/$(CODE_PATH)/common",target=$(DOCKER_WORKDIR)/$(EXP)/common \
		$(EXP):latest \
		python $(EXP)/local.py $(XARGS) \
	rm -rf $(CODE_PATH)/$(EXP)/common;

jupyter: check-exp-arg
	docker run --rm -it -p 8888:8888 $(RUN_XARGS) \
		--mount type=bind,source="$(PWD)/data",target=$(DOCKER_WORKDIR)/data \
		--mount type=bind,source="$(PWD)/$(CODE_PATH)/$(EXP)",target=$(DOCKER_WORKDIR)/$(EXP) \
		--mount type=bind,source="$(PWD)/$(CODE_PATH)/common",target=$(DOCKER_WORKDIR)/$(EXP)/common \
		--mount type=bind,source="$(PWD)/notebooks",target=$(DOCKER_WORKDIR)/notebooks \
		$(EXP):latest \
		/bin/bash -c "pip install jupyterlab; jupyter lab --allow-root --ip 0.0.0.0 --no-browser" \
		|| true
	rm -rf $(CODE_PATH)/$(EXP)/common;

terminal: check-exp-arg
	docker run --rm -it $(RUN_XARGS) \
		--mount type=bind,source="$(PWD)/data",target=$(DOCKER_WORKDIR)/data \
		--mount type=bind,source="$(PWD)/$(CODE_PATH)/$(EXP)",target=$(DOCKER_WORKDIR)/$(EXP) \
		--mount type=bind,source="$(PWD)/$(CODE_PATH)/common",target=$(DOCKER_WORKDIR)/$(EXP)/common \
		$(EXP):latest \
		/bin/bash || true
	rm -rf $(CODE_PATH)/$(EXP)/common;
