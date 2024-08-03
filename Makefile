build:
	docker build -t contrakit -f .\Dockerfile .

start:
	docker run -d contrakit

