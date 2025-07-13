# input_handler.py

DEFAULT_INSTANCE_TYPE = "t2.micro"  # Free Tier default

class InputHandler:
    def __init__(self):
        self.ami_options = {
            "1": ("Ubuntu", "ami-0fc5d935ebf8bc3bc"),
            "2": ("Amazon Linux", "ami-0c101f26f147fa7fd")
        }
        self.instance_options = {
            "1": DEFAULT_INSTANCE_TYPE
        }
        self.az_options = {
            "1": "us-east-1a",
            "2": "us-east-1b"
        }

    def get_inputs(self):
        print("AWS Deployment – Setup")

        ami_id = self.get_choice(self.ami_options, "system")

        print("\nSelect instance type (Free Tier only):")
        for key, val in self.instance_options.items():
            print(f"{key}. {val}")
        print("Type 'exit' to cancel.")

        choice = input("Your choice: ").strip()
        if choice.lower() == 'exit':
            print("Exiting setup.")
            exit()

        if choice in self.instance_options:
            instance_type = self.instance_options[choice]
        else:
            print(f"Invalid input. Instance type '{DEFAULT_INSTANCE_TYPE}' chosen by default due to Free Tier budget limitations.")
            instance_type = DEFAULT_INSTANCE_TYPE

        region_input = input("\nEnter AWS Region (default is 'us-east-1'): ").strip()
        if not region_input:
            region = "us-east-1"
        elif region_input != "us-east-1":
            print("Only 'us-east-1' is supported. Defaulting to 'us-east-1'.")
            region = "us-east-1"
        else:
            region = region_input

        availability_zone = self.get_choice(self.az_options, "Availability Zone")

        while True:
            lb_name = input("\nEnter a name for the Load Balancer: ").strip()
            if lb_name and lb_name.replace('-', '').replace('_', '').isalnum():
                break
            print("Invalid name. Use only alphanumeric, hyphen or underscore.")

        return {
            "ami": ami_id,
            "instance_type": instance_type,
            "region": region,
            "availability_zone": availability_zone,
            "load_balancer_name": lb_name
        }

    def get_choice(self, options, label):
        while True:
            print(f"\nSelect {label}:")
            for key, val in options.items():
                if isinstance(val, tuple):
                    print(f"{key}. {val[0]}")
                else:
                    print(f"{key}. {val}")
            print("Type 'exit' to cancel.")

            choice = input("Your choice: ").strip()
            if choice.lower() == 'exit':
                print("Exiting setup.")
                exit()
            if choice in options:
                return options[choice][1] if isinstance(options[choice], tuple) else options[choice]
            else:
                print("Invalid input. Please try again.")
