| :warning: WARNING           |
|:----------------------------|
| Import Service is obsolete and superseded by [cWDS](https://github.com/DataBiosphere/terra-workspace-data-service). |

-----


# import_service_terraform
Terraform for import service

Your .tfvars file should contain the following:

**variable**|**description**
-----|-----
`env`                                             | used to generate a lot of defaults
`import_service_google_project_folder_id`    | the folder ID to put the project in, e.g. `"123456789012"`
`billing_account_id`                            | the google billing account to link the project to, e.g. `"XXXXXX-XXXXXX-XXXXXX"`
`terraform_google_project`                      | the google project owning the service account that Terraform runs as. can be empty if running locally
`audience_domain`                                | used as a semi-secret by pub/sub. must match import service environment variable
`rawls_sa_email`                                | email address of the rawls service account in this env
`back_rawls_instance`                           | resource name for the back rawls vm in this env
`orchestration_instances                        | a list of resource names of the orchestration vms in this env
`clusters_to_whitelist`                         | a list of terra k8s clusters to whitelist traffic from. Needed to communicate with back rawls and orch in k8s
`sam_sa_email`                                  | email address of the sam service account in this env
`terra_google_project`                          | google project that terra monolithic services run in (i.e. where rawls and sam SAs live)


Your .tfvars MAY contain the following, if you want to override the defaults during local development:


**variable**|**default**|**description**
-----|-----|------
`import_service_google_project` | `terra-importservice-{var.env}` | The Google project to create
`bucket_suffix` | `{var.env}` | Creates the import service batchUpsert bucket, `import-service-batchupsert-{bucket_suffix}`
`vault_path` | `{var.env}/import-service` | Vault secrets will be published in `secret/dsde/firecloud/{vault_path}`
