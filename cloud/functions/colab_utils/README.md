# Building and Publishing the Library

## For Google Cloud Artifact Registry (current setup):

1. Authenticate with Google Cloud and configure Poetry for publishing:
   ```
   gcloud auth application-default login
   poetry config http-basic.gcp oauth2accesstoken "$(gcloud auth application-default print-access-token)"
   ```

2. Install dependencies:
   ```
   poetry install
   ```

3. Build the library:
   ```
   poetry build
   ```

4. Publish to the Google Cloud Artifact Registry:
   ```
   poetry publish -r gcp
   ```

## For PyPI (if you want to switch):

1. Get your PyPI API token from https://pypi.org/manage/account/token/

2. Configure Poetry with your PyPI token:
   ```
   poetry config pypi-token.pypi your-api-token-here
   ```

3. Update pyproject.toml to remove the custom repository or add PyPI as secondary:
   ```
   poetry source remove gcp
   ```

4. Build and publish to PyPI:
   ```
   poetry build
   poetry publish
   ```