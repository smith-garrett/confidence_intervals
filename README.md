# Confidence intervals


## Testing

### Unit tests

Unit tests are run by `lefthook` as a pre-push hook.

### Integration/smoke tests

Integration/smoke tests are run manually using the following shell scripts:

```bash
# Run integration smoke tests
tests/integration/smoke_test.sh && tests/integration/teardown.sh
```
