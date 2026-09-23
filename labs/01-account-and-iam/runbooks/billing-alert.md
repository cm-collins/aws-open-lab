# Set a billing alert

## Outcome

You receive an alert when estimated charges cross a threshold you choose (so a forgotten resource is less likely to surprise you).

## Prerequisites

- [Create an AWS account](create-aws-account.md)
- Sign in as **root** or an IAM user with billing permissions (root is simplest for this one-time setup)
- Time: ~10 minutes

## Steps

1. Sign in to the AWS Management Console.
2. Open **Billing and Cost Management** (search in the top bar).
3. If prompted, choose **Activate IAM access to Billing** (root only) so IAM users can view billing later—optional for lab 1, useful soon.
4. In the left menu, open **Budgets** (under **Budgets and planning**) or **Billing preferences** / **Alert preferences**, depending on what AWS shows in your console.
5. Create a **budget** or **billing alert**:
   - For a simple start: a **monthly cost budget** with a fixed amount (for example **$5** or **$10** for a learning account).
   - Set an alert at **100%** of that amount (or **80%** if you want early warning).
   - Add your email as the notification target and confirm the subscription email if AWS sends one.

   - **Verify:** The budget or alert appears in the list, and your email shows as subscribed (check spam for the confirmation).

## Troubleshooting

| Symptom | Likely cause | What to try |
| --- | --- | --- |
| No email | Not confirmed | Click the link in AWS’s confirmation message |
| Budgets menu missing | Wrong account or permissions | Sign in as root for initial setup |
| Charges look like $0 forever | New account, no usage yet | That is normal until you create billable resources |

## Teardown

Keep the budget or alert. Update the threshold when your usage grows.

## Last verified

- **Date:** 2026-09-23
- **Region:** N/A (billing is global)
- **Notes:** AWS moves billing UI often; the goal is any working spend notification, not a specific menu name.
