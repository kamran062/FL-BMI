// BMI Health — Shared UI primitives
// All components are visual/UX recreations matching the design tokens in
// ../../colors_and_type.css. Inline styles only, no CSS-in-JS dependency.

const COLORS = {
  brand: '#1FB573',
  brandHover: '#18A065',
  brandTint: '#E8F7EF',
  brandTintDeep: '#C6EFDA',

  bgCanvas: '#FAFAF7',
  bgSurface: '#FFFFFF',
  bgSunken: '#F1F2EE',
  bgTint: '#F4FBF7',

  fg1: '#0E1411',
  fg2: '#4A5450',
  fg3: '#8A938F',

  borderSubtle: 'rgba(14,20,17,0.10)',
  borderFaint: 'rgba(14,20,17,0.06)',

  under: '#3B82F6', underTint: '#EAF1FE', underInk: '#1D4ED8',
  normal: '#1FB573', normalTint: '#E8F7EF', normalInk: '#128055',
  over: '#F59E0B',   overTint: '#FEF4E2',   overInk: '#9A6500',
  obese: '#EF4444',  obeseTint: '#FDEAEA',  obeseInk: '#B91C1C',
};

const FONT_STACK = 'Inter, -apple-system, BlinkMacSystemFont, "Segoe UI", system-ui, sans-serif';

// ─── BMI category helpers ────────────────────────────────────
function bmiCategory(bmi) {
  if (bmi < 18.5) return { key: 'under', label: 'Underweight', color: COLORS.under, tint: COLORS.underTint, ink: COLORS.underInk };
  if (bmi < 25.0) return { key: 'normal', label: 'Normal',     color: COLORS.normal, tint: COLORS.normalTint, ink: COLORS.normalInk };
  if (bmi < 30.0) return { key: 'over',   label: 'Overweight', color: COLORS.over,   tint: COLORS.overTint,   ink: COLORS.overInk };
  return            { key: 'obese',  label: 'Obese',      color: COLORS.obese,  tint: COLORS.obeseTint,  ink: COLORS.obeseInk };
}

function calcBMI(weightKg, heightCm) {
  const m = heightCm / 100;
  if (!m) return 0;
  return weightKg / (m * m);
}

// ─── Lucide icon (loaded via CDN in index.html) ──────────────
function Icon({ name, size = 22, strokeWidth = 2, color = 'currentColor', style = {} }) {
  // Lucide replaces <i data-lucide=...> with <svg>. We render an empty <i>
  // and call lucide.createIcons() once the tree mounts.
  const ref = React.useRef(null);
  React.useEffect(() => {
    if (window.lucide && ref.current) {
      ref.current.setAttribute('data-lucide', name);
      ref.current.setAttribute('width', size);
      ref.current.setAttribute('height', size);
      ref.current.setAttribute('stroke-width', strokeWidth);
      window.lucide.createIcons({ nameAttr: 'data-lucide', icons: window.lucide.icons });
    }
  }, [name, size, strokeWidth]);
  return <i ref={ref} style={{ display: 'inline-flex', color, lineHeight: 0, ...style }} />;
}

// ─── Button ──────────────────────────────────────────────────
function Button({ children, variant = 'primary', size = 'md', icon, onClick, style = {}, disabled = false, full = false }) {
  const [pressed, setPressed] = React.useState(false);
  const base = {
    font: '600 15px/1 ' + FONT_STACK,
    letterSpacing: '-0.005em',
    border: 'none',
    borderRadius: 14,
    padding: '14px 22px',
    cursor: disabled ? 'not-allowed' : 'pointer',
    display: 'inline-flex',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 8,
    transition: 'filter 150ms cubic-bezier(0.22,0.61,0.36,1), transform 120ms cubic-bezier(0.22,0.61,0.36,1)',
    transform: pressed ? 'scale(0.98)' : 'scale(1)',
    filter: pressed ? 'brightness(0.96)' : 'brightness(1)',
    opacity: disabled ? 0.4 : 1,
    width: full ? '100%' : 'auto',
    appearance: 'none',
    WebkitTapHighlightColor: 'transparent',
  };
  const sizeMap = {
    sm: { padding: '9px 14px', fontSize: 13, borderRadius: 10 },
    md: { padding: '14px 22px', fontSize: 15, borderRadius: 14 },
    lg: { padding: '17px 28px', fontSize: 17, borderRadius: 16 },
  };
  const variants = {
    primary:   { background: COLORS.brand, color: '#fff', boxShadow: '0 1px 2px rgba(31,181,115,0.3), 0 4px 12px rgba(31,181,115,0.18)' },
    secondary: { background: COLORS.bgSunken, color: COLORS.fg1 },
    ghost:     { background: 'transparent', color: COLORS.brand },
    light:     { background: 'rgba(255,255,255,0.18)', color: '#fff', backdropFilter: 'blur(12px)' },
    dark:      { background: COLORS.fg1, color: '#fff' },
    destructive:{ background: COLORS.obeseTint, color: COLORS.obeseInk },
  };
  return (
    <button
      style={{ ...base, ...sizeMap[size], ...variants[variant], ...style }}
      onClick={disabled ? undefined : onClick}
      onPointerDown={() => !disabled && setPressed(true)}
      onPointerUp={() => setPressed(false)}
      onPointerLeave={() => setPressed(false)}
      disabled={disabled}
    >
      {icon && <Icon name={icon} size={size === 'lg' ? 20 : 18} strokeWidth={2.2} />}
      {children}
    </button>
  );
}

