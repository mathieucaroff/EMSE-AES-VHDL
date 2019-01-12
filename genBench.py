#!/usr/bin/python3

# Mathieu CAROFF
# 2018-12-31

description = """
Generate vhdl testbenches using a pytemplate file
"""

import logging

import argparse as ap
from pathlib import Path
from datetime import date

import re
from collections import namedtuple
from functools import wraps, lru_cache

import textwrap as tw

memoize = lru_cache(maxsize=None)

def get_args():
    default_date = date.today().strftime("%Y-%m-%d"),
    default_author = "Mathieu CAROFF" # None

    class name(str):
        def __new__(cls, *a, **kw):
            s = str.__new__(cls, *a, **kw)
            if not re.fullmatch(r"[A-Za-z]([A-Za-z0-9_]*[A-Za-z0-9])?", s):
                raise ValueError(f"`{s}` is not a valid name")
            return s

    class commented_line(str):
        def __new__(cls, *a, **kw):
            b = a
            if a and isinstance(a[0], str):
                b = [f"-- {a[0]}\n", *a[1:]]
            return str.__new__(cls, *b, **kw)

    class directory(str):
        def __new__(cls, *a, **kw):
            s = str.__new__(cls, *a, **kw)
            if not Path(s).is_dir():
                raise ValueError(f"`{s}` is not a diretory")
            return s

    class regular_file(str):
        def __new__(cls, *a, **kw):
            s = str.__new__(cls, *a, **kw)
            if not Path(s).is_file():
                raise ValueError(f"`{s}` is not a regular file")
            return s

    parser = ap.ArgumentParser(description=description)
    arg = parser.add_argument
    arg(
        "name",
        type=name,
        help="""Name of the entity for which a test bench must be generated""",
    )

    arg(
        "--author",
        default=default_author,
        type=commented_line,
        help="""Specify an author for the bench file"""
    )

    arg(
        "--date",
        default=default_date,
        type=commented_line,
        nargs="?",
        help="""Specify a creation date for the bench file"""
    )

    arg(
        "--description",
        type=str,
        help="""Specify a description for the bench file"""
    )

    arg(
        "--template",
        default="./template",
        type=directory,
        help="""Path of the directory containing the template files""",
    )

    arg(
        "--bench_config",
        default="bench_config",
        type=directory,
        help="""Name of the directory where the configurations test bench configurations should be read""",
    )

    arg(
        "--gbench",
        default="./gbench",
        type=directory,
        help="""Path of the directory where the generated test bench files should be put""",
    )

    arg(
        "--source",
        default="./osource",
        type=directory,
        help="""Path of the directory containing the source files""",
    )

    args = parser.parse_args()

    return args


def just(f):
    @wraps(f)
    def g(*a, **kw):
        return f(*a, **kw)
    return g

def show(**kw):
    for key, val in kw.items():
        v = val if isinstance(val, str) else repr(val)
        t = type(val).__name__
        print(key, ":", t, "=", v)


Port = namedtuple("Port", "name io type")


class Source():
    def __init__(self, name, path):
        self.name = name
        self.path = path
    
    @memoize
    def get_port_declaration(self):
        text = self.path.read_text()
        m = re.search(
            r"entity\s+{}\s+is\s+port\s*\(([^)]*)\n\s*\);".format(self.name),
            text
        )
        assert m, "Couldn't find the declaration of entity {} in file {}"\
            .format(self.name, self.path)
        port_declaration = m.group(1)
        logging.debug(port_declaration)
        return port_declaration

    @memoize
    def get_port_list(self):
        port_list = []
        port_declaration = self.get_port_declaration()
        reg = r"(\w+)\s*:\s*(in|out)\s+(\w+)"
        for result in re.finditer(reg, port_declaration):
            name = result.group(1)
            io = result.group(2)
            typ = result.group(3)
            port_list.append(Port(name, io, typ))
        return port_list


class Bench():
    def __init__(self, path, template, format_param):
        self.path = path
        self.template = template
        self.format_param = format_param
    
    def text(self):
        return self.template.format(**self.format_param)
    
    def write(self):
        self.path.write_text(self.text())


class Bench_config():
    def __init__(self, path):
        self.path = path

    @memoize
    def read(self):
        linelist = self.path.read_text().splitlines()
        self._description = linelist[0]
        linelist[0] = ""
        self._test_array = "\n            ".join(linelist)
    
    @property
    @memoize
    def description(self):
        self.read()
        return self._description
    
    @property
    @memoize
    def test_array(self):
        self.read()
        return self._test_array


def main():
    args = get_args()

    source_path    = Path(args.source) / (args.name + ".vhd")
    bench_path     = Path(args.gbench) / (args.name + "_tb.vhd")
    config_path    = Path(args.bench_config) / (args.name + ".txt")

    source_file = Source(args.name, source_path)
    config_file = Bench_config(config_path)

    pl = port_list = source_file.get_port_list()

    assert len(pl) in {2, 3}, len(pl)
    assert pl[0].type in "bit8 byte16".split()
    assert pl[0].type == pl[1].type == pl[-1].type
    assert pl[0].io == pl[-2].io == "in" and pl[-1].io == "out"

    signature = f"{pl[0].type}_{len(pl)}"

    template_path = Path(args.template) / f"{signature}.template.vhd"

    format_param = dict(
        name=args.name,
        author=args.author,
        date=args.date or "",
        description=args.description or config_file.description,
        test_array=config_file.test_array,
        state_i=pl[0].name,
        state_o=pl[-1].name,
        state0_i=pl[0].name,
        state1_i=pl[1].name,
        byte_i=pl[0].name,
        byte_o=pl[-1].name,
        byte0_i=pl[0].name,
        byte1_i=pl[1].name,
        s=max(map(lambda p:len(p.name), pl)),
    )

    bench_file = Bench(
        path=bench_path,
        template=template_path.read_text(),
        format_param=format_param
    )

    bench_file.write()


if __name__ == "__main__":
    try:
        main()
    except Exception:
        # import traceback
        # traceback.print_exc()
        
        from IPython.core.ultratb import AutoFormattedTB
        AutoFormattedTB(mode="Verbose")()

        import pdb
        pdb.post_mortem()
