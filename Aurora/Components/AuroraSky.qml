import QtQuick 2.11

// Aurora borealis, rendered in a single GLSL fragment shader.
//   · waving light curtains (layered domain-warped fBm) tinted green→teal→violet by altitude
//   · twinkling procedural starfield
//   · mountain silhouette on the horizon
//   · a still lake mirroring the sky with a rippling reflection
Item {
    id: sky

    property color low:  config.AuroraLow  || "#2dff8c"   // near-horizon green
    property color mid:  config.AuroraMid  || "#19e6f0"   // teal
    property color high: config.AuroraHigh || "#9b4dff"   // high violet
    property real auroraSpeed: parseFloat(config.AuroraSpeed) || 1.0
    property real starDensity: parseFloat(config.StarDensity) || 1.0

    ShaderEffect {
        anchors.fill: parent
        property real iTime: 0
        property size iResolution: Qt.size(width, height)
        property color cLow: sky.low
        property color cMid: sky.mid
        property color cHigh: sky.high
        property real spd: sky.auroraSpeed
        property real starDensity: sky.starDensity

        NumberAnimation on iTime {
            from: 0; to: 100000.0; duration: 100000000
            loops: Animation.Infinite; running: true
        }

        fragmentShader: "
            varying highp vec2 qt_TexCoord0;
            uniform lowp float qt_Opacity;
            uniform highp float iTime;
            uniform highp vec2 iResolution;
            uniform lowp vec4 cLow;
            uniform lowp vec4 cMid;
            uniform lowp vec4 cHigh;
            uniform highp float spd;
            uniform highp float starDensity;

            highp float hash21(highp vec2 p){
                p = fract(p * vec2(123.34, 456.21));
                p += dot(p, p + 45.32);
                return fract(p.x * p.y);
            }
            highp float vnoise(highp vec2 p){
                highp vec2 i = floor(p); highp vec2 f = fract(p);
                highp vec2 u = f*f*(3.0 - 2.0*f);
                highp float a = hash21(i);
                highp float b = hash21(i + vec2(1.0, 0.0));
                highp float c = hash21(i + vec2(0.0, 1.0));
                highp float d = hash21(i + vec2(1.0, 1.0));
                return mix(mix(a,b,u.x), mix(c,d,u.x), u.y);
            }
            highp float fbm(highp vec2 p){
                highp float s = 0.0, amp = 0.5;
                for(int i = 0; i < 5; i++){ s += amp*vnoise(p); p = p*2.02 + 3.1; amp *= 0.5; }
                return s;
            }
            highp float starLayer(highp vec2 p, highp float scale, highp float t){
                p *= scale;
                highp vec2 id = floor(p); highp vec2 gv = fract(p) - 0.5;
                highp float n = hash21(id);
                highp vec2 off = (vec2(hash21(id + 7.1), hash21(id + 13.7)) - 0.5) * 0.7;
                highp float star = smoothstep(0.055, 0.0, length(gv - off));
                star *= step(0.90, n);
                return star * (0.5 + 0.5*sin(t*2.0 + n*90.0)) * (0.5 + n);
            }

            // aurora intensity field over the sky (uv.y: 0 top .. 1 down)
            highp float aurora(highp vec2 uv, highp float t){
                highp float total = 0.0;
                for(int i = 0; i < 3; i++){
                    highp float fi = float(i);
                    highp float baseY = 0.46 - 0.12 * fi;
                    // snaking horizontal waves (two harmonics + drift)
                    highp float wave = 0.090 * sin(uv.x * 3.0 + t * 0.5 + fi * 2.0)
                                     + 0.050 * sin(uv.x * 7.0 - t * 0.3 + fi)
                                     + 0.060 * fbm(vec2(uv.x * 2.0 - t * 0.1 + fi * 8.0, 0.3));
                    highp float yc = baseY + wave;
                    highp float thick = 0.115 - 0.018 * fi;
                    highp float dy = (uv.y - yc) / thick;
                    // hanging curtain: sharp top edge, long soft tail downward
                    highp float e = (dy > 0.0) ? 0.8 : 2.6;
                    highp float band = exp(-dy * dy * e);
                    // soft vertical ray striations, localized to the ribbon
                    highp float rays = 0.5 + 0.5 * sin(uv.x * 120.0 + fbm(vec2(uv.x * 8.0 + fi, t * 0.15)) * 14.0);
                    rays = mix(1.0, rays, 0.55);
                    total += band * rays * (0.95 - 0.18 * fi);
                }
                return max(total, 0.0);
            }

            highp vec3 auroraColor(highp float y){
                highp float h = smoothstep(0.58, 0.10, y);   // 0 low .. 1 high
                highp vec3 c = (h < 0.5) ? mix(cLow.rgb, cMid.rgb, h * 2.0)
                                         : mix(cMid.rgb, cHigh.rgb, (h - 0.5) * 2.0);
                return c;
            }

            void main(){
                highp vec2 uv = qt_TexCoord0;
                highp float asp = iResolution.x / iResolution.y;
                highp float t = iTime * spd;

                highp float horizon = 0.72;

                // ---- sky gradient ----
                highp vec3 col = mix(vec3(0.015, 0.022, 0.060),   // zenith
                                     vec3(0.030, 0.060, 0.105),   // near horizon
                                     smoothstep(0.0, horizon, uv.y));

                // ---- stars (sky only, fade toward horizon) ----
                if(uv.y < horizon){
                    highp vec2 sp = vec2(uv.x * asp, uv.y);
                    highp float st = starLayer(sp, 22.0*starDensity, t)
                                   + 0.7*starLayer(sp + 5.0, 38.0*starDensity, t*1.3);
                    col += vec3(0.9, 0.95, 1.0) * st * smoothstep(horizon, 0.15, uv.y);
                }

                // ---- aurora (sky) ----
                highp float a = aurora(uv, t) * smoothstep(horizon + 0.02, 0.05, uv.y);
                col += auroraColor(uv.y) * a * 1.55;
                // soft horizon glow from the aurora
                col += cLow.rgb * smoothstep(0.08, 0.0, abs(uv.y - horizon)) * 0.25
                       * (0.4 + 0.6 * fbm(vec2(uv.x * 3.0 - t * 0.1, 0.0)));

                // ---- lake reflection (below horizon) ----
                if(uv.y > horizon){
                    highp float d = uv.y - horizon;
                    highp float ripple = 0.010 * sin(uv.x * 60.0 + t * 1.5) * (0.3 + d)
                                       + 0.012 * fbm(vec2(uv.x * 8.0, d * 30.0 - t * 0.4));
                    highp float my = horizon - d * 1.25;            // mirrored sky y
                    highp vec2 ruv = vec2(uv.x + ripple, my);
                    highp float ra = aurora(ruv, t) * smoothstep(0.0, 0.4, my);
                    highp vec3 lake = vec3(0.012, 0.028, 0.055);    // dark water
                    lake += auroraColor(my) * ra * 0.7;
                    lake *= (1.0 - smoothstep(0.0, 0.30, d) * 0.55); // darken with depth
                    col = lake;
                }

                // ---- mountain silhouette straddling the horizon ----
                highp float ridge = horizon - 0.015
                                  + 0.045 * fbm(vec2(uv.x * 3.0, 7.0))
                                  + 0.022 * sin(uv.x * 6.0 + 1.0)
                                  + 0.012 * sin(uv.x * 19.0);
                if(uv.y > ridge && uv.y < horizon + 0.02){
                    highp vec3 mtn = vec3(0.006, 0.012, 0.024);
                    // faint aurora rim-light on the ridge top
                    highp float rim = smoothstep(0.018, 0.0, uv.y - ridge);
                    mtn += auroraColor(ridge) * rim * 0.25;
                    col = mtn;
                }

                // ---- grade ----
                col = col / (col + vec3(0.92));
                col = pow(col, vec3(0.86));
                highp float vig = smoothstep(1.35, 0.30, length((uv - 0.5) * vec2(asp, 1.0)));
                col *= 0.55 + 0.45 * vig;

                gl_FragColor = vec4(col, 1.0) * qt_Opacity;
            }
        "
    }
}
