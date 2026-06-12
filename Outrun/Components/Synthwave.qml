import QtQuick 2.11

// Synthwave / outrun sunset, rendered in a single GLSL fragment shader.
//   · gradient sky (indigo → magenta) with a few stars
//   · a retro sun with horizontal scanline gaps + glow
//   · a neon perspective grid scrolling toward the viewer (vanishing at the sun)
Item {
    id: scene

    property color mag:  config.Accent  || "#ff4fd8"   // magenta neon
    property color cyan: config.Accent2 || "#41f0ff"   // cyan neon
    property color sunTop: config.SunTop || "#ffe24a"  // sun top (yellow)
    property color sunBot: config.SunBot || "#ff2e8e"  // sun bottom (pink)
    property real gridSpeed: parseFloat(config.GridSpeed) || 1.0

    ShaderEffect {
        anchors.fill: parent
        property real iTime: 0
        property size iResolution: Qt.size(width, height)
        property color cMag: scene.mag
        property color cCyan: scene.cyan
        property color cSunTop: scene.sunTop
        property color cSunBot: scene.sunBot
        property real spd: scene.gridSpeed

        NumberAnimation on iTime {
            from: 0; to: 100000.0; duration: 100000000
            loops: Animation.Infinite; running: true
        }

        fragmentShader: "
            varying highp vec2 qt_TexCoord0;
            uniform lowp float qt_Opacity;
            uniform highp float iTime;
            uniform highp vec2 iResolution;
            uniform lowp vec4 cMag;
            uniform lowp vec4 cCyan;
            uniform lowp vec4 cSunTop;
            uniform lowp vec4 cSunBot;
            uniform highp float spd;

            highp float hash21(highp vec2 p){
                p = fract(p * vec2(123.34, 456.21));
                p += dot(p, p + 45.32);
                return fract(p.x * p.y);
            }

            void main(){
                highp vec2 uv = qt_TexCoord0;
                highp float asp = iResolution.x / iResolution.y;
                highp float t = iTime * spd;

                highp float horizon = 0.58;
                highp float sunCX = 0.60;
                highp float sunCY = 0.40;
                highp float sunR  = 0.165;

                highp vec3 col;

                if(uv.y < horizon){
                    // ---- sky gradient ----
                    col = mix(vec3(0.06, 0.02, 0.16),               // zenith indigo
                              vec3(0.45, 0.08, 0.42),               // horizon magenta
                              smoothstep(0.0, horizon, uv.y));
                    // warm band right at the horizon
                    col += vec3(0.5, 0.18, 0.25) * smoothstep(0.16, 0.0, horizon - uv.y);

                    // ---- stars (upper sky) — soft round points ----
                    highp vec2 sp = vec2(uv.x * asp, uv.y) * 80.0;
                    highp vec2 sid = floor(sp);
                    highp float sh = hash21(sid);
                    highp float star = smoothstep(0.10, 0.0, length(fract(sp) - 0.5)) * step(0.95, sh);
                    if(uv.y < 0.36)
                        col += vec3(0.8, 0.85, 1.0) * star * (0.4 + 0.6 * sin(t * 3.0 + sh * 80.0));

                    // ---- retro sun ----
                    highp vec2 su = (uv - vec2(sunCX, sunCY)) * vec2(asp, 1.0);
                    highp float sd = length(su);
                    highp float yy = (uv.y - (sunCY - sunR)) / (2.0 * sunR);  // 0 top .. 1 bottom
                    highp vec3 sunCol = mix(cSunTop.rgb, cSunBot.rgb, clamp(yy, 0.0, 1.0));
                    // scanline gaps widen toward the bottom
                    highp float stripe = fract(yy * 13.0);
                    highp float keep = step(stripe, mix(1.0, 0.0, smoothstep(0.42, 1.0, yy)));
                    highp float disc = smoothstep(sunR, sunR - 0.004, sd) * keep;
                    // glow halo
                    highp float glow = smoothstep(sunR * 2.4, sunR, sd);
                    col += sunCol * glow * 0.35;
                    col = mix(col, sunCol, disc);
                } else {
                    // ---- ground + neon grid ----
                    highp float y = uv.y - horizon;
                    col = mix(vec3(0.16, 0.01, 0.18), vec3(0.02, 0.0, 0.05),
                              smoothstep(0.0, 0.28, y));

                    highp float z = 0.13 / y;                 // perspective depth
                    highp float scroll = t * 1.1;
                    highp float gz = abs(fract(z - scroll) - 0.5);          // floor lines (depth)
                    highp float gx = abs(fract((uv.x - sunCX) * z) - 0.5);  // rails (converge to sun)
                    // perspective-aware line width
                    highp float w = 0.025 + 0.05 * y;
                    highp float lineH = smoothstep(w, 0.0, gz);
                    highp float lineV = smoothstep(w, 0.0, gx);
                    highp float fade = smoothstep(0.0, 0.06, y);            // fade in below horizon
                    // cyan rails + magenta floor lines
                    col += cCyan.rgb * lineV * fade * 2.1;
                    col += cMag.rgb  * lineH * fade * 1.7;
                    // neon reflection of the sun pooling on the grid
                    col += cSunBot.rgb * smoothstep(0.12, 0.0, abs(uv.x - sunCX))
                           * smoothstep(0.34, 0.0, y) * 0.30;
                }

                // ---- horizon glow line ----
                col += mix(cCyan.rgb, cSunBot.rgb, 0.5)
                       * smoothstep(0.012, 0.0, abs(uv.y - horizon)) * 0.9;

                // ---- scanlines (CRT) + grade ----
                col *= 0.92 + 0.08 * sin(uv.y * iResolution.y * 1.4);
                col = col / (col + vec3(0.85));
                col = pow(col, vec3(0.85));
                highp float vig = smoothstep(1.4, 0.35, length((uv - 0.5) * vec2(asp, 1.0)));
                col *= 0.6 + 0.4 * vig;

                gl_FragColor = vec4(col, 1.0) * qt_Opacity;
            }
        "
    }
}
