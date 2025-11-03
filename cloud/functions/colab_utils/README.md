# Building and Publishing the Library

1. Authenticate with Google Cloud and configure Poetry for publishing:
   ```
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

4. Publish to the Google Cloud repository:
   ```
   poetry publish -r gcp
   ```