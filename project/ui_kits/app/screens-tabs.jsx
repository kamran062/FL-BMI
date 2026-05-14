// BMI Health — Tab & flow screens: History, Tips, Goal, Paywall, Settings

// ─── 5. HISTORY ─────────────────────────────────────────────
function HistoryScreen({ entries, openTab }) {
  // line chart points (BMI over time)
  const w = 350, h = 130, pad = 12;
  const pts = entries.slice().reverse(); // chronological
  const bmis = pts.map(p => p.bmi);
  const min = Math.min(...bmis, 22) - 0.5;
  const max = Math.max(...bmis, 26) + 0.5;
  const xs = (i) => pad + (i / Math.max(1, pts.length - 1)) * (w - 2 * pad);
  const ys = (v) => pad + (1 - (v - min) / (max - min)) * (h - 2 * pad);
  const path = pts.map((p, i) => `${i === 0 ? 'M' : 'L'} ${xs(i).toFixed(1)} ${ys(p.bmi).toFixed(1)}`).join(' ');
  const area = `${path} L ${xs(pts.length - 1).toFixed(1)} ${h - pad} L ${pad} ${h - pad} Z`;

  const empty = entries.length === 0;

  return (
    <Screen>
      <ScreenHeader title="History" large
        trailing={<Button variant="ghost" size="sm" icon="filter"></Button>}
      />

      {empty ? (
        <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 18, padding: '0 32px' }}>
          <div style={{ width: 88, height: 88, borderRadius: 999, background: COLORS.bgTint, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Icon name="line-chart" size={36} color={COLORS.brand} />
          </div>
          <div style={{ textAlign: 'center', display: 'flex', flexDirection: 'column', gap: 6 }}>
            <h3 style={{ margin: 0, font: '600 19px/1.3 ' + FONT_STACK, color: COLORS.fg1 }}>No history yet</h3>
            <p style={{ margin: 0, font: '400 15px/1.45 ' + FONT_STACK, color: COLORS.fg2 }}>Start tracking today — every entry shapes your trend.</p>
          </div>
          <Button variant="primary" icon="plus" onClick={() => openTab?.('calculate')}>Add first entry</Button>
        </div>
      ) : (
        <div style={{ padding: '0 20px 20px', display: 'flex', flexDirection: 'column', gap: 14 }}>
          {/* Trend card */}
          <Card padding={18}>
            <div style={{ display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between', marginBottom: 10 }}>
              <div style={{ display: 'flex', flexDirection: 'column' }}>
                <span style={{ font: '600 11px/1 ' + FONT_STACK, letterSpacing: '0.08em', textTransform: 'uppercase', color: COLORS.fg3 }}>BMI Trend</span>
                <span style={{ font: '700 28px/1.1 ' + FONT_STACK, letterSpacing: '-0.02em', fontVariantNumeric: 'tabular-nums', color: COLORS.fg1, marginTop: 6 }}>
                  {pts[pts.length - 1].bmi.toFixed(1)}
                </span>
                <span style={{ font: '500 13px/1.3 ' + FONT_STACK, color: COLORS.fg3, marginTop: 2 }}>
                  Last 4 weeks
                </span>
              </div>
              <span style={{
                background: COLORS.normalTint, color: COLORS.normalInk,
                font: '600 12px/1 ' + FONT_STACK, padding: '6px 10px', borderRadius: 999,
                display: 'inline-flex', alignItems: 'center', gap: 4, fontVariantNumeric: 'tabular-nums',
              }}>
                <Icon name="trending-down" size={12} strokeWidth={3} /> −0.6 BMI
              </span>
            </div>
            <svg viewBox={`0 0 ${w} ${h}`} width="100%" height={h} style={{ display: 'block' }}>
              <defs>
                <linearGradient id="trendFill" x1="0" x2="0" y1="0" y2="1">
                  <stop offset="0" stopColor={COLORS.brand} stopOpacity="0.22" />
                  <stop offset="1" stopColor={COLORS.brand} stopOpacity="0" />
                </linearGradient>
              </defs>
              {/* healthy band */}
              <rect x={pad} y={ys(24.9)} width={w - 2 * pad} height={ys(18.5) - ys(24.9)} fill={COLORS.normalTint} opacity="0.6" rx="4" />
              <path d={area} fill="url(#trendFill)" />
              <path d={path} fill="none" stroke={COLORS.brand} strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" />
              {pts.map((p, i) => (
                <circle key={i} cx={xs(i)} cy={ys(p.bmi)} r={i === pts.length - 1 ? 5 : 3} fill="#fff" stroke={COLORS.brand} strokeWidth="2" />
              ))}
            </svg>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 6, font: '500 11px/1 ' + FONT_STACK, color: COLORS.fg3, fontVariantNumeric: 'tabular-nums' }}>
              {pts.map((p, i) => <span key={i}>{p.short}</span>)}
            </div>
          </Card>

          {/* Entry list */}
          <Card padding={0} style={{ overflow: 'hidden' }}>
            <div style={{ padding: '12px 18px', font: '600 11px/1 ' + FONT_STACK, letterSpacing: '0.08em', textTransform: 'uppercase', color: COLORS.fg3 }}>
              Entries  ·  {entries.length}
            </div>
            {entries.map((e, i) => {
              const cat = bmiCategory(e.bmi);
              return (
                <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 14, padding: '14px 18px', borderTop: '1px solid ' + COLORS.borderFaint }}>
                  <div style={{ width: 38, height: 38, borderRadius: 11, background: cat.tint, color: cat.ink, display: 'flex', alignItems: 'center', justifyContent: 'center', flex: 'none' }}>
                    <Icon name={e.delta < 0 ? 'trending-down' : e.delta > 0 ? 'trending-up' : 'minus'} size={18} strokeWidth={2.4} />
                  </div>
                  <div style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
                    <span style={{ font: '600 15px/1.2 ' + FONT_STACK, color: COLORS.fg1, fontVariantNumeric: 'tabular-nums' }}>{e.weight.toFixed(1)} kg</span>
                    <span style={{ font: '500 13px/1.4 ' + FONT_STACK, color: COLORS.fg3, fontVariantNumeric: 'tabular-nums' }}>{e.date} · BMI {e.bmi.toFixed(1)}</span>
                  </div>
                  <span style={{ font: '600 12px/1 ' + FONT_STACK, color: cat.ink }}>{cat.label}</span>
                </div>
              );
            })}
          </Card>
        </div>
      )}
    </Screen>
  );
}

