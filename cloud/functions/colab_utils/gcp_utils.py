import os
from google.cloud import secretmanager

def get_project_id():
    return os.environ.get("GCLOUD_PROJECT_NUMBER")


def get_secret(secret_id):
    client = secretmanager.SecretManagerServiceClient()
    project_id = get_project_id()

    name = f"projects/{project_id}/secrets/{secret_id}/versions/latest"
    response = client.access_secret_version(name=name)
    return response.payload.data.decode("UTF-8")