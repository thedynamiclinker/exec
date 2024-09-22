#!/usr/bin/env python

import os
import re
import sys
import json
import subprocess

def fixnames(text):
    return subprocess.run(["fixnames", text], capture_output=True).stdout.decode().strip()

class Shoe:

    def __init__(self, root):

        if not os.path.isdir(root):
            raise FileNotFoundError(f"Could not find shoe root: {self.root!r}")

        self.root = root
        self.name = os.path.basename(root)
        self.compilation = f"{root}/compilation"

        if not os.path.isdir(self.compilation):
            raise FileNotFoundError(f"Could not find compilation dir: {self.compilation}")

        text = os.popen(f"book-parse {self.compilation!r}").read()
        data = json.loads(text)
        self.books = [Book(name, data[name], shoe=self)
                      for name in sorted(data.keys())]

    def grep(self, regex, flags=re.I):
        return [o for o in self.books if re.search(regex, o.name, flags=flags)]

    def __repr__(self):
        return f"{self.__class__.__name__}({self.name})"


class Book:

    def __init__(self, name, data, *, shoe):
        self.name = name
        self.shoe = shoe
        self.data = data
        self.chapters = [Chapter(name, markdown, book=self)
                         for name, markdown in self.data.items()]

    def __repr__(self):
        return f"{self.__class__.__name__}({self.name})"

    def grep(self, regex, flags=re.I):
        return [o for o in self.chapters if re.search(regex, o.name, flags=flags)]


class Chapter:
    def __init__(self, name, data, *, book):
        self.name = re.sub(r'[.]md$', '', name)
        self.data = data
        self.link = data['link']
        self.clips = [Clip(c, chapter=self) for c in data.get('clips', [])]
        self.book = book

    def __repr__(self):
        return f"{self.__class__.__name__}({self.name})"

    def download(self, output_dir='.'):
        link = self.link
        name = self.name
        output_path = os.path.realpath(os.path.join(output_dir, f"{name}.mp4"))

        command = ' '.join([
            f"yt-dlp",
            f"-f 'bv*[ext=mp4]+ba[ext=mp3]/b[ext=mp4]'",
            f"--merge-output-format mp4",
            f"-o {output_path!r}",
            f"{link!r}",
        ])

        os.makedirs(os.path.dirname(output_path), exist_ok=True)

        p = subprocess.run(command, shell=True)

        if not os.path.exists(output_path):
            raise RuntimeError(f"Download failed: {name}: {link}")

        return output_path


class Clip:

    def __init__(self, data, *, chapter):
        self.name = data['title']
        self.start = data['start']
        self.end = data['end']
        self.data = data
        self.chapter = chapter

    def __repr__(self):
        return f"{self.__class__.__name__}({self.name})"

    def download(self, output_dir='.'):
        link = self.chapter.link
        start = self.start
        end = self.end
        name = fixnames(self.name)[:200]
        output_path = os.path.realpath(os.path.join(output_dir, f"{name}.mp4"))

        command = ' '.join([
            f"yt-dlp",
            f"-f 'bv*[ext=mp4]+ba[ext=mp3]/b[ext=mp4]'",
            f"--merge-output-format mp4",
            f"-o {output_path!r}",
            f"--download-sections '*{start}-{end}'",
            f"{link!r}",
        ])

        os.makedirs(os.path.dirname(output_path), exist_ok=True)

        p = subprocess.run(command, shell=True)

        if not os.path.exists(output_path):
            raise RuntimeError(f"Download failed: {clip}: {link}")

        return output_path

shus = [
    'Sudocode',
    'LD',
    'Before We Know How',
    'Softwar',
    'We',
]

input_root = os.getenv('OBSIDIAN')
output_root = os.path.join(os.getenv('DROPBOX'), 'eye-of-the-tiger', 'videos')

for shu in shus:

    path = os.path.join(input_root, shu)
    try:
        shoe = Shoe(path)
    except FileNotFoundError as e:
        print(type(e), e)
        continue

    for book in shoe.books:

        if 'harmon' not in book.name:
            print(f"Skipping {book.name}")
            continue

        chapter_dir = os.path.join(
            output_root, shoe.name, 'compilation', book.name,
        )

        for chapter in book.chapters:

            chapter.download(chapter_dir)

            clip_dir = os.path.join(
                output_root, shoe.name, 'assembly', book.name, chapter.name
            )

            for clip in chapter.clips:
                clip.download(clip_dir)