// ─── 6. GOAL ─────────────────────────────────────────────────
function GoalScreen({ profile, current, onStart, onClose }) {
  const [target, setTarget] = React.useState(73);
  const [weeks, setWeeks] = React.useState(8);
  const diff = +(current - target).toFixed(1);
  const direction = diff > 0 ? 'lose' : diff < 0 ? 'gain' : 'maintain';
  const perWeek = Math.abs(diff) / weeks;
  const safe = perWeek <= 1.0;

  return (
    <div style={{ position: 'absolute', inset: 0, background: COLORS.bgCanvas, display: 'flex', flexDirection: 'column', overflow: 'auto', paddingTop: 54, zIndex: 50 }}>
      <ScreenHeader title="Set a goal"
        leading={<Button variant="ghost" size="sm" icon="chevron-left" onClick={onClose}></Button>}
      />

      <div style={{ padding: '0 20px', display: 'flex', flexDirection: 'column', gap: 14 }}>
        {/* Current vs target hero */}
        <Card padding={20} tint={COLORS.bgTint}>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr auto 1fr', alignItems: 'center', gap: 14 }}>
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4 }}>
              <span style={{ font: '600 11px/1 ' + FONT_STACK, letterSpacing: '0.08em', textTransform: 'uppercase', color: COLORS.fg3 }}>Current</span>
              <span style={{ font: '700 28px/1 ' + FONT_STACK, letterSpacing: '-0.025em', fontVariantNumeric: 'tabular-nums', color: COLORS.fg1 }}>{current.toFixed(1)}</span>
              <span style={{ font: '500 12px/1 ' + FONT_STACK, color: COLORS.fg3 }}>kg</span>
            </div>
            <Icon name="arrow-right" size={20} color={COLORS.brand} />
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4 }}>
              <span style={{ font: '600 11px/1 ' + FONT_STACK, letterSpacing: '0.08em', textTransform: 'uppercase', color: COLORS.brand }}>Target</span>
              <span style={{ font: '700 28px/1 ' + FONT_STACK, letterSpacing: '-0.025em', fontVariantNumeric: 'tabular-nums', color: COLORS.fg1 }}>{target.toFixed(1)}</span>
              <span style={{ font: '500 12px/1 ' + FONT_STACK, color: COLORS.fg3 }}>kg</span>
            </div>
          </div>
        </Card>

        {/* Target field */}
        <Card padding={18}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 10 }}>
            <span style={{ font: '600 11px/1 ' + FONT_STACK, letterSpacing: '0.08em', textTransform: 'uppercase', color: COLORS.fg3 }}>Target weight</span>
            <span style={{ font: '500 12px/1 ' + FONT_STACK, color: COLORS.fg3, fontVariantNumeric: 'tabular-nums' }}>{target} kg</span>
          </div>
          <input type="range" min={45} max={120} step={0.5} value={target}
            onChange={e => setTarget(+e.target.value)}
            style={{ width: '100%', accentColor: COLORS.brand }} />
          <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 4, font: '500 11px/1 ' + FONT_STACK, color: COLORS.fg3, fontVariantNumeric: 'tabular-nums' }}>
            <span>45 kg</span><span>120 kg</span>
          </div>
        </Card>

        {/* Timeline */}
        <Card padding={18}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 12 }}>
            <span style={{ font: '600 11px/1 ' + FONT_STACK, letterSpacing: '0.08em', textTransform: 'uppercase', color: COLORS.fg3 }}>Timeline</span>
          </div>
          <Segmented
            options={[{ value: 4, label: '4 weeks' }, { value: 8, label: '8 weeks' }, { value: 12, label: '12 weeks' }, { value: 24, label: '24 weeks' }]}
            value={weeks}
            onChange={setWeeks}
          />
        </Card>

        {/* Plan preview */}
        <Card padding={20} elevation={2} tint={safe ? COLORS.bgSurface : COLORS.overTint}>
          <span style={{ font: '600 11px/1 ' + FONT_STACK, letterSpacing: '0.08em', textTransform: 'uppercase', color: COLORS.fg3 }}>Your plan</span>
          {direction === 'maintain' ? (
            <h3 style={{ margin: '6px 0', font: '600 20px/1.3 ' + FONT_STACK, letterSpacing: '-0.015em', color: COLORS.fg1 }}>
              Maintain your current weight
            </h3>
          ) : (
            <h3 style={{ margin: '6px 0', font: '600 20px/1.3 ' + FONT_STACK, letterSpacing: '-0.015em', color: COLORS.fg1 }}>
              {direction === 'lose' ? 'Lose' : 'Gain'} <span style={{ color: COLORS.brand, fontVariantNumeric: 'tabular-nums' }}>{Math.abs(diff).toFixed(1)} kg</span> in {weeks} weeks
            </h3>
          )}
          <p style={{ margin: '4px 0 12px', font: '400 14px/1.5 ' + FONT_STACK, color: COLORS.fg2 }}>
            That's <span style={{ fontVariantNumeric: 'tabular-nums', fontWeight: 600, color: COLORS.fg1 }}>{perWeek.toFixed(2)} kg / week</span>
            {safe ? ' — a safe, sustainable pace.' : ' — faster than recommended. Try a longer timeline.'}
          </p>
          <div style={{ display: 'flex', gap: 12 }}>
            <div style={{ flex: 1 }}>
              <span style={{ font: '500 11px/1 ' + FONT_STACK, color: COLORS.fg3, letterSpacing: '0.06em', textTransform: 'uppercase' }}>Reach by</span>
              <div style={{ font: '600 15px/1.2 ' + FONT_STACK, color: COLORS.fg1, marginTop: 4 }}>
                {(() => {
                  const d = new Date(); d.setDate(d.getDate() + weeks * 7);
                  return d.toLocaleDateString(undefined, { day: 'numeric', month: 'short', year: 'numeric' });
                })()}
              </div>
            </div>
            <div style={{ flex: 1 }}>
              <span style={{ font: '500 11px/1 ' + FONT_STACK, color: COLORS.fg3, letterSpacing: '0.06em', textTransform: 'uppercase' }}>Daily calories</span>
              <div style={{ font: '600 15px/1.2 ' + FONT_STACK, color: COLORS.fg1, marginTop: 4, fontVariantNumeric: 'tabular-nums' }}>
                {direction === 'lose' ? '−' : direction === 'gain' ? '+' : '±'}{Math.round(perWeek * 1100)} kcal
              </div>
            </div>
          </div>
        </Card>

        <Button variant="primary" size="lg" full icon="target" onClick={onStart} style={{ marginTop: 6, marginBottom: 24 }}>
          Start tracking goal
        </Button>
      </div>
    </div>
  );
}

