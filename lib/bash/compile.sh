#!/usr/bin/env bash

# assembly and c

gasm() {
    gcc -fno-asynchronous-unwind-tables -fno-ident -S "$@";
}

compile() { file="$1" && stem="${file%.*}" && gcc -g -o "$stem" "$file"; }

crun() { file="$1"; shift; stem="${file%.*}" && gcc -g -o "$stem" "$file" && ./"$stem" "$@"; }

asmrun() { file="$1" && stem="${file%.*}" && as -o "$stem.o" "$stem.s" && ld -o "$stem" "$stem.o" && ./"$stem"; }

nasmcompile32() { file="$1" && stem="${file%.*}" && nasm -f elf   "$file" && ld -o "$stem" -m elf_i386 "$stem.o" && rm "${stem}.o"; }

nasmcompile64() { file="$1" && stem="${file%.*}" && nasm -f elf64 "$file" && ld -o "$stem" "$stem.o" && rm "${stem}.o"; }

nasmcompile() { nasmcompile64 "$1"; }

nasmcompilecrt() {
    # compile a nasm file but link in the C runtime.
    file="$1"
    stem="${file%.*}"
    nasm -f elf64 -o "${stem}.o" "${file}" &&
    ld -o "$stem" -dynamic-linker /lib/ld-linux-x86-64.so.2 /lib/crt1.o /lib/crti.o "${stem}.o" -lc /lib/crtn.o &&
    rm "${stem}.o"
}

nasmrun32() { file="$1" && stem="${file%.*}" && nasmcompile32 "$file" && ./"$stem"; }

nasmrun64() { file="$1" && stem="${file%.*}" && nasmcompile64 "$file" && ./"$stem"; }

nasmrun() { nasmrun64 "$1"; }

nasmruncrt() { file="$1" && stem="${file%.*}" && nasmcompilecrt "$file" && ./"$stem"; }

