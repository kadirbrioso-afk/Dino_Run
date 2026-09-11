# 🦖 ROADMAP: Dino Endless Runner 2D — Godot Engine 4.x

> **Perfil del desarrollador:** Programador con experiencia general (variables, condicionales, bucles, clases, funciones), principiante en Godot Engine.
> **Objetivo final:** Clon funcional y pulido del "Dino de Chrome", con dificultad progresiva, sistema de puntuación persistente y sonido.

---

## 📚 Índice de Fases

- [x] Fase 1: Configuración del Proyecto y Estructura de Archivos
- [x] Fase 2: El Personaje Principal (Dino)
- [x] Fase 3: Escenario y Suelo Infinito
- [x] Fase 4: Sistema de Obstáculos (Spawner)
- [x] Fase 5: Colisiones y Game Over
- [x] Fase 6: Sistema de Puntuación (Score y High Score)
- [x] Fase 7: Interfaz de Usuario (UI/HUD)
- [x] Fase 8: Pulido y Jugabilidad (Juice)

---

## Fase 1: Configuración del Proyecto y Estructura de Archivos

### 🎯 Objetivo de la fase
Dejar el proyecto de Godot correctamente configurado para un juego 2D en pixel art / vectorial simple, con una resolución fija, escalado nítido (sin borrones) y una estructura de carpetas ordenada que soporte el crecimiento del proyecto.

### 🧩 Nodos específicos de Godot a utilizar
Ninguno todavía (esta fase es de configuración del proyecto, no de escenas).

### 🛠 Paso a paso de implementación

1. **Crear el proyecto** en Godot 4.x, eligiendo el renderer **"Compatibility"** (mejor rendimiento y compatibilidad para juegos 2D simples).
2. **Definir la estructura de carpetas** dentro de `res://`:
   ```
   res://
   ├── assets/
   │   ├── sprites/
   │   │   ├── dino/
   │   │   ├── obstacles/
   │   │   └── environment/
   │   ├── fonts/
   │   └── audio/
   │       ├── sfx/
   │       └── music/
   ├── scenes/
   │   ├── main/
   │   ├── player/
   │   ├── obstacles/
   │   └── ui/
   ├── scripts/
   │   └── autoload/
   └── resources/
   ```
3. Ir a **Project > Project Settings > Display > Window** y configurar:
   - `Viewport Width`: `1280`
   - `Viewport Height`: `720`
   - `Stretch Mode`: `canvas_items`
   - `Stretch Aspect`: `expand` (o `keep` si prefieres letterboxing fijo)
4. Ir a **Project > Project Settings > Rendering > Textures** y configurar:
   - `Default Texture Filter`: `Nearest` (esto evita que los sprites se vean borrosos si usas pixel art; si tus assets son vectoriales/suavizados, deja `Linear`).
5. Configurar **Input Map** (Project > Project Settings > Input Map) con las acciones que usarás desde ya:
   - `jump` → tecla `Space` / `Flecha Arriba`
   - `duck` → tecla `Flecha Abajo` / `Ctrl`
   - `restart` → tecla `Enter`
6. Hacer un primer **commit de Git** (si usas control de versiones) con esta estructura base y un `.gitignore` que excluya `.godot/`.

### 📖 Conceptos clave de Godot explicados

| Concepto | Explicación breve |
|---|---|
| **Project Settings** | Es el archivo de configuración global (`project.godot`) del juego. Todo lo que ajustes ahí aplica a todo el proyecto, no a una escena en particular. |
| **Stretch Mode (`canvas_items`)** | Define cómo se escala tu juego a distintas resoluciones de pantalla. `canvas_items` escala los nodos 2D manteniendo nitidez razonable; es el estándar para juegos 2D. |
| **Texture Filter (`Nearest` vs `Linear`)** | `Nearest` conserva los bordes duros de los píxeles (ideal para pixel art). `Linear` suaviza/difumina los bordes (mejor para arte vectorial o de alta resolución). |
| **Input Map** | Una capa de abstracción entre "tecla física" y "acción del juego". En vez de preguntar `¿se presionó la tecla Espacio?`, tu código pregunta `¿se activó la acción "jump"?`, lo que te permite remapear controles sin tocar el código. |
| **`res://`** | Es la ruta raíz de tu proyecto Godot (equivalente a la carpeta del proyecto). Todos los recursos se referencian con esta ruta virtual. |

### ✅ Criterio de aceptación
- [x] El proyecto abre en Godot sin errores.
- [x] La estructura de carpetas descrita existe físicamente en el proyecto.
- [x] La resolución de ventana está fijada en 1280x720 con `Stretch Mode` configurado.
- [x] Las acciones `jump`, `duck` y `restart` existen en el Input Map y responden a las teclas asignadas (puedes probarlo temporalmente con un `print()` en un script vacío adjunto a un nodo `Node`).

---

## Fase 2: El Personaje Principal (Dino)

### 🎯 Objetivo de la fase
Tener un Dino controlable que corre automáticamente, puede saltar con física de gravedad realista, y puede agacharse, con animaciones que reflejan cada estado.

### 🧩 Nodos específicos de Godot a utilizar
- `CharacterBody2D` (nodo raíz del jugador)
- `AnimatedSprite2D` (animaciones: run, jump, duck)
- `CollisionShape2D` (dos formas, una para de pie y otra para agachado)

### 🛠 Paso a paso de implementación

1. Crear una nueva escena: `scenes/player/Dino.tscn`.
2. Nodo raíz: `CharacterBody2D`, renómbralo a `Dino`.
3. Añadir como hijos:
   - `AnimatedSprite2D` (nómbralo `Sprite`)
   - `CollisionShape2D` (nómbralo `CollisionStanding`)
   - `CollisionShape2D` (nómbralo `CollisionDucking`, inicialmente desactivada con `disabled = true`)
4. En el `AnimatedSprite2D`, crea un `SpriteFrames` con 3 animaciones:
   - `run` (loop activado)
   - `jump` (loop desactivado, un solo frame o varios)
   - `duck` (loop activado)
5. Crear el script `Dino.gd` y adjuntarlo al nodo raíz:

