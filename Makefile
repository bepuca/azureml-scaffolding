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
	cp -rP .experiment_template $(CODE_PATH)

	# Rename the freshly created folder to match the requested experiment name
	mv -f $(CODE_PATH)/.experiment_template $(CODE_PATH)/$(exp)

job: file=azure-ml-job.yaml
job: check-arg-exp check-exp-exists
	# Submit the job to Azure ML and continue to next step even if submission fails
	az ml job create -f $(CODE_PATH)/$(exp)/$(file) \
		--resource-group $(RESOURCE_GROUP) --workspace-name $(WORKSPACE) $(job-xargs) || true

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
		--mount type=bind,source="$(PWD)/$(CODE_PATH)/common",target=$(DOCKER_WORKDIR)/common \
		--mount type=bind,source="$(PWD)/models",target=$(DOCKER_WORKDIR)/models \
		--workdir $(DOCKER_WORKDIR) \
		$(exp):latest \
		python $(exp)/$(script) $(script-xargs) \
		|| true

test: build-exp
	# Run test suite inside the docker environment of the specified experiment
	docker run --rm $(run-xargs) \
		--mount type=bind,source="$(PWD)/data",target=$(DOCKER_WORKDIR)/data \
		--mount type=bind,source="$(PWD)/$(CODE_PATH)/$(exp)",target=$(DOCKER_WORKDIR)/$(exp) \
		--mount type=bind,source="$(PWD)/$(CODE_PATH)/common",target=$(DOCKER_WORKDIR)/common \
		--workdir $(DOCKER_WORKDIR)/$(exp) \
		$(exp):latest \
		python -m pytest $(test-xargs) \
		|| true

# Lines as `<command>: var=val` define defaults for optional arguments.
jupyter: port=8888
jupyter: build-exp
	# Start a jupyter server inside the docker environment of the specified experiment
	docker run --rm -it -p $(port):$(port) $(run-xargs) \
		--mount type=bind,source="$(PWD)/data",target=$(DOCKER_WORKDIR)/data \
		--mount type=bind,source="$(PWD)/$(CODE_PATH)/$(exp)",target=$(DOCKER_WORKDIR)/$(exp) \
		--mount type=bind,source="$(PWD)/$(CODE_PATH)/common",target=$(DOCKER_WORKDIR)/common \
		--mount type=bind,source="$(PWD)/notebooks",target=$(DOCKER_WORKDIR)/notebooks \
		--mount type=bind,source="$(PWD)/models",target=$(DOCKER_WORKDIR)/models \
		--workdir $(DOCKER_WORKDIR) \
		$(exp):latest \
		/bin/bash -c "pip install jupyterlab; jupyter lab --allow-root --ip 0.0.0.0 --no-browser --port $(port)" \
		|| true

terminal: build-exp
	# Start an interactive terminal inside the docker environment of the specified experiment
	docker run --rm -it $(run-xargs) \
		--mount type=bind,source="$(PWD)/data",target=$(DOCKER_WORKDIR)/data \
		--mount type=bind,source="$(PWD)/$(CODE_PATH)/$(exp)",target=$(DOCKER_WORKDIR)/$(exp) \
		--mount type=bind,source="$(PWD)/$(CODE_PATH)/common",target=$(DOCKER_WORKDIR)/common \
		--workdir $(DOCKER_WORKDIR) \
		$(exp):latest \
		/bin/bash \
		|| true

# Use the base command `check-arg` to ensure `dep` argument was passed
check-arg-dep: arg=dep
check-arg-dep: check-arg

dependency: check-arg-exp check-exp-exists check-arg-dep
	@dep_dir=`dirname $(dep)`; \
	dep_obj=`basename $(dep)`; \
	mkdir -p $(CODE_PATH)/$(exp)/common/$$dep_dir; \
	cd $(CODE_PATH)/$(exp)/common/$$dep_dir; \
	subexp_depth=`echo $(exp) | grep -o '/' - | wc -l`; \
	rel_path=../..; \
	for i in `seq 1 1 $$subexp_depth`; do rel_path=$$rel_path/..; done; \
	ln -s $$rel_path/common/$(dep) .
	@echo "Dependency successfully created!"
