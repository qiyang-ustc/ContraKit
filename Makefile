build:
	docker build -t contrakit -f .\Dockerfile .

run:
    docker run --mount type=bind,source=".",target=/app contrakit ./examples/net.yaml ./tmp/res.yaml
# docker exec $(docker ps -aq)