```gdscript
extends CharacterBody2D

@export var gravity: float = 4200.0
@export var jump_velocity: float = -1400.0
@export var duck_speed_multiplier: float = 1.0

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var collision_standing: CollisionShape2D = $CollisionStanding
@onready var collision_ducking: CollisionShape2D = $CollisionDucking

var is_ducking: bool = false

func _physics_process(delta: float) -> void:
	# Aplicar gravedad si no está en el suelo
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	# Saltar (solo si está en el suelo)
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		sprite.play("jump")

	# Agacharse
	if Input.is_action_pressed("duck") and is_on_floor():
		_start_duck()
	else:
		_stop_duck()

	move_and_slide()
	_update_animation()

func _start_duck() -> void:
	if is_ducking:
		return
	is_ducking = true
	collision_standing.disabled = true
	collision_ducking.disabled = false

func _stop_duck() -> void:
	if not is_ducking:
		return
	is_ducking = false
	collision_standing.disabled = false
	collision_ducking.disabled = true

func _update_animation() -> void:
	if not is_on_floor():
		if sprite.animation != "jump":
			sprite.play("jump")
	elif is_ducking:
		sprite.play("duck")
	else:
		sprite.play("run")
```

6. Posiciona el `Dino` sobre una plataforma temporal (un `StaticBody2D` simple) para probar el salto antes de construir el suelo infinito real (eso se hace en la Fase 3).
7. Prueba que el salto, la gravedad y el agachado funcionen correctamente y que el sprite cambie de animación según el estado.

### 📖 Conceptos clave de Godot explicados

| Concepto | Explicación breve |
|---|---|
| **`CharacterBody2D`** | Nodo especializado para personajes controlados por código (jugador o enemigos), con métodos como `move_and_slide()` que manejan colisiones con el entorno automáticamente. Es distinto de `RigidBody2D` (físicas simuladas) porque aquí **tú** controlas el movimiento explícitamente. |
| **`velocity` y `move_and_slide()`** | `velocity` es una propiedad integrada del `CharacterBody2D` que almacena la dirección/velocidad actual. `move_and_slide()` mueve el nodo según esa velocidad y resuelve colisiones deslizando contra superficies, sin que tengas que calcular la física de choque tú mismo. |
| **`is_on_floor()`** | Método que devuelve `true` si el `CharacterBody2D` está tocando una superficie detectada como "suelo" en el frame anterior. Es la forma estándar de saber si un personaje puede saltar. |
| **`@onready`** | Anotación que le dice a Godot "asigna esta variable justo cuando el nodo entra en el árbol de escena", útil para obtener referencias a nodos hijos (`$Sprite`) sin errores de nodos aún no inicializados. |
| **`@export`** | Expone una variable en el Inspector del editor, permitiendo ajustar valores (como gravedad o velocidad de salto) sin tocar código. |
| **Dos `CollisionShape2D`** | Un patrón común: en vez de redimensionar dinámicamente una sola colisión, se usan dos formas separadas (de pie / agachado) y se activa/desactiva la que corresponda con `.disabled`. Es más predecible y evita bugs de colisión. |
| **`AnimatedSprite2D` y `SpriteFrames`** | `AnimatedSprite2D` reproduce animaciones de sprites 2D. El recurso `SpriteFrames` es donde defines qué imágenes componen cada animación (`run`, `jump`, `duck`) y su velocidad de reproducción (FPS). |

### ✅ Criterio de aceptación
- [x] El Dino cae por gravedad y se detiene al tocar una superficie temporal.
- [x] Al presionar `jump` estando en el suelo, el Dino salta con un arco de gravedad natural.
- [x] Al mantener `duck`, el Dino cambia su colisión y animación a estado agachado, y vuelve a estado normal al soltar la tecla.
- [x] Las animaciones `run`, `jump` y `duck` se reproducen correctamente según el estado.

---

## Fase 3: Escenario y Suelo Infinito

### 🎯 Objetivo de la fase
Crear la sensación de que el Dino corre indefinidamente hacia la derecha, moviendo el fondo/suelo en lugar del personaje, con un loop perfecto e imperceptible.

### 🧩 Nodos específicos de Godot a utilizar
- `Node2D` (contenedor del suelo)
- `Sprite2D` o `TextureRect` (segmentos del suelo, x2 mínimo)
- `ParallaxBackground` + `ParallaxLayer` (opcional, para fondo decorativo con profundidad)

### 🛠 Paso a paso de implementación

1. Decide el enfoque: **el Dino se queda fijo en X** (por ejemplo `x = 150`) y **todo el escenario se mueve hacia la izquierda**. Esto simplifica enormemente la cámara y el spawn de obstáculos.
2. Crea `scenes/main/Ground.tscn`:
   - Nodo raíz `Node2D` llamado `Ground`.
   - Dos hijos `Sprite2D` (`GroundSegmentA`, `GroundSegmentB`), usando la misma textura de suelo, colocados uno justo después del otro (si el sprite mide 1280px de ancho, el segundo empieza en `x = 1280`).
3. Script `Ground.gd`:

```gdscript
extends Node2D

@export var scroll_speed: float = 600.0
@onready var segments: Array[Sprite2D] = [$GroundSegmentA, $GroundSegmentB]

var segment_width: float

func _ready() -> void:
	segment_width = segments[0].texture.get_width()

func _process(delta: float) -> void:
	for segment in segments:
		segment.position.x -= scroll_speed * delta

	# Reposicionar el segmento que salió de pantalla al final del otro
	for segment in segments:
		if segment.position.x <= -segment_width:
			var other_segment: Sprite2D = _get_other_segment(segment)
			segment.position.x = other_segment.position.x + segment_width

func _get_other_segment(current: Sprite2D) -> Sprite2D:
	return segments[1] if current == segments[0] else segments[0]
```

4. (Opcional pero recomendado para "juice" visual) Añade un `ParallaxBackground` con una o dos `ParallaxLayer` (montañas, nubes) detrás del suelo, con `motion_scale` menor a 1 (ej. `0.3`) para que se muevan más lento que el suelo y generen sensación de profundidad.
5. Instancia `Ground.tscn` dentro de tu escena principal `Main.tscn` (la crearás formalmente en la Fase 7, pero puedes usar una escena de prueba `Main.tscn` desde ahora) junto al `Dino`.
6. Ajusta `scroll_speed` para que combine visualmente con el movimiento del Dino.

### ⚠️ Paso adicional imprescindible: la física del piso (no confundir con el suelo visual)

**Este paso NO estaba en la versión original del roadmap y es indispensable — sin él, el Dino nunca deja de caer, porque `is_on_floor()` nunca da `true`.**

El `Ground.tscn` que acabás de crear es **puramente decorativo**: son dos `Sprite2D` que se deslizan, sin ninguna colisión física asociada. `is_on_floor()` (usado en `Dino.gd` desde la Fase 2) necesita que el `CharacterBody2D` del Dino choque contra un cuerpo físico real (`StaticBody2D`, `RigidBody2D` o `CharacterBody2D`), y ese cuerpo todavía no existe en ningún lado del proyecto.

