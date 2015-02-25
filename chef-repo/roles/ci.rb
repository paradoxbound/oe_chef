name "ci_server"
description "Role to confiure the CI environment"

run_list(
  "recipe[apt]",
  "recipe[OpenEyes::default]",
  "recipe[OpenEyes::development]",
  "recipe[OpenEyes::jenkins]"
)
