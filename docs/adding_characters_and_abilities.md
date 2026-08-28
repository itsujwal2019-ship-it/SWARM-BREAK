# Adding Characters and Abilities to SWARM//BREAK

This guide explains exactly what to create and modify when adding a new character or a new ability.

---

## Quick Reference

| I want to...                        | Files to create / modify                        |
|-------------------------------------|-------------------------------------------------|
| Add a new character                 | Create one `.tres` file                         |
| Add a new ability                   | Create one `.gd` file                           |
| Add a new ability with a projectile | Create one `.gd` + one `.tscn`                  |
| Assign abilities to a character     | Edit the character's `.tres` file               |

---

## Part 1 — Adding a New Ability

### Where abilities live

```
features/abilities/
```

### Step 1 — Create the ability script

Create a new `.gd` file in `features/abilities/`.

```
features/abilities/my_ability.gd
```

Every ability extends `Ability`, which lives at `features/abilities/ability.gd`.

**Minimum template:**

```gdscript
class_name MyAbility
extends Ability

# --- Configuration (set these in the .tres or in code) ---
@export var my_value: float = 50.0

# --- Behavior ---
func _execute(owner_node: Node2D) -> void:
    # owner_node is the Player who activated this ability.
    # Put your ability logic here.
    pass
```

`_execute` is called automatically by `Ability.activate()` after the cooldown check passes.
You do not need to call `super._execute()`.

### What `owner_node` gives you

Inside `_execute`, `owner_node` is the `Player` node. From it you can reach:

| What you need                        | How to get it                                                   |
|--------------------------------------|-----------------------------------------------------------------|
| Player's world position              | `owner_node.global_position`                                    |
| Aim direction (toward mouse)         | `owner_node.get_aim_direction()`                                |
| Player's health component            | `owner_node.get_node("HealthComponent") as HealthComponent`     |
| All allies (group: `"allies"`)       | `owner_node.get_tree().get_nodes_in_group("allies")`            |
| All enemies (group: `"enemies"`)     | `owner_node.get_tree().get_nodes_in_group("enemies")`           |
| Projectile container (group)         | `owner_node.get_tree().get_first_node_in_group("projectiles")`  |
| Status effects on an enemy           | `enemy.get_node_or_null("StatusEffectComponent")`               |

### Cooldown

Set `cooldown` in the `.tres` file or as a default in the script.

```gdscript
@export var cooldown: float = 5.0  # inherited from Ability base class
```

The base class handles the timer. You only implement `_execute`.

---

### Ability type examples

#### Instant area effect (no projectile)

```gdscript
class_name BlastAbility
extends Ability

@export var damage: float = 60.0
@export var effect_range: float = 200.0

func _execute(owner_node: Node2D) -> void:
    for enemy in owner_node.get_tree().get_nodes_in_group("enemies"):
        if owner_node.global_position.distance_to(enemy.global_position) <= effect_range:
            if enemy.has_method("take_damage"):
                enemy.take_damage(damage)
```

> **Note:** Do NOT name the variable `range`. It shadows a GDScript built-in.
> Use `effect_range`, `radius`, or `blast_radius` instead.

#### Heal allies

```gdscript
class_name GroupHealAbility
extends Ability

@export var heal_amount: float = 40.0
@export var effect_range: float = 250.0

func _execute(owner_node: Node2D) -> void:
    for ally in owner_node.get_tree().get_nodes_in_group("allies"):
        if ally is Node2D:
            var dist := owner_node.global_position.distance_to(ally.global_position)
            if dist <= effect_range and ally.has_method("heal"):
                ally.heal(heal_amount)
```

#### Apply status effect to enemies

```gdscript
class_name StunAbility
extends Ability

@export var stun_duration: float = 2.0
@export var effect_range: float = 300.0

func _execute(owner_node: Node2D) -> void:
    for enemy in owner_node.get_tree().get_nodes_in_group("enemies"):
        if owner_node.global_position.distance_to(enemy.global_position) <= effect_range:
            var status := enemy.get_node_or_null("StatusEffectComponent") as StatusEffectComponent
            if status:
                status.apply_effect(StatusEffectComponent.EffectType.FREEZE, stun_duration, 1.0)
```

