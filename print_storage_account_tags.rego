# Author: Nicholas Gulrajani  
# Description: OPA policy for enforcing tagging on Azure Storage Accounts


package terraform.analysis

import input as tfplan

########################
# Parameters for Policy
########################
resource_types := ["azurerm_storage_account"]
mandatory_tags := ["environment", "project", "owner"]

#########
# Functions
#########
array_contains(arr, elem) {
    arr[_] = elem
}

missing_tags(resource_tags, required_tags) := missing {
    existing_tags := {tag | resource_tags[tag]}
    required_set := {tag | tag := required_tags[_]}
    missing := required_set - existing_tags
}

#########
# Policy
#########
deny[msg] {
    res := tfplan.resource_changes[_]
    res.type == resource_types[_]
    res.change.actions[_] != "delete"
    
    resource_tags := object.get(res.change.after, "tags", {})
    missing := missing_tags(resource_tags, mandatory_tags)
    count(missing) > 0
    
    msg := sprintf("Resource '%v' of type '%v' is missing mandatory tags: %v", [res.name, res.type, concat(", ", missing)])
}

# Rule to identify compliant resources
compliant_resources[res.name] {
    res := tfplan.resource_changes[_]
    res.type == resource_types[_]
    res.change.actions[_] != "delete"
    
    resource_tags := object.get(res.change.after, "tags", {})
    missing := missing_tags(resource_tags, mandatory_tags)
    count(missing) == 0
}

# Rule to summarize the results
summary = {
    "total_resources": count(resource_changes),
    "compliant_resources": compliant_resources,
    "compliant_count": count(compliant_resources),
    "non_compliant_count": count(resource_changes) - count(compliant_resources)
}

# Helper to get all relevant resource changes
resource_changes[res.name] {
    res := tfplan.resource_changes[_]
    res.type == resource_types[_]
    res.change.actions[_] != "delete"
}
