#Author: Nicholas Gulrajani, July 2024 


# Azure Storage Account Tagging Policy with OPA

This project demonstrates how to use Open Policy Agent (OPA) to enforce tagging policies for Azure Storage Accounts in Terraform configurations.

## Files

- `print_storage_account_tags.rego`: The main OPA policy file
- `pass_input.json`: A sample Terraform plan JSON with compliant resources
- `fail_input.json`: A sample Terraform plan JSON with non-compliant resources

## Main Rego Code Functionality

The `print_storage_account_tags.rego` file contains the OPA policy for enforcing tagging on Azure Storage Accounts. Here's a breakdown of its functionality:

1. It defines the resource type (Azure Storage Account) and mandatory tags (environment, project, owner).
2. It includes helper functions to check for missing tags.
3. The `deny` rule identifies resources missing required tags and generates error messages.
4. The `compliant_resources` rule identifies resources with all required tags.
5. The `summary` rule provides an overview of compliance across all resources.

## JSON Files

1. `pass_input.json`: Contains a Terraform plan where all Azure Storage Account resources have the required tags. Used to test the "passing" scenario.

2. `fail_input.json`: Contains a Terraform plan where some or all Azure Storage Account resources are missing required tags. Used to test the "failing" scenario.

## Usage

To evaluate the policy against the sample inputs, use the following commands:

1. For the passing scenario:


opa eval --data print_storage_account_tags.rego --input pass_input.json "data.terraform.analysis.summary"



This command will show a summary of compliant resources.


opa eval --data print_storage_account_tags.rego --input pass_input.json "data.terraform.analysis.summary"


OUTPUT


{
  "result": [
    {
      "expressions": [
        {
          "value": {
            "compliant_count": 2,
            "compliant_resources": [
              "another_storage",
              "example_storage"
            ],
            "non_compliant_count": 0,
            "total_resources": 2
          },
          "text": "data.terraform.analysis.summary",
          "location": {
            "row": 1,
            "col": 1
          }
        }
      ]
    }
  ]
}

DESCRIPTION

This output is the result of evaluating the OPA policy against a Terraform plan.

 Let's break down what this means:
 
  1. "compliant_count":
  
   2 - This indicates that 2 resources in the Terraform plan are compliant with the tagging policy.  
   
   "compliant_resources": ["another_storage", "example_storage"] - This is an array listing the names of the resources that are compliant.  
   
   - In this case, two Azure Storage Account resources named "another_storage" and "example_storage" have all the required tags.  
   
   3. "non_compliant_count": 0 - This shows that there are no resources that violate the tagging policy.  
   
   4. "total_resources": 2 - This is the total number of Azure Storage Account resources found in the Terraform plan.
   
   5. "text": "data.terraform.analysis.summary"
   - This indicates that the output is from the "summary" rule in the OPA policy.

   6. "location": {"row": 1, "col": 1}
   - 
   This refers to the location in the OPA policy file where the summary rule is defined.

In summary, this output tells us that:

- The Terraform plan contains 2 Azure Storage Account resources.
- Both resources ("another_storage" and "example_storage") have all the required tags as 
  specified in the OPA policy.

- There are no resources violating the tagging policy.

This result suggests that the Terraform configuration is fully compliant with the defined tagging policy for Azure Storage Accounts. 

It's a positive outcome, indicating that all resources have the necessary tags for proper management and governance.


2. For the failing scenario:


opa eval --data print_storage_account_tags.rego --input fail_input.json "data.terraform.analysis.deny"

OUTPUT

{
  "result": [
    {
      "expressions": [
        {
          "value": [
            "Resource 'another_storage' of type 'azurerm_storage_account' is missing mandatory tags: owner, project",
            "Resource 'example_storage' of type 'azurerm_storage_account' is missing mandatory tags: owner"
          ],
          "text": "data.terraform.analysis.deny",
          "location": {
            "row": 1,
            "col": 1
          }
        }
      ]
    }
  ]
}

DESCRIPTION 

This output represents the result of evaluating the OPA policy against a Terraform plan that contains non-compliant resources. Let's break it down:

The output is an array of denial messages, indicating that some resources do not meet the tagging requirements.

There are two denial messages, each corresponding to a non-compliant Azure Storage Account resource:
a. First message:

Resource name: 'another_storage'
Resource type: 'azurerm_storage_account'
Missing tags: 'owner' and 'project'

b. Second message:

Resource name: 'example_storage'
Resource type: 'azurerm_storage_account'
Missing tag: 'owner'


"text": "data.terraform.analysis.deny" indicates that this output is from the "deny" rule in the OPA policy.
The "location" field shows where in the policy file the deny rule is defined.

In summary, this output tells us:

The Terraform plan contains at least two Azure Storage Account resources.
Neither of these resources is fully compliant with the tagging policy.
'another_storage' is missing both the 'owner' and 'project' tags.
'example_storage' is missing the 'owner' tag.

This result suggests that the Terraform configuration needs to be updated to include the missing tags on these resources before it can be considered compliant with the defined tagging policy.

 It provides clear guidance on which resources need attention and which specific tags need to be added to each resource. CopyRetry




This command will show denial messages for non-compliant resources.

## Expected Output

1. For the passing scenario, you should see a summary indicating all resources are compliant.

2. For the failing scenario, you should see messages detailing which resources are missing which tags.

## Customization

You can modify the `mandatory_tags` in the Rego file to change the required tags for your organization's needs. You can also extend the policy to cover additional Azure resource types by modifying the `resource_types` array.

## Integration

This policy can be integrated into your CI/CD pipeline to automatically check Terraform plans for tag compliance before applying changes to your Azure infrastructure.
