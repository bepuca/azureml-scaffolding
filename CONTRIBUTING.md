# Contributing

After changes, the following workflow should work seamlessly:

1. `bin/pkg/new exp_test`
2. Run local in VSCode.
3. Run tests in VSCode.

4. The following should cause no git changes

```bash
bin/pkg/rm example-reader-step && \
bin/pkg/rm example-writer-step && \
rm pipelines/example-pipeline.yaml \
&& bin/pipe/new example-pipeline
```

Removing an experiment

TODO:
run job in aml to test all works nice