**La solución es simple gracias a la decisión de diseño de la Fase 3 ("el Dino se queda fijo en X"):** como el Dino nunca se desplaza horizontalmente y el suelo visual siempre se ve igual (es un loop), el piso físico **no necesita moverse ni reciclarse** como el `Ground` visual. Basta con un único `StaticBody2D` fijo e invisible, colocado exactamente a la altura donde se ve la superficie del suelo.

**7. Crear la colisión física del piso**, como hermano de `Ground` y `Dino` en tu escena principal (`Main.tscn` de prueba):

```
Main (Node2D)
├── Ground (Node2D)                 ← visual (ya creado en este paso a paso)
│   ├── GroundSegmentA (Sprite2D)
│   └── GroundSegmentB (Sprite2D)
├── FloorCollision (StaticBody2D)   ← física, nuevo
│   └── CollisionShape2D (RectangleShape2D)
└── Dino (CharacterBody2D)
```

   - Click derecho en `Main` → `Add Child Node` → `StaticBody2D`. Renómbralo `FloorCollision`.
   - Click derecho en `FloorCollision` → `Add Child Node` → `CollisionShape2D`.
   - En el Inspector del `CollisionShape2D`, en `Shape`, creá un `RectangleShape2D` con `Size` = `(3000, 50)` (ancho grande para cubrir toda la pantalla con margen).
   - Posicioná el `FloorCollision` (nodo padre) en `Position` = `(0, Y_DEL_SUELO)`, donde `Y_DEL_SUELO` es la coordenada Y donde visualmente están parados tus `Sprite2D` del `Ground` (ajustalo a ojo hasta que el Dino "pise" el sprite visual, no quede flotando ni hundido).

**8. Configurar las capas de colisión** (Project Settings > Layer Names > 2D Physics), para que el piso no se mezcle más adelante con los obstáculos de la Fase 4:
   - Renombrá la capa `1` como `"world"`.
   - En `FloorCollision` (StaticBody2D) → pestaña `Collision` del Inspector → `Collision Layer`: activá solo la capa `1` (`"world"`).
   - En el nodo raíz `Dino` (`CharacterBody2D`, **no** el `HurtBox` que se agrega recién en la Fase 5) → pestaña `Collision` → `Collision Mask`: activá la capa `1` (`"world"`).

   > 💡 Nota para más adelante: en la Fase 5 vas a configurar capas `"player"` y `"obstacles"` para un `Area2D` hijo llamado `HurtBox`. Ese es un sistema de colisión **completamente distinto** al que acabás de configurar acá: el `CharacterBody2D` raíz del Dino (con su mask en `"world"`) es el que detecta el piso; el `HurtBox` (Area2D, con mask en `"obstacles"`) es el que detecta obstáculos. Son dos chequeos de física independientes que conviven en el mismo nodo `Dino`, sin interferir entre sí.

### 📖 Conceptos clave de Godot explicados

| Concepto | Explicación breve |
|---|---|
| **Truco del "mundo que se mueve"** | En runners infinitos casi nunca se mueve al jugador; se mueve el escenario. Esto evita manejar cámaras complejas y hace trivial el "loop infinito": solo reciclas segmentos que salen de pantalla. |
| **`_process(delta)` vs `_physics_process(delta)`** | `_process` se ejecuta una vez por frame renderizado (puede variar en frecuencia). `_physics_process` se ejecuta a un paso fijo (por defecto 60 Hz), ideal para todo lo relacionado a física y colisiones. Mover un `Sprite2D` decorativo puede ir en `_process`; el movimiento del `CharacterBody2D` del Dino debe ir en `_physics_process`. |
| **`ParallaxBackground` / `ParallaxLayer`** | Sistema nativo de Godot para crear efecto de profundidad (parallax scrolling): capas más lejanas se mueven más lento que las cercanas. `motion_scale` en cada `ParallaxLayer` controla ese factor de velocidad relativo. |
| **Reciclado de segmentos ("object pooling" simple)** | En vez de crear/destruir sprites de suelo constantemente (costoso), reutilizas los mismos dos nodos moviéndolos al final de la fila cuando salen de pantalla. Es una técnica de optimización fundamental en runners infinitos. |
| **Suelo visual vs. suelo físico (concepto nuevo)** | En muchos runners 2D, lo que el jugador *ve* como piso (sprites que se deslizan) y lo que el motor de físicas *detecta* como piso (un `StaticBody2D` con `CollisionShape2D`) son dos cosas separadas que solo coinciden en posición. Esto es más simple que hacer que la colisión también se recicle, porque el piso físico puede quedarse quieto mientras el Dino no cambie de posición horizontal. |
| **`StaticBody2D`** | Cuerpo físico que no se mueve por sí mismo ni reacciona a fuerzas, pero **sí** bloquea y es detectado por otros cuerpos (como el `CharacterBody2D` del Dino vía `move_and_slide()`). Ideal para superficies fijas: suelos, paredes, plataformas. |
| **Collision Layers y Masks (introducción)** | `collision_layer` define en qué "capa" vive un objeto; `collision_mask` define qué capas puede *detectar*. El `FloorCollision` vive en la capa `"world"`; el Dino tiene esa capa activada en su mask, así que la detecta. Se profundiza más en la Fase 4 y 5 cuando aparecen los obstáculos. |

### ✅ Criterio de aceptación
- [ ] El suelo se desplaza continuamente hacia la izquierda sin saltos ni huecos visibles entre segmentos.
- [ ] El loop es imperceptible: no se nota el momento en que un segmento se recicla.
- [ ] El Dino permanece fijo horizontalmente mientras el suelo se mueve debajo de él.
- [ ] (Opcional) El fondo parallax se mueve a distinta velocidad que el suelo, dando sensación de profundidad.
- [ ] **(Nuevo) El Dino cae por gravedad y se detiene exactamente sobre el `FloorCollision`, coincidiendo visualmente con la superficie del `Ground`, sin flotar ni hundirse.**
- [ ] **(Nuevo) `is_on_floor()` devuelve `true` cuando el Dino está parado, permitiendo saltar con normalidad (podés verificarlo con un `print(is_on_floor())` temporal en `_physics_process`).**

---

## Fase 4: Sistema de Obstáculos (Spawner)

### 🎯 Objetivo de la fase
Generar obstáculos de forma aleatoria y periódica (cactus en el suelo, pterodáctilos voladores a distintas alturas), que se muevan hacia el jugador y se autodestruyan al salir de pantalla.

