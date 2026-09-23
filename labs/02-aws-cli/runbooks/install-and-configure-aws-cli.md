# Install and configure the AWS CLI

## Outcome

On your Linux machine, **AWS CLI v2** is installed, profile **`lab-admin`** points at your IAM user’s access keys, and **`aws sts get-caller-identity`** returns your account and **`lab-admin`** ARN.

## Prerequisites

- [Lab 1 complete](../../01-account-and-iam/README.md#final-check) — especially IAM user **`lab-admin`** (not root for daily work)
- Terminal on Linux (this lab uses the [official AWS CLI v2 bundle](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html))

**Alternative:** Reopen this repo in the [dev container](../../../.devcontainer/README.md) — **AWS CLI v2**, **gh**, **jq**, **uv**, and other lab CLIs are preinstalled. Mount host **`~/.aws`**, then complete **Part C** (profile **`lab-admin`**) inside the container or on the host.
- Time: ~20 minutes
- Cost: Free (CLI is local; AWS charges only if you call paid services)

## AWS skills in this repo

This project includes **24 AWS Agent Toolkit skills** under [`.cursor/skills/`](../../../.cursor/skills/) (see [`.cursor/skills/README.md`](../../../.cursor/skills/README.md)). Cursor loads them from the repo when you work in this clone.

If you updated skills globally with `aws configure agent-toolkit`, refresh the repo copy:

```bash
./scripts/sync-agent-toolkit-skills-to-repo.sh
```

That step is optional for CLI install; it keeps contributors aligned on the same skill files.

## AWS MCP in this repo

Cursor can use the **AWS MCP server** from [`.cursor/mcp.json`](../../../.cursor/mcp.json) when this repo is open.

1. Install **[uv](https://docs.astral.sh/uv/)** so **`uvx`** works in your shell.
2. Complete **Part C** below (`AWS_PROFILE=lab-admin`) so MCP calls have credentials.
3. Reload the Cursor window if **`aws-mcp`** does not appear under MCP tools.

See [`.cursor/skills/README.md`](../../../.cursor/skills/README.md#aws-mcp-server-project).

## After this runbook

Run [Verify AWS CLI setup](verify-aws-cli-setup.md). Optional: [Lab 1 budget scripts](../../01-account-and-iam/scripts/README.md).

## Azure parallel

| Azure | AWS (this runbook) |
| --- | --- |
| `az login` (browser) | Access keys + `aws configure` (common for CLI labs) |
| `az account show` | `aws sts get-caller-identity` |
| `az configure` / named subscriptions | `aws configure --profile lab-admin` and `AWS_PROFILE` |

Console MFA does not apply to each CLI call when you use **access keys** for an IAM user. Protect keys like passwords; rotate or delete unused keys.

---

## Part A — Install AWS CLI v2 (Linux x86_64)

1. Check whether the CLI is already installed:

   ```bash
   aws --version
   ```

   If you see **`aws-cli/2.`**, skip to Part B.

2. Install dependencies and download the official installer:

   ```bash
   sudo apt-get update
   sudo apt-get install -y unzip curl
   curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
   unzip -q /tmp/awscliv2.zip -d /tmp
   ```

3. Install (system-wide):

   ```bash
   sudo /tmp/aws/install
   ```

   User-local install (no `sudo`):  
   `/tmp/aws/install -i "$HOME/.local/aws-cli" -b "$HOME/.local/bin"`  
   then ensure `"$HOME/.local/bin"` is on your `PATH`.

4. Confirm:

   ```bash
   aws --version
   ```

   - **Verify:** Output starts with **`aws-cli/2.`**

---

## Part B — Create an access key for `lab-admin` (console)

Do **not** create access keys for the **root** user. Use **`lab-admin`**.

1. Sign in to the AWS console as **`lab-admin`** (IAM sign-in URL + MFA).
2. Open **IAM** → **Users** → **`lab-admin`** → **Security credentials**.
3. Under **Access keys**, choose **Create access key**.

   - **Verify:** Breadcrumb shows **IAM → Users → lab-admin → Create access key** and the wizard lists three steps on the left.

### Step 1 — Access key best practices & alternatives

4. **Use case:** select **Command Line Interface (CLI)**.

   Description on the console: you plan to use this access key so the **AWS CLI** can access your account.

5. Read the **Alternatives recommended** notice (for example **`aws login`** with AWS CLI v2, or **CloudShell** in the browser). Those are good long-term options. **This lab** uses a named profile with access keys on your **`dev`** machine so the steps stay explicit and work everywhere the runbook is followed.

6. Check **I understand the above recommendation and want to proceed to create an access key**.

7. Choose **Next**.

   - **Verify:** Step **2 — Set description tag** is active.

### Step 2 — Set description tag (optional)

8. **Description tag value:** optional but useful for rotation later, e.g. **`aws-open-lab dev CLI`** (max **256** characters; letters, numbers, spaces, and `_.:/=+-@`).

9. Choose **Create access key**.

   - **Verify:** The wizard advances to **Step 3 — Retrieve access keys**.

### Step 3 — Retrieve access keys

10. Copy **Access key ID** and **Secret access key** into your password manager, or use **Download .csv file** and import securely.

    AWS shows this secret **only once** on this screen.

11. Choose **Done** (or return to **Security credentials**).

    - **Verify:** **Access keys** lists **1** active key (or one more than before). The description tag appears if you set one.

**Do not** commit keys, `.csv` files, paste them in GitHub, or store them in this repo.

---

## Part C — Configure profile `lab-admin`

12. In your terminal:

   ```bash
   aws configure --profile lab-admin
   ```

13. Enter when prompted:

   | Prompt | Value |
   | --- | --- |
   | AWS Access Key ID | From Part B — starts with **`AKIA`** (20 characters). **Not** your IAM user name (`lab-admin`). |
   | AWS Secret Access Key | From Part B — long secret string (40 characters). Copy the full value with no extra spaces. |
   | Default region name | Your home region, e.g. **`us-east-2`** (Ohio) |
   | Default output format | **`json`** |

14. Files created (should already be gitignored in this repo if you work inside a clone):

   - `~/.aws/credentials` — secrets  
   - `~/.aws/config` — region and profile metadata  

15. Use the profile for every Lab 2 command:

    ```bash
    export AWS_PROFILE=lab-admin
    ```

    Add that line to your shell profile if you want it in every new terminal (optional).

    - **Verify:** `echo "$AWS_PROFILE"` prints **`lab-admin`**.

---

## Part D — Prove identity

16. Run:

    ```bash
    aws sts get-caller-identity
    ```

    - **Verify:** JSON includes:
      - **`"Arn"`** ending with `:user/lab-admin`  
      - **`"Account"`** — your 12-digit account id  
      - **`"UserId"`** — IAM user id  

17. Optional sanity check (region from config):

    ```bash
    aws configure get region --profile lab-admin
    ```

    - **Verify:** Matches the region you set (e.g. **`us-east-2`**).

---

## Troubleshooting

| Symptom | Likely cause | What to try |
| --- | --- | --- |
| `aws: command not found` | Install not on `PATH` | Re-run Part A; check `~/.local/bin` |
| `Unable to locate credentials` | Profile not set | `export AWS_PROFILE=lab-admin` or pass `--profile lab-admin` |
| `InvalidClientTokenId` | Wrong key or deleted key | Create a new access key; re-run `aws configure --profile lab-admin` |
| `IncompleteSignature` | Access key ID and secret mismatched or mangled | Re-run `aws configure --profile lab-admin`. Access key must be **`AKIA…`**, not **`lab-admin`**. Re-copy secret from a new key if needed (no line breaks). |
| Command ignores `lab-admin` profile | `AWS_PROFILE` not set | Use `export AWS_PROFILE=lab-admin` or add `--profile lab-admin` to every command |
| `AccessDenied` on later commands | IAM policy | Confirm **`lab-admin`** still has needed policies (Lab 1) |
| Accidentally created root key | Root key on disk | Delete root access key in console; never use root for CLI |
| **Next** disabled on Step 1 | Confirmation unchecked | Check **I understand… proceed to create an access key** |
| Wrong use case selected | Local code vs CLI | Go **Previous** and pick **Command Line Interface (CLI)** |

## Teardown

Keep the CLI installed. To revoke CLI access only: IAM → **`lab-admin`** → **Security credentials** → deactivate/delete the access key. Remove or update `~/.aws/credentials` for profile **`lab-admin`**.

## Last verified

- **Date:** 2026-09-23
- **Region:** **`us-east-2`** in `~/.aws/config`
- **Notes:** Access key wizard (CLI use case + confirmation); `export AWS_PROFILE=lab-admin`; `aws sts get-caller-identity` returns `:user/lab-admin`. Access key id must be **`AKIA…`**, not the IAM user name.
