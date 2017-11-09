.PHONY: build push test

TAG ?= $(shell git log -n 1 --pretty=format:"%H")
IMAGE ?= juanluisbaptiste/mysql-backup
TARGET ?= $(IMAGE):$(TAG)


build:
	docker build -t $(TARGET) .

push:
	docker tag $(TARGET) $(IMAGE):latest
	docker push $(TARGET)
	docker push $(IMAGE):latest

test:
	cd test && ./test.sh
