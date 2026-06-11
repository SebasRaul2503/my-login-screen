import QtQuick 2.11

// Real-time gravitational black hole, rendered in a single GLSL fragment shader.
//   · procedural starfield with gravitational lensing (light bending near the hole)
//   · inclined accretion disk with Keplerian (inner-faster) rotation + fBm turbulence
//   · relativistic Doppler beaming (approaching side brighter & bluer)
//   · photon ring + hard event horizon
// Colors and motion are driven from theme.conf via the uniform properties below.
Item {
    id: bh

    property color accent:  config.Accent  || "#ffae5c"   // outer disk (warm)
    property color accent2: config.Accent2 || "#7cc7ff"   // cool tint / stars
    property color hot:     config.DiskHot || "#fff3d6"    // inner disk (incandescent)
    property real diskSpeed: parseFloat(config.DiskSpeed) || 1.0
    property real starDensity: parseFloat(config.StarDensity) || 1.0

    ShaderEffect {
        id: fx
        anchors.fill: parent

        property real iTime: 0
        property size iResolution: Qt.size(width, height)
        property color cAccent: bh.accent
        property color cAccent2: bh.accent2
        property color cHot: bh.hot
        property real diskSpeed: bh.diskSpeed
        property real starDensity: bh.starDensity
        // hole center in aspect-corrected space (x right, y up). Pushed up/right
        // so a screen-centered login panel rests in the calmer lower-left.
        property real cx: 0.34
        property real cy: 0.12

        // ~1 unit per second; long loop so the reset is effectively never seen.
        NumberAnimation on iTime {
            from: 0; to: 100000.0; duration: 100000000
            loops: Animation.Infinite; running: true
        }

        fragmentShader: "
            varying highp vec2 qt_TexCoord0;
            uniform lowp float qt_Opacity;
            uniform highp float iTime;
            uniform highp vec2 iResolution;
            uniform lowp vec4 cAccent;
            uniform lowp vec4 cAccent2;
            uniform lowp vec4 cHot;
            uniform highp float diskSpeed;
            uniform highp float starDensity;
            uniform highp float cx;
            uniform highp float cy;

            const highp float PI = 3.14159265;

            highp float hash21(highp vec2 p){
                p = fract(p * vec2(123.34, 456.21));
                p += dot(p, p + 45.32);
                return fract(p.x * p.y);
            }
            highp float vnoise(highp vec2 p){
                highp vec2 i = floor(p);
                highp vec2 f = fract(p);
                highp vec2 u = f*f*(3.0 - 2.0*f);
                highp float a = hash21(i);
                highp float b = hash21(i + vec2(1.0, 0.0));
                highp float c = hash21(i + vec2(0.0, 1.0));
                highp float d = hash21(i + vec2(1.0, 1.0));
                return mix(mix(a,b,u.x), mix(c,d,u.x), u.y);
            }
            highp float fbm(highp vec2 p){
                highp float s = 0.0;
                highp float amp = 0.5;
                for(int i = 0; i < 5; i++){
                    s += amp * vnoise(p);
                    p = p * 2.02 + 3.1;
                    amp *= 0.5;
                }
                return s;
            }
            // one twinkling star layer over a cell grid
            highp float starLayer(highp vec2 p, highp float scale, highp float t){
                p *= scale;
                highp vec2 id = floor(p);
                highp vec2 gv = fract(p) - 0.5;
                highp float n = hash21(id);
                highp vec2 off = (vec2(hash21(id + 7.1), hash21(id + 13.7)) - 0.5) * 0.7;
                highp float d = length(gv - off);
                highp float star = smoothstep(0.06, 0.0, d);
                star *= step(0.90, n);                       // only some cells host a star
                highp float tw = 0.55 + 0.45 * sin(t * 2.3 + n * 90.0); // twinkle
                return star * tw * (0.5 + n);
            }

            void main(){
                highp vec2 res = iResolution;
                // aspect-corrected, centered; y up; unit ~ screen height
                highp vec2 uv = (qt_TexCoord0 * res - 0.5 * res) / res.y;
                highp vec2 c  = vec2(cx, cy);
                highp vec2 p  = uv - c;
                highp float r = length(p);
                highp float ang = atan(p.y, p.x);
                highp float t = iTime;

                highp float Rh = 0.115;                        // event horizon radius

                // ---- gravitational lensing of the background ----
                highp float bend = (Rh * Rh) / (r * r + 0.0008);
                highp vec2  luv  = p * (1.0 - clamp(bend * 1.7, 0.0, 0.97)) + c;

                // ---- starfield (lensed) ----
                highp vec3 col = vec3(0.012, 0.013, 0.028);    // deep space base
                // faint nebula wash
                highp float neb = fbm(luv * 2.3 + vec2(0.0, t * 0.01));
                col += mix(vec3(0.02, 0.03, 0.06), vec3(0.05, 0.02, 0.07), neb) * 0.6 * neb;
                highp float s1 = starLayer(luv, 26.0 * starDensity, t);
                highp float s2 = starLayer(luv + 5.0, 16.0 * starDensity, t * 0.7);
                highp float s3 = starLayer(luv - 9.0, 40.0 * starDensity, t * 1.3);
                highp vec3 starCol = mix(vec3(1.0), cAccent2.rgb, 0.35);
                col += starCol * (s1 + 0.8 * s2 + 0.6 * s3);

                // ---- accretion disk ----
                // un-squish vertically to model an inclined (near edge-on) disk
                highp float incl = 0.34;                       // smaller = more edge-on
                highp vec2  d2   = vec2(p.x, p.y / incl);
                highp float dr   = length(d2);
                highp float da   = atan(d2.y, d2.x);

                highp float Rin = 0.150;
                highp float Rout = 0.66;
                highp float band = smoothstep(Rin, Rin + 0.04, dr)
                                 * (1.0 - smoothstep(Rout - 0.30, Rout, dr));

                // Keplerian swirl: inner orbits faster (~1/dr). fBm in (angle,radius).
                highp float rot = t * diskSpeed * (0.35 + 0.18 / max(dr, 0.05));
                highp float turb = fbm(vec2(da / PI * 16.0 - rot, dr * 9.0 + rot * 0.15));
                highp float turb2 = fbm(vec2(da / PI * 27.0 + rot * 1.3, dr * 16.0));
                // streakier filaments: bias the product and sharpen contrast
                highp float dens = band * pow(0.22 + 1.05 * turb, 2.0) * (0.35 + 0.95 * turb2);

                // radial temperature: deep ember outer -> warm mid -> hot core
                highp float temp = 1.0 - smoothstep(Rin, Rout, dr);
                highp vec3 cEmber = vec3(0.95, 0.20, 0.02);
                highp vec3 diskCol = mix(cEmber, cAccent.rgb, smoothstep(0.0, 0.5, temp));
                diskCol = mix(diskCol, cHot.rgb, pow(temp, 3.2));   // incandescent core only

                // relativistic Doppler beaming: approaching side (right) brighter & bluer
                highp float side = p.x / max(dr, 0.001);          // +1 right, -1 left
                highp float doppler = 0.45 + 0.75 * side;
                doppler = clamp(doppler, 0.12, 1.6);
                diskCol = mix(diskCol, mix(diskCol, cAccent2.rgb, 0.55), clamp(side, 0.0, 1.0) * 0.30);

                highp vec3 disk = diskCol * dens * doppler * 3.9;

                // gravitational redshift: fade disk light just outside the horizon
                disk *= smoothstep(Rh * 0.95, Rh * 1.5, r);
                col += disk;

                // ---- lensed halo: far side of the disk bent up over the poles ----
                highp float arc = smoothstep(0.085, 0.0, abs(r - Rh * 1.85));
                highp float vertical = abs(p.y) / max(r, 0.001);   // strongest top & bottom
                arc *= (0.20 + 0.80 * vertical);
                highp float arcTurb = 0.5 + 0.7 * fbm(vec2(ang * 4.0 - rot * 0.6, r * 12.0));
                col += mix(cAccent.rgb, cHot.rgb, 0.35) * arc * arcTurb * 1.5;

                // ---- photon ring (bright thin halo hugging the horizon) ----
                highp float ring = smoothstep(0.016, 0.0, abs(r - Rh * 1.16));
                col += mix(cHot.rgb, cAccent.rgb, 0.25) * ring * 2.6;
                // soft outer glow of the ring
                col += cAccent.rgb * smoothstep(0.14, 0.0, abs(r - Rh * 1.3)) * 0.22;

                // ---- event horizon (hard black sphere) ----
                highp float hole = smoothstep(Rh, Rh * 0.985, r);
                col *= (1.0 - hole);

                // ---- grade ----
                col = col / (col + vec3(1.05));                // tonemap (Reinhard-ish)
                col = pow(col, vec3(0.80));                    // lift
                // saturation boost so the ember disk stays vivid, not beige
                highp float luma = dot(col, vec3(0.299, 0.587, 0.114));
                col = clamp(mix(vec3(luma), col, 1.45), 0.0, 1.0);
                highp float vig = smoothstep(1.25, 0.25, length(uv));
                col *= 0.5 + 0.5 * vig;

                gl_FragColor = vec4(col, 1.0) * qt_Opacity;
            }
        "
    }
}
