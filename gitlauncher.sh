#!/bin/bash

echo "🚀 Bienvenido al asistente Git Bash "
echo "______________________________________"

# Pedir mensaje de commit
read -p "📝 Escribe el mensaje del commit: " mensaje

# Confirmar la rama actual
read -p "🌿 Escribe el nombre de la rama (por ejemplo, main): " rama

if [ -z "$rama" ]; then
  rama="main"
fi

# Confirmar antes de continuar
echo ""
echo "Resumen:"
echo "Mensaje del commit: $mensaje"
echo "Rama: $rama"
read -p "¿Deseas continuar con el push? (s/n): " confirmacion

if [[ "$confirmacion" == "s" || "$confirmacion" == "S" ]]; then
  git add .
  git commit -m "$mensaje"
  git push origin "$rama"
  echo "✅ ¡Cambios enviados exitosamente!"
else
  echo "❌ Operación cancelada."
fi
