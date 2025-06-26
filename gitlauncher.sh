#!/bin/bash
# Cargar configuración persistente si existe
[ -f ~/.asistente_config ] && source ~/.asistente_config

# Pila de funciones para procesos de Git Bash
# Registrar path de proyectos
  function config_path {
    read -p "🛠️ Ingresa la ruta que deseas agregar al PATH (formato tipo /c/Users/diamp/...): " nueva_ruta

    # Evita duplicados en el PATH
    if [[ ":$PATH:" == *":$nueva_ruta:"* ]]; then
      echo "ℹ️ La ruta ya está en el PATH."
    else
      echo "export PATH=\"\$PATH:$nueva_ruta\"" >> ~/.bashrc
      echo "✅ Ruta agregada al PATH de manera permanente."
    fi

    # Registrar en archivo de configuración
    if ! grep -q "RUTA_PERSONAL_PROYECTOS=" ~/.asistente_config 2>/dev/null; then
      echo "export RUTA_PERSONAL_PROYECTOS=\"$nueva_ruta\"" >> ~/.asistente_config
      echo "📁 Ruta guardada como base para tus proyectos."
    else
      # Reemplazar si ya existía
      sed -i "s|^export RUTA_PERSONAL_PROYECTOS=.*|export RUTA_PERSONAL_PROYECTOS=\"$nueva_ruta\"|" ~/.asistente_config
      echo "📌 Ruta base actualizada."
    fi

    # Aplicar cambios en sesión actual
    export RUTA_PERSONAL_PROYECTOS="$nueva_ruta"
  }

  # función para realizar un checkout entre ramas
  function changing_project {
    if [[ -z "$RUTA_PERSONAL_PROYECTOS" ]]; then
      echo "⚠️ Aún no has configurado una ruta base. Ve a la opción 8 primero."
      return
    fi

    read -p "🔍 Introduce el nombre del proyecto al que quieres acceder: " proyecto
    ruta="$RUTA_PERSONAL_PROYECTOS/$proyecto"

    if [ -d "$ruta" ]; then
      cd "$ruta"
      echo "✅ Cambio realizado con éxito a '$ruta'."
    else
      echo "❌ Proyecto no encontrado en la ruta: $ruta"
    fi
  }

  # Sección para realizar un checkout entre ramas
  function checkout_branches {
    read -p "🌿 Indica a que rama deseas cambiar: " rama
    git checkout "$rama" 2>/dev/null
    if [[ $? -ne 0 ]]; then
      echo "⚠️  Error al cambiar de rama. Asegúrate de que '$rama' existe."
    else
      echo "✅ Cambio exitoso a '$rama'."
    fi
  }

  # Sección para realizar pull a github
  function git_push {
    read -p "📝 Escribe el mensaje del commit: " mensaje
    read -p "🌿 Escribe el nombre de la rama (por ejemplo, main): " rama
    rama=${rama:-main}
    
    # Confirmar antes de continuar
    echo ""
    echo "Resumen:"
    echo "Mensaje del commit: $mensaje"
    echo "Rama: $rama"
    read -p "¿Deseas continuar con el push? (s/n): " confirmacion

    if [[ "$confirmacion" =~ ^[sS]$ ]]; then
          git add .
          git commit -m "$mensaje"
          git push origin "$rama"
          echo "✅ ¡Cambios enviados exitosamente!"
        else
          echo "❌ Operación cancelada."
    fi
  }


while true; do

  # Bienvenida
  echo "🚀 Bienvenido al asistente Git Bash "
  echo "Estas son algunas acciones que puedo realizar"
  echo "_____________________________________________"

  # Menú general
  echo "1️⃣ Congifurar ruta de proyecto"
  echo "2️⃣ Ir a proyecto"
  echo "3️⃣ Realizar pull request"
  echo "4️⃣ Checkout entre ramas"
  echo "5️⃣ Realizar merge"
  echo "6️⃣ Realizar push"
  echo "7️⃣ Configurar tus claves de git en el sistema"
  echo "8 Salir"

  read -p "Espero tu selección" seleccion

  # llamado de funciones
  case "$seleccion" in
    1) config_path ;;
    2) changing_project ;;
    3) ;;
    4) checkout_branches ;;
    5) ;;
    6) git_push ;;
    7) ;;
    8) exit 1;;
    *) echo "📌 Esa funcionalidad aún está en desarrollo. ¿La construimos juntos?" ;;
  esac

  echo ""
  read -p "Presiona enter para volver al menú..."
done

  validas=("1" "2" "3" "4" "5" "6" "7" "8")
  finded=false
  for opcion in  "${validas[@]}"; do
    if [[ "$seleccion" == "$opcion" ]]; then
      finded=true
      echo "✅ Opción válida seleccionada: $seleccion"
      break
    fi
  done

  if ! $finded; then
    echo "❌ Opción incorrecta, favor de validar tu selección"
    exit 1
  fi

# Fin del script
# Manejo global de errores
trap 'echo -e "\n💥 Ocurrió un error inesperado en la línea $LINENO. Revisa tu entrada o permisos."; read -p "Presiona Enter para salir..."' ERR

# Evita que el script se cierre automáticamente al terminar
function pausar_final {
  echo ""
  read -p "🛑 Presiona Enter para salir..."
}
echo "👋 Gracias por usar el asistente Git Bash. ¡Hasta luego!"
pausar_final