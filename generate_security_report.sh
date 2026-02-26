#!/bin/bash
# generate_security_report.sh
# Generates a markdown report summarizing security checks for an R package
# Combines results from check_package.sh and local_package_check.R

PACKAGE=$1
REPO_URL=$2
REVIEWER_NAME=${3:-"[REVIEWER_NAME]"}

if [ -z "$PACKAGE" ]; then
    cat << 'EOF'
Usage: ./generate_security_report.sh <package_name> [github_repo_url] [reviewer_name]

Examples:
  ./generate_security_report.sh aws.s3 https://github.com/cloudyr/aws.s3 "Alice Smith"
  ./generate_security_report.sh usethis https://github.com/r-lib/usethis "John Doe"

This script:
  1. Runs all security checks (Scorecard, local R checks, credential scan)
  2. Generates a markdown report summarizing the findings
  3. Saves the report as security_reports/<package_name>_security_report.md

You can then:
    - Copy/paste the markdown into GitHub issues
    - Edit the [TODO] sections manually
    - Add your own comments and recommendations
    - Add screenshots where indicated
EOF
    exit 1
fi

# Create output directory
mkdir -p security_reports
mkdir -p local_results

REPORT_FILE="security_reports/${PACKAGE}_security_report.md"
REVIEW_DATE=$(date +"%Y-%m-%d")

echo "=════════════════════════════════════════════════════════════════════"
echo " GENERATING SECURITY REPORT: $PACKAGE"
echo "════════════════════════════════════════════════════════════════════="
echo ""

# =════════════════════════════════════════════════════════════════════
# RUN ALL CHECKS
# =════════════════════════════════════════════════════════════════════

echo "[1/4] Running all local checks..."
if [ -f "local_package_check.R" ]; then
    Rscript local_package_check.R "$PACKAGE" > /dev/null 2>&1
    echo "✓ Local checks complete"
else
    echo "⚠️ local_package_check.R not found, skipping local checks"
fi

echo "[2/4] Running credential scan..."
if [ -f "scan_credentials.sh" ]; then
    bash scan_credentials.sh "$PACKAGE" > /dev/null 2>&1
    echo "✓ Credential scan complete"
else
    echo "⚠️ scan_credentials.sh not found, skipping credential scan"
fi

echo "[3/4] Running complete package check (Scorecard + all checks)..."
if [ -n "$REPO_URL" ] && command -v scorecard &> /dev/null; then
    bash check_package.sh "$PACKAGE" "$REPO_URL" > /dev/null 2>&1
    scorecard --repo="$REPO_URL" --format=json > "local_results/${PACKAGE}_scorecard.json" 2>&1
    echo "✓ Complete package check complete"
else
    echo "⚠️ check_package.sh or scorecard not found, skipping complete package check"
fi

echo "[4/4] Extracting results..."
echo ""

# =════════════════════════════════════════════════════════════════════
# EXTRACT RESULTS
# =════════════════════════════════════════════════════════════════════

# Get Cran Info
CRAN_STATUS="[TODO: Yes/No] (check CRAN page)"
CRAN_VERSION="[TODO: Latest version on CRAN]"
LAST_UPDATE="[TODO: Date of last update]"
if [ -f "local_results/${PACKAGE}_local_check.json" ]; then
    CRAN_STATUS=$(jq -r 'local_checks.on_cran // "[TODO]"' "local_results/${PACKAGE}_local_check.json" 2>/dev/null)
    if [ "$CRAN_STATUS" == "true" ]; then
        CRAN_STATUS="Yes";
        elif [ "$CRAN_STATUS" == "false" ]; then
        CRAN_STATUS="No";
    fi
    CRAN_VERSION=$(jq -r 'local_checks.cran_version // "[TODO]"' "local_results/${PACKAGE}_local_check.json" 2>/dev/null)
    LAST_UPDATE=$(jq -r 'local_checks.last_update // "[TODO]"' "local_results/${PACKAGE}_local_check.json" 2>/dev/null)
fi

# Get dependency info
TOTAL_DEPS="[TODO: Total number of dependencies]"
DIRECT_DEPS="[TODO: Number of direct dependencies]"
if [ -f "local_results/${PACKAGE}_local_check.json" ]; then
    TOTAL_DEPS=$(jq -r 'local_checks.total_dependencies // "[TODO]"' "local_results/${PACKAGE}_local_check.json" 2>/dev/null)
    DIRECT_DEPS=$(jq -r 'local_checks.direct_dependencies // "[TODO]"' "local_results/${PACKAGE}_local_check.json" 2>/dev/null)
fi