// ─── Input field ─────────────────────────────────────────────
function Field({ label, value, onChange, unit, placeholder, focused, error, type = 'text', help }) {
  const [hasFocus, setHasFocus] = React.useState(false);
  const active = hasFocus || focused;
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
      {label && <span style={{ font: '500 13px/1.4 ' + FONT_STACK, color: COLORS.fg2 }}>{label}</span>}
      <div style={{
        background: COLORS.bgSurface,
        border: '1px solid ' + (error ? COLORS.obese : (active ? COLORS.brand : COLORS.borderSubtle)),
        borderRadius: 12,
        padding: '14px 16px',
        display: 'flex',
        alignItems: 'center',
        gap: 10,
        boxShadow: active ? `0 0 0 4px ${error ? 'rgba(239,68,68,0.18)' : 'rgba(31,181,115,0.18)'}, 0 1px 2px rgba(14,20,17,0.04)` : '0 1px 2px rgba(14,20,17,0.04), 0 1px 3px rgba(14,20,17,0.06)',
        transition: 'box-shadow 180ms cubic-bezier(0.22,0.61,0.36,1), border-color 180ms',
      }}>
        <input
          value={value ?? ''}
          onChange={e => onChange?.(e.target.value)}
          placeholder={placeholder}
          inputMode={type === 'number' ? 'decimal' : undefined}
          onFocus={() => setHasFocus(true)}
          onBlur={() => setHasFocus(false)}
          style={{
            border: 'none', outline: 'none', background: 'none',
            font: '500 17px/1 ' + FONT_STACK, flex: 1,
            fontVariantNumeric: 'tabular-nums', letterSpacing: '-0.01em',
            color: COLORS.fg1, width: '100%', padding: 0,
          }}
        />
        {unit && <span style={{ font: '500 13px/1 ' + FONT_STACK, color: COLORS.fg3 }}>{unit}</span>}
      </div>
      {help && <span style={{ font: '500 12px/1.4 ' + FONT_STACK, color: error ? COLORS.obese : COLORS.fg3 }}>{help}</span>}
    </div>
  );
}

// ─── Segmented control ───────────────────────────────────────
function Segmented({ options, value, onChange, size = 'md' }) {
  const padding = size === 'sm' ? 3 : 4;
  const segPad = size === 'sm' ? '6px 12px' : '8px 14px';
  const fontSize = size === 'sm' ? 12 : 13;
  return (
    <div style={{
      display: 'inline-flex', padding, background: COLORS.bgSunken,
      borderRadius: 12, gap: padding,
    }}>
      {options.map(opt => {
        const v = typeof opt === 'string' ? opt : opt.value;
        const label = typeof opt === 'string' ? opt : opt.label;
        const on = v === value;
        return (
          <button key={v} onClick={() => onChange?.(v)} style={{
            font: `600 ${fontSize}px/1 ${FONT_STACK}`, padding: segPad, borderRadius: 8,
            background: on ? COLORS.bgSurface : 'transparent',
            color: on ? COLORS.fg1 : COLORS.fg2,
            boxShadow: on ? '0 1px 2px rgba(14,20,17,0.04), 0 1px 3px rgba(14,20,17,0.06)' : 'none',
            border: 'none', cursor: 'pointer', transition: 'all 150ms',
            WebkitTapHighlightColor: 'transparent',
          }}>{label}</button>
        );
      })}
    </div>
  );
}

