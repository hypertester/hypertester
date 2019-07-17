import os, sys
from jinja2 import Template

def p4_template_compile(context):
    reload(sys)
    sys.setdefaultencoding('utf8')
    template_dir = os.path.dirname(__file__)
    src_dir= os.path.join(template_dir, "..")
    template_file = os.path.join(template_dir, 'query_distinct.p4.jinja')
    print template_file
    with open(template_file) as f:
        template = Template(f.read())
        if "distinct_queries" in context:
            template.render(distinct_queries = context["distinct_queries"])

    template_file = os.path.join(template_dir, 'query_filter.p4.jinja')
    with open(template_file) as f:
        template = Template(f.read())
        if "filters" in context:
            template.render(filters = context["filters"])

    template_file = os.path.join(template_dir, 'query_reduce.p4.jinja')
    with open(template_file) as f:
        template = Template(f.read())
        if "reduce_queries" in context:
            template.render(reduce_queries = context["reduce_queries"])

    template_file = os.path.join(template_dir, 'query.p4.jinja')
    with open(template_file) as f:
        template = Template(f.read())
        if "queries" in context:
            template.render(queries = context["queries"])

    template_file = os.path.join(template_dir, 'trigger_editor.p4.jinja')
    with open(template_file) as f:
        template = Template(f.read())
        if "editors" in context:
            p4 = template.render(editors = context["editors"])
            src = open(os.path.join(src_dir, "trigger_editor.p4"), 'w')
            src.write(p4)
            src.close()

    template_file = os.path.join(template_dir, 'trigger_replicator.p4.jinja')
    with open(template_file) as f:
        template = Template(f.read())
        if "replicators" in context:
            p4 = template.render(replicators = context["replicators"])
            src = open(os.path.join(src_dir, "trigger_replicator.p4"), 'w')
            src.write(p4)
            src.close()

if __name__ == "__main__":
    print "TODO: P4 template testing."
    