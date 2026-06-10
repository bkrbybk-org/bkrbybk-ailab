# AILAB

This project is for learning how to deploy AI/LLM using Ollama container

### Setup

Create and save key pair on AWS then replace key name in main.tf file

Spin AWS EC2 instance with terraform

```
terraform apply
```

### Docker Compose

Then run a model on Ollama container

```
docker exec -it ollama ollama run llama3.2:1b
```

### Ollama

```
http://<container-ip>:11434
```

### Open Webui

```
http://<container-ip>:3000
```

### Streamlit

```
http://<container-ip>:8080
```