// ─── Toggle switch ──────────────────────────────────────────
function Toggle({ on, onChange }) {
  return (
    <button onClick={() => onChange?.(!on)} style={{
      position: 'relative', width: 44, height: 26,
      background: on ? COLORS.brand : '#D9DCD7',
      borderRadius: 999, transition: 'background 200ms', border: 'none',
      cursor: 'pointer', padding: 0, WebkitTapHighlightColor: 'transparent',
    }}>
      <span style={{
        position: 'absolute', top: 2, left: on ? 20 : 2, width: 22, height: 22,
        background: '#fff', borderRadius: 999,
        boxShadow: '0 1px 3px rgba(0,0,0,0.2)',
        transition: 'left 200ms cubic-bezier(0.22,0.61,0.36,1)',
      }} />
    </button>
  );
}

// ─── Card ───────────────────────────────────────────────────
function Card({ children, padding = 20, radius = 20, tint, elevation = 1, style = {}, onClick }) {
  const shadows = {
    0: 'none',
    1: '0 1px 2px rgba(14,20,17,0.04), 0 1px 3px rgba(14,20,17,0.06)',
    2: '0 4px 12px rgba(14,20,17,0.05), 0 2px 4px rgba(14,20,17,0.04)',
    3: '0 12px 32px rgba(14,20,17,0.08), 0 4px 12px rgba(14,20,17,0.05)',
  };
  return (
    <div onClick={onClick} style={{
      background: tint || COLORS.bgSurface,
      borderRadius: radius,
      padding,
      boxShadow: shadows[elevation],
      cursor: onClick ? 'pointer' : 'default',
      ...style,
    }}>{children}</div>
  );
}

// ─── Status pill ────────────────────────────────────────────
function StatusPill({ category, solid = false, size = 'md' }) {
  const cat = typeof category === 'string' ? bmiCategory(category === 'under' ? 17 : category === 'normal' ? 22 : category === 'over' ? 27 : 32) : category;
  const sizes = {
    sm: { padding: '4px 10px', fontSize: 10 },
    md: { padding: '6px 12px', fontSize: 12 },
    lg: { padding: '8px 16px', fontSize: 13 },
  };
  return (
    <span style={{
      display: 'inline-flex', alignItems: 'center', gap: 6,
      background: solid ? cat.color : cat.tint,
      color: solid ? '#fff' : cat.ink,
      font: `600 ${sizes[size].fontSize}px/1 ${FONT_STACK}`,
      letterSpacing: 0.3, textTransform: 'uppercase',
      padding: sizes[size].padding, borderRadius: 999,
    }}>
      <span style={{ width: 6, height: 6, borderRadius: 999, background: solid ? '#fff' : cat.color }} />
      {cat.label}
    </span>
  );
}

// ─── BMI Gauge ──────────────────────────────────────────────
function BMIGauge({ value, size = 240, animate = true }) {
  const cat = bmiCategory(value);
  const r = (size - 36) / 2;
  const cx = size / 2, cy = size / 2;
  const circumference = 2 * Math.PI * r;
  // Map BMI value 14–40 to angle 0..360 starting at -90deg (top)
  const min = 14, max = 40;
  const pct = Math.max(0, Math.min(1, (value - min) / (max - min)));
  // angle: convert to indicator position
  const angle = pct * 360 - 90;
  const ind = {
    x: cx + r * Math.cos((angle * Math.PI) / 180),
    y: cy + r * Math.sin((angle * Math.PI) / 180),
  };
  // 4 colored arcs sized to the BMI buckets within the displayed range (14–40)
  const buckets = [
    { from: 14,   to: 18.5, color: COLORS.under },
    { from: 18.5, to: 25.0, color: COLORS.normal },
    { from: 25.0, to: 30.0, color: COLORS.over },
    { from: 30.0, to: 40.0, color: COLORS.obese },
  ];
  const gap = 6; // px gap between segments
  return (
    <div style={{ position: 'relative', width: size, height: size }}>
      <svg width={size} height={size} viewBox={`0 0 ${size} ${size}`} style={{ transform: 'rotate(-90deg)' }}>
        <circle cx={cx} cy={cy} r={r} fill="none" stroke={COLORS.bgSunken} strokeWidth={18} />
        {buckets.map((b, i) => {
          const startPct = (b.from - min) / (max - min);
          const endPct = (b.to - min) / (max - min);
          const len = (endPct - startPct) * circumference - gap;
          const offset = -(startPct * circumference);
          return (
            <circle key={i} cx={cx} cy={cy} r={r} fill="none"
              stroke={b.color} strokeWidth={18} strokeLinecap="round"
              strokeDasharray={`${len} ${circumference - len}`}
              strokeDashoffset={offset}
              style={animate ? { transition: 'stroke-dasharray 600ms cubic-bezier(0.22,0.61,0.36,1)' } : undefined}
            />
          );
        })}
      </svg>
      <svg width={size} height={size} viewBox={`0 0 ${size} ${size}`} style={{ position: 'absolute', inset: 0 }}>
        <circle cx={ind.x} cy={ind.y} r={9} fill="#fff" stroke={cat.color} strokeWidth={4}
          style={animate ? { transition: 'cx 600ms cubic-bezier(0.34,1.56,0.64,1), cy 600ms cubic-bezier(0.34,1.56,0.64,1)' } : undefined}
        />
      </svg>
      <div style={{
        position: 'absolute', inset: 0, display: 'flex',
        flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 2,
      }}>
        <span style={{ font: '600 11px/1 ' + FONT_STACK, letterSpacing: '0.08em', textTransform: 'uppercase', color: cat.color }}>{cat.label}</span>
        <span style={{
          font: `700 ${Math.round(size * 0.28)}px/1 ` + FONT_STACK,
          letterSpacing: '-0.03em', fontVariantNumeric: 'tabular-nums', color: COLORS.fg1,
        }}>{value.toFixed(1)}</span>
        <span style={{ font: '500 11px/1 ' + FONT_STACK, color: COLORS.fg3 }}>kg/m²</span>
      </div>
    </div>
  );
}

