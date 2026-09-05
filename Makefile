PACKAGE=github.com/argoproj/argo-rollouts
CURRENT_DIR=$(shell pwd)
DIST_DIR=${CURRENT_DIR}/dist
PATH := $(DIST_DIR):$(PATH)

BUILD_DATE=$(shell date -u +'%Y-%m-%dT%H:%M:%SZ')
GIT_COMMIT=$(shell git rev-parse HEAD)
GIT_TAG=$(shell if [ -z "`git status --porcelain`" ]; then git describe --exact-match --tags HEAD 2>/dev/null; fi)
GIT_TREE_STATE=$(shell if [ -z "`git status --porcelain`" ]; then echo "clean" ; else echo "dirty"; fi)
VERSION=$(shell if [ ! -z "${GIT_TAG}" ] ; then echo "${GIT_TAG}" | sed -e "s/^v//"  ; else cat VERSION ; fi)

override LDFLAGS += \
  -X ${PACKAGE}/utils/version.version=${VERSION} \
  -X ${PACKAGE}/utils/version.buildDate=${BUILD_DATE} \
  -X ${PACKAGE}/utils/version.gitCommit=${GIT_COMMIT} \
  -X ${PACKAGE}/utils/version.gitTreeState=${GIT_TREE_STATE}

ifneq (${GIT_TAG},)
override LDFLAGS += -X ${PACKAGE}.gitTag=${GIT_TAG}
endif

IMAGE_TAG=fips-v1.9.0-rc3

.PHONY: build-fips
build-fips:
	DOCKER_BUILDKIT=1 docker build --platform=linux/amd64 -t argo-rollouts:$(IMAGE_TAG) -f Dockerfile-FIPS .

.PHONY: controller-fips
controller-fips:
	GOEXPERIMENT=boringcrypto CGO_ENABLED=1 go build -v -ldflags '${LDFLAGS}' -o ${DIST_DIR}/rollouts-controller ./cmd/rollouts-controller

# Note: This target might not work as expected on arm64 architecture.
.PHONY: check-fips
check-fips: controller-fips
	go tool nm ${DIST_DIR}/rollouts-controller | grep "_Cfunc__goboringcrypto_" || (echo "CGO boringcrypto could not be detected in the go application binary" && exit 1)

