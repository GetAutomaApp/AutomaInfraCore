Remember to run migrate before deploying to envs
swift run App migrate --env {env}

TODO: We will move to Kubernetes after a while, but for we will make use of fly machines to run procs

ensure to docker compose in order to run locally

also, run `fly secrets import < .env.sandbox -a automa-backend-sandbox` (or similar) to deploy secrets for the correct env.

All the env files are stored in Zoho vault