// ─── 7. TIPS ─────────────────────────────────────────────────
function TipsScreen({ openPaywall }) {
  const [cat, setCat] = React.useState('all');
  const tips = [
    { cat: 'diet', icon: 'apple', title: 'Half your plate, vegetables',
      copy: 'A simple visual rule that crowds out higher-calorie foods without counting.', color: '#16A34A', tint: '#E6F7EC' },
    { cat: 'hydration', icon: 'glass-water', title: 'Water before coffee',
      copy: 'Drink 200 ml of water before your first coffee to reset overnight dehydration.', color: '#3B82F6', tint: '#EAF1FE' },
    { cat: 'exercise', icon: 'footprints', title: 'A 10-min walk after meals',
      copy: 'Studies show short post-meal walks meaningfully lower blood-glucose spikes.', color: '#F59E0B', tint: '#FEF4E2' },
    { cat: 'lifestyle', icon: 'moon', title: 'Sleep is the multiplier',
      copy: 'Under 7 hours raises hunger hormones the next day. Protect a wind-down ritual.', color: '#8B5CF6', tint: '#F0EBFE' },
    { cat: 'diet', icon: 'salad', title: 'Protein first, every meal',
      copy: 'Eat the protein on your plate before carbs — satiety lasts longer.', color: '#16A34A', tint: '#E6F7EC' },
  ];
  const cats = [
    { id: 'all', label: 'All' },
    { id: 'diet', label: 'Diet' },
    { id: 'exercise', label: 'Exercise' },
    { id: 'hydration', label: 'Hydration' },
    { id: 'lifestyle', label: 'Lifestyle' },
  ];
  const visible = cat === 'all' ? tips : tips.filter(t => t.cat === cat);
  const featured = visible[0];

  return (
    <Screen>
      <ScreenHeader title="Daily tips" large
        trailing={<Button variant="ghost" size="sm" icon="bookmark"></Button>}
      />
      {/* Chips */}
      <div style={{ padding: '0 20px 16px', display: 'flex', gap: 8, overflowX: 'auto' }}>
        {cats.map(c => (
          <button key={c.id} onClick={() => setCat(c.id)} style={{
            font: '600 13px/1 ' + FONT_STACK, padding: '9px 14px', borderRadius: 999,
            background: cat === c.id ? COLORS.fg1 : COLORS.bgSurface,
            color: cat === c.id ? '#fff' : COLORS.fg1,
            border: 'none', boxShadow: cat === c.id ? 'none' : '0 1px 2px rgba(14,20,17,0.04)',
            whiteSpace: 'nowrap', cursor: 'pointer', flex: 'none',
          }}>{c.label}</button>
        ))}
      </div>
      <div style={{ padding: '0 20px 20px', display: 'flex', flexDirection: 'column', gap: 14 }}>
        {/* Featured */}
        {featured && (
          <Card padding={22} tint={featured.tint} radius={24}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 16 }}>
              <span style={{
                width: 32, height: 32, borderRadius: 10, background: '#fff',
                display: 'flex', alignItems: 'center', justifyContent: 'center', color: featured.color,
              }}>
                <Icon name={featured.icon} size={18} />
              </span>
              <span style={{ font: '600 11px/1 ' + FONT_STACK, letterSpacing: '0.08em', textTransform: 'uppercase', color: featured.color }}>
                Today · {featured.cat}
              </span>
            </div>
            <h2 style={{ margin: 0, font: '700 24px/1.25 ' + FONT_STACK, letterSpacing: '-0.02em', color: COLORS.fg1 }}>{featured.title}</h2>
            <p style={{ margin: '8px 0 0', font: '400 15px/1.5 ' + FONT_STACK, color: COLORS.fg2 }}>{featured.copy}</p>
          </Card>
        )}

        {/* The rest */}
        {visible.slice(1).map((t, i) => (
          <Card key={i} padding={16}>
            <div style={{ display: 'flex', gap: 14, alignItems: 'flex-start' }}>
              <span style={{
                width: 40, height: 40, borderRadius: 12, background: t.tint, color: t.color,
                display: 'flex', alignItems: 'center', justifyContent: 'center', flex: 'none',
              }}>
                <Icon name={t.icon} size={20} />
              </span>
              <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 2 }}>
                <span style={{ font: '600 15px/1.3 ' + FONT_STACK, color: COLORS.fg1 }}>{t.title}</span>
                <span style={{ font: '400 13px/1.4 ' + FONT_STACK, color: COLORS.fg2 }}>{t.copy}</span>
              </div>
            </div>
          </Card>
        ))}

        {/* Pro nudge */}
        <Card padding={18} tint={COLORS.fg1} radius={24} style={{ color: '#fff' }} onClick={openPaywall}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
            <span style={{ width: 36, height: 36, borderRadius: 10, background: 'rgba(255,255,255,0.12)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <Icon name="sparkles" size={18} color="#fff" />
            </span>
            <div style={{ flex: 1 }}>
              <div style={{ font: '600 14px/1.2 ' + FONT_STACK, color: '#fff' }}>Unlock 500+ premium tips</div>
              <div style={{ font: '400 12px/1.3 ' + FONT_STACK, color: 'rgba(255,255,255,0.7)' }}>Personalized to your BMI and goals</div>
            </div>
            <Icon name="chevron-right" size={18} color="rgba(255,255,255,0.7)" />
          </div>
        </Card>
      </div>
    </Screen>
  );
}

