# Define variables
VERSION := $(shell grep '^version' shard.yml | awk '{print $$2}')
IMAGE_NAME := bendangelo/caster

# Define targets and their commands
image:
	docker build -t $(IMAGE_NAME):$(VERSION) .

# Default target
.DEFAULT_GOAL := image