### 🧩 Nodos específicos de Godot a utilizar
- `Area2D` (para cada obstáculo — detecta colisión sin física sólida)
- `CollisionShape2D` (hijo del Area2D)
- `Sprite2D` o `AnimatedSprite2D` (visual del obstáculo, el pterodáctilo puede animarse volando)
- `Timer` (para controlar el intervalo de spawn)
- `Node2D` o `Marker2D` (como punto de spawn / spawner)
- `VisibleOnScreenNotifier2D` (para destruir obstáculos automáticamente al salir de pantalla)

### 🛠 Paso a paso de implementación

1. **Crear la escena base de obstáculo** `scenes/obstacles/Cactus.tscn`:
   - Raíz: `Area2D` (nómbralo `Cactus`), con `collision_layer` y `collision_mask` configurados en la capa `"obstacles"` (ver tabla de conceptos).
   - Hijos: `Sprite2D` + `CollisionShape2D` + `VisibleOnScreenNotifier2D`.
2. Script `Obstacle.gd` (genérico, reutilizable también para el pterodáctilo):

```gdscript
extends Area2D

@export var speed: float = 600.0

@onready var notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

func _ready() -> void:
	notifier.screen_exited.connect(_on_screen_exited)

func _process(delta: float) -> void:
	position.x -= speed * delta

func _on_screen_exited() -> void:
	queue_free()
```

3. Duplica esta escena para crear `scenes/obstacles/Pterodactyl.tscn`, cambiando el sprite por una `AnimatedSprite2D` con animación de vuelo, y ajustando la `CollisionShape2D` a su tamaño.
4. **Crear el Spawner**: `scenes/obstacles/ObstacleSpawner.tscn`:
   - Raíz: `Node2D` (nómbralo `ObstacleSpawner`).
   - Hijo: `Timer` (nómbralo `SpawnTimer`, `one_shot = true` porque reiniciaremos el tiempo manualmente con valores aleatorios cada vez).
   - Hijos `Marker2D`: `SpawnPointGround`, `SpawnPointAirLow`, `SpawnPointAirHigh` (posiciones donde pueden aparecer los distintos obstáculos).
5. Script `ObstacleSpawner.gd`:

```gdscript
extends Node2D

@export var cactus_scene: PackedScene
@export var pterodactyl_scene: PackedScene
@export var min_spawn_time: float = 0.9
@export var max_spawn_time: float = 2.2

@onready var timer: Timer = $SpawnTimer
@onready var spawn_ground: Marker2D = $SpawnPointGround
@onready var spawn_air_low: Marker2D = $SpawnPointAirLow
@onready var spawn_air_high: Marker2D = $SpawnPointAirHigh

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	_start_next_timer()

func _start_next_timer() -> void:
	timer.wait_time = randf_range(min_spawn_time, max_spawn_time)
	timer.start()

func _on_timer_timeout() -> void:
	_spawn_random_obstacle()
	_start_next_timer()

func _spawn_random_obstacle() -> void:
	var roll: float = randf()
	var scene: PackedScene
	var spawn_point: Marker2D

	if roll < 0.6:
		scene = cactus_scene
		spawn_point = spawn_ground
	elif roll < 0.8:
		scene = pterodactyl_scene
		spawn_point = spawn_air_low
	else:
		scene = pterodactyl_scene
		spawn_point = spawn_air_high

	var obstacle: Area2D = scene.instantiate()
	obstacle.global_position = spawn_point.global_position
	get_parent().add_child(obstacle)
```

6. En el editor, asigna en el Inspector los `@export` `cactus_scene` y `pterodactyl_scene` arrastrando los archivos `.tscn` correspondientes.
7. Instancia `ObstacleSpawner.tscn` en tu `Main.tscn`, posicionado fuera de la pantalla a la derecha.

### ⚠️ Paso adicional: posiciones concretas de los `Marker2D` (no estaban especificadas)

El roadmap original no daba valores numéricos para los tres `Marker2D` hijos del spawner, dejando ambigua su ubicación. Como referencia de partida (asumiendo viewport de `1280x720` y el suelo visual cerca del borde inferior, en la misma altura Y que configuraste para el `FloorCollision` de la Fase 3):

| Marker2D | Position X | Position Y (relativa al piso) | Propósito |
|---|---|---|---|
| `SpawnPointGround` | `1350` | Igual a `Y_DEL_SUELO` (altura del piso) | Cactus, obstáculo que se esquiva saltando |
| `SpawnPointAirLow` | `1350` | `Y_DEL_SUELO - 150` aprox. | Pterodáctilo bajo, obliga a agacharse |
| `SpawnPointAirHigh` | `1350` | `Y_DEL_SUELO - 300` aprox. | Pterodáctilo alto, pasa por encima sin necesidad de reaccionar (o se esquiva corriendo) |

Estos valores son un punto de partida razonable, no exactos: ajustalos jugando y observando el tamaño real de tu sprite del Dino y su altura de salto (`jump_velocity` y `gravity` definidos en la Fase 2). El objetivo es que `SpawnPointAirLow` quede a una altura que el Dino **no pueda esquivar saltando** (solo agachándose), y que `SpawnPointAirHigh` quede lo suficientemente alto como para no representar un desafío real (o ajustalo más abajo si querés que también obligue a reaccionar).

### 📖 Conceptos clave de Godot explicados

| Concepto | Explicación breve |
|---|---|
| **`Area2D`** | Nodo de detección de colisiones **sin** física sólida (no bloquea el movimiento, no empuja cuerpos). Ideal para obstáculos, zonas de daño, ítems recolectables: solo necesitas saber "¿algo entró en esta zona?", no simular un choque físico real. |
| **`PackedScene`** | Es una escena (`.tscn`) "empaquetada" como recurso, que puedes instanciar dinámicamente en tiempo de ejecución con `.instantiate()`. Es el mecanismo estándar en Godot para generar copias de un objeto (como obstáculos) muchas veces durante el juego. |
| **`.instantiate()` / `add_child()`** | `instantiate()` crea una copia en memoria de la escena; `add_child()` la inserta realmente en el árbol de la escena para que se vuelva visible y activa. Sin `add_child()`, el nodo existe pero no aparece en el juego. |
| **`VisibleOnScreenNotifier2D`** | Nodo que emite señales (`screen_entered`, `screen_exited`) cuando el nodo padre entra o sale del viewport visible. Es la forma idiomática en Godot de saber cuándo destruir (`queue_free()`) un objeto que ya no se ve, liberando memoria automáticamente. |
| **`queue_free()`** | Marca un nodo para ser eliminado de forma segura al final del frame actual (a diferencia de `free()`, que lo elimina inmediatamente y puede causar errores si el nodo está siendo usado en ese momento). |
| **`Timer` con `one_shot = true`** | Un `Timer` normal se repite automáticamente (`autostart`/loop). Con `one_shot = true`, se dispara una sola vez y debes reiniciarlo manualmente (`timer.start()`), lo que te da control total para variar el tiempo de espera en cada disparo (spawn aleatorio). |
| **Señales (`timeout`, `screen_exited`)** | Es el sistema de eventos de Godot (equivalente al patrón Observer). En vez de que un nodo pregunte constantemente "¿ya pasó el tiempo?", el `Timer` **emite** la señal `timeout` cuando ocurre, y tu script se **conecta** a ella (`timer.timeout.connect(funcion)`) para reaccionar solo cuando sucede. |
| **Collision Layers y Masks** | Sistema de "capas" de físicas de Godot. `collision_layer` define **en qué capa vive** un objeto; `collision_mask` define **qué capas puede detectar/chocar**. Por ejemplo: el Dino puede estar en la capa `player`, con mask apuntando a `obstacles`; los obstáculos están en la capa `obstacles`. Así controlas exactamente qué colisiona con qué sin lógica manual de filtrado. Se configuran visualmente en el Inspector o con nombres en Project Settings > Layer Names > 2D Physics. |

### ✅ Criterio de aceptación
- [ ] Los cactus aparecen por el lado derecho de la pantalla a intervalos aleatorios y se mueven hacia la izquierda.
- [ ] Los pterodáctilos aparecen a distintas alturas (baja/alta) de forma también aleatoria.
- [ ] Ningún obstáculo se queda "vivo" en memoria tras salir de pantalla (puedes verificarlo con el Monitor de nodos del Debugger de Godot mientras el juego corre varios minutos).
- [ ] El intervalo entre spawns varía dentro del rango configurado, sin patrones repetitivos obvios.

---

## Fase 5: Colisiones y Game Over

### 🎯 Objetivo de la fase
Detectar cuándo el Dino choca con un obstáculo, detener completamente el bucle del juego (movimiento del suelo, spawns, física del jugador) y permitir reiniciar la partida.

### 🧩 Nodos específicos de Godot a utilizar
- `Area2D` (ya en el Dino o como hijo adicional para la hitbox de daño) — *nota:* si el Dino es `CharacterBody2D`, necesitas un `Area2D` extra como hijo suyo para detectar colisiones contra los obstáculos (los `CharacterBody2D` no emiten señales de colisión con `Area2D` por sí mismos).
- `CollisionShape2D`
- Autoload/Singleton `GameManager` (`Node` global, ver conceptos clave)

### 🛠 Paso a paso de implementación

1. En `Dino.tscn`, añade un `Area2D` hijo llamado `HurtBox`, con su propio `CollisionShape2D` (puede compartir tamaño con la colisión de pie/agachado, o ser una sola forma intermedia simplificada).
2. Configura las Collision Layers/Masks (Project Settings > Layer Names > 2D Physics):
   - Capa `player` → el `HurtBox` del Dino vive aquí.
   - Capa `obstacles` → los obstáculos (`Cactus`, `Pterodactyl`) viven aquí.
   - El `HurtBox` del Dino debe tener su `collision_mask` apuntando a `obstacles`.

   > ⚠️ **Aclaración imprescindible (no estaba en el roadmap original):** esta configuración de capas es para el `HurtBox`, que es un `Area2D` **hijo** del Dino, distinto del propio nodo raíz `Dino` (`CharacterBody2D`). Ya en la Fase 3 configuraste el `collision_mask` del `CharacterBody2D` raíz apuntando a la capa `"world"`, para que detecte el `FloorCollision` y `is_on_floor()` funcione. Ese ajuste **no se toca ni se pisa** con esta nuevo: son dos sistemas de física totalmente independientes conviviendo en el mismo nodo `Dino`:
   > - **Cuerpo raíz (`CharacterBody2D`)** → mask en `"world"` → detecta el piso físico, resuelve `move_and_slide()` y `is_on_floor()`.
   > - **`HurtBox` (`Area2D` hijo)** → mask en `"obstacles"` → detecta colisiones con obstáculos y dispara el Game Over.
   >
   > Si mezclás estas dos configuraciones (por ejemplo, poniendo `"obstacles"` en el mask del cuerpo raíz en vez del `HurtBox`), el Dino podría "chocar" físicamente contra los obstáculos como si fueran paredes sólidas, en vez de simplemente detectar el choque y disparar Game Over.
3. Crea el script `scripts/autoload/GameManager.gd`:

```gdscript
extends Node

signal game_over
signal game_started
signal score_updated(new_score: int)

var is_game_running: bool = false
var current_score: int = 0

func start_game() -> void:
	current_score = 0
	is_game_running = true
	game_started.emit()

func end_game() -> void:
	is_game_running = false
	game_over.emit()

func add_score(amount: int) -> void:
	if not is_game_running:
		return
	current_score += amount
	score_updated.emit(current_score)
```

4. Registra este script como **Autoload**: Project > Project Settings > Autoload, agrega `GameManager.gd` con el nombre `GameManager`.
5. En `Dino.gd`, conecta la señal de colisión del `HurtBox`:

```gdscript
@onready var hurt_box: Area2D = $HurtBox

func _ready() -> void:
	hurt_box.area_entered.connect(_on_hurt_box_area_entered)

func _on_hurt_box_area_entered(_area: Area2D) -> void:
	GameManager.end_game()
```

6. En `Dino.gd`, `Ground.gd` y `ObstacleSpawner.gd`, añade una comprobación al inicio de `_process`/`_physics_process` para detener el movimiento cuando el juego terminó:

```gdscript
func _physics_process(delta: float) -> void:
	if not GameManager.is_game_running:
		return
	# ... resto del código de movimiento
```

7. Conecta la acción `restart` (definida en Fase 1) para reiniciar la escena completa cuando el juego terminó:

```gdscript
func _unhandled_input(event: InputEvent) -> void:
	if not GameManager.is_game_running and Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
```

*(Este bloque puede vivir en tu script de `Main.gd`, que crearás formalmente en la Fase 7).*

### 📖 Conceptos clave de Godot explicados

