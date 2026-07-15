#!/usr/bin/env bash
set -e

echo "==> Creando script wrapper para conservación de batería..."
sudo tee /usr/local/bin/battery-conservation << 'EOF'
#!/usr/bin/env bash
echo "$1" > /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode
EOF
sudo chmod 755 /usr/local/bin/battery-conservation

echo "==> Configurando regla sudoers..."
sudo rm -f /etc/sudoers.d/power-control
echo "eosorio ALL=(ALL) NOPASSWD: /usr/local/bin/battery-conservation" | sudo tee /etc/sudoers.d/power-control
sudo chmod 440 /etc/sudoers.d/power-control

echo "==> Verificando..."
sudo /usr/local/bin/battery-conservation 1
VALUE=$(cat /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode)
if [[ "$VALUE" == "1" ]]; then
  sudo /usr/local/bin/battery-conservation 0
  echo "✓ Todo funciona correctamente. Conservación desactivada (restaurado a normal)."
else
  echo "✗ Algo falló. Revisa los pasos manualmente."
  exit 1
fi
