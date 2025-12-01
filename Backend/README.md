1. Create `./infra/docker-secrets/` directory with the following files and secrets:
    1. "GITHUB_SSH_AUTHENTICATION_TOKEN": A Github fine-grained token that allows cloning AutomaUtilities repository (private)

TODOS:
- [ ] CURRENT BRANCH: deploy temporal and temporal worker on fly.io. Delete vapor-queues worker fly.io config and apps in organizations
- [ ] Fix profile picture image generation not working (current problem: OpenAI platform billing hard limit reached)
- [ ] FUTURE: Fix swift protobuf package warnings (find upstream package, make a pull request to swift protobuf to support latest 
    swift version - fix warnings) and update upstream package `Package.swift` to use 
    latest protobuf version.
