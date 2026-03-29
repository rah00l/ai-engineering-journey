# AI Analyst Reliability Test Scenarios (v0.4.0)


This document captures manual validation scenarios executed
to verify reliability and failure-handling behavior.

## SIMULATE_INVALID_JSON
(Expected: Invalid output failure, no crash)

Enter your question (or type 'exit'):
SIMULATE_INVALID_JSON
{
  "status": "ERROR",
  "error": {
    "status": "FAILURE",
    "reason": "INVALID_OUTPUT",
    "message": "Request terminated safely"
  }
}

## SIMULATE_RATE_LIMIT
(Expected: Classified rate limit failure)

Enter another question:
SIMULATE_RATE_LIMIT
{
  "status": "ERROR",
  "error": {
    "status": "FAILURE",
    "reason": "RATE_LIMIT",
    "message": "Request terminated safely"
  }
}

## SIMULATE_TIMEOUT
(Expected: Terminal failure, no retry loop)

Enter another question:
SIMULATE_TIMEOUT
{
  "status": "ERROR",
  "error": {
    "status": "FAILURE",
    "reason": "TERMINAL",
    "message": "Request terminated safely"
  }
}

## Standard Success Scenario
(Expected: Structured explanation unchanged)

Enter another question:
What does MAPPING ERROR – Payment ID Not Found mean?
{
  "status": "SUCCESS",
  "result": {
    "error": {
      "code": "MAPPING_ERROR",
      "description": "Payment ID Not Found",
      "details": {
        "definition": "This error indicates that the specified Payment ID does not exist in the payment reconciliation system.",
        "possible_causes": [
          "The Payment ID was entered incorrectly.",
          "The Payment ID has not been processed or recorded in the system.",
          "The Payment ID has been deleted or is no longer valid."
        ],
        "recommended_actions": [
          "Verify the Payment ID for accuracy.",
          "Check if the Payment ID has been processed recently.",
          "Consult the payment records or logs for further details."
        ]
      }
    }
  }
}

Enter another question:
What does PARTIALLY RECONCILED mean?
{
  "status": "SUCCESS",
  "result": {
    "definition": "PARTIALLY RECONCILED refers to a state in a payment reconciliation process where some transactions have been matched and verified against the corresponding records, but not all transactions have been accounted for or resolved. This indicates that there are discrepancies or unmatched items that still need to be addressed to achieve full reconciliation.",
    "implications": {
      "status": "Incomplete",
      "next_steps": [
        "Identify unmatched transactions",
        "Investigate discrepancies",
        "Update records as necessary",
        "Complete the reconciliation process"
      ]
    }
  }
}