Available effect types: `FREEZE`, `SLOW`, `HEAL_OVER_TIME`

#### Projectile ability

Create two files: one ability script and one projectile scene.

**Ability script** (`features/abilities/my_shot.gd`):

```gdscript
class_name MyShotAbility
extends Ability

const PROJECTILE_SCENE := preload("res://features/abilities/my_projectile.tscn")

@export var damage: float = 35.0
@export var speed: float = 700.0
@export var lifetime: float = 2.0

func _execute(owner_node: Node2D) -> void:
    var container := owner_node.get_tree().get_first_node_in_group("projectiles")
    if container == null:
        container = owner_node.get_tree().current_scene

    var projectile: Bullet = PROJECTILE_SCENE.instantiate()
    projectile.direction = owner_node.get_aim_direction()
    projectile.speed = speed
    projectile.damage = damage
    projectile.lifetime = lifetime
    projectile.global_position = owner_node.global_position
    container.add_child(projectile)
```

**Projectile scene** (`features/abilities/my_projectile.tscn`):

```
[gd_scene format=3]

[ext_resource type="Script" path="res://features/weapons/bullet.gd" id="1"]

[sub_resource type="CircleShape2D" id="1"]
radius = 8.0

[node name="MyProjectile" type="Area2D"]
script = ExtResource("1")
collision_layer = 4
collision_mask = 24

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
shape = SubResource("1")

[node name="Body" type="Polygon2D" parent="."]
polygon = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)
color = Color(1.0, 0.5, 0.0, 1.0)
```

> Reuse `bullet.gd` for standard projectiles (move, hit hurtbox, die).
> Create a script that `extends Bullet` only if you need extra behavior on hit (e.g., slow, pierce, chain).

#### Projectile that applies a status effect on hit

```gdscript
# features/abilities/my_special_projectile_node.gd
class_name MySpecialProjectileNode
extends Bullet   # inherits movement, lifetime, collision

@export var slow_duration: float = 2.0

func _on_area_entered(area: Area2D) -> void:
    if area is HurtboxComponent:
        area.receive_damage(damage)
        var status := area.get_parent().get_node_or_null("StatusEffectComponent") as StatusEffectComponent
        if status:
            status.apply_effect(StatusEffectComponent.EffectType.SLOW, slow_duration, 0.5)
        queue_free()
```

---

### Visual feedback (optional but recommended)

Any ability can draw a temporary circle to show its radius:

```gdscript
func _show_flash(owner_node: Node2D, radius: float, color: Color) -> void:
    var circle := Polygon2D.new()
    var verts := PackedVector2Array()
    for i in 24:
        var a := (float(i) / 24.0) * TAU
        verts.append(Vector2(cos(a), sin(a)) * radius)
    circle.polygon = verts
    circle.color = color
    circle.global_position = owner_node.global_position
    owner_node.get_tree().current_scene.add_child(circle)
    owner_node.get_tree().create_timer(0.25).timeout.connect(circle.queue_free)
```

Call it at the end of `_execute`:

```gdscript
_show_flash(owner_node, effect_range, Color(1.0, 0.5, 0.1, 0.4))
```

---

## Part 2 — Adding a New Character

### Where characters live

```
features/characters/
```

### Step 1 — Create the `.tres` resource file

Create a new file:

```
features/characters/my_character.tres
```

**Template:**

```gdresource
[gd_resource type="Resource" script_class="CharacterDefinition" format=3 uid="uid://charXXXXX"]

[ext_resource type="Script" path="res://features/characters/character_definition.gd" id="1_def"]
[ext_resource type="Script" path="res://features/abilities/my_ability_1.gd" id="2_ab1"]
[ext_resource type="Script" path="res://features/abilities/my_ability_2.gd" id="3_ab2"]

[sub_resource type="Resource" id="Resource_ab1"]
script = ExtResource("2_ab1")
ability_name = "My First Ability"
cooldown = 5.0
my_value = 40.0

[sub_resource type="Resource" id="Resource_ab2"]
script = ExtResource("3_ab2")
ability_name = "My Second Ability"
cooldown = 10.0
my_other_value = 200.0

[resource]
script = ExtResource("1_def")
character_id = "my_character"
display_name = "My Character"
role = 2
max_health = 150.0
movement_speed = 240.0
ability_1 = SubResource("Resource_ab1")
ability_2 = SubResource("Resource_ab2")
```

