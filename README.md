# 🦖 Dino_Run

Videojuego **Endless Runner 2D** inspirado en el clásico dinosaurio de Google Chrome, desarrollado desde cero con **Godot Engine 4.x** y GDScript.

Estética **Pixel Art** con sonidos retro, física de salto/agachado, obstáculos generados dinámicamente y dificultad progresiva.

---

## 🎮 Cómo jugar

| Acción | Tecla |
|---|---|
| Saltar | `Espacio` / `Flecha Arriba` |
| Agacharse | `Flecha Abajo` / `Ctrl` |
| Reiniciar partida | `Enter` |

El objetivo es sobrevivir el mayor tiempo/distancia posible esquivando cactus y pterodáctilos, mientras la velocidad del juego aumenta progresivamente.

---

## 🛠️ Tecnología

- **Motor:** Godot Engine 4.x (renderer GL Compatibility)
- **Lenguaje:** GDScript
- **Resolución base:** 1280x720, `stretch mode: canvas_items`, filtrado de textura `Nearest` (píxeles nítidos)

---

## 📁 Estructura del proyecto

```
Dino_Run/
├── assets/          # Sprites, fuentes y audio
├── scenes/          # Escenas .tscn (Dino, suelo, obstáculos, UI)
├── script/          # Scripts .gd
├── icon.svg         # Icono del proyecto
├── project.godot    # Configuración del proyecto
└── LICENSE.md
```

---

## 🚧 Estado de desarrollo

El proyecto se está construyendo de forma incremental siguiendo un roadmap por fases:

- [x] **Fase 1:** Configuración del proyecto (resolución, input map, filtrado de texturas)
- [x] **Fase 2:** Personaje principal — física de salto, gravedad, agachado y animaciones
- [ ] **Fase 3:** Escenario y suelo infinito
- [ ] **Fase 4:** Sistema de obstáculos (spawner de cactus y pterodáctilos)
- [ ] **Fase 5:** Colisiones y Game Over
- [ ] **Fase 6:** Sistema de puntuación (score y high score persistente)
- [ ] **Fase 7:** Interfaz de usuario (pantalla de inicio, HUD, Game Over)
- [ ] **Fase 8:** Pulido — dificultad progresiva, sonido y efectos de juice

---

## ▶️ Cómo ejecutar el proyecto

1. Instala [Godot Engine 4.x](https://godotengine.org/download).
2. Clona este repositorio:
   ```bash
   git clone https://github.com/kadirbrioso-afk/Dino_Run.git
   ```
3. Abre Godot y selecciona **Import**, apuntando al archivo `project.godot`.
4. Presiona `F5` o el botón de Play para ejecutar el juego.

---

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Consulta [LICENSE.md](LICENSE.md) para más detalles.
