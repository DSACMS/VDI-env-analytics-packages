# **Security Check Instructions for R Packages**

**Purpose:** This guide walks you through checking an R package for security issues before approving it for use.

**Time Required:** 30-40 minutes per package (most of it is waiting for automated checks)

**What You'll Need:**

* Access to the GitHub repository with the security workflows  
* Terminal/Command Line access  
* The security checking scripts (provided)

---

## **🚩 Red Flags to Watch For (Quick Reference)**

Before you start, know these red flags. If you see any, be extra cautious:

| RED FLAG | WHAT IT MEANS | ACTION |
| :---- | :---- | :---- |
| Package not on CRAN | Less trustworthy | Needs explanation from user |
| Package name very similar to popular package | Possible URL hijacking | Investigate carefully |
| No GitHub repository | Can't verify source | Note in report, higher scrutiny |
| Not updated in 2+ years | Possibly abandoned | Check for alternatives |
| User can't explain what it does | They don't understand it | Ask more questions |
| Found on random blog/website | Unknown source | High risk |
| Many dependencies (>50) | Large attack surface | Review dependency list |

**If you see 2+ red flags:** Discuss with a colleague before approving.

---

## Overview: The Complete Process

You'll do **4 main things:**

1. **Find information about the new package**  
2. **Run automated checks on GitHub**  
3. **Run local checks on your computer**  
4. **Fill in the report**

Then you'll have a complete security review to share with your team.

---

## Part 1: Starting With a New Package Request

A user wants to use a new R package. You've never heard of it. Here's how to find the information you need to check it.

### Step 1: Find the Package on CRAN

**What is CRAN?** It's the official repository for R packages.

