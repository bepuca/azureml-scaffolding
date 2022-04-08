include config.env

check-exp-arg:
	@if [[ -z "$(EXP)" ]]; then { echo "You must pass EXP=<experiment_name> with this command"; exit 1; } fi

new-exp: check-exp-arg
	unzip experiment_template.zip -d $(CODE_PATH)
	mv $(CODE_PATH)/experiment_template $(CODE_PATH)/$(EXP)

job: check-exp-arg
	cp -R $(CODE_PATH)/common $(CODE_PATH)/$(EXP);
	az ml job create -f $(CODE_PATH)/$(EXP)/azure-ml-job.yaml \
		--resource-group $(RESOURCE_GROUP) --workspace-name $(WORKSPACE) $(XARGS) || true
	rm -r $(CODE_PATH)/$(EXP)/common;

build-exp: check-exp-arg
	docker build --tag $(EXP):latest $(XARGS) $(CODE_PATH)/$(EXP)/docker

local: check-exp-arg
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
