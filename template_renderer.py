from jinja2 import Template

class TemplateRenderer:
    def __init__(self, template_path="template.j2", output_path="main.tf"):
        self.template_path = template_path
        self.output_path = output_path

    def render(self, context):
        try:
            with open(self.template_path, "r") as file:
                template_str = file.read()
        except FileNotFoundError:
            raise Exception(f"Template file '{self.template_path}' not found.")

        try:
            template = Template(template_str)
            rendered_output = template.render(context)
        except Exception as e:
            raise Exception(f"Error rendering template: {e}")

        try:
            with open(self.output_path, "w") as f:
                f.write(rendered_output)
        except Exception as e:
            raise Exception(f"Error writing rendered file: {e}")

        print(f"Terraform configuration written to {self.output_path}"
