##################################################
# Where validation lives
##################################################

# Nothing here on purpose. `check {}` blocks only emit WARNINGS, and every
# failure this module can detect should stop a plan rather than scroll past:
# each one otherwise costs a 30-45 minute create to discover.
#
#   Single-variable rules   validation {} blocks in variables.tf — types,
#                           enums, ranges, required fields.
#
#   Cross-variable rules    locals.tf builds one error list per category,
#                           aggregated into local.validation_errors and
#                           enforced by the precondition in main.tf. These
#                           cannot live in a variable block because they span
#                           several variables and, for existence checks, live
#                           data.
#
# To add a rule: build the offending data as a list in locals.tf (empty means
# valid), concat it into local.validation_errors, and cover it with a failing
# case in tests/validation.tftest.hcl.
