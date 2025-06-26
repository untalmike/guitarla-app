#!/bin/bash

# controladores
# proyectos = ("guitarla-app", "mailbox")

# Bienvenida
echo "🚀 Bienvenido al asistente Git Bash "
echo "Estas son algunas acciones que puedo realizar"
echo "_____________________________________________"

# Menú general
echo "1️⃣ Ir a proyecto"
echo "2️⃣ Realizar pull request"
echo "3️⃣ Checkout entre ramas"
echo "4️⃣ Realizar merge"
echo "5️⃣ Realizar push"
echo "6️⃣ Configurar tus claves de git en el sistema"
echo "7️⃣ Salir"
read -p "Espero tu selección" seleccion

  validas = ("1", "2", "3", "4", "5", "6", "7")
  finded = false
  for valida in  "${validas[@]}"; do
    if [["$seleccion" == "$valida"]]; then
      finded = true
      break
    fi
  done

  if ! $finded; then
    echo "❌ Opción incorrecta, favor de validar tu selección"
  else
  

    # Sección para realizar un checkout entre ramas
    if [[ "$seleccion" == "1"]]; then
      read -p " Introduce el nombre del proyecto al que quieres acceder: " proyecto
      if [[ $? -ne 0]]; then
        echo "Lo siento, al parecer el proyecto mencionado no existe"
      else
        echo " Cambiando al proyecto '$proyecto'... "
        cd C:/Users/diamp/Documents/projects/"$proyecto"
        echo "✅ Cambio realizado con éxito"
    fi

    # Sección para realizar un checkout entre ramas
    if [[ "$seleccion" == "3"]]; then    
      read -p "🌿 Indica a que rama deseas cambiar: " rama
      
      if [[ $? -ne 0 ]]; then
        echo "⚠️  Error al cambiar de rama. Asegúrate de que '$rama' existe."
      else
        echo "🔁 Cambiando a la rama solicitada... '$rama'" 
        git checkout "$rama"
        echo "✅ Cambio exitoso a '$rama'."
    fi

    # Sección para realizar pull a github
    if [[ "$seleccion" == "5"]]; then    
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
