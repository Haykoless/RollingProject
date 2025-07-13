from input_handler import InputHandler
from template_renderer import TemplateRenderer

if __name__ == "__main__":
    handler = InputHandler()
    context = handler.get_inputs()

    # Review before proceeding
    print("\nReview your configuration:")
    for key, value in context.items():
        print(f"- {key}: {value}")

    print("\nChoose an option:")
    print("1. Confirm and generate main.tf")
    print("2. Remake selections")
    print("3. Cancel and exit")

    while True:
        decision = input("Enter your choice (1/2/3): ").strip()
        if decision == "1":
            break
        elif decision == "2":
            context = handler.get_inputs()
            print("\nReview your configuration:")
            for key, value in context.items():
                print(f"- {key}: {value}")
            print("\nChoose an option:")
            print("1. Confirm and generate main.tf")
            print("2. Remake selections")
            print("3. Cancel and exit")
        elif decision == "3":
            print("Operation cancelled by user.")
            exit()
        else:
            print("Invalid input. Please choose 1, 2, or 3.")

    renderer = TemplateRenderer()
    renderer.render(context)

    print("\nmain.tf generated successfully. You may now run Terraform manually:")
    print("terraform init && terraform plan && terraform apply")
