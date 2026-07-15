#!/usr/bin/env bash
# Abre wlogout mostrando el usuario actual en el header
wlogout \
  -p layer-shell \
  -b 3 \
  -T 400 \
  -B 400 \
  --protocol layer-shell \
  2>/dev/null || wlogout -p layer-shell
