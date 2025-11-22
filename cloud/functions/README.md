
# Project Setup and Packaging Instructions

This guide explains how to create a `.tar.gz` file for your Python project using Poetry, and how to package it into a `.zip` file.

## Prerequisites

1. Ensure you have `Poetry` installed. If not, you can install it using the following command:
   
   ```bash
   curl -sSL https://install.python-poetry.org | python3 -
   ```

2. Make sure you have `tar` and `zip` installed (most Unix-like systems have these utilities by default).

3. Auth to remote repository

   ```bash
poetry config http-basic.gcp _json_key "$(cat .../frigate-nvr/cloud/key-prod.json | tr -d '\n')"
   ```

## Steps to Create the Package

1. **Run the build script**:

   You can simply execute a `build.sh` script to automate the packaging process:

   ```bash
   ./build.sh
   ```

   This script will handle the creation of required artifacts for all functions.

2. **Install project dependencies**:
   
   In the root directory of your project, run the following command to install all required dependencies:

   ```bash
   poetry lock
   poetry install
   ```

3. **Build the Package**:
   
   To generate the `requirements.txt` file of your project, run:

   ```bash
   poetry export --without-hashes -f requirements.txt > requirements.txt
   ```

# Functions

## ask_chat

You have to provide manually API key:

```bash
echo -n "your_secret_api_key" | gcloud secrets create chatgpt-api-key \
  --data-file=- \
  --replication-policy=automatic
```
## bb

You have to provide manually API key:

```bash
echo -n "your_secret_api_key" | gcloud secrets create fmp-api-key \
  --data-file=- \
  --replication-policy=automatic
```

## colab utils (library)

See [doc](colab_utils/README.md)

## Telegram

### How to get chat id?

Method 1 (simplest) — via getUpdates in browser:

1. Send any message to your bot in Telegram

2. Open in browser:

   ```
   https://api.telegram.org/bot<YOUR_TOKEN>/getUpdates
   ```

3. In the response you'll see JSON with:

   ```json
   {
   "message": {
     "chat": {
      "id": 123456789
     }
   }
   }
   ```

   This number is your `chat_id`.

### Register webhook

Add webhook (i.e., set function as callback for messages):

```bash
curl "https://api.telegram.org/bot<YOUR_TOKEN>/setWebhook?url=<YOUR_HTTPS_URL>"
```

### How to check if webhook is set

Execute:

```
https://api.telegram.org/bot<YOUR_TOKEN>/getWebhookInfo
```

### Where is my token?


Your token is stored in Google Cloud Secret Manager.

It was added by:

```bash
echo -n XXX | gcloud secrets create colab-invest-telegram-token --data-file=-
```

And can be accessed through:

```bash
gcloud secrets versions access latest --secret="colab-invest-telegram-token"
```

