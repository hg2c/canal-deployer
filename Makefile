colon := :
$(colon) := :
IMAGE_NAME ?= easi/canal-deployer$(:)v1.1.5-30

build:
	docker build -t $(IMAGE_NAME) .

run:
	docker run -it --name=canal-deployer --rm \
		--env="canal.destinations=cdc" \
		$(IMAGE_NAME)

bash:
	docker run -it --rm \
		--env="CDC_INSTANCE=cdc" \
		--env="CDC_MASTER_ADDRESS=prod.rds.amazonaws.com:3306" \
		--env="CDC_MASTER_DATABASE=easi_delivery" \
		--env="CDC_MASTER_USERNAME=cdcuser" \
		--env="CDC_MASTER_PASSWORD=cdcpass" \
		--env="CDC_INSTANCE_FILTER_REGEX=easi_delivery\\\\..*" \
		--env="CDC_MASTER_JOURNAL_NAME=mysql-bin-changelog.000061" \
		--env="CDC_MASTER_JOURNAL_POSITION=4771748" \
		-v $(CURDIR)/app.sh:/app.sh \
		$(IMAGE_NAME) bash

push:
	docker push $(IMAGE_NAME)
