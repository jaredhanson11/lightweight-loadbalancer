docker-user=jaredhanson11
name=${docker-user}/lightweight-load-balancer

build:
	docker build . -t ${name}:latest
push: build
	docker push ${name}:latest
push-images: push
