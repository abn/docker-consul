
ROOT		:= $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
BUILDER		:= local/builder

IMAGE		:= alectolytic/consul
REPOSITORY	:= docker.io/$(IMAGE)
VERSION		:= 0.5.2

.PHONY: all build clean tag tag/$(VERSION) push push/$(VERSION)

all: build

build:
	@docker build -t $(BUILDER) $(ROOT)
	@docker run \
		--privileged \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v $(shell which docker):$(shell which docker) \
		-it $(BUILDER)

tag/$(VERSION):
	@docker tag -f $(IMAGE):latest $(REPOSITORY):$(VERSION)

tag: tag/$(VERSION)
	@docker tag -f $(IMAGE) $(REPOSITORY)

push/$(VERSION): tag
	@docker push $(REPOSITORY):$(VERSION)

push: | push/$(VERSION)
	@docker push $(REPOSITORY):latest

clean:
	@docker rmi -f $(BUILDER)
