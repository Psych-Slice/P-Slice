#!/usr/bin/env bash
set -euo pipefail

flags="$(awk -F: '/^flags[[:space:]]*:/{print $2; exit}' /proc/cpuinfo)"
has() { [[ " $flags " == *" $1 "* ]]; }

if has avx512f && has avx512bw && has avx512cd && has avx512dq && has avx512vl; then
  exec /opt/myapp/bin-v4 "$@"
elif has avx && has avx2 && has bmi1 && has bmi2 && has f16c && has fma && has abm && has movbe && has xsave; then
  exec /opt/myapp/bin-v3 "$@"
elif has cx16 && has lahf_lm && has popcnt && has sse4_1 && has sse4_2 && has ssse3; then
  exec /opt/myapp/bin-v2 "$@"
else
  exec /opt/myapp/bin-v1 "$@"
fi
