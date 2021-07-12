colon := :
$(colon) := :
IMAGE_NAME ?= easi/canal-deployer$(:)v1.1.5-18

build:
	docker build -t $(IMAGE_NAME) .

run:
	docker run -it --name=canal-deployer --rm \
		--env="canal.destinations=cdc" \
		$(IMAGE_NAME)

bash:
	docker run -it --rm \
		-v $(CURDIR)/app.sh:/app.sh \
		$(IMAGE_NAME) bash

push:
	docker push $(IMAGE_NAME)
