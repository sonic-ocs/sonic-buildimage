# OCS libs: fetch .debs from GitHub Releases
# Publish debs at: https://github.com/sonic-ocs/sonic-ocs-libs/releases
#
# Tag = release/bundle identifier (not package version). Each .deb has its own
# version in the filename (e.g. libsai-ocs-kvm-1.0.0-amd64.deb).
#   make OCS_LIBS_RELEASE_TAG=latest ...
#   make OCS_LIBS_RELEASE_TAG=release-2024q1 ...
OCS_LIBS_RELEASE_TAG ?= v1.0.0
OCS_LIBS_RELEASE_URL = https://github.com/sonic-ocs/sonic-ocs-libs/releases/download/$(OCS_LIBS_RELEASE_TAG)
