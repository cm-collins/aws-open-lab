# Set a billing alert

## Outcome

You have a **monthly cost budget** that emails you when spend hits AWS’s built-in thresholds (85% and 100% of your limit, plus a forecast alert), so a forgotten lab resource is less likely to surprise you.

## Prerequisites

- [Create an AWS account](create-aws-account.md)
- Sign in as **root** or an IAM user with permission to manage budgets (root is simplest the first time)
- An email address you check (work or personal)
- Time: ~10 minutes
- Cost: Creating a budget is free; you only pay for AWS usage the budget watches

## Which template to pick

AWS now offers **templates** on the create-budget flow. For this lab, use one of these:

| Template | Good for | Default alerts |
| --- | --- | --- |
| **Monthly cost budget** (recommended) | Learning accounts with some planned spend | Actual **85%**, actual **100%**, forecast **100%** of your budget amount |
| **Zero spend budget** | Maximum caution: any billable usage above **$0.01** | Tuned for “something started costing money” |

Pick **Monthly cost budget** unless you want an alert on almost any charge. You can add a second budget later.

## Steps

### Open Budgets

1. Sign in to the [AWS Management Console](https://console.aws.amazon.com/).
2. Search for **Billing and Cost Management** and open it.
3. In the left menu, under **Budgets and planning**, choose **Budgets**.
4. Choose **Create budget**.

   - **Verify:** The breadcrumb shows **Billing and Cost Management → Budgets → Create budget**.

### Optional: IAM access to billing

5. If you plan to use an IAM user for daily work (next runbook), and billing pages are blocked for IAM users: as **root**, open **Billing and Cost Management → Account**, find **IAM user and role access to Billing information**, and choose **Activate**. Skip this if you are still on root for setup only.

### Create the budget (simplified template)

6. Under **Budget setup**, select **Use a template (simplified)**.

   Leave **Customize (advanced)** for later unless you need filters (one service, one tag, etc.).

7. Under **Templates**, select **Monthly cost budget**.

   Description on the console: notifies you if you exceed, or are forecasted to exceed, the budget amount.

8. Fill in **Monthly cost budget - Template**:

   | Field | What to enter |
   | --- | --- |
   | **Budget name** | Something you will recognize, e.g. `lab-monthly-spend` (1–100 characters) |
   | **Enter your budgeted amount ($)** | A monthly cap you are willing to be alerted on. For a tight learning guardrail, **$10** or **$20** is common. A higher number (e.g. **$100**) alerts later; it does not block spend. |
   | **Email recipients** | Your email. Multiple addresses: separate with commas (max **10**). |

   **Scope (read-only on the template):** all AWS services in this account are included.

9. Read **Automatic notification thresholds** on the page. For this template, AWS creates alerts for:

   - Actual spend reaches **85%** of the budget
   - Actual spend reaches **100%** of the budget
   - **Forecasted** spend is expected to reach **100%** of the budget

   You do not need to add thresholds manually when using this template.

10. Choose **Create budget**.

    - **Verify:** You return to the **Budgets** list and see your new budget name with status **OK** or similar (not an error state).

### Confirm email

11. Check the inbox for each address you added. AWS sends subscription messages for budget notifications.
12. Open each message and **confirm** the subscription (link in the email). Until you confirm, alerts may not arrive.

    - **Verify:** Budget detail page lists your email recipients without a “pending confirmation” warning (wording may vary).

## After you finish

- **Last month’s cost** on the form may show **$0.00** on a new account. That is normal until you run billable resources.
- You can open the budget later and switch to **Custom** settings if you need different thresholds or scopes (**Template settings** on the create page links to that path).
- Budgets **notify**; they do **not** shut off services. Teardown in each lab still matters.

## Troubleshooting

| Symptom | Likely cause | What to try |
| --- | --- | --- |
| No alert email | Subscription not confirmed | Search spam; click confirm in AWS email |
| **Budgets** missing or access denied | IAM user without billing/budget permissions | Sign in as root for setup, or attach billing policy to the IAM user |
| Alert never fires but you see charges in **Cost Explorer** | Budget amount set very high | Lower the budget amount or add a **Zero spend budget** as a second budget |
| Only **Customize (advanced)** appears | Console A/B or account type | Use advanced flow: monthly cost budget, same amount and email, add the same three thresholds |
| Forecast alerts feel noisy | Normal on new accounts with little history | Keep the budget; adjust thresholds later under **Edit budget** if needed |

## Automation (CLI lab — planned)

This runbook stays **console-first** so you see thresholds and confirm notification email.

When [Lab 2 — AWS CLI](../../02-aws-cli/) is ready, the same monthly cost budget will be creatable with bash and **`aws budgets create-budget`**, using env-driven settings and a checked-in JSON example. Plan and layout: [docs/planned-aws-cli-lab.md](../../../docs/planned-aws-cli-lab.md).

Until then, use the steps above once in the console.

## Teardown

Keep the budget. Raise or lower the amount as your labs grow. Delete the budget only if you replace it with something better.

## Last verified

- **Date:** 2026-09-23
- **Region:** N/A (billing is global; console tested from **US East (N. Virginia)**)
- **Notes:** Flow uses **Create budget → Use a template (simplified) → Monthly cost budget** with automatic 85% / 100% / forecast thresholds.
