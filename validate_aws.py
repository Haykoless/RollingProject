import boto3
import json

class AWSValidator:
    def __init__(self, output_file="terraform_output.json", region="us-east-1"):
        self.output_file = output_file
        self.region = region
        self.ec2_client = boto3.client("ec2", region_name=region)
        self.elbv2_client = boto3.client("elbv2", region_name=region)
        self.data = {}

    def load_outputs(self):
        try:
            with open(self.output_file) as f:
                tf_output = json.load(f)
            self.data["instance_id"] = tf_output["ec2_instance_id"]["value"]
            self.data["public_ip"] = tf_output["ec2_public_ip"]["value"]
            self.data["lb_dns"] = tf_output["load_balancer_dns"]["value"]
        except Exception as e:
            raise Exception(f"Error loading Terraform output: {e}")

    def validate_instance(self):
        try:
            res = self.ec2_client.describe_instances(InstanceIds=[self.data["instance_id"]])
            instance = res["Reservations"][0]["Instances"][0]
            self.data["instance_state"] = instance["State"]["Name"]
        except Exception as e:
            raise Exception(f"Error validating EC2 instance: {e}")

    def validate_load_balancer(self):
        try:
            lbs = self.elbv2_client.describe_load_balancers()["LoadBalancers"]
            found = any(lb["DNSName"] == self.data["lb_dns"] for lb in lbs)
            if not found:
                raise Exception("Load Balancer DNS not found.")
        except Exception as e:
            raise Exception(f"Error validating Load Balancer: {e}")

    def save_results(self, file="aws_validation.json"):
        with open(file, "w") as f:
            json.dump(self.data, f, indent=2)

if __name__ == "__main__":
    validator = AWSValidator()
    validator.load_outputs()
    validator.validate_instance()
    validator.validate_load_balancer()
    validator.save_results()
    print("Validation complete. Results saved to aws_validation.json")