// ─── Screen header ──────────────────────────────────────────
function ScreenHeader({ title, leading, trailing, large = false }) {
  return (
    <div style={{
      paddingTop: 6, paddingLeft: 20, paddingRight: 20, paddingBottom: large ? 8 : 12,
      display: 'flex', alignItems: 'center', gap: 12, minHeight: 44,
    }}>
      {leading}
      <span style={{
        font: large
          ? `700 28px/1.2 ${FONT_STACK}`
          : `600 17px/1.2 ${FONT_STACK}`,
        letterSpacing: '-0.015em', color: COLORS.fg1, flex: 1,
        textAlign: leading || trailing ? 'center' : 'left',
      }}>{title}</span>
      {trailing}
    </div>
  );
}

// ─── Bottom navigation ──────────────────────────────────────
function BottomNav({ tab, onChange }) {
  const tabs = [
    { id: 'calculate', icon: 'calculator', label: 'Calculate' },
    { id: 'history',   icon: 'line-chart', label: 'History' },
    { id: 'tips',      icon: 'lightbulb',  label: 'Tips' },
    { id: 'settings',  icon: 'settings-2', label: 'Settings' },
  ];
  return (
    <div style={{
      position: 'absolute', left: 0, right: 0, bottom: 0,
      paddingBottom: 34, // home indicator
      background: 'rgba(255,255,255,0.85)',
      backdropFilter: 'blur(14px) saturate(180%)',
      WebkitBackdropFilter: 'blur(14px) saturate(180%)',
      borderTop: '1px solid ' + COLORS.borderFaint,
      zIndex: 30,
    }}>
      <div style={{ display: 'flex', height: 64 }}>
        {tabs.map(t => {
          const on = t.id === tab;
          return (
            <button key={t.id} onClick={() => onChange?.(t.id)} style={{
              flex: 1, background: 'none', border: 'none', cursor: 'pointer',
              display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
              gap: 4, color: on ? COLORS.brand : COLORS.fg3,
              WebkitTapHighlightColor: 'transparent',
            }}>
              <Icon name={t.icon} size={22} strokeWidth={on ? 2.4 : 2} />
              <span style={{ font: '600 10.5px/1 ' + FONT_STACK, letterSpacing: 0.1 }}>{t.label}</span>
            </button>
          );
        })}
      </div>
    </div>
  );
}

// ─── Screen container ──────────────────────────────────────
function Screen({ children, bg = COLORS.bgCanvas, withTabBar = true, padTop = 54, scroll = true }) {
  return (
    <div style={{
      position: 'absolute', inset: 0, background: bg,
      paddingTop: padTop, paddingBottom: withTabBar ? 64 + 34 : 34,
      overflow: scroll ? 'auto' : 'hidden',
      display: 'flex', flexDirection: 'column',
    }}>
      {children}
    </div>
  );
}

// Export to window so other JSX files can read them
Object.assign(window, {
  COLORS, FONT_STACK, bmiCategory, calcBMI,
  Icon, Button, Field, Segmented, Toggle, Card, StatusPill,
  BMIGauge, ScreenHeader, BottomNav, Screen,
});
