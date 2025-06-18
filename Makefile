DOCKER_NAME=hashicraft/minecraft
DOCKER_VERSION=v1.21.6-fabric

build:
	docker build -t ${DOCKER_NAME}:${DOCKER_VERSION} --no-cache .

build_and_push: build
	docker push ${DOCKER_NAME}:${DOCKER_VERSION}

compress:
	@echo "Compressing mods folder..."
	@if [ -d "mods" ] && [ "$(shell ls -A mods 2>/dev/null)" ]; then \
		tar -czf mods.tar.gz -C mods .; \
		echo "Created mods.tar.gz"; \
	else \
		echo "mods folder is empty or doesn't exist"; \
	fi

deploy-mods: compress
	@echo "Mods compressed to mods.tar.gz"
	@echo "To deploy:"
	@echo "1. git add mods.tar.gz"
	@echo "2. git commit -m 'Update mods'"
	@echo "3. git push"
	@echo ""
	@echo "The mods will be available at:"
	@echo "https://raw.githubusercontent.com/Desarso/Docker-Minecraft-Server-Fabric/main/mods.tar.gz"

ngrok:
	ngrok tcp 25565

build_multi:
	docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
	docker buildx create --name multi || true
	docker buildx use multi
	docker buildx inspect --bootstrap
	docker buildx build --platform linux/arm64,linux/amd64 \
		-t ${DOCKER_NAME}:${DOCKER_VERSION} \
    -f ./Dockerfile \
    . \
		--push
	docker buildx rm multi