| Concepto | Explicación breve |
|---|---|
| **Autoload / Singleton** | Un script registrado como Autoload se carga una única vez al iniciar el juego y es accesible desde **cualquier** script del proyecto usando su nombre directamente (ej. `GameManager.end_game()`), sin necesidad de referencias manuales entre nodos. Es el patrón estándar en Godot para manejar estado global (puntuación, estado del juego, configuración). |
| **`Area2D.area_entered` vs `body_entered`** | `Area2D` emite `area_entered` cuando **otra `Area2D`** entra en su zona, y `body_entered` cuando entra un `PhysicsBody2D` (como `CharacterBody2D` o `StaticBody2D`). Como tanto el `HurtBox` del Dino como los obstáculos son `Area2D`, usamos `area_entered`. |
| **`reload_current_scene()`** | Método de `SceneTree` que recarga la escena actual desde cero, reseteando todas las variables y posiciones de nodos a su estado inicial. Es la forma más simple de "reiniciar partida" sin gestionar manualmente el reseteo de cada variable. |
| **`_unhandled_input(event)`** | Función especial que se llama cuando ocurre un evento de input que **ningún otro nodo consumió antes** (a diferencia de `_input`, que se llama para todo evento sin importar si ya fue procesado). Útil para inputs "globales" como reiniciar partida. |
| **Guard clause con `is_game_running`** | Patrón de programación defensiva: en vez de envolver todo el código en un `if`, cortas la ejecución temprano con `return` si la condición para continuar no se cumple. Aquí evita que el suelo/obstáculos/Dino se sigan moviendo tras el Game Over. |

### ✅ Criterio de aceptación
- [ ] Al chocar el Dino con cualquier obstáculo, el juego se detiene por completo (suelo, spawner y Dino dejan de moverse).
- [ ] No es posible saltar, agacharse ni generar más obstáculos mientras el juego está en estado "Game Over".
- [ ] Presionar la tecla de reinicio (`restart`) reinicia la partida completamente desde cero.
- [ ] No hay falsos positivos de colisión (el Dino no "muere" sin tocar visualmente un obstáculo).

---

## Fase 6: Sistema de Puntuación (Score y High Score)

### 🎯 Objetivo de la fase
Implementar un contador de puntuación basado en distancia/tiempo sobrevivido, y persistir el récord más alto (high score) en disco para que se mantenga entre sesiones de juego.

### 🧩 Nodos específicos de Godot a utilizar
- `Timer` (para incrementar el score a intervalos regulares) — *alternativa:* incrementar directamente en `_process` usando `delta`, sin `Timer`.
- (Ampliación del Autoload `GameManager` ya creado en Fase 5)

### 🛠 Paso a paso de implementación

1. Amplía `GameManager.gd` con lógica de puntuación por tiempo y persistencia usando `ConfigFile`:

```gdscript
extends Node

signal game_over
signal game_started
signal score_updated(new_score: int)

const SAVE_PATH: String = "user://savegame.save"
const SCORE_PER_SECOND: float = 10.0

var is_game_running: bool = false
var current_score: float = 0.0
var high_score: int = 0

func _ready() -> void:
	_load_high_score()

func start_game() -> void:
	current_score = 0.0
	is_game_running = true
	game_started.emit()
	score_updated.emit(0)

func end_game() -> void:
	is_game_running = false
	_check_and_save_high_score()
	game_over.emit()

func _process(delta: float) -> void:
	if not is_game_running:
		return
	current_score += SCORE_PER_SECOND * delta
	score_updated.emit(get_score_int())

func get_score_int() -> int:
	return int(current_score)

func _check_and_save_high_score() -> void:
	if get_score_int() > high_score:
		high_score = get_score_int()
		_save_high_score()

func _save_high_score() -> void:
	var config: ConfigFile = ConfigFile.new()
	config.set_value("score", "high_score", high_score)
	config.save(SAVE_PATH)

func _load_high_score() -> void:
	var config: ConfigFile = ConfigFile.new()
	var error: Error = config.load(SAVE_PATH)
	if error == OK:
		high_score = config.get_value("score", "high_score", 0)
	else:
		high_score = 0
```

2. Nota: mover el incremento de puntaje a `_process` del propio Autoload (en vez de un `Timer` separado) simplifica el código, ya que un `Node` Autoload también tiene su ciclo de `_process`.
3. Verifica que `user://` sea la ruta correcta para guardar datos persistentes (ver conceptos clave).
4. Prueba el flujo completo: jugar, perder con un score alto, cerrar el juego completamente, reabrirlo, y confirmar que el high score se mantuvo.

### 📖 Conceptos clave de Godot explicados

| Concepto | Explicación breve |
|---|---|
| **`ConfigFile`** | Clase integrada de Godot para leer/escribir archivos de configuración simples en formato `.ini`-like, organizados en secciones y claves (`set_value(seccion, clave, valor)`). Es la forma más simple de guardar datos pequeños como high scores, configuración de audio, etc., sin lidiar con serialización manual. |
| **`user://`** | Ruta especial (distinta de `res://`) que apunta a una carpeta persistente específica del sistema operativo del usuario (en Windows suele ser `%APPDATA%/Godot/app_userdata/NombreDelProyecto/`). A diferencia de `res://` (los archivos del proyecto, de solo lectura una vez exportado), `user://` es donde **debes** guardar cualquier dato que el juego genere en tiempo de ejecución (saves, configuración, high scores). |
| **`Error` y códigos de retorno (`OK`)** | Muchas funciones de Godot (como `config.load()`) devuelven un valor de tipo `Error` en vez de lanzar excepciones. `OK` (valor `0`) indica éxito; cualquier otro valor indica un tipo específico de fallo (archivo no encontrado, permisos, etc.). Es buena práctica siempre comprobar este valor antes de asumir que la operación funcionó (por ejemplo, la primera vez que se ejecuta el juego, el archivo de save no existirá aún). |
| **Autoload con `_process` propio** | Cualquier nodo, incluidos los Autoload, puede implementar `_process`/`_physics_process`. Como el `GameManager` está siempre presente en el árbol de escena (por ser Autoload), es un lugar perfectamente válido para lógica global que debe ejecutarse cada frame, como el incremento de puntuación. |

### ✅ Criterio de aceptación
- [ ] El score aumenta de forma constante y predecible mientras el juego está activo.
- [ ] El score se detiene exactamente en el momento del Game Over (no sigue sumando).
- [ ] Al superar el high score anterior, este se actualiza y persiste en disco.
- [ ] Cerrar y volver a abrir el juego conserva el high score guardado previamente.

---

## Fase 7: Interfaz de Usuario (UI/HUD)

### 🎯 Objetivo de la fase
Construir las pantallas de Inicio, HUD en vivo (score/high score) y Game Over, conectadas reactivamente al estado del `GameManager` mediante señales.

### 🧩 Nodos específicos de Godot a utilizar
- `CanvasLayer` (contenedor de UI que ignora la cámara/scroll del mundo del juego)
- `Control`, `Label`, `Panel`, `VBoxContainer`/`CenterContainer` (construcción de UI)
- `Button` (reiniciar partida, iniciar partida)

### 🛠 Paso a paso de implementación

1. Crea la escena principal `scenes/main/Main.tscn` si aún no existe formalmente:
   - Raíz: `Node2D` (nómbralo `Main`).
   - Hijos: instancias de `Dino.tscn`, `Ground.tscn`, `ObstacleSpawner.tscn` (de fases anteriores).
2. Añade un `CanvasLayer` hijo llamado `HUD`, y dentro de él la estructura de UI:
   ```
   HUD (CanvasLayer)
   ├── ScoreLabel (Label) — esquina superior derecha
   ├── HighScoreLabel (Label) — junto al ScoreLabel
   ├── StartScreen (Control, full rect)
   │   ├── TitleLabel (Label)
   │   └── StartButton (Button) — "Presiona para empezar"
   └── GameOverScreen (Control, full rect, oculto por defecto)
       ├── GameOverLabel (Label)
       ├── FinalScoreLabel (Label)
       └── RestartHint (Label) — "Presiona Enter para reintentar"
   ```

   > ⚠️ **Paso no explicado en el roadmap original: cómo lograr el "full rect".** El diagrama menciona que `StartScreen` y `GameOverScreen` deben ser `Control, full rect`, pero no dice cómo configurarlo. En el editor:
   > 1. Seleccioná el nodo `Control` (`StartScreen` o `GameOverScreen`).
   > 2. En la barra superior del viewport 2D, vas a ver un ícono llamado **"Layout"** (aparece solo cuando el nodo seleccionado es un `Control`).
   > 3. Hacé click y elegí el preset **"Full Rect"**.
   > 4. Esto ancla los 4 bordes del `Control` a los 4 bordes del viewport, así ocupa toda la pantalla sin importar la resolución. Sin este paso, el `Control` queda con tamaño `(0, 0)` por defecto y no se ve nada dentro de él, aunque sus hijos (`Label`, `Button`) técnicamente existan.
   > 5. Repetí lo mismo para cada `Control` que deba cubrir toda la pantalla. Los `Label` y `Button` individuales dentro de esos contenedores no necesitan "Full Rect"; para esos alcanza con centrarlos manualmente o envolverlos en un `VBoxContainer`/`CenterContainer` como sugiere la tabla de conceptos.

3. Script `HUD.gd`:

```gdscript
extends CanvasLayer

@onready var score_label: Label = $ScoreLabel
@onready var high_score_label: Label = $HighScoreLabel
@onready var start_screen: Control = $StartScreen
@onready var game_over_screen: Control = $GameOverScreen
@onready var final_score_label: Label = $GameOverScreen/FinalScoreLabel
@onready var start_button: Button = $StartScreen/StartButton

func _ready() -> void:
	GameManager.score_updated.connect(_on_score_updated)
	GameManager.game_started.connect(_on_game_started)
	GameManager.game_over.connect(_on_game_over)
	start_button.pressed.connect(_on_start_button_pressed)

	high_score_label.text = "HI %04d" % GameManager.high_score
	start_screen.visible = true
	game_over_screen.visible = false

func _on_score_updated(new_score: int) -> void:
	score_label.text = "%04d" % new_score

func _on_game_started() -> void:
	start_screen.visible = false
	game_over_screen.visible = false

func _on_game_over() -> void:
	game_over_screen.visible = true
	final_score_label.text = "Score: %04d" % GameManager.get_score_int()
	high_score_label.text = "HI %04d" % GameManager.high_score

func _on_start_button_pressed() -> void:
	GameManager.start_game()
```

4. Script `Main.gd` (adjunto al nodo raíz `Main`), encargado de reiniciar la escena y de que el juego **no arranque solo**:

```gdscript
extends Node2D

func _ready() -> void:
	get_tree().paused = false

func _unhandled_input(event: InputEvent) -> void:
	if not GameManager.is_game_running and Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
```

5. Asegúrate de que en `Dino.gd`, `Ground.gd` y `ObstacleSpawner.gd`, el movimiento **también** respete `GameManager.is_game_running` desde el inicio (es decir, que no se muevan antes de presionar "Start").
6. Prueba el flujo completo: Pantalla de inicio → Start → juego corriendo con HUD actualizándose en vivo → colisión → pantalla de Game Over con score final → reinicio.

### 📖 Conceptos clave de Godot explicados

| Concepto | Explicación breve |
|---|---|
| **`CanvasLayer`** | Nodo que dibuja su contenido en una capa separada del "mundo del juego" (2D world), ignorando transformaciones de cámara. Es indispensable para HUDs: quieres que el score se quede fijo en pantalla sin importar cómo se mueva o escale la escena del juego. |
| **`Control` y layout (Anchors/Containers)** | `Control` es la clase base de todos los nodos de UI en Godot. Los `Containers` (`VBoxContainer`, `CenterContainer`, etc.) organizan automáticamente a sus hijos (verticalmente, centrados, etc.), evitando que tengas que posicionar manualmente cada elemento en píxeles fijos. |
| **Arquitectura orientada a señales para UI** | En vez de que el HUD pregunte constantemente "¿cuál es el score actual?" en cada frame, el HUD se **suscribe** a las señales del `GameManager` (`score_updated`, `game_over`, etc.) y solo actualiza su texto cuando realmente cambia algo. Es más eficiente y es el patrón idiomático en Godot (similar a Observer/Pub-Sub). |
| **Formato de string `"%04d"`** | Sintaxis de formateo de Godot (similar a `printf` de C) para rellenar un número con ceros a la izquierda hasta 4 dígitos — el clásico "0000" del juego de Chrome. |
| **Separación de responsabilidades (HUD vs GameManager)** | El `GameManager` no sabe nada de `Label`s ni `Button`s: solo emite señales con datos crudos (`int`, `bool`). El `HUD` es el único responsable de traducir esos datos a texto visual. Este desacoplamiento facilita cambiar el diseño visual sin tocar la lógica del juego. |

### ✅ Criterio de aceptación
- [ ] Al abrir el juego, se muestra la pantalla de inicio y **nada se mueve** hasta presionar "Start".
- [ ] Durante la partida, el score en el HUD se actualiza en tiempo real de forma fluida.
- [ ] Al perder, aparece la pantalla de Game Over mostrando el score final y el high score actualizado si corresponde.
- [ ] El flujo completo (Inicio → Jugar → Game Over → Reinicio → Jugar de nuevo) funciona sin errores ni estados colgados.

---

## Fase 8: Pulido y Jugabilidad (Juice)

### 🎯 Objetivo de la fase
Añadir dificultad progresiva (el juego se vuelve más rápido con el tiempo), sonido, y pequeños detalles de "juice" (feedback sensorial) que transforman un prototipo funcional en un juego que se siente satisfactorio de jugar.