// ─── 8. PAYWALL ──────────────────────────────────────────────
function PaywallScreen({ onClose }) {
  const [plan, setPlan] = React.useState('yearly');
  const plans = [
    { id: 'monthly', label: 'Monthly',  price: '$4.99', sub: 'per month' },
    { id: 'yearly',  label: 'Yearly',   price: '$29.99', sub: '$2.50 / mo · save 50%', badge: 'BEST VALUE' },
    { id: 'lifetime',label: 'Lifetime', price: '$79.99', sub: 'one-time' },
  ];
  const features = [
    { icon: 'check', label: 'Remove ads' },
    { icon: 'line-chart', label: 'Detailed history charts' },
    { icon: 'target', label: 'Unlimited goal tracking' },
    { icon: 'sparkles', label: 'AI-personalized recommendations' },
    { icon: 'lightbulb', label: '500+ premium daily tips' },
    { icon: 'cloud', label: 'Encrypted cloud backup' },
  ];

  return (
    <div style={{ position: 'absolute', inset: 0, background: COLORS.bgCanvas, overflow: 'auto', paddingTop: 54, zIndex: 50 }}>
      <ScreenHeader title=""
        leading={<Button variant="ghost" size="sm" icon="x" onClick={onClose}></Button>}
        trailing={<Button variant="ghost" size="sm" onClick={onClose}>Restore</Button>}
      />

      {/* Hero */}
      <div style={{ padding: '12px 20px 24px', display: 'flex', flexDirection: 'column', gap: 6 }}>
        <span style={{ display: 'inline-flex', alignItems: 'center', gap: 6, font: '600 11px/1 ' + FONT_STACK, letterSpacing: '0.12em', textTransform: 'uppercase', color: COLORS.brand }}>
          <Icon name="sparkles" size={14} /> Premium
        </span>
        <h1 style={{ margin: '6px 0 6px', font: '700 30px/1.15 ' + FONT_STACK, letterSpacing: '-0.025em', color: COLORS.fg1 }}>
          Unlock your full health journey
        </h1>
        <p style={{ margin: 0, font: '400 15px/1.5 ' + FONT_STACK, color: COLORS.fg2 }}>
          Everything in BMI Health, plus the long-term tools to turn one reading into a habit.
        </p>
      </div>

      {/* Feature list */}
      <div style={{ padding: '0 20px' }}>
        <Card padding={18}>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            {features.map((f, i) => (
              <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                <span style={{ width: 26, height: 26, borderRadius: 8, background: COLORS.brandTint, color: COLORS.brand, display: 'flex', alignItems: 'center', justifyContent: 'center', flex: 'none' }}>
                  <Icon name={f.icon} size={14} strokeWidth={2.5} />
                </span>
                <span style={{ font: '500 15px/1.3 ' + FONT_STACK, color: COLORS.fg1 }}>{f.label}</span>
              </div>
            ))}
          </div>
        </Card>
      </div>

      {/* Plans */}
      <div style={{ padding: '20px 20px 0', display: 'flex', flexDirection: 'column', gap: 10 }}>
        {plans.map(p => {
          const on = p.id === plan;
          return (
            <Card key={p.id}
              padding={18}
              tint={on ? COLORS.brandTint : COLORS.bgSurface}
              elevation={on ? 0 : 1}
              style={{
                border: on ? '2px solid ' + COLORS.brand : '2px solid transparent',
                position: 'relative', cursor: 'pointer',
              }}
              onClick={() => setPlan(p.id)}
            >
              <div style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
                <span style={{
                  width: 22, height: 22, borderRadius: 999, border: '2px solid ' + (on ? COLORS.brand : COLORS.borderSubtle),
                  background: on ? COLORS.brand : 'transparent', display: 'flex', alignItems: 'center', justifyContent: 'center', flex: 'none',
                }}>
                  {on && <Icon name="check" size={12} color="#fff" strokeWidth={3} />}
                </span>
                <div style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                    <span style={{ font: '600 16px/1.2 ' + FONT_STACK, color: COLORS.fg1 }}>{p.label}</span>
                    {p.badge && <span style={{ font: '700 10px/1 ' + FONT_STACK, letterSpacing: 0.6, padding: '4px 8px', borderRadius: 999, background: COLORS.brand, color: '#fff' }}>{p.badge}</span>}
                  </div>
                  <span style={{ font: '500 13px/1.3 ' + FONT_STACK, color: COLORS.fg3, marginTop: 2 }}>{p.sub}</span>
                </div>
                <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-end' }}>
                  <span style={{ font: '700 19px/1 ' + FONT_STACK, color: COLORS.fg1, fontVariantNumeric: 'tabular-nums', letterSpacing: '-0.02em' }}>{p.price}</span>
                </div>
              </div>
            </Card>
          );
        })}
      </div>

      <div style={{ padding: '20px 20px 12px' }}>
        <Button variant="primary" size="lg" full icon="sparkles" onClick={onClose}>Upgrade now</Button>
      </div>
      <p style={{ margin: '0 20px 36px', font: '500 12px/1.4 ' + FONT_STACK, color: COLORS.fg3, textAlign: 'center' }}>
        Auto-renews. Cancel anytime. No ads, no tracking.
      </p>
    </div>
  );
}

