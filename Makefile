APP_NAME=dalf/filtron

build:
	docker rmi -f $(APP_NAME):latest
	docker build -t $(APP_NAME) .

run:
	@echo "\n /!\ DO NOT use in production\n"
	docker run --rm -t -i --net=host --name="filtron" $(APP_NAME) --target 127.0.0.1:8888

push: build
	docker push $(APP_NAME)