### 🧩 Nodos específicos de Godot a utilizar
- `AudioStreamPlayer` (efectos de sonido puntuales: salto, choque, punto extra)
- `AudioStreamPlayer` adicional o `MusicPlayer` (música de fondo, si aplica)
- (Reutilización del Autoload `GameManager` para centralizar la velocidad global del juego)

### 🛠 Paso a paso de implementación

1. **Dificultad progresiva — velocidad global centralizada.**
   Añade al `GameManager` una variable de velocidad global que todos los sistemas (suelo, obstáculos) consulten en vez de tener su propia velocidad fija:

```gdscript
# Añadir en GameManager.gd
const BASE_SPEED: float = 600.0
const MAX_SPEED: float = 1400.0
const SPEED_INCREASE_PER_SECOND: float = 8.0

var current_speed: float = BASE_SPEED

func start_game() -> void:
	current_speed = BASE_SPEED
	current_score = 0.0
	is_game_running = true
	game_started.emit()
	score_updated.emit(0)

func _process(delta: float) -> void:
	if not is_game_running:
		return
	current_score += SCORE_PER_SECOND * delta
	current_speed = min(current_speed + SPEED_INCREASE_PER_SECOND * delta, MAX_SPEED)
	score_updated.emit(get_score_int())
```

   Luego, en `Ground.gd` y en `Obstacle.gd`, reemplaza la variable local `speed`/`scroll_speed` por una lectura de `GameManager.current_speed` en cada frame de movimiento.

2. **Efectos de sonido.** Añade nodos `AudioStreamPlayer` en las escenas correspondientes:
   - En `Dino.tscn`: uno para el salto (reproducido cuando se presiona `jump`) y otro para la colisión/muerte (reproducido en `_on_hurt_box_area_entered`).
   - En `GameManager` o `HUD`: uno opcional para un sonido de "hito" cada cierta cantidad de puntos (ej. cada 100 puntos, similar al beep del juego original).

```gdscript
@onready var jump_sound: AudioStreamPlayer = $JumpSound
@onready var hit_sound: AudioStreamPlayer = $HitSound

# Dentro del bloque de salto:
if Input.is_action_just_pressed("jump") and is_on_floor():
	velocity.y = jump_velocity
	jump_sound.play()

func _on_hurt_box_area_entered(_area: Area2D) -> void:
	hit_sound.play()
	GameManager.end_game()
```

3. **Música de fondo (opcional).** Añade un `AudioStreamPlayer` en `Main.tscn` con música en loop, iniciado en `_on_game_started` y detenido/atenuado en `_on_game_over`.
4. **Screen shake sutil al chocar (juice extra, opcional).** Puedes animar la `Camera2D` con un pequeño offset aleatorio durante unos frames al morir, usando un `Tween`.
5. **Parpadeo o flash del Dino al morir (juice extra, opcional).** Usa un `Tween` sobre la propiedad `modulate` del `Sprite` para un efecto de parpadeo antes de mostrar Game Over.
6. **Ajuste fino de sensación ("game feel").** Prueba distintos valores de `jump_velocity`, `gravity` y `SPEED_INCREASE_PER_SECOND` hasta que el salto se sienta "justo" (ni flotante ni demasiado brusco) y la curva de dificultad sea desafiante pero justa.

### 📖 Conceptos clave de Godot explicados

| Concepto | Explicación breve |
|---|---|
| **`AudioStreamPlayer` vs `AudioStreamPlayer2D`** | `AudioStreamPlayer` reproduce sonido sin atenuación posicional (ideal para SFX de UI/HUD y música). `AudioStreamPlayer2D` atenúa el volumen según la distancia a un punto 2D en el mundo (útil si quisieras, por ejemplo, sonido de un obstáculo específico). Para un runner simple como este, `AudioStreamPlayer` normal es suficiente para todo. |
| **Fuente de verdad única (`GameManager.current_speed`)** | Concepto de diseño (no exclusivo de Godot): en vez de que cada sistema (suelo, cada obstáculo) mantenga su propia velocidad de forma independiente, centralizas ese valor en un solo lugar. Así, aumentar la dificultad global es cambiar **una** variable, y todo el juego reacciona de forma consistente. |
| **`Tween`** | Nodo/clase de Godot para animar propiedades de cualquier nodo a lo largo del tiempo de forma declarativa (ej. `tween.tween_property(sprite, "modulate:a", 0.0, 0.2)`), sin necesidad de escribir manualmente interpolación cuadro a cuadro. Ideal para efectos de juice rápidos: shakes, flashes, escalados, fade in/out. |
| **`modulate`** | Propiedad de color que multiplica el color/alpha de cualquier `CanvasItem` (sprites, labels, etc.). Cambiar su canal alfa (`modulate:a`) es la forma más simple de crear efectos de parpadeo o desvanecimiento. |
| **"Game Feel" / Juice** | Término de diseño de juegos que se refiere a los pequeños detalles de feedback (sonido, vibración visual, partículas, easing en animaciones) que no cambian la lógica del juego pero incrementan drásticamente la satisfacción al jugarlo. Suele ser el último 10% de trabajo que aporta el 50% de la percepción de calidad. |

### ✅ Criterio de aceptación
- [ ] La velocidad del juego (suelo y obstáculos) aumenta de forma perceptible y suave a medida que pasa el tiempo, hasta un límite máximo razonable.
- [ ] Se reproducen efectos de sonido claros para saltar y para chocar/perder.
- [ ] (Si se implementó) La música de fondo suena durante la partida y se detiene/cambia en Game Over.
- [ ] El juego se siente "completo": desde la pantalla de inicio hasta el Game Over, cada acción del jugador tiene una respuesta sensorial (visual o sonora) clara.

---

## 🏁 Checklist Final del Proyecto

- [x] El juego arranca en una pantalla de inicio clara.
- [x] El Dino corre, salta y se agacha con física consistente.
- [x] El suelo se recicla infinitamente sin cortes visibles.
- [x] Los obstáculos (cactus y pterodáctilos) se generan de forma aleatoria y equilibrada.
- [x] Las colisiones terminan la partida de forma confiable y sin falsos positivos.
- [x] El score aumenta con el tiempo y el high score persiste entre sesiones.
- [x] El HUD refleja en vivo el estado del juego (score, high score, Game Over).
- [x] La dificultad escala progresivamente y el juego incluye sonido.
- [x] Se puede reiniciar la partida indefinidamente sin bugs ni fugas de memoria (nodos huérfanos).

**¡Felicidades! 🦖 Con este checklist completo, tienes un Dino Endless Runner funcional, pulido y jugable de principio a fin.**