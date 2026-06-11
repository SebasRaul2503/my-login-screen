# my-login-screen — Temas de login SDDM para Arch + Hyprland

Colección de **temas SDDM** hechos a mano en QML. Cada tema vive en **su propia
rama** para mantenerlos aislados entre sí; esta rama `main` es solo el **índice**
que te lleva al tema correcto.

> 👉 Elige un tema en la tabla y cambia a su rama. `main` no contiene ningún tema
> instalable: solo este índice y la documentación de diseño en `docs/superpowers/`.

## Temas disponibles

| Tema | Vista previa | Rama | Estado |
|---|---|---|---|
| **MatrixRain** — lluvia de katakana verde sobre negro, cajas estilo terminal con glow | [![MatrixRain](docs/screenshots/matrixrain.png)](https://github.com/SebasRaul2503/my-login-screen/tree/feat/matrixrain-theme) | [`feat/matrixrain-theme`](https://github.com/SebasRaul2503/my-login-screen/tree/feat/matrixrain-theme) | ✅ funcional |

## Cómo usar un tema

```bash
git clone https://github.com/SebasRaul2503/my-login-screen.git
cd my-login-screen
git switch feat/matrixrain-theme   # o la rama del tema que quieras
```

El `README.md` de cada rama incluye requisitos, cómo probar sin instalar
(`sddm-greeter --test-mode`), instalación, activación con red de seguridad y
cómo revertir.

## Añadir un tema nuevo

1. Parte de `main` y crea una rama `feat/<nombre>-theme`.
2. Construye el tema en su propio directorio (p. ej. `MiTema/`) con su
   `metadata.desktop`, `theme.conf`, `Main.qml` y componentes.
3. Añade un `README.md` con runbook y una captura en `docs/screenshots/`.
4. Vuelve a `main` y agrega una fila a la tabla de arriba apuntando a la rama.

## Documentación de diseño

Specs y planes detallados (compartidos por todas las ramas) en
[`docs/superpowers/`](docs/superpowers/).
