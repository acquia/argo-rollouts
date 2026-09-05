# Argo Rollouts FIPS Build

This branch builds a FIPS-compliant Argo Rollouts controller image.

## Creating a New Tag

When upgrading to a new upstream Argo Rollouts version, update the following files:

### 1. Update the upstream version in Dockerfiles

Update the `ARGO_ROLLOUTS_UPSTREAM` build argument in both Dockerfiles:

**Dockerfile-FIPS** (line 40):
```dockerfile
ARG ARGO_ROLLOUTS_UPSTREAM=v1.10.0-rc1
```

**.acquia/Dockerfile.ci** (line 40):
```dockerfile
ARG ARGO_ROLLOUTS_UPSTREAM=v1.10.0-rc1
```

### 2. Update the custom tag in pipeline.yaml

Update `custom_tags` in `.acquia/pipeline.yaml` (line 28):
```yaml
custom_tags:
  - fips-v1.10.0-rc1
```

### 3. Commit and push

Commit your changes and push to the `enhance-fips-build` branch. The pipeline will build the FIPS-compliant image with the specified tag.