1. **Go to CRAN:** Open your web browser and go to:

		[`https://cran.r-project.org/web/packages/`](https://cran.r-project.org/web/packages/)

2. **Search for the package:**  
   * You can either:   
     * **Option A:** Scroll down and click "Table of available packages" then press `Ctrl+F`(Windows) or `Cmd+F` (Mac) and search for the package name  
     * **Option B:** Go directly to: [https://cran.r-project.org/web/packages/PACKAGE_NAME/](https://cran.r-project.org/web/packages/PACKAGE_NAME/)  
3. **Example:** For package "aws.s3", go to:  
4. **What if the package isn't on CRAN?**
	[https://cran.r-project.org/web/packages/aws.s3/](https://cran.r-project.org/web/packages/aws.s3/)

* This is a **red flag** 🚩  
  * The package might be:   
    * Only on GitHub (less trustworthy)  
    * Very new (not vetted yet)  
    * Abandoned (removed from CRAN)  
  * **You should still check it**, but mark it as higher risk  
  * Ask the user, such as a contractor: "Where did you find this package?"

### Step 2: Get Package Information

On the CRAN page for the package, you'll see important information. **Write this down:**

**Package Name:** (exact spelling, case matters)

* Example: `aws.s3`

**Version:** (shown at top of page)

* Example: `0.3.21`

**Published Date:** (when it was last updated)

* Example: `2025-10-15`

**Description:** (what the package does)

* Example: "AWS S3 Client Package"

**URL:** (look for GitHub link)

* Example: [https://github.com/cloudyr/aws.s3](https://github.com/cloudyr/aws.s3)  
* This is what you need for the security checks!

**License:** (shown on CRAN page)

* Example: `GPL-2`

### Step 3: Understand What the Package Does

Before you check it, understand its purpose:

1. **Read the description** on the CRAN page  
2. **Look at the README** on GitHub (if available)  
3. **Ask yourself:**  
   * What is this package for?  
   * Does it make sense for our work?  
   * Does it interact with external services? (AWS, databases, APIs, etc.)

**Why this matters:**

* AWS packages WILL reference credentials (that's normal)  
* Database packages might have connection strings (expected)  
* Plotting packages shouldn't need network access (suspicious if they do)

### Step 4: Check if GitHub Repository Exists

Some packages don't have a GitHub repository. Here's how to check:

1. **On the CRAN page**, look for the "URL:" field  
2. **Look for a link** that includes [github.com](http://github.com)  
   * If you see one: Great! Copy that URL.  
   * If you don't see one: The package might not have a GitHub repo

**If no GitHub repository:**

* You can still check the package  
* But some checks (Scorecard, Hipcheck) will be skipped  
* This is a **moderate concern** ⚠️ but not automatic rejection

### Step 5: Check What the User Told You

Look at the user's request. They should have told you:

* **Package name:** (exact name)  
* **Why they need it:** (what they'll use it for)  
* **Where they found it:** (CRAN, GitHub, blog post, etc.)

**Red flags to watch for:**

* ❌ They want a package that's NOT on CRAN  
* ❌ They found it on some random blog  
* ❌ They can't explain what it does  
* ❌ The package name is very similar to a popular package

**Example of a good request:**
```
Package: ggplot2
Purpose: Creating data visualizations  
Found: CRAN (standard tidyverse package)
```

**Example of a suspicious request:**
```
Package: gglot2 (note the typo!)  
Purpose: Plotting
Found: Random GitHub repository
```

### Step 6: Quick Pre-Check (Before Running Full Security Check)

Before spending 30 minutes on a full check, do a 2-minute sanity check:

**Quick Check Checklist:**

- [ ] Package exists on CRAN (or is from a known trusted source)  
- [ ] Package has been updated in the last 2 years  
- [ ] Package name matches what contractor requested (no typos)  
- [ ] Package purpose makes sense for our work  
- [ ] You found a GitHub URL (or confirmed there isn't one)

**If any of these fail**, ask the user for more information before proceeding.

### Step 7: Document Your Starting Point

Before running checks, write down what you know:
```
Package: aws.s3  
Version: 0.3.21  
CRAN: Yes (https://cran.r-project.org/web/packages/aws.s3/)
GitHub: https://github.com/cloudyr/aws.s3
Last Updated: October 2025 (4 months ago) 
Purpose: AWS S3 file storage access
Contractor: John Doe
Use Case: Reading data from S3 buckets
```

This helps you later when writing your review.

---

## Part 2: Running GitHub Actions (Automated Checks)

GitHub Actions will automatically check the package for you. You just need to trigger them.

### Step 1: Add Package to Workflow File

First, you need to tell GitHub Actions which package to check.

1. **Open your repository on GitHub** (in your web browser)  
   * Go to: [https://github.com/YOUR-ORG/YOUR-REPO](https://github.com/YOUR-ORG/YOUR-REPO)  
2. **Navigate to the workflows folder**  
   * Click on `.github` folder  
   * Click on `workflows` folder  
   * You should see files like `scorecard.yml`, `hipcheck.yml`  
3. **For now, just note these files exist** - we'll trigger them manually

### Step 2: Trigger the Scorecard Check

**⚠️ IMPORTANT:** This only works if the package has a GitHub repository. If you didn't find a GitHub URL in Step 1.4, skip to Step 2.3.

1. **Go to the Actions tab** in your repository  
   * Click the "Actions" tab at the top of the page  
2. **Find "OSSF Scorecard Analysis"** in the left sidebar  
   * Click on it  
3. **Click "Run workflow"** button (on the right side)  
   * A dropdown will appear  
4. **Fill in the form:**  
   * **Package name:** Type the package name (e.g., `aws.s3`)  
   * **GitHub repo URL:** Paste the GitHub link you found in Step 0.4   
     * Example: [https://github.com/cloudyr/aws.s3](https://github.com/cloudyr/aws.s3)  
     * Make sure it's the EXACT URL (copy/paste to avoid typos)  
5. **Click "Run workflow"** (green button)  
6. **Wait for it to finish** (~2-3 minutes)  
   * You'll see a yellow dot turn into a green checkmark ✅ or red ❌  
   * Click on the workflow run to see details

**If the package doesn't have a GitHub repository:**

* You'll note this in your report as: "No GitHub repository available"  
* Scorecard and Hipcheck checks will be marked "N/A - No GitHub repo"  
* This is a **concern** but not an automatic rejection  
* Make sure to note this when you make your final decision

<!-- ### **Step 3: Trigger the Trivy Scan**

1. **In the Actions tab**, find "Trivy Vulnerability Scan" in left sidebar  
2. **Click "Run workflow"**  
3. **Fill in:**  
   * **Package name:** Same package (e.g., `aws.s3`)  
4. **Click "Run workflow"**  
5. **Wait for it to finish** (\~3-5 minutes) -->

### Step 3: Trigger the Hipcheck Analysis

**⚠️ IMPORTANT:** This also requires a GitHub repository. If the package doesn't have one, skip this step.

1. **In the Actions tab**, find "Hipcheck Supply Chain Analysis"  
2. **Click "Run workflow"**  
3. **Fill in:**  
   * **Package name:** Same package  
   * **GitHub repo URL:** Same URL as Step 1.2  
4. **Click "Run workflow"**  
5. **Wait for it to finish** (~2-3 minutes)

**If no GitHub repository:**

* Skip this step  
* You'll mark Hipcheck as "N/A - No GitHub repo" in your report

### Step 4: Review GitHub Actions Results

Once all three workflows complete, you need to get the results:

#### For Scorecard:

1. Click on the completed Scorecard workflow  
2. Look for the score (e.g., "7.5/10")  
3. **Write down:**  
   * Overall score: \_\_\_\_\_/10  
   * Code-Review score: \_\_\_\_\_/10  
   * Maintained score: \_\_\_\_\_/10  
   * Token-Permissions score: \_\_\_\_\_/10

<!-- #### **For Trivy:**

1. Click on the completed Trivy workflow  
2. Click on "Trivy Security Scan" job  
3. Look for the summary (usually shows a table)  
4. **Write down:**  
   * CRITICAL vulnerabilities: \_\_\_\_\_  
   * HIGH vulnerabilities: \_\_\_\_\_  
   * MEDIUM vulnerabilities: \_\_\_\_\_ -->

#### **For Hipcheck:**

1. Click on the completed Hipcheck workflow  
2. Look at the summary  
3. **Write down:**  
   * Did it pass? (Yes/No)  
   * Any concerns mentioned? \_\_\_\_\_

**📸 OPTIONAL:** Take screenshots of these results - you can add them to your final report.

---

## Part 3: Running Local Checks

Now you'll run checks on your own computer.

### Step 1: Open Terminal

**Mac:**

* Press `Cmd + Space`  
* Type "Terminal"  
* Press Enter

**Windows:**

* Press `Windows Key + R`  
* Type "cmd"  
* Press Enter

### Step 2: Navigate to the Scripts Folder

In Terminal, type:

`cd path/to/r-security-local-checks`

Replace `path/to/` with where you saved the scripts folder.

**Example:**

`cd ~/Downloads/r-security-local-checks`

Press Enter.

### Step 3: Run the Report Generator

Type this command (replace `aws.s3` with your package name):

`./generate_security_report.sh aws.s3 https://github.com/cloudyr/aws.s3 "Your Name"`

**Example:**

`./generate_security_report.sh aws.s3 https://github.com/cloudyr/aws.s3 "Jane Doe"`

Press Enter.

**What happens:**

* The script downloads the package  
* Checks CRAN status  
* Analyzes dependencies  
* Scans for credentials  
* Creates a markdown report file

**This takes about 3-4 minutes.**

### Step 4: Find Your Report

When it finishes, you'll see:

`Report saved to: security_reports/aws.s3_security_review.md`

This is your report file.

---

## Part 4: Completing the Report

Now you'll fill in the missing information.

### Step 1: Open the Report File

1. **Navigate to the folder** where the scripts are  
2. **Open the `security_reports` folder**  
3. **Find the file** named `PACKAGE_security_review.md`  
4. **Open it** with any text editor (TextEdit on Mac, Notepad on Windows, or VS Code)

### Step 2: Search for "[TODO]"

Press `Ctrl+F` (Windows) or `Cmd+F` (Mac) and search for:

	`TODO`

This will highlight all the spots you need to complete.

### Step 3: Fill In Each Section

Work through each `[TODO]` section. Here's what to put in each:

#### At the top:

	`## [TODO: ✅ APPROVED FOR USE / ❌ DISAPPROVED FOR USE]`

**Change to:**

- `## ✅ APPROVED FOR USE` if all checks passed  
- `## ❌ DISAPPROVED FOR USE` if critical issues found

#### GitHub Actions sections:

Use the numbers you wrote down in Step 2.5:

**Scorecard:**
If this wasn’t automatically filled in, fill in.

- **Score:** `[TODO from GitHub Actions]`

Change to:

	`- **Score:** 7.5/10`

(Use your actual score)

**Status:**

* If score ≥ 7.0: Change to `✅ PASS`  
* If score < 7.0: Change to `⚠️ REVIEW` or `❌ FAIL`

**Key Findings:** Copy from GitHub Actions results

<!-- **Trivy:**

`- **CRITICAL:** [TODO: Check GitHub Actions tab]`

Change to:

	`- **CRITICAL:** 0`

(Use your actual numbers)

**Status:**

* If 0 CRITICAL and ≤2 HIGH: `✅ PASS`  
* If any CRITICAL or \>2 HIGH: `❌ FAIL` -->

**Hipcheck:**
- **Status:** [TODO: ✅ PASS / ❌ FAIL]

Use what you saw in GitHub Actions.

#### Local Checks:

Most of these are already filled in\! Just verify they look correct.

**CRAN Status:**

* **Status:**  
  * On CRAN \+ updated \<1 year ago: `✅ PASS`  
  * On CRAN but old: `⚠️ ACCEPTABLE`  
  * Not on CRAN: `❌ FAIL`

**Dependencies:**

* **Status:**  
  * \<30 total: `✅ PASS`  
  * 30-50 total: `⚠️ ACCEPTABLE`  
  * 50 total: `❌ FAIL`

**Installation Hooks:**

* **Status:**  
  * None or clean: `✅ PASS`  
  * Suspicious: `❌ FAIL`

**License:**

* **Type:**  
  * MIT, BSD, Apache: `Permissive`  
  * GPL: `Copyleft`  
  * Other: `Other`  
* **Status:**  
  * Permissive: `✅ GREAT`  
  * Copyleft: `⚠️ ACCEPTABLE`  
  * Incompatible: `❌ NO`

**Credentials:** Look at the file `local_results/PACKAGE_credentials.txt`:

* If empty or just variable names: `✅ PASS`  
* If actual secrets found: `❌ FAIL`

#### **Important Note section:**

If checking an AWS package (like `aws.s3`):

`## Important Note: Credential References Expected`

`The credential scanner detected references to AWS credentials. This is completely expected and normal for an AWS SDK package.`

`**What was found:**`  
``- References to `AWS_ACCESS_KEY_ID` (variable name)``  
``- References to `AWS_SECRET_ACCESS_KEY` (variable name)``

`**What was NOT found:**`  
`- No actual hardcoded AWS access keys`

`**Verdict:** These are all false positives.`

For other packages, explain anything unusual about the results.

#### Overall Assessment:

Fill in the status column of the table based on what you determined above.

Calculate overall score:

* Count how many checks got ✅ PASS  
* If ≥6 out of 8: Score ≥ 85 (APPROVE)  
* If 5-6 out of 8: Score 70-84 (REVIEW)  
* If \<5 out of 8: Score \<70 (REJECT)

#### Decision section:

`## Decision: [TODO: ✅ APPROVED / ❌ REJECTED]`

`**Reasoning:**`  
`1. [Explain each major check result]`  
`2. [Note any concerns]`  
`3. [State why you approve or reject]`

`**Recommendation:** [Your final recommendation]`

### Step 4: Remove Brackets

After filling everything in, search for `[TODO:` one more time to make sure you got everything.

Remove any remaining `[TODO:` text and brackets `]`.

### Step 5: Save the File

Save your completed report.

---

## Part 5: Posting Your Review

### Step 1: Copy the Report

1. Open your completed report file  
2. Select all text (`Ctrl+A` or `Cmd+A`)  
3. Copy (`Ctrl+C` or `Cmd+C`)

### Step 2: Post to GitHub Issue

1. **Go to the GitHub issue** where the contractor requested this package  
2. **Scroll to the comment box** at the bottom  
3. **Paste your report** (`Ctrl+V` or `Cmd+V`)  
4. **Preview** (click "Preview" tab) to make sure it looks good  
5. **Click "Comment"**

Done! The user will now see your security review.

---

## Quick Reference: Decision Rules

Use these to quickly decide PASS/FAIL for each check:

| Check | PASS if... | FAIL if... |
| ----- | ----- | ----- |
| Scorecard | ≥ 7.0/10 | < 5.0/10 |
| Trivy | 0 CRITICAL, ≤2 HIGH | Any CRITICAL or >2 HIGH |
| Hipcheck | No issues | Supply chain concerns |
| CRAN | On CRAN, updated <1yr | Not on CRAN |
| Dependencies | <30 total | >50 total |
| Hooks | None or clean | Malicious code |
| License | MIT/BSD/Apache | Incompatible |
| Credentials | None or false positives | Real secrets found |

**Overall Decision:**

* **APPROVE:** ≥6 out of 8 checks pass  
* **REVIEW:** 5-6 out of 8 checks pass  
* **REJECT:** <5 out of 8 checks pass

---

## Common Questions

### Q: What if GitHub Actions fails to run?

**A:** Check that:

1. You entered the package name correctly (exact spelling, case-sensitive)  
2. You provided a valid GitHub URL  
3. The repository is public (workflows can't access private repos)

If still failing, ask for help.

### Q: What if the report script says "command not found"?

**A:** Make sure you ran this first:

	`chmod +x generate_security_report.sh`

Then try again.

### Q: What if I'm not sure if something is a PASS or FAIL?

**A:** When in doubt:

* Mark it as `⚠️ REVIEW`  
* Add a note explaining your uncertainty  
* Ask a colleague to review

### Q: Can I edit the report after posting to GitHub?

**A:** Yes! Click the "..." menu on your comment and select "Edit".

### Q: What if credential scan finds something suspicious?

**A:**

1. Open the file: `local_results/PACKAGE_credentials.txt`  
2. Look at each finding  
3. Determine if it's:   
   * A variable name (like `AWS_ACCESS_KEY_ID`) → False positive, OK  
   * An actual key (like `AKIAI44QH8DHBEXAMPLE`) → Real secret, REJECT

### Q: How do I know if dependencies are too many?

**A:**

* <30: Good (PASS)  
* 30-50: Moderate (ACCEPTABLE for complex packages)  
* 50: High risk (FAIL unless there's a good reason)

---

## Troubleshooting

### Issue: "scorecard: command not found"

The report will still generate, but the scorecard section will say \[TODO\]. Just use the results from GitHub Actions instead.

### Issue: "R: command not found"

You need to install R first:

1. Go to [https://cran.r-project.org/](https://cran.r-project.org/)  
2. Download R for your operating system  
3. Install it  
4. Try again

### Issue: Script says "local\_package\_check.R not found"

Make sure you're in the correct folder:

`cd path/to/r-security-local-checks`  
`ls`

You should see `generate_security_report.sh` in the list.

### Issue: GitHub Actions shows "Repository not found"

The package might not have a GitHub repository. That's OK - skip the GitHub-specific checks and note this in your review.

### Issue: Package not found on CRAN

**This is a bigger problem.** Ask the contractor:

1. **"Where did you find this package?"**  
   * If it's only on GitHub → Higher risk, needs extra scrutiny  
   * If it's on Bioconductor → Different repository, that's OK (go to [bioconductor.org](http://bioconductor.org))  
   * If it's from a random source → **RED FLAG** 🚩  
2. **"Why do you need this specific package?"**  
   * Maybe there's a similar package on CRAN you can use instead  
3. **"Is this package still maintained?"**  
   * Check the GitHub repo for recent commits  
   * If no activity in 2+ years → Likely abandoned

**Decision for non-CRAN packages:**

* Can still be approved IF:   
  * It's from a trusted source (like a university or established organization)  
  * It's actively maintained (recent commits)  
  * All other security checks pass  
* But it's automatically higher risk than CRAN packages

### Issue: User gave me a package name with a typo

**Example:** They wrote "gglot2" instead of "ggplot2"

**This could be a malicious package!**

**What to do:**

1. Search CRAN for the exact name they gave you  
2. If it exists and looks suspicious, **REJECT IT**  
3. If it doesn't exist, ask the user: "Did you mean \[correct name\]?"  
4. Check if the correct package name exists on CRAN

**Red flags for URL hijacking or typosquatting:**

* Package name is 1 letter different from popular package  
* Package was recently published (created to look like the real one)  
* Package description mentions the popular package  
* Very few downloads

### Issue: Package seems shady but I'm not sure

**Trust your instincts!** If something feels wrong, it probably is.

**Ask for help from a colleague or:**

1. Mark it as "REVIEW REQUIRED" instead of approving  
2. In your report, explain your concerns  
3. Ask the contractor for more information  
4. Delay approval until you're confident

**Better to be cautious than approve something risky.**

### Issue: User is in a hurry and pushing for quick approval

**Security checks are not negotiable.**

Response: "I understand you need this quickly, but security checks take 30-40 minutes minimum. I'll prioritize your request and get back to you by [give realistic timeframe]."

**Do not skip steps to save time.**

---

## Example: Complete Walkthrough

Let's check the package `ggplot2`:

### Step 1: GitHub Actions

1. Go to Actions tab  
2. Run Scorecard with:   
   * Package: `ggplot2`  
   * URL: [https://github.com/tidyverse/ggplot2](https://github.com/tidyverse/ggplot2)  
3. Run Trivy with:   
   * Package: `ggplot2`  
4. Run Hipcheck with:   
   * Package: `ggplot2`  
   * URL: [https://github.com/tidyverse/ggplot2](https://github.com/tidyverse/ggplot2)  
5. Wait for all three to finish  
6. Write down results:   
   * Scorecard: 8.5/10 ✅  
   * Trivy: 0 CRITICAL, 0 HIGH ✅  
   * Hipcheck: PASS ✅

### Step 2: Local Checks

In Terminal:

```
cd ~/Downloads/r-security-local-checks
./generate_security_report.sh ggplot2 https://github.com/tidyverse/ggplot2 "Jane Doe"
```

Wait 3-4 minutes.

### Step 3: Fill In Report

1. Open: `security_reports/ggplot2_security_review.md`  
2. Change first `[TODO` to: `## ✅ APPROVED FOR USE`  
3. Fill in Scorecard score: `8.5/10`  
4. Fill in Trivy: CRITICAL: 0, HIGH: 0  
5. Fill in Hipcheck: `✅ PASS`  
6. Verify local checks look good  
7. Fill in decision: `✅ APPROVED`  
8. Save file

### Step 4: Post

1. Copy entire file  
2. Go to GitHub issue  
3. Paste in comment box  
4. Click Comment

Done! ✅

---

## Getting Help

If you get stuck:

1. **Check this guide** - search for your issue  
2. **Check the error message** - often tells you what's wrong  
3. **Ask a colleague** - show them the error  
4. **Contact:** *Your team contact info*

---

## **Summary Checklist**

For each package review, complete these steps:

**Part 1: New Package Research**

- [ ] Verify package exists on CRAN (or document why it doesn't)  
- [ ] Write down package name, version, and last update date  
- [ ] Find GitHub repository URL (or note that it doesn't exist)  
- [ ] Understand what the package does  
- [ ] Verify package name spelling (watch for typosquatting)  
- [ ] Review contractor's request for red flags

**Part 2: GitHub Actions**

- [ ] Trigger Scorecard on GitHub Actions (if GitHub repo exists)  
- [ ] Trigger Trivy on GitHub Actions  
- [ ] Trigger Hipcheck on GitHub Actions (if GitHub repo exists)  
- [ ] Wait for all workflows to complete  
- [ ] Write down results from GitHub Actions

**Part 3: Local Checks**

- [ ] Run `generate_security_report.sh` locally  
- [ ] Verify script completed successfully

**Part 4: Complete Report**

- [ ] Open the generated markdown file  
- [ ] Fill in all `[TODO` sections with GitHub Actions results  
- [ ] Review all auto-filled sections for accuracy  
- [ ] Make APPROVE/REJECT decision based on criteria

**Part 5: Post Results**

- [ ] Copy completed report  
- [ ] Post to GitHub issue as comment  
- [ ] Respond to contractor with decision  
- [ ] Add package to approved/rejected list

**Time:** ~40-50 minutes total per package, this includes research time

---

**You're ready!** Follow these steps for each package that needs review.