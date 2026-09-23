# Lab 1 — Account and IAM

**Goal.** Have an AWS account you can learn in, with MFA on the root user and a separate administrator you actually use.

**You need.** An email address that is not already an AWS root user, a phone for MFA, and a password manager.

**Region.** Any. This lab does not create regional resources. `eu-west-1` (Ireland) or the region closest to you is a fine default later.

## Steps

1. Create an account at [aws.amazon.com](https://aws.amazon.com/). The email and password you use here belong to the **root user**. Write them down in a password manager.
2. Sign in as root. Turn on an MFA device for root. Prefer an authenticator app over SMS.
3. Open the Billing console and enable a billing alarm, or a Free Tier usage alert, so a forgotten instance does not surprise you.
4. In IAM, create a user for yourself. Attach the AWS managed policy `AdministratorAccess` for this lab account only. This account is for learning, not for production.
5. Turn on MFA for that user too.
6. Sign out of root. Sign back in as the IAM user. Do the rest of your learning as that user.

## Check

- Root has MFA.
- You can sign in as the IAM user.
- You are not using the root user for the next lab.

## Clean up

Nothing to delete. Keep the account. Do not delete the IAM user.

## What it cost

Account creation is free. You still need a card on the account. No running resources means no compute charge.

## Write back

When you finish, add a short note here or in a pull request: which MFA method you used, and anything in the sign-up flow that has changed.
