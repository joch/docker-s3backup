.PHONY: build
build:
	docker build -t joch/s3backup .

.PHONY: clean
clean:
	docker rmi -f joch/s3backup