# Get hooks info
HOOKS_FOUND="[TODO: Yes/No]"
if [ -f "local_results/${PACKAGE}_local_check.json" ]; then
    HOOKS_RAW=$(jq -r 'local_checks.hooks.hooks_found // [] | join(", ")' "local_results/${PACKAGE}_local_check.json" 2>/dev/null)
    if [ -n "$HOOKS_RAW" ] && [ "$HOOKS_RAW" != "[]" ]; then
        HOOKS_FOUND="Yes ($HOOKS_RAW)";
    else
        HOOKS_FOUND="No";
    fi
fi

# Get license info
LICENSE_TYPE="[TODO: License type]"
if [ -f "local_results/${PACKAGE}_local_check.json" ]; then
    LICENSE_TYPE=$(jq -r 'local_checks.license // "[TODO]"' "local_results/${PACKAGE}_local_check.json" 2>/dev/null)
fi

# Get credential scan info
CRED_FINDINGS="[TODO: Yes/No]"
if [ -f "local_results/${PACKAGE}_credentials.txt" ]; then
    CRED_COUNT=$(wc -l < "local_results/${PACKAGE}_credentials.txt" 2>/dev/null || tr -d ' ')
    if [ "$CRED_COUNT" -gt 0 ]; then
        CRED_FINDINGS="Yes ($CRED_COUNT potential credentials found, review for false positives)";
    else
        CRED_FINDINGS="No";
    fi
fi

# Get Scorecard info
SCORECARD_SCORE="[TODO: Scorecard score]"
if [ -f "local_results/${PACKAGE}_scorecard.json" ]; then
    SCORECARD_SCORE=$(jq -r '.score // "[TODO]"' "local_results/${PACKAGE}_scorecard.json" 2>/dev/null)
    SCORECARD_SCORE="$SCORECARD_SCORE/10"
fi

# =════════════════════════════════════════════════════════════════════
# GENERATE MARKDOWN REPORT
# =════════════════════════════════════════════════════════════════════

cat > "$REPORT_FILE" << EOF
# Security Results: ${PACKAGE}

## [TODO: ✅ APPROVE FOR USE / ❌ DISAPPROVE FOR USE / ⚠️ SECOND REVIEW REQUIRED]

After a comprehensive review, **${PACKAGE}** has been [TODO: APPROVED / NOT APPROVED / FLAGGED FOR SECOND REVIEW] for installation. Below is a summary of the findings from various security checks.

**Package:** ${PACKAGE}
**Version:** ${CRAN_VERSION}
**CRAN:** https://cran.r-project.org/package=${PACKAGE}
**GitHub Repo:** ${REPO_URL}
**Reviewer:** ${REVIEWER_NAME}
**Review Date:** ${REVIEW_DATE}
---

## Security Checks Performed

### ✅ GitHub Actions (Automated Checks)

**1. OSS Scorecard:**
- **Score:** ${SCORECARD_SCORE}
- **Status:** [TODO: PASS / FAIL / REVIEW REQUIRED]
- **Key Findings:**
  - Code Review: [TODO: Check GitHub Actions logs for details]
  - Maintained: [TODO: Check GitHub Actions logs for details]
  - Token Permissions: [TODO: Check GitHub Actions logs for details]
- **Notes:** [TODO: Add any specific notes from the Scorecard results]

**2. Trivy Vulnarbility Scan:**
- **CRITICAL:** [TODO: Check GitHub Actions logs for details]
- **HIGH:** [TODO: Check GitHub Actions logs for details]
- **MEDIUM:** [TODO: Check GitHub Actions logs for details]
- **LOW:** [TODO: Check GitHub Actions logs for details]
- **Status:** [TODO: PASS / FAIL / REVIEW REQUIRED]
- **Notes:** [TODO: Add any specific notes from the Trivy results]

**3. Hipcheck Supply Chain Analysis:**
- **Status:** [TODO: PASS / FAIL / REVIEW REQUIRED]
- **Notes:** [TODO: Add any specific notes from the Hipcheck results]

### ✅ Local Checks (Manual/Automated)

**4. CRAN Status:**
- **On CRAN:** ${CRAN_STATUS}
- **Last Update:** ${LAST_UPDATE}
- **Status:** [TODO: ✅ PASS / ❌ FAIL]

**5. Dependency Analysis:**
- **Total Dependencies:** ${TOTAL_DEPS}
- **Direct Dependencies:** ${DIRECT_DEPS}
- **Status:** [TODO: ✅ PASS / ⚠️ ACCEPTABLE / ❌ FAIL]

**6. Hooks Detection:**
- **Hooks Found:** ${HOOKS_FOUND}
- **Malicious Hooks Detected:** [TODO: Review local_results/${PACKAGE}_local_check.json for details]
- **Status:** [TODO: ✅ PASS / ❌ FAIL]

