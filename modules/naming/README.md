# Naming module

Generates the accepted compact naming pattern:

```text
<resource-type>-<region><environment>-<workload-code>-<instance>
```

Set `use_hyphens = false` only for Azure resource types that prohibit separators. Global-name collisions are resolved by incrementing the resource type's two-digit instance and replanning.
