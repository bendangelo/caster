# Define variables
VERSION := $(shell shards version)
IMAGE_NAME := bendangelo/caster

# Define targets and their commands
image:
	docker build -t $(IMAGE_NAME):$(VERSION) .

# Default target
.DEFAULT_GOAL := image