**7. License Analysis:**
- **License**: ${LICENSE}
- **Type:** ${LICENSE_TYPE}
- **Status:** [TODO: ✅ GREAT / ⚠️ ACCEPTABLE / ❌ NOT ACCEPTABLE]
- **Notes:** [TODO: Add any specific notes about the license]

**8. Credential Scan:**
- **Potential Credentials Found:** ${CRED_FINDINGS}
- **Actual Secrets Detected:** [TODO: Review local_results/${PACKAGE}_credentials.txt for details]
- **Status:** [TODO: ✅ PASS / ❌ FAIL]

---

## Important Notes and Recommendations: [TODO: Add any specific notes, recommendations, or next steps based on the findings]

**Example using AWS packages:**
The credential scanner detected references to AWS credentials. This is expected and normal for packages like aws.s3.
However, it's important to review the findings to ensure there are no actual hardcoded secrets. 
Variable names like 'AWS_ACCESS_KEY_ID' are common and not a concern, but any actual values should be investigated.

**What was found:**
- References to \`AWS_ACCESS_KEY_ID\` (variable name, not a hardcoded value)
- References to \`AWS_SECRET_ACCESS_KEY\` (variable name, not a hardcoded value)

**What was not found:**
- No actual hardcoded AWS access keys
- No actual secrets

**Verdict:** These are all false positives.
---

## Overall Assessment: 

[TODO: Add a screenshot of the summary table here if desired]

---

## Decision: [TODO: ✅ APPROVE / ❌ DISAPPROVE]

**Reasoning:**
[TODO: Add a brief explanation of the decision based on the findings]

Example points to consider:
1. Package is actively maintained on CRAN
2. All security checks passed or had acceptable results
3. Low/high dependency count is acceptable for our use case
4. Installation hooks were found but are not malicious
5. No critical vulnerabilities or secrets found
6. License is acceptable for use in our environment

**Recommendation:** [TODO: Add any specific recommendations for monitoring, re-reviewing in the future, or additional checks to perform]

---

## Installation Instructions:
[TODO: Add instructions if approved - 
please proceed with initiating CMS Connect ticket for installation request with VDI team: 
https://cmsitsm.servicenowservices.com/connect?page=cat_item&sys_id=05f38e27db692f00c83df6531f96198f&sysparm_c]

---

## Review Artifacts:
- Scorecard report: local_results/${PACKAGE}_scorecard.json
- Local checks result: local_results/${PACKAGE}_local_check.json
- Credential scan results: local_results/${PACKAGE}_credentials.txt
- Trivy report: [TODO: Add path to Trivy report if available]
- Hipcheck report: [TODO: Add path to Hipcheck report if available] 

---

**Questions or concerns? Please comment on this issue or reach out to the reviewer: ${REVIEWER_NAME}**
EOF

# =════════════════════════════════════════════════════════════════════
# SUMMARY OUTPUT
# =════════════════════════════════════════════════════════════════════

echo "=════════════════════════════════════════════════════════════════════"
echo " Report Generated Successfully"
echo "════════════════════════════════════════════════════════════════════"
echo ""
echo "Report file: $REPORT_FILE"
echo ""
echo "Next steps:"
echo "1. Open the report $REPORT_FILE and fill in the [TODO] sections with the findings"
echo "2. Add GitHub Actions results (see instructions below)"
echo "3. Review and edit as needed"
echo "4. Copy/paste the markdown into a GitHub issue for discussion and final decision"
echo ""
echo "Instructions for adding GitHub Actions results:"
echo "1. Go to the GitHub repository for the package (e.g. https:// github.com/cloudyr/aws.s3)"
echo "2. Click on the 'Actions' tab"
echo "3. Find the most recent workflow runs for $PACKAGE and open the logs for the Scorecard, Trivy, and Hipcheck checks"
echo "4. Copy the relevant results (scores, vulnerability counts, etc.) and paste them into the corresponding [TODO] sections in the report"
echo ""
echo "Result files to review:"
if [ -f "local_results/${PACKAGE}_scorecard.json" ]; then
    echo "- ✔ local_results/${PACKAGE}_scorecard.json"
fi
if [ -f "local_results/${PACKAGE}_local_check.json" ]; then
    echo "- ✔ local_results/${PACKAGE}_local_check.json"
fi
if [ -f "local_results/${PACKAGE}_credentials.txt" ]; then
    echo "- ✔ local_results/${PACKAGE}_credentials.txt"
fi
echo ""
echo "=════════════════════════════════════════════════════════════════════"
