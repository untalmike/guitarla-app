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
      echo "⚠️ Aún no has configurado una ruta base. Ve a la opción 1 primero."
      return
    fi

    read -p "🔍 Introduce el nombre del proyecto al que quieres acceder: " proyecto
    base="$RUTA_PERSONAL_PROYECTOS"
    ruta="$proyecto"
  
    if [ -d "$base/$ruta" ]; then
      cd "$base/$ruta"
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

  # Sección para comprobar el estado del repositorio
  check_git_status() {
    local branch
    branch=$(git rev-parse --abbrev-ref HEAD)

    git fetch origin &>/dev/null

    local local_commit remote_commit base_commit
    local_commit=$(git rev-parse "$branch")
    remote_commit=$(git rev-parse "origin/$branch")
    base_commit=$(git merge-base "$branch" "origin/$branch")

    if [[ "$local_commit" == "$remote_commit" ]]; then
        echo "✅ Todo está sincronizado. No se necesita ni pull ni push."
    elif [[ "$local_commit" == "$base_commit" ]]; then
        echo "⬇️ Tu rama está detrás de la remota. Haz un git pull."
    elif [[ "$remote_commit" == "$base_commit" ]]; then
        echo "⬆️ Tu rama está adelante de la remota. Haz un git push."
    else
        echo "⚠️ Tu rama y el remoto han divergido. Posible rebase o conflictos por resolver."
    fi
  }

  # Autopull en caso de ser requerido
  auto_pull_if_needed() {
    local branch status
    branch=$(git rev-parse --abbrev-ref HEAD)

    # Ejecutar verificación
    status=$(check_git_status)

    if [[ "$status" == *"Haz un git pull."* ]]; then
        echo "ℹ️ Realizando git pull para la rama '$branch'..."
        git pull origin "$branch"
    else
        echo "✅ No es necesario hacer pull: $status"
    fi
  }

  # Función para realizar merge entre ramas
  merge_branches() {
    read -p "🔀 ¿Desde qué rama quieres hacer merge (source)? " source_branch
    read -p "➡️  ¿A qué rama quieres aplicar el merge (target)? " target_branch

    # Guardamos la rama actual para poder volver al final
    current_branch=$(git rev-parse --abbrev-ref HEAD)

    echo "💡 Verificando ramas disponibles..."
    git fetch origin &>/dev/null

    if ! git show-ref --verify --quiet "refs/heads/$source_branch"; then
        echo "❌ La rama fuente '$source_branch' no existe localmente."
        return 1
    fi

    if ! git show-ref --verify --quiet "refs/heads/$target_branch"; then
        echo "❌ La rama destino '$target_branch' no existe localmente."
        return 1
    fi

    echo "🚀 Cambiando a la rama destino '$target_branch'..."
    git checkout "$target_branch" || return 1

    echo "🔄 Actualizando rama destino desde remoto..."
    git pull origin "$target_branch"

    echo "🔀 Realizando merge desde '$source_branch'..."
    if git merge "$source_branch"; then
        echo "✅ Merge exitoso."
    else
        echo "⚠️ Conflictos detectados. Resuélvelos antes de continuar."
    fi

    echo "🔙 Volviendo a tu rama original ($current_branch)..."
    git checkout "$current_branch"
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

  # Configuración de credenciales de GitHub
  update_github_credentials() {
    echo "🔐 Actualizando credenciales de GitHub..."

    read -p "Ingrese su nombre de usuario de GitHub: " github_user
    read -s -p "Ingrese su token personal de acceso (PAT): " github_token
    echo ""

    # Formato de URL para almacenar credenciales
    git_credential_url="https://${github_user}:${github_token}@github.com"

    # Guardar en el helper de credenciales (si está disponible)
    git config --global credential.helper store
    echo "https://${github_user}:${github_token}@github.com" > ~/.git-credentials

    echo "✅ Credenciales actualizadas correctamente."

    # Opcional: prueba de autenticación
    echo "🌐 Probando autenticación..."
    if git ls-remote "$git_credential_url" &>/dev/null; then
        echo "🔗 Autenticación exitosa con GitHub."
    else
        echo "❌ Falló la autenticación. Verifica tus credenciales."
    fi
  }

  salida() {
    echo "👋 Gracias por usar el asistente Git Bash. ¡Hasta luego!"
    exit 0
  }


while true; do

  # Bienvenida
  base="$RUTA_PERSONAL_PROYECTOS/"
  ruta="$proyecto"
  echo "🚀 Bienvenido al asistente Git Bash "
  echo "_____________________________________________"
  echo "📂 Actualmente estás en esta ruta: $base"
  echo "🎯 Te encuentras en este proyecto: $ruta"
  echo "_____________________________________________"
  echo "🫰🏻 Estas son algunas acciones que puedo realizar"
  echo "_____________________________________________"

  # Menú general
  echo "1️⃣ Congifurar carpeta principal" 
  echo "2️⃣ Ir a proyecto"
  echo "3️⃣ Checkout entre ramas"
  echo "4️⃣ Comprobar estado del repositorio"
  echo "5️⃣ Realizar pull automático"
  echo "6️⃣ Realizar merge"
  echo "7️⃣ Realizar push"
  echo "8️⃣ Configurar tus claves de git en el sistema"
  echo "9️⃣ Salir"

  read -p "Espero tu selección: " seleccion

  # llamado de funciones
  case "$seleccion" in
    1) config_path ;;
    2) changing_project ;;
    3) checkout_branches ;;
    4) check_git_status ;;
    5) auto_pull_if_needed ;;
    6) merge_branches;;
    7) git_push ;;
    8) update_github_credentials ;;
    9) salida ;;
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
pausar_final