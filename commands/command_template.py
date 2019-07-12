import os
from jinja2 import Template

def command_template_compile(context):
    template_dir = os.path.dirname(__file__)
    template_file = os.path.join(template_dir, 'query_distinct.p4.jinja')
    with open(template_file) as f:
        template = Template(f.read())
        template.render(distinct_queries = context["distinct_queries"])


    template_file = os.path.join(template_dir, 'query_filter.p4.jinja')
    with open(template_file) as f:
        template = Template(f.read())
        template.render(filters = context["filters"])

    template_file = os.path.join(template_dir, 'query_reduce.p4.jinja')
    with open(template_file) as f:
        template = Template(f.read())
        template.render(reduce_queries = context["reduce_queries"])


    template_file = os.path.join(template_dir, 'query.p4.jinja')
    with open(template_file) as f:
        template = Template(f.read())
        template.render(queries = context["queries"])

    template_file = os.path.join(template_dir, 'trigger_editor.p4.jinja')
    with open(template_file) as f:
        template = Template(f.read())
        template.render(editors = context["editors"])

    template_file = os.path.join(template_dir, 'trigger_replicator.p4.jinja')
    with open(template_file) as f:
        template = Template(f.read())
        template.render(replicators = context["replicators"])

if __name__ == "__main__":
    print "TODO: P4 template testing."
    