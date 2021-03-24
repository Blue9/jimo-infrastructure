# jimo-infrastructure

## Install

1. Install terraform: `brew install terraform`
1. [1 time] Go to [Create a new service key](https://console.cloud.google.com/apis/credentials/serviceaccountkey),
   generate the key, and save it in the `main/` folder. If the name is not creds.json then update the `main.tf` file to 
   the correct file name.
1. [1 time] Run `terraform init` to pull in the Google Cloud provider plugin.
1. Whenever you make a change run `terraform plan` to confirm the template builds.
1. To deploy run `terraform apply`.