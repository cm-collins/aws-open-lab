# Enable IAM billing access via a group

## Outcome

IAM users (including **`lab-admin`**) can open **Billing and Cost Management** and see **Cost and usage** on the console home, because the account allows IAM billing access and **`lab-admin`** is in a group with the right billing policies.

## Prerequisites

- [Create an admin IAM user](create-admin-iam-user.md) — **`lab-admin`** exists
- [Set a billing alert](billing-alert.md) — optional but recommended first
- **Root user** sign-in for the one-time account activation (IAM users cannot turn this on)
- Time: ~15 minutes

## Why this runbook exists

Two separate gates block IAM users from billing:

| Gate | What it is | Who can change it |
| --- | --- | --- |
| **Account setting** | “IAM user and role access to Billing information” | **Root only**, once per account |
| **IAM permissions** | Policies that allow `aws-portal` / Cost Explorer / Budgets APIs | Admin attaches via **group** (best practice) or user |

If **`lab-admin`** has **`AdministratorAccess`** but the home **Cost and usage** widget shows **Access denied**, the account setting is usually still **off**. Turning it on fixes most dashboard errors; the **group** teaches how teams grant billing in production.

**Why a group, not another policy on the user alone?** Same reason as the create-user wizard: permissions by **job function** (Billing, Developers, Admins). You add users to **`lab-billing`** instead of stacking policies on each person.

**Azure parallel:** Like enabling cost management for non–Global Admin users via RBAC roles assigned through a **group**, after the subscription allows it.

---

## Part A — Activate IAM access to billing (root only)

### Do not use the Billing left sidebar for this step

The **Billing and Cost Management** sidebar (with **Bills**, **Budgets**, **Cost Explorer**, and **Billing view** toggles) does **not** include **Account** in the current console. If you only open **Billing → Bills**, you will not find the IAM activation control. That is normal—not a mistake on your side.

The setting lives on the separate **Account** page for your AWS account. Open it using **Method 1** or **Method 2** below (root only).

1. Sign **out** of **`lab-admin`** (and any other IAM user).
2. Sign in as the **root user** (the email and password from account sign-up, plus root MFA). IAM users **cannot** activate this setting.

### Method 1 — Account menu (recommended)

3. From **any** console page (Home, Billing, IAM, etc.), choose your **account label** in the **top navigation bar** (next to the region name).
4. In the dropdown, choose **Account**.

   This is **not** IAM → Account settings. It is the **AWS account** menu entry that opens billing account details.

5. On the **Account** page, scroll to **IAM user and role access to Billing information**.
6. Choose **Edit**.
7. Select **Activate IAM access** (checkbox or toggle, depending on console version).
8. Choose **Update**.

   - **Verify:** The page shows a success message such as **IAM user/role access to billing information is activated**, or the section shows access as **Activated**.

### Method 2 — Direct link (if the menu is hard to find)

Alternatively, while signed in as **root**, open:

[https://console.aws.amazon.com/billing/home#/account](https://console.aws.amazon.com/billing/home#/account)

Then continue at step 5 above (**IAM user and role access to Billing information** → **Edit** → **Activate IAM access** → **Update**).

9. Sign **out** of root when Part A is done. Use root only when a runbook requires it.

---

## Part B — Create a billing group and add `lab-admin`

Activation in Part A **does not** grant billing permissions by itself. You still attach policies (here, via a **group**).

Do Part B signed in as **root** or as an IAM user that can manage IAM (e.g. **`lab-admin`** with **`AdministratorAccess`**).

### Create the group

10. Open **IAM** → **User groups** (left menu under **Access management**).
11. Choose **Create group**.
12. **User group name:** e.g. **`lab-billing`** (1–128 characters; letters, numbers, `+=,.@-_`).

### Attach billing policies

13. In **Attach permissions policies**, use **Search** (same pattern as **IAM → Policies**). Filter or search; do not scroll the full list.

14. Attach **one or both** of these AWS managed policies, depending on what you need:

    | Policy | Type | Choose when |
    | --- | --- | --- |
    | **`AWSBillingReadOnlyAccess`** | AWS managed | **Start here** — view costs, Cost Explorer, and home **Cost and usage** without changing payment methods |
    | **`Billing`** | AWS managed — **job function** | **`lab-admin`** should **create or edit budgets** in the console as IAM (not only view) |

    For this lab after [Set a billing alert](billing-alert.md), **`AWSBillingReadOnlyAccess`** is enough to clear the home widget **Access denied**. Add **`Billing`** if you want the IAM user to manage budgets without relying on **`AdministratorAccess`**.

15. Check the box(es) next to the policy name(s), then continue.

    - **Verify:** The create-group summary lists **`lab-billing`** and the policy names you selected.

16. On **Add users to the group**, select **`lab-admin`**.

17. Choose **Create group**.

    - **Verify:** **User groups** lists **`lab-billing`** with **1** user and the attached policy count.

### Confirm on the user

18. Open **IAM** → **Users** → **`lab-admin`** → **Groups** tab.

    - **Verify:** **`lab-billing`** appears.

19. Open the **Permissions** tab. You should see:

    - **`AdministratorAccess`** (from user creation), and  
    - Policies inherited from **`lab-billing`** (group).

    Effective access is the **union** of user and group policies (still subject to any permissions boundary—you did not set one in Lab 1).

---

## Part C — Verify as `lab-admin`

20. Sign in as **`lab-admin`** (IAM sign-in URL + MFA).
21. Open **Console home** and check the **Cost and usage** widget.

    - **Verify:** Spend summary or Free Tier/credits load instead of **Access denied**.

22. Open **Billing and Cost Management** → **Budgets** (left sidebar under **Budgets and planning**).

    - **Verify:** Your [monthly cost budget](billing-alert.md) is visible if you created one.

    If budgets are **Access denied** but costs work, add the **`Billing`** job function policy to **`lab-billing`** (edit group → **Add permissions**).

## Troubleshooting

| Symptom | Likely cause | What to try |
| --- | --- | --- |
| No **Account** in Billing left menu | Expected in the new billing UI | Use **top bar → Account** or the [direct Account URL](https://console.aws.amazon.com/billing/home#/account) (Part A) |
| No **Activate IAM access** button | Signed in as IAM user | Complete **Part A** as **root** |
| Opened **IAM → Account settings** by mistake | Wrong “Account” | Use the **top navigation account menu → Account**, not IAM account settings |
| Still **Access denied** on home after Part A | Group/policy missing or console delay | Finish Part B; wait a few minutes; hard refresh |
| Cannot create group | IAM permission | Sign in as root or user with `iam:CreateGroup` |
| **`Billing`** policy not found | Search typo | Search **`Billing`**; pick **job function** **`Billing`**, not unrelated names |
| Duplicate access | **`AdministratorAccess`** + group | Expected for this lab; in production use groups with narrower policies instead of admin on every user |

## Teardown

Keep **`lab-billing`** and the account activation. Do not deactivate IAM billing access while you still use IAM users for the account.

## Last verified

- **Date:** 2026-09-23
- **Region:** Global (IAM / billing); console tested with **`lab-admin`**
- **Notes:** IAM activation is **not** under Billing sidebar **Account** (link absent in new billing view); use **top bar → Account** or `#/account` URL. Group **`lab-billing`** with **`AWSBillingReadOnlyAccess`** (+ optional **`Billing`** job function).
