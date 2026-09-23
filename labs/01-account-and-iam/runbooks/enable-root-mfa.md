# Enable MFA on the root user

## Outcome

Signing in as the **root user** requires a second factor (MFA device).

## Prerequisites

- [Create an AWS account](create-aws-account.md) — you can sign in as root
- An authenticator app (recommended) or SMS-capable phone
- Time: ~5 minutes

## Steps

1. Sign in to the AWS Management Console as the **root user**.
2. Open **IAM** (search in the top bar), or go to **Account** → **Security credentials** for the root user (AWS sometimes routes root MFA from the account menu → **Security credentials**).
3. Find **Multi-factor authentication (MFA)** for the root user.
4. Choose **Assign MFA device** (or **Activate MFA**).
5. Select **Authenticator app** if offered. Scan the QR code with your app, enter two consecutive codes, and finish activation.

   - **Verify:** Sign out, sign in as root again—you must enter MFA after the password.

## Troubleshooting

| Symptom | Likely cause | What to try |
| --- | --- | --- |
| Codes rejected | Clock skew on phone | Enable automatic time on the device; wait for the next code |
| Lost access to MFA | Device lost or app reset | Use root recovery via AWS support; prevention is why you store recovery codes if offered |
| Cannot find MFA for root | Looking at an IAM user by mistake | Use the account menu / root **Security credentials**, not only IAM → Users |

## Teardown

Keep MFA enabled on root. Do not remove it.

## Last verified

- **Date:** 2026-09-23
- **Region:** N/A
- **Notes:** Prefer an authenticator app over SMS where possible.
