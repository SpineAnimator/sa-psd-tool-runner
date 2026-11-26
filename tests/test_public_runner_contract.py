from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
WORKFLOW = ROOT / ".github" / "workflows" / "psd-validation.yml"


class PublicRunnerContractTests(unittest.TestCase):
    def test_every_job_uses_github_hosted_ubuntu(self):
        source = WORKFLOW.read_text(encoding="utf-8")
        jobs = source.split("\njobs:\n", 1)[1]
        run_targets = re.findall(r"^\s+runs-on:\s*(.+?)\s*$", jobs, re.MULTILINE)
        self.assertTrue(run_targets, "workflow must define executable jobs")
        self.assertTrue(
            all(target in {"ubuntu-24.04", "ubuntu-latest"} for target in run_targets),
            f"non-public runner target found: {run_targets}",
        )
        self.assertNotRegex(source, r"(?i)self-hosted|RUNNER_TOKEN|config\.sh|run\.sh")

    def test_no_containerized_runner_registration_remains(self):
        forbidden = [
            ROOT / "Dockerfile",
            ROOT / "compose.yaml",
            ROOT / "entrypoint.sh",
        ]
        existing = [str(path.relative_to(ROOT)) for path in forbidden if path.exists()]
        self.assertEqual(existing, [], f"obsolete runner bootstrap files remain: {existing}")

    def test_validation_job_runs_in_this_public_repository(self):
        source = WORKFLOW.read_text(encoding="utf-8")
        self.assertIn("psd-spine-validation:", source)
        self.assertIn("github.repository == 'SpineAnimator/sa-psd-tool-runner'", source)

    def test_reusable_job_can_validate_an_explicit_private_source_on_public_runner(self):
        source = WORKFLOW.read_text(encoding="utf-8")
        self.assertIn("workflow_call:", source)
        self.assertIn("source-repository:", source)
        self.assertIn("source-ref:", source)
        self.assertIn("repository: ${{ inputs.source-repository || github.repository }}", source)
        self.assertIn("token: ${{ secrets.SOURCE_REPO_TOKEN || github.token }}", source)
        self.assertIn("runs-on: ubuntu-24.04", source)

    def test_public_site_psd_browser_e2e_is_available_as_public_runner_suite(self):
        source = WORKFLOW.read_text(encoding="utf-8")
        self.assertIn("suite:", source)
        self.assertIn("public-site-browser-e2e:", source)
        self.assertIn("inputs.suite == 'public-site-e2e'", source)
        self.assertIn("node scripts/verify_public_site_e2e.mjs", source)
        self.assertIn("runs-on: ubuntu-24.04", source)


if __name__ == "__main__":
    unittest.main()