// ─── 9. SETTINGS ─────────────────────────────────────────────
function SettingsScreen({ profile, setProfile, theme, setTheme, openPaywall }) {
  const sections = [
    {
      title: 'Appearance',
      rows: [
        { icon: 'moon', label: 'Dark mode', kind: 'toggle', state: theme === 'dark', onChange: v => setTheme(v ? 'dark' : 'light') },
      ],
    },
    {
      title: 'Units',
      rows: [
        { icon: 'ruler', label: 'Height', kind: 'meta', meta: profile.heightUnit === 'cm' ? 'cm' : 'ft / in' },
        { icon: 'weight', label: 'Weight', kind: 'meta', meta: profile.weightUnit === 'kg' ? 'kg' : 'lbs' },
      ],
    },
    {
      title: 'Notifications',
      rows: [
        { icon: 'bell', label: 'Daily reminders', kind: 'toggle', state: true },
        { icon: 'calendar', label: 'Weekly check-in', kind: 'toggle', state: false },
      ],
    },
    {
      title: 'About',
      rows: [
        { icon: 'shield-check', label: 'Privacy', kind: 'nav', meta: 'On-device' },
        { icon: 'refresh-ccw', label: 'Restore purchases', kind: 'nav' },
        { icon: 'info', label: 'Version', kind: 'meta', meta: '1.0 (build 42)' },
      ],
    },
  ];

  return (
    <Screen>
      <ScreenHeader title="Settings" large />

      <div style={{ padding: '0 20px 20px', display: 'flex', flexDirection: 'column', gap: 20 }}>
        {/* Premium upsell */}
        <Card padding={20} radius={24} tint={COLORS.fg1} style={{ color: '#fff', position: 'relative', overflow: 'hidden' }} onClick={openPaywall}>
          <div style={{
            position: 'absolute', right: -40, top: -40, width: 160, height: 160, borderRadius: 999,
            background: 'radial-gradient(circle, rgba(31,181,115,0.45), rgba(31,181,115,0))', pointerEvents: 'none',
          }} />
          <div style={{ position: 'relative' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 8 }}>
              <Icon name="sparkles" size={16} color={COLORS.brand} />
              <span style={{ font: '600 11px/1 ' + FONT_STACK, letterSpacing: '0.12em', textTransform: 'uppercase', color: COLORS.brand }}>Premium</span>
            </div>
            <h3 style={{ margin: 0, font: '600 19px/1.3 ' + FONT_STACK, letterSpacing: '-0.015em' }}>Track your full journey</h3>
            <p style={{ margin: '4px 0 14px', font: '400 13px/1.4 ' + FONT_STACK, color: 'rgba(255,255,255,0.65)' }}>Unlimited goals, advanced insights, and 500+ tips — from $2.50 / mo.</p>
            <Button variant="primary" size="sm" icon="arrow-right" onClick={openPaywall}>See plans</Button>
          </div>
        </Card>

        {sections.map((sec, si) => (
          <div key={si} style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
            <span style={{ padding: '0 4px', font: '600 11px/1 ' + FONT_STACK, letterSpacing: '0.08em', textTransform: 'uppercase', color: COLORS.fg3 }}>{sec.title}</span>
            <Card padding={0} style={{ overflow: 'hidden' }}>
              {sec.rows.map((r, ri) => (
                <div key={ri} style={{
                  display: 'flex', alignItems: 'center', gap: 14, padding: '14px 18px',
                  borderTop: ri > 0 ? '1px solid ' + COLORS.borderFaint : 'none',
                }}>
                  <span style={{ width: 32, height: 32, borderRadius: 10, background: COLORS.bgTint, color: COLORS.brand, display: 'flex', alignItems: 'center', justifyContent: 'center', flex: 'none' }}>
                    <Icon name={r.icon} size={16} />
                  </span>
                  <span style={{ flex: 1, font: '500 15px/1.3 ' + FONT_STACK, color: COLORS.fg1 }}>{r.label}</span>
                  {r.kind === 'toggle' && <Toggle on={r.state} onChange={r.onChange} />}
                  {r.kind === 'meta' && <span style={{ font: '500 13px/1 ' + FONT_STACK, color: COLORS.fg3, fontVariantNumeric: 'tabular-nums' }}>{r.meta}</span>}
                  {r.kind === 'nav' && (
                    <>
                      {r.meta && <span style={{ font: '500 13px/1 ' + FONT_STACK, color: COLORS.fg3 }}>{r.meta}</span>}
                      <Icon name="chevron-right" size={18} color={COLORS.fg3} />
                    </>
                  )}
                </div>
              ))}
            </Card>
          </div>
        ))}

        <p style={{ textAlign: 'center', font: '500 12px/1.4 ' + FONT_STACK, color: COLORS.fg3, margin: '8px 0 0' }}>
          Made with care.  ·  No account required.
        </p>
      </div>
    </Screen>
  );
}

Object.assign(window, {
  HistoryScreen, GoalScreen, TipsScreen, PaywallScreen, SettingsScreen,
});