### Step 2 — Set the role

`role` is an integer from the `CharacterRole.Role` enum:

| Value | Role    |
|-------|---------|
| 0     | Tank    |
| 1     | Support |
| 2     | Damage  |
| 3     | Control |

### Step 3 — Configure ability properties

Each `[sub_resource]` block is an instance of your ability class.
The properties you can set are the `@export` variables defined in that ability's `.gd` file.

For example, if `my_ability_1.gd` exports:

```gdscript
@export var damage: float = 50.0
@export var effect_range: float = 200.0
```

Then in the `.tres` you write:

```gdresource
[sub_resource type="Resource" id="Resource_ab1"]
script = ExtResource("2_ab1")
ability_name = "Blast"
cooldown = 6.0
damage = 75.0
effect_range = 180.0
```

### Step 4 — Register the character in `game.gd`

Open `features/game/game.gd` and add the path to the `CHARACTER_DEFS` array:

```gdscript
const CHARACTER_DEFS := [
    "res://features/characters/fire_wizard.tres",
    "res://features/characters/ice_wizard.tres",
    "res://features/characters/healer.tres",
    "res://features/characters/tank.tres",
    "res://features/characters/my_character.tres",  # <-- add here
]
```

That's it. Tab will now cycle through your character.

---

## Part 3 — Using an Existing Ability on a New Character

Abilities are reusable. You can assign any ability to any character.

In your character's `.tres`, reference an existing ability script:

```gdresource
[ext_resource type="Script" path="res://features/abilities/fireball.gd" id="2_ab1"]

[sub_resource type="Resource" id="Resource_fireball"]
script = ExtResource("2_ab1")
ability_name = "Fireball"
cooldown = 2.0       # override the default
damage = 30.0        # configure it differently for this character
speed = 800.0
lifetime = 3.0
```

The same `FireballAbility` class, different configuration.

---

## Part 4 — Checklist

### New ability only

- [ ] Create `features/abilities/my_ability.gd` extending `Ability`
- [ ] Add `class_name MyAbility`
- [ ] Implement `_execute(owner_node: Node2D)`
- [ ] Export any configurable values with `@export`
- [ ] Do NOT name any variable `range` (GDScript built-in conflict)
- [ ] If it needs a projectile: also create `my_projectile.tscn`

### New character only (using existing abilities)

- [ ] Create `features/characters/my_character.tres`
- [ ] Set `character_id`, `display_name`, `role`, `max_health`, `movement_speed`
- [ ] Reference existing ability scripts and configure their properties
- [ ] Add the `.tres` path to `CHARACTER_DEFS` in `features/game/game.gd`

### New character with new abilities

- [ ] Do both of the above

---

## Part 5 — File Reference

| File | Purpose |
|------|---------|
| `features/abilities/ability.gd` | Base class for all abilities |
| `features/abilities/ability_controller.gd` | Loads and activates abilities on the player |
| `features/characters/character_definition.gd` | Data container for a character |
| `features/characters/character_role.gd` | Role enum (Tank / Support / Damage / Control) |
| `features/combat/health_component.gd` | Health, shield, damage, death |
| `features/combat/status_effect_component.gd` | Freeze, Slow, Heal Over Time |
| `features/combat/hurtbox_component.gd` | Receives hits from bullets/projectiles |
| `features/weapons/bullet.gd` | Standard projectile (reuse or extend) |
| `features/game/game.gd` | CHARACTER_DEFS list lives here |

### Existing ability scripts (ready to reuse)

| Script | What it does |
|--------|-------------|
| `area_heal.gd` | Instantly heals allies in a radius |
| `heal_over_time.gd` | Applies HoT to allies in a radius |
| `shield.gd` | Gives the player temporary shield HP |
| `taunt.gd` | Forces nearby enemies to target the caster |
| `fireball.gd` | Fires a high-damage projectile toward mouse |
| `area_explosion.gd` | Damages all enemies in a radius |
| `ice_projectile.gd` | Fires a slowing projectile |
| `freeze_area.gd` | Freezes all enemies in a radius |
