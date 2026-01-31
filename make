#!/usr/bin/env bash
# Use when make isn't in PATH (e.g. Git Bash on Windows).
u="$(uname -s)"
if [[ "$u" == MINGW* || "$u" == MSYS* || "$u" == CYGWIN* ]]; then
  export OS=Windows_NT
  if ! command -v make >/dev/null 2>&1; then
    for d in "/c/Program Files (x86)/GnuWin32/bin" "/c/Program Files/GnuWin32/bin"; do
      [ -x "$d/make.exe" ] && export PATH="$d:$PATH" && break
    done
  fi
fi
exec make "$@"
