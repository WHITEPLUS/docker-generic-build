NAME      := generic-build
REGISTRY  := whiteplus/$(NAME)
VERSION   := 20171122

.PHONY: build push


build:
	cd $(VERSION); docker build -t $(NAME):$(VERSION) .


run:
	docker run -it $(NAME):$(VERSION) bash


push: build
	docker tag $(NAME):$(VERSION) $(REGISTRY):$(VERSION)
	docker push $(REGISTRY):$(VERSION)


push-latest: build
	docker tag $(NAME):$(VERSION) $(REGISTRY):latest
	docker push $(REGISTRY):latest
