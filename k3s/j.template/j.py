from jinja2 import Template, Environment, FileSystemLoader
import sys

def render(var, filename):
    load = FileSystemLoader(searchpath="./")
    env = Environment(loader=load)
    template = env.get_template(filename)
    result = template.render(Number=var)
    print(result)

if __name__ == '__main__':
    assert len(sys.argv)-2 > 0 # didn't specify any node
    for i in range(2,len(sys.argv)):
        render(int(sys.argv[i]), sys.argv[1])
