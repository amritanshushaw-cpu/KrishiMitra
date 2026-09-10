// "Mesh drift" (Dark Mode) & "Silk" (Light Mode) WebGL1 Background Renderer
// Exact shaders & parameters generated via 21st.dev Shader Builder
(function () {
  const canvas = document.getElementById("mesh-drift-canvas");
  if (!canvas) return;

  const gl = canvas.getContext("webgl", {
    alpha: false,
    antialias: false,
    depth: false,
    stencil: false,
    preserveDrawingBuffer: false,
    powerPreference: "low-power",
  });

  if (!gl) {
    console.warn("WebGL not supported, falling back to static background.");
    return;
  }

  // Fullscreen triangle vertex shader (covers NDC [-1, 1] with 3 vertices)
  const vsSource = `
    attribute vec2 a_position;
    void main() {
      gl_Position = vec4(a_position, 0.0, 1.0);
    }
  `;

  // Shared Fragment Shader Header & Common Routines
  const fsHeader = `
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif

uniform vec3 u_colors[8];
uniform vec4 u_scene;      // resolution.xy, time, colour count
uniform vec4 u_shape;      // scale, intensity, paramA, warp
uniform vec4 u_surface;    // detail, contrast, brightness, saturation
uniform vec4 u_finish;     // hue, vignette, blur, grain
uniform vec4 u_transform;  // seed, rotation, drift, OKLab toggle
uniform vec4 u_space;      // offset.xy, pointer.xy
uniform vec4 u_cursor;

#define u_resolution u_scene.xy
#define u_time u_scene.z
#define u_colorCount u_scene.w
#define u_scale u_shape.x
#define u_intensity u_shape.y
#define u_paramA u_shape.z
#define u_warp u_shape.w
#define u_detail u_surface.x
#define u_contrast u_surface.y
#define u_brightness u_surface.z
#define u_saturation u_surface.w
#define u_hue u_finish.x
#define u_vignette u_finish.y
#define u_blur u_finish.z
#define u_grain u_finish.w
#ifdef GL_FRAGMENT_PRECISION_HIGH
#define u_seed u_transform.x
#else
#define u_seed mod(u_transform.x, 31.0)
#endif
#define u_rotate u_transform.y
#define u_drift u_transform.z
#define u_oklab u_transform.w
#define u_offset u_space.xy
#define u_mouse u_space.zw
#define u_cursorPresence u_cursor.x
#define u_cursorEffect u_cursor.y
#define u_cursorStrength u_cursor.z
#define u_cursorRadius u_cursor.w

float hash21(vec2 p) {
#ifndef GL_FRAGMENT_PRECISION_HIGH
  p = mod(p, 31.0);
#endif
  p = fract(p * vec2(234.34, 435.345));
  p += dot(p, p + 34.23);
  return fract(p.x * p.y);
}

float grainHash(vec2 p) {
  vec3 p3 = fract(vec3(p.xyx) * 0.1031);
  p3 += dot(p3, p3.yzx + 33.33);
  return fract((p3.x + p3.y) * p3.z);
}

vec2 hash22(vec2 p) {
#ifndef GL_FRAGMENT_PRECISION_HIGH
  p = mod(p, 31.0);
#endif
  float n = sin(dot(p, vec2(41.0, 289.0)));
  return fract(vec2(15731.743, 7892.321) * n);
}

float noise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  vec2 u = f * f * (3.0 - 2.0 * f);
  return mix(
    mix(hash21(i), hash21(i + vec2(1.0, 0.0)), u.x),
    mix(hash21(i + vec2(0.0, 1.0)), hash21(i + vec2(1.0, 1.0)), u.x),
    u.y);
}

float fbm(vec2 p) {
  float v = 0.0;
  float a = 0.5;
  for (int i = 0; i < 5; i++) {
    v += a * noise(p);
    p = p * 2.03 + vec2(17.0, 9.2);
    a *= 0.5;
  }
  return v;
}

vec3 srgbToLinear(vec3 c) {
  return mix(c / 12.92, pow((c + 0.055) / 1.055, vec3(2.4)),
    step(0.04045, c));
}
vec3 linearToSrgb(vec3 c) {
  return mix(c * 12.92, 1.055 * pow(max(c, vec3(0.0)), vec3(1.0 / 2.4)) - 0.055,
    step(0.0031308, c));
}
vec3 linToOklab(vec3 c) {
  float l = 0.4122214708 * c.r + 0.5363325363 * c.g + 0.0514459929 * c.b;
  float m = 0.2119034982 * c.r + 0.6806995451 * c.g + 0.1073969566 * c.b;
  float s = 0.0883024619 * c.r + 0.2817188376 * c.g + 0.6299787005 * c.b;
  l = pow(max(l, 0.0), 1.0 / 3.0);
  m = pow(max(m, 0.0), 1.0 / 3.0);
  s = pow(max(s, 0.0), 1.0 / 3.0);
  return vec3(
    0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s,
    1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s,
    0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s);
}
vec3 oklabToLin(vec3 c) {
  float l = c.x + 0.3963377774 * c.y + 0.2158037573 * c.z;
  float m = c.x - 0.1055613458 * c.y - 0.0638541728 * c.z;
  float s = c.x - 0.0894841775 * c.y - 1.2914855480 * c.z;
  l = l * l * l; m = m * m * m; s = s * s * s;
  return vec3(
    4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
    -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
    -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s);
}
vec3 mixColour(vec3 a, vec3 b, float t) {
  if (u_oklab > 0.5) {
    vec3 la = linToOklab(srgbToLinear(a));
    vec3 lb = linToOklab(srgbToLinear(b));
    return clamp(linearToSrgb(oklabToLin(mix(la, lb, t))), 0.0, 1.0);
  }
  return mix(a, b, t);
}

vec3 palette(float x) {
  float n = max(u_colorCount - 1.0, 1.0);
  float f = clamp(x, 0.0, 1.0) * n;
  vec3 col = u_colors[0];
  for (int i = 0; i < 7; i++) {
    if (float(i) < n)
      col = mixColour(col, u_colors[i + 1],
        smoothstep(0.0, 1.0, clamp(f - float(i), 0.0, 1.0)));
  }
  return col;
}

vec3 hueRotate(vec3 col, float a) {
  const mat3 toYIQ = mat3(0.299, 0.596, 0.211,
                          0.587, -0.274, -0.523,
                          0.114, -0.322, 0.312);
  const mat3 toRGB = mat3(1.0, 1.0, 1.0,
                          0.956, -0.272, -1.106,
                          0.621, -0.647, 1.703);
  vec3 yiq = toYIQ * col;
  float ca = cos(a), sa = sin(a);
  yiq = vec3(yiq.x, yiq.y * ca - yiq.z * sa, yiq.y * sa + yiq.z * ca);
  return toRGB * yiq;
}
  `;

  // Shared Post-Processing & Main Execution
  const fsFooter = `
void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 screenUv = uv;
  vec2 p = (gl_FragCoord.xy - 0.5 * u_resolution.xy)
    / min(u_resolution.x, u_resolution.y);
  float cursorMask = 0.0;

  if (u_cursorPresence > 0.001) {
    vec2 cursor = (0.5 * u_mouse * u_resolution.xy)
      / min(u_resolution.x, u_resolution.y);
    vec2 cursorDelta = p - cursor;
    if (u_cursorEffect < 0.5) {
      p += cursor * u_cursorPresence * u_cursorStrength * 0.55;
    } else {
      float cursorDistance = length(cursorDelta);
      vec2 cursorDirection = cursorDelta / max(cursorDistance, 0.0001);
      cursorMask = u_cursorPresence
        * (1.0 - smoothstep(0.0, u_cursorRadius, cursorDistance));
      if (u_cursorEffect < 1.5) {
        p -= cursorDirection * cursorMask * u_cursorStrength * 0.24;
      } else if (u_cursorEffect < 2.5) {
        float cursorAngle = cursorMask * u_cursorStrength * 2.2;
        float cc = cos(cursorAngle), cs = sin(cursorAngle);
        p = cursor + mat2(cc, -cs, cs, cc) * cursorDelta;
      } else if (u_cursorEffect < 3.5) {
        float ripple = sin(
          cursorDistance / max(u_cursorRadius, 0.001) * 18.0 - u_time * 5.0);
        p -= cursorDirection * ripple * cursorMask * u_cursorStrength * 0.07;
      }
    }
  }

  uv = p * min(u_resolution.x, u_resolution.y) / u_resolution.xy + 0.5;
  p *= u_scale;
  if (abs(u_rotate) > 0.0001) {
    float cr = cos(u_rotate), sr = sin(u_rotate);
    p = mat2(cr, -sr, sr, cr) * p;
  }
  p += u_offset;
  if (u_drift > 0.0001)
    p += u_drift * vec2(sin(u_time * 0.31), cos(u_time * 0.23));
  if (u_warp > 0.0) {
    p += u_warp * (vec2(
      fbm(p * u_detail + u_seed),
      fbm(p * u_detail + vec2(5.2, 1.3))) - 0.5);
  }

  vec3 col;
  if (u_blur > 0.0) {
    float e = u_blur;
    float pe = e * u_scale;
    vec2 uvE = vec2(e) * min(u_resolution.x, u_resolution.y) / u_resolution.xy;
    col  = shade(uv, p, u_time) * 0.36;
    col += shade(uv + vec2(uvE.x, 0.0), p + vec2(pe, 0.0), u_time) * 0.16;
    col += shade(uv - vec2(uvE.x, 0.0), p - vec2(pe, 0.0), u_time) * 0.16;
    col += shade(uv + vec2(0.0, uvE.y), p + vec2(0.0, pe), u_time) * 0.16;
    col += shade(uv - vec2(0.0, uvE.y), p - vec2(0.0, pe), u_time) * 0.16;
  } else {
    col = shade(uv, p, u_time);
  }

  if (abs(u_contrast - 1.0) > 0.0001)
    col = (col - 0.5) * u_contrast + 0.5;
  if (abs(u_saturation - 1.0) > 0.0001) {
    float luma = dot(col, vec3(0.299, 0.587, 0.114));
    col = mix(vec3(luma), col, u_saturation);
  }
  if (abs(u_hue) > 0.0001)
    col = hueRotate(col, u_hue);
  if (abs(u_brightness) > 0.0001)
    col += u_brightness;
  if (u_vignette > 0.0001) {
    float vd = length(screenUv - 0.5) * 1.41421356;
    col *= 1.0 - u_vignette * smoothstep(0.35, 1.0, vd);
  }
  if (u_cursorPresence > 0.001 && u_cursorEffect > 3.5)
    col += (vec3(0.18) + col * 0.12) * cursorMask * u_cursorStrength;
  if (u_grain > 0.0001)
    col += (grainHash(
      gl_FragCoord.xy + vec2(u_seed * 17.0, u_seed * 31.0)) - 0.5) * u_grain;
  gl_FragColor = vec4(clamp(col, 0.0, 1.0), 1.0);
}
  `;

  // 1. "Mesh Drift" (Blobs Shader for Dark Mode)
  const shadeMeshDrift = `
vec3 shade(vec2 uv, vec2 p, float t) {
  vec3 acc = u_colors[0] * 0.15;
  float total = 0.15;
  for (int i = 0; i < 8; i++) {
    if (float(i) >= u_colorCount) break;
    float fi = float(i);
    vec2 c = vec2(
      sin(t * (0.21 + fi * 0.071) + fi * 2.4 + u_seed),
      cos(t * (0.17 + fi * 0.093) + fi * 1.7)) * (0.45 + u_intensity * 0.35);
    float w = exp(-dot(p - c, p - c) * 6.0);
    acc += u_colors[i] * w;
    total += w;
  }
  return acc / total;
}
  `;

  // 2. "Silk" (Flow Shader for Light Mode)
  const shadeSilk = `
vec3 shade(vec2 uv, vec2 p, float t) {
  vec2 q = p * 1.6;
  float amp = 0.25 + u_intensity * 0.85;
  for (float i = 1.0; i < 5.0; i += 1.0) {
    q.x += amp / i * cos(i * 2.4 * q.y + t * 0.8 + u_seed);
    q.y += amp / i * cos(i * 1.7 * q.x + t * 0.6);
  }
  return palette(0.5 + 0.5 * sin(q.x + q.y));
}
  `;

  function createShader(type, source) {
    const shader = gl.createShader(type);
    gl.shaderSource(shader, source);
    gl.compileShader(shader);
    if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
      console.error(gl.getShaderInfoLog(shader));
      gl.deleteShader(shader);
      return null;
    }
    return shader;
  }

  function createProgram(fsShadeCode) {
    const vs = createShader(gl.VERTEX_SHADER, vsSource);
    const fs = createShader(gl.FRAGMENT_SHADER, fsHeader + fsShadeCode + fsFooter);
    if (!vs || !fs) return null;

    const prog = gl.createProgram();
    gl.attachShader(prog, vs);
    gl.attachShader(prog, fs);
    gl.linkProgram(prog);

    if (!gl.getProgramParameter(prog, gl.LINK_STATUS)) {
      console.error(gl.getProgramInfoLog(prog));
      return null;
    }

    return {
      program: prog,
      aPosition: gl.getAttribLocation(prog, "a_position"),
      uColors: gl.getUniformLocation(prog, "u_colors"),
      uScene: gl.getUniformLocation(prog, "u_scene"),
      uShape: gl.getUniformLocation(prog, "u_shape"),
      uSurface: gl.getUniformLocation(prog, "u_surface"),
      uFinish: gl.getUniformLocation(prog, "u_finish"),
      uTransform: gl.getUniformLocation(prog, "u_transform"),
      uSpace: gl.getUniformLocation(prog, "u_space"),
      uCursor: gl.getUniformLocation(prog, "u_cursor"),
    };
  }

  const progMeshDrift = createProgram(shadeMeshDrift);
  const progSilk = createProgram(shadeSilk);

  if (!progMeshDrift || !progSilk) {
    console.error("Failed to compile WebGL shaders.");
    return;
  }

  // Fullscreen single-triangle geometry buffer
  const positionBuffer = gl.createBuffer();
  gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);
  gl.bufferData(
    gl.ARRAY_BUFFER,
    new Float32Array([
      -1.0, -1.0,
       3.0, -1.0,
      -1.0,  3.0
    ]),
    gl.STATIC_DRAW
  );

  // Colours (low -> high): #03120E, #0E7C5A, #7CE577, #F4FFC7
  const colorsData = new Float32Array([
    0.012, 0.071, 0.055, // #03120E
    0.055, 0.486, 0.353, // #0E7C5A
    0.486, 0.898, 0.467, // #7CE577
    0.957, 1.000, 0.780, // #F4FFC7
    0.0, 0.0, 0.0,
    0.0, 0.0, 0.0,
    0.0, 0.0, 0.0,
    0.0, 0.0, 0.0,
  ]);

  // Preset Configurations
  const presets = {
    mesh_drift: {
      // Dark Mode: speed 33, zoom 33, intensity 34, contrast 62, grain 26
      progObj: progMeshDrift,
      speedMult: 0.73,
      shape: [1.16, 0.34, 0.50, 0.00],
      surface: [2.40, 1.16, 0.00, 1.00],
      finish: [0.00, 0.00, 0.000, 0.09],
      transform: [1453.0, 0.00, 0.00, 0.0],
      space: [0.00, 0.00, 0.0, 0.0],
      cursor: [0.0, 2.0, 0.65, 0.46],
    },
    silk: {
      // Light Mode: speed 39, zoom 4, intensity 20, contrast 23, grain 4
      progObj: progSilk,
      speedMult: 0.84,
      shape: [0.58, 0.20, 0.50, 0.00],
      surface: [2.40, 0.81, 0.00, 1.00],
      finish: [0.00, 0.00, 0.000, 0.01],
      transform: [707.0, 2.51, 0.00, 0.0],
      space: [0.06, 0.60, 0.0, 0.0],
      cursor: [0.0, 2.0, 0.65, 0.46],
    },
  };

  let activeMode = "mesh_drift";
  let activePreset = presets.mesh_drift;

  function setShaderMode(mode) {
    const targetMode = mode === "silk" ? "silk" : "mesh_drift";
    if (activeMode === targetMode && gl.getParameter(gl.CURRENT_PROGRAM) === activePreset.progObj.program) {
      return;
    }
    activeMode = targetMode;
    activePreset = presets[activeMode];

    const p = activePreset.progObj;
    gl.useProgram(p.program);

    gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);
    gl.enableVertexAttribArray(p.aPosition);
    gl.vertexAttribPointer(p.aPosition, 2, gl.FLOAT, false, 0, 0);

    gl.uniform3fv(p.uColors, colorsData);
    gl.uniform4fv(p.uShape, new Float32Array(activePreset.shape));
    gl.uniform4fv(p.uSurface, new Float32Array(activePreset.surface));
    gl.uniform4fv(p.uFinish, new Float32Array(activePreset.finish));
    gl.uniform4fv(p.uTransform, new Float32Array(activePreset.transform));
    gl.uniform4fv(p.uSpace, new Float32Array(activePreset.space));
    gl.uniform4fv(p.uCursor, new Float32Array(activePreset.cursor));
  }

  // Public APIs for Flutter Web interop
  window.setShaderMode = setShaderMode;
  window.setShaderTheme = function (isDark) {
    setShaderMode(isDark ? "mesh_drift" : "silk");
  };

  // Determine initial mode from stored preference or DOM attribute
  try {
    const savedTheme = localStorage.getItem("flutter.is_dark_mode");
    if (savedTheme === "false") {
      setShaderMode("silk");
    } else {
      setShaderMode("mesh_drift");
    }
  } catch (_) {
    setShaderMode("mesh_drift");
  }

  // Observe DOM attributes for dynamic theme sync
  const themeObserver = new MutationObserver(function () {
    const themeAttr = document.documentElement.getAttribute("data-theme") || document.body.getAttribute("data-theme");
    if (themeAttr === "light") {
      setShaderMode("silk");
    } else if (themeAttr === "dark") {
      setShaderMode("mesh_drift");
    }
  });
  themeObserver.observe(document.documentElement, { attributes: true, attributeFilter: ["data-theme", "class"] });

  // Resize handler capping devicePixelRatio at 2
  function resize() {
    const dpr = Math.min(window.devicePixelRatio || 1, 2);
    const width = Math.floor(window.innerWidth * dpr);
    const height = Math.floor(window.innerHeight * dpr);

    if (canvas.width !== width || canvas.height !== height) {
      canvas.width = width;
      canvas.height = height;
      gl.viewport(0, 0, width, height);
    }
  }

  window.addEventListener("resize", resize, { passive: true });
  resize();

  // Animation RAF Loop with visibility pause
  let rafId = null;
  const startTime = performance.now();

  function render(time) {
    if (document.hidden) {
      rafId = null;
      return;
    }

    const elapsedSeconds = (time - startTime) * 0.001;
    const p = activePreset.progObj;

    // Uniform u_scene: vec4(width, height, seconds * speedMult, 4.0)
    gl.uniform4f(
      p.uScene,
      canvas.width,
      canvas.height,
      elapsedSeconds * activePreset.speedMult,
      4.0
    );

    gl.drawArrays(gl.TRIANGLES, 0, 3);
    rafId = requestAnimationFrame(render);
  }

  document.addEventListener("visibilitychange", () => {
    if (!document.hidden && !rafId) {
      rafId = requestAnimationFrame(render);
    }
  });

  rafId = requestAnimationFrame(render);
})();
