from python_terraform import Terraform, IsFlagged

class TerraformExecutor:
    def __init__(self, working_dir="."):
        self.terraform = Terraform(working_dir=working_dir)

    def run_init(self):
        print("\n[Terraform] Initializing...")
        return_code, stdout, stderr = self.terraform.init(capture_output=False)
        if return_code != 0:
            raise Exception("Terraform init failed.")

    def run_plan(self):
        print("\n[Terraform] Planning...")
        return_code, stdout, stderr = self.terraform.plan(no_color=IsFlagged)
        if return_code not in [0, None]:
            raise Exception("Terraform plan failed.")
        print(stdout)

    def run_apply(self):
        print("\n[Terraform] Applying...")
        return_code, stdout, stderr = self.terraform.apply(skip_plan=True, capture_output=False, auto_approve=True)
        if return_code != 0:
            raise Exception("Terraform apply failed.")
