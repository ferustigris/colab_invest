# Directory Structure

```
.
├── main.tf                 # Main Terraform configuration file
├── variables.tf            # Variables used in Terraform
├── outputs.tf              # Outputs from Terraform
├── key.json                # Service account key for Terraform (generated or downloaded manually)
├── functions/              # Cloud functions for GCP
│   ├── list_user_video/    # Returns video list from storage
│   ├── temporal_video_url/ # Returns signedurl for specific file

```

- **[`functions/`](functions/README.md)**: Contains cloud functions for GCP. See the [README](functions/README.md) for details on each function.

# 🚀 Terraform + GCP Quick Start

## 1. Install Terraform

**Mac / Linux:**
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

Or download directly from:  
👉 https://developer.hashicorp.com/terraform/downloads

---

## 2. Install Google Cloud SDK

**macOS:**
```bash
brew install --cask google-cloud-sdk
```

Then initialize and authenticate:
```bash
gcloud init
```

---

## 3. Create Service Account and Key

Replace `video-processing-458313` with your actual project ID. If you have not cteated yet:

```bash
gcloud iam service-accounts create terraform

gcloud projects add-iam-policy-binding video-processing-458313 \
  --member="serviceAccount:terraform@video-processing-458313.iam.gserviceaccount.com" \
  --role="roles/editor"
```

Download the key:

```
gcloud iam service-accounts keys create key.json \
  --iam-account=terraform@video-processing-458313.iam.gserviceaccount.com
```

```
export GOOGLE_APPLICATION_CREDENTIALS="$(pwd)/key.json"
```


## 4. Prerequisites and artifacts

### Build docker images and push it to registry

See details in [rsync](..//rsync/README.md)

### Create keys and other dependencies for functions

See details in [functions](functions/README.md)


---

## 5. Terraform Commands

```bash
terraform init       # Initialize working directory
terraform plan       # Show execution plan
terraform apply      # Apply infrastructure changes (by default for dev)
terraform destroy    # Tear down infrastructure
```

---

## 6. Import Existing GCP Resources

If the bucket already exists:

```bash
terraform import google_storage_bucket.frigate-video-archive frigate-video-archive
```

Terraform will now manage that resource without creating it again.

---

## ✅ Done!

You're now ready to manage GCP infrastructure using Terraform 🎉
