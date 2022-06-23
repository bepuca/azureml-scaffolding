# All variables referenced in UPPER_CAPS come from configuration.
# All variables referenced in lower_caps are arguments to be passed (some with defaults).
# Loads the variables in `config.env` so that they are available for the commands of this file
include config.env

help:
	@echo ""
	@if [ -z "$(cmd)" ]; then { \
		echo "For a more detailed help of a command, run 'make help cmd=<cmd>'.\n"; \
		echo "Commands:"; \
		for file in `ls ./docs/makefile`; do cat ./docs/makefile/$$file | head -2 | tail -1; done; \
	} else { \
		cat ./docs/makefile/$(cmd); \
	} fi
	@echo "";

# Base command used for argument checking, never to be called manually
check-arg:
	@# Checks that the argument `arg` is pointing to is passed and raises error if not
	@if [ -z "$($(arg))" ]; then { echo "You must pass '$(arg)' argument with this command"; exit 1; } fi

# Use the base command `check-arg` to ensure `exp` argument was passed
check-arg-exp: arg=exp
check-arg-exp: check-arg

# Command for validity of 'exp' specified, never to be called manually.
check-exp-exists:
	@# Checks that specified `exp` exists as folder in the project code path and raises error if not
	@if [ ! -d "$(CODE_PATH)/$(exp)" ]; then { echo "Experiment '$(exp)' not found"; exit 1; } fi


format:
	black .
	isort .
	flake8 .

new-exp: check-arg-exp
	# Unzip the experiment template
	unzip experiment_template.zip -d $(CODE_PATH)

	# Rename the freshly created folder to match the requested experiment name
	mv -f $(CODE_PATH)/experiment_template $(CODE_PATH)/$(exp)

job: check-arg-exp check-exp-exists
	# Temporarily copy common folder inside experiment so it ends up in the Azure ML snapshot
	cp -R $(CODE_PATH)/common $(CODE_PATH)/$(exp);

	# Submit the job to Azure ML and continue to next step even if submission fails
	az ml job create -f $(CODE_PATH)/$(exp)/azure-ml-job.yaml \
		--resource-group $(RESOURCE_GROUP) --workspace-name $(WORKSPACE) $(job-xargs) || true

	# Remove the common folder from inside the experiment folder
	rm -r $(CODE_PATH)/$(exp)/common;

build-exp: check-arg-exp check-exp-exists
	docker build --tag $(exp):latest $(build-xargs) $(CODE_PATH)/$(exp)/environment

# Lines as `<command>: var=val` define defaults for optional arguments.
local: script="local.py"
local: build-exp
	@# Check if there is the requested script for the requested experiment and raise error if not
	@if [ ! -f "$(CODE_PATH)/$(exp)/$(script)" ]; then { echo "$(script) missing for exp=$(exp)"; exit 1; } fi

	# Execute script inside the docker environment of the specified experiment
	docker run --rm $(run-xargs) \
		--mount type=bind,source="$(PWD)/data",target=$(DOCKER_WORKDIR)/data \
		--mount type=bind,source="$(PWD)/$(CODE_PATH)/$(exp)",target=$(DOCKER_WORKDIR)/$(exp) \
		--mount type=bind,source="$(PWD)/$(CODE_PATH)/common",target=$(DOCKER_WORKDIR)/$(exp)/common \
		--workdir $(DOCKER_WORKDIR) \
		$(exp):latest \
		python $(exp)/$(script) $(script-xargs) \
		|| true

	# Remove common folder from inside experiment created as byproduct of mounts in docker
	rm -rf $(CODE_PATH)/$(exp)/common;

test: build-exp
	# Run test suite inside the docker environment of the specified experiment
	docker run --rm $(run-xargs) \
		--mount type=bind,source="$(PWD)/data",target=$(DOCKER_WORKDIR)/data \
		--mount type=bind,source="$(PWD)/$(CODE_PATH)/$(exp)",target=$(DOCKER_WORKDIR)/$(exp) \
		--mount type=bind,source="$(PWD)/$(CODE_PATH)/common",target=$(DOCKER_WORKDIR)/$(exp)/common \
		--workdir $(DOCKER_WORKDIR)/$(exp) \
		$(exp):latest \
		python -m pytest $(test-xargs) \
		|| true

	# Remove common folder from inside experiment created as byproduct of mounts in docker
	rm -rf $(CODE_PATH)/$(exp)/common;

# Lines as `<command>: var=val` define defaults for optional arguments.
jupyter: port=8888
jupyter: port=8888
jupyter: build-exp
	# Start a jupyter server inside the docker environment of the specified experiment
	docker run --rm -it -p $(port):$(port) $(run-xargs) \
		--mount type=bind,source="$(PWD)/data",target=$(DOCKER_WORKDIR)/data \
		--mount type=bind,source="$(PWD)/$(CODE_PATH)/$(exp)",target=$(DOCKER_WORKDIR)/$(exp) \
		--mount type=bind,source="$(PWD)/$(CODE_PATH)/common",target=$(DOCKER_WORKDIR)/$(exp)/common \
		--mount type=bind,source="$(PWD)/notebooks",target=$(DOCKER_WORKDIR)/notebooks \
		--workdir $(DOCKER_WORKDIR) \
		$(exp):latest \
		/bin/bash -c "pip install jupyterlab; jupyter lab --allow-root --ip 0.0.0.0 --no-browser --port $(port)" \
		|| true

	# Remove common folder from inside experiment created as byproduct of mounts in docker
	rm -rf $(CODE_PATH)/$(exp)/common;

terminal: build-exp
	# Start an interactive terminal inside the docker environment of the specified experiment
	docker run --rm -it $(RUN_XARGS) \
		--mount type=bind,source="$(PWD)/data",target=$(DOCKER_WORKDIR)/data \
		--mount type=bind,source="$(PWD)/$(CODE_PATH)/$(exp)",target=$(DOCKER_WORKDIR)/$(exp) \
		--mount type=bind,source="$(PWD)/$(CODE_PATH)/common",target=$(DOCKER_WORKDIR)/$(exp)/common \
		--workdir $(DOCKER_WORKDIR) \
		$(exp):latest \
		/bin/bash \
		|| true

	# Remove common folder from inside experiment created as byproduct of mounts in docker
	rm -rf $(CODE_PATH)/$(exp)/common;
