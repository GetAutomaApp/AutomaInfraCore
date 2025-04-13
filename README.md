# AutomaInfracore

## Setup

**Local**:

1. Create `.env.development`, copy and paste variables from `env.development` note in Automa Obsidian vault
2. Run `npm run compose:up` to start all the services

**Cloud environment**:

Having a script that automates setting up all hosted environments on fly.io aren't needed, because we will never migrate to another fly.io account. In the future we might migrate to another platform.

1. Run `fly secrets import < .env.sandbox -a automa-backend-sandbox` (replace app and env file names)

