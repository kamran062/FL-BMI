// BMI Health — Flow screens: Splash, Onboarding, Home, Result, ShareCard

// ─── 1. SPLASH ─────────────────────────────────────────────
function SplashScreen({ onDone }) {
  React.useEffect(() => {
    const t = setTimeout(() => onDone?.(), 1900);
    return () => clearTimeout(t);
  }, [onDone]);
  return (
    <div style={{
      position: 'absolute', inset: 0,
      background: 'linear-gradient(180deg, #E8F7EF 0%, #F4FBF7 50%, #FFFFFF 100%)',
      display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 24,
    }}>
      <style>{`
        @keyframes bmihealthPulse {
          0%, 100% { transform: scale(1); opacity: 0.55; }
          50%      { transform: scale(1.18); opacity: 0; }
        }
        @keyframes bmihealthRise { from { opacity: 0; transform: translateY(8px); } to { opacity: 1; transform: translateY(0); } }
      `}</style>
      <div style={{ position: 'relative', width: 132, height: 132 }}>
        {/* glow */}
        <div style={{
          position: 'absolute', inset: 0, borderRadius: 999,
          background: 'radial-gradient(circle, rgba(31,181,115,0.30), rgba(31,181,115,0) 70%)',
          animation: 'bmihealthPulse 2.4s ease-in-out infinite',
        }} />
        <div style={{
          position: 'absolute', inset: 12, borderRadius: 999,
          background: '#fff', boxShadow: '0 12px 32px rgba(31,181,115,0.18), 0 1px 0 rgba(255,255,255,0.6) inset',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <img src="../../assets/logomark.svg" width="64" height="64" alt="" />
        </div>
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8, animation: 'bmihealthRise 700ms 400ms cubic-bezier(0.22,0.61,0.36,1) both' }}>
        <span style={{ font: '700 32px/1 ' + FONT_STACK, letterSpacing: '-0.025em', color: COLORS.fg1 }}>BMI Health</span>
        <span style={{ font: '400 15px/1.4 ' + FONT_STACK, color: COLORS.fg2 }}>Know Your Body. Improve Your Health.</span>
      </div>
      <div style={{ position: 'absolute', bottom: 72, font: '500 12px/1 ' + FONT_STACK, color: COLORS.fg3, letterSpacing: 0.4, textTransform: 'uppercase' }}>v 1.0</div>
    </div>
  );
}

// ─── 2. ONBOARDING ─────────────────────────────────────────
function OnboardingScreen({ onDone }) {
  const [i, setI] = React.useState(0);
  const steps = [
    {
      art: 'calculator',
      title: 'Track your health easily',
      sub: 'Calculate your BMI in seconds, no account needed.',
    },
    {
      art: 'lightbulb',
      title: 'Get smart recommendations',
      sub: 'Personalized advice based on your body and goals.',
    },
    {
      art: 'line-chart',
      title: 'Track progress over time',
      sub: 'See your weight journey visually, week by week.',
    },
  ];
  const last = i === steps.length - 1;
  const step = steps[i];

  return (
    <div style={{ position: 'absolute', inset: 0, background: COLORS.bgCanvas, display: 'flex', flexDirection: 'column' }}>
      {/* top bar */}
      <div style={{ paddingTop: 54, paddingLeft: 20, paddingRight: 20, display: 'flex', alignItems: 'center', justifyContent: 'flex-end', height: 80 }}>
        {!last && <Button variant="ghost" size="sm" onClick={onDone}>Skip</Button>}
      </div>
      {/* art */}
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '0 32px', gap: 40 }}>
        <div style={{
          width: 200, height: 200, borderRadius: 999,
          background: 'linear-gradient(160deg, #E8F7EF, #C6EFDA)',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          boxShadow: '0 24px 48px rgba(31,181,115,0.12)',
        }}>
          <Icon name={step.art} size={88} strokeWidth={1.5} color={COLORS.normalInk} />
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 12, textAlign: 'center' }}>
          <h1 style={{ margin: 0, font: '700 28px/1.2 ' + FONT_STACK, letterSpacing: '-0.02em', color: COLORS.fg1 }}>{step.title}</h1>
          <p style={{ margin: 0, font: '400 17px/1.4 ' + FONT_STACK, color: COLORS.fg2, maxWidth: 300 }}>{step.sub}</p>
        </div>
      </div>
      {/* dots */}
      <div style={{ display: 'flex', justifyContent: 'center', gap: 8, paddingBottom: 28 }}>
        {steps.map((_, k) => (
          <span key={k} style={{
            width: k === i ? 22 : 8, height: 8, borderRadius: 999,
            background: k === i ? COLORS.brand : COLORS.borderSubtle,
            transition: 'all 240ms cubic-bezier(0.22,0.61,0.36,1)',
          }} />
        ))}
      </div>
      {/* CTA */}
      <div style={{ padding: '0 20px 48px' }}>
        <Button
          variant="primary" size="lg" full
          onClick={() => last ? onDone?.() : setI(i + 1)}
        >{last ? 'Get started' : 'Continue'}</Button>
      </div>
    </div>
  );
}

// ─── 3. HOME / CALCULATE ───────────────────────────────────
function HomeScreen({ profile, setProfile, onCalculate, lastResult, openTab }) {
  return (
    <Screen>
      <ScreenHeader title="BMI Calculator" large
        trailing={<Button variant="ghost" size="sm" icon="user-round" onClick={() => openTab?.('settings')}></Button>}
      />

      {/* Hint subtitle */}
      <div style={{ padding: '0 20px 16px' }}>
        <span style={{ font: '400 15px/1.5 ' + FONT_STACK, color: COLORS.fg2 }}>
          Enter your measurements to see your BMI and a tailored recommendation.
        </span>
      </div>

      <div style={{ padding: '0 20px 24px', display: 'flex', flexDirection: 'column', gap: 14 }}>
        {/* Height */}
        <Card padding={18}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 12 }}>
            <span style={{ font: '600 11px/1 ' + FONT_STACK, letterSpacing: '0.08em', textTransform: 'uppercase', color: COLORS.fg3 }}>Height</span>
            <Segmented size="sm"
              options={[{ value: 'cm', label: 'cm' }, { value: 'ft', label: 'ft / in' }]}
              value={profile.heightUnit}
              onChange={v => setProfile({ ...profile, heightUnit: v })}
            />
          </div>
          <Field
            value={profile.height}
            onChange={v => setProfile({ ...profile, height: v })}
            unit={profile.heightUnit === 'cm' ? 'cm' : 'ft / in'}
            type="number"
          />
        </Card>

        {/* Weight */}
        <Card padding={18}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 12 }}>
            <span style={{ font: '600 11px/1 ' + FONT_STACK, letterSpacing: '0.08em', textTransform: 'uppercase', color: COLORS.fg3 }}>Weight</span>
            <Segmented size="sm"
              options={[{ value: 'kg', label: 'kg' }, { value: 'lbs', label: 'lbs' }]}
              value={profile.weightUnit}
              onChange={v => setProfile({ ...profile, weightUnit: v })}
            />
          </div>
          <Field
            value={profile.weight}
            onChange={v => setProfile({ ...profile, weight: v })}
            unit={profile.weightUnit}
            type="number"
          />
        </Card>

        {/* Age + Gender */}
        <Card padding={18}>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
            <div>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 10 }}>
                <span style={{ font: '600 11px/1 ' + FONT_STACK, letterSpacing: '0.08em', textTransform: 'uppercase', color: COLORS.fg3 }}>Age</span>
                <span style={{ font: '600 22px/1 ' + FONT_STACK, color: COLORS.fg1, fontVariantNumeric: 'tabular-nums', letterSpacing: '-0.02em' }}>{profile.age}<span style={{ font: '500 12px/1 ' + FONT_STACK, color: COLORS.fg3, marginLeft: 4 }}>yrs</span></span>
              </div>
              <input type="range" min={14} max={90} value={profile.age}
                onChange={e => setProfile({ ...profile, age: +e.target.value })}
                style={{ width: '100%', accentColor: COLORS.brand }} />
            </div>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
              <span style={{ font: '600 11px/1 ' + FONT_STACK, letterSpacing: '0.08em', textTransform: 'uppercase', color: COLORS.fg3 }}>Gender</span>
              <Segmented size="sm"
                options={[{ value: 'f', label: 'Female' }, { value: 'm', label: 'Male' }, { value: 'o', label: 'Other' }]}
                value={profile.gender}
                onChange={v => setProfile({ ...profile, gender: v })}
              />
            </div>
          </div>
        </Card>

        <Button variant="primary" size="lg" full icon="calculator" onClick={onCalculate} style={{ marginTop: 8 }}>
          Calculate BMI
        </Button>

        {lastResult && (
          <Card tint={COLORS.bgTint} padding={16} style={{ marginTop: 4 }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
              <div style={{ width: 40, height: 40, borderRadius: 12, background: COLORS.bgSurface, display: 'flex', alignItems: 'center', justifyContent: 'center', color: COLORS.brand }}>
                <Icon name="history" size={20} />
              </div>
              <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 2 }}>
                <span style={{ font: '500 13px/1 ' + FONT_STACK, color: COLORS.fg3 }}>Last result · {lastResult.date}</span>
                <span style={{ font: '600 15px/1 ' + FONT_STACK, color: COLORS.fg1, fontVariantNumeric: 'tabular-nums' }}>BMI {lastResult.bmi.toFixed(1)} · <span style={{ color: bmiCategory(lastResult.bmi).color }}>{bmiCategory(lastResult.bmi).label}</span></span>
              </div>
              <Icon name="chevron-right" size={18} color={COLORS.fg3} />
            </div>
          </Card>
        )}
      </div>
    </Screen>
  );
}

// ─── 4. RESULT ─────────────────────────────────────────────
function ResultScreen({ bmi, onClose, onSave, onSetGoal, onShare }) {
  const cat = bmiCategory(bmi);
  const advice = {
    under: {
      headline: 'Slightly below the normal range',
      copy: 'A small calorie surplus and strength work can help you reach a healthy range.',
      steps: ['Aim for +300 kcal/day from whole foods', 'Add 2 strength sessions a week', 'Track weight every 3 days'],
    },
    normal: {
      headline: 'You are in the healthy range',
      copy: 'Maintain with consistent movement, sleep, and balanced meals.',
      steps: ['Walk 7,000+ steps daily', 'Sleep 7–9 hours', 'Re-check BMI in 4 weeks'],
    },
    over: {
      headline: 'Slightly above the normal range',
      copy: 'A small, sustained calorie deficit moves you back to the normal range without crash dieting.',
      steps: ['Aim for a 0.5 kg loss this week', 'Add 30 min daily movement', 'Drink water before meals'],
    },
    obese: {
      headline: 'Above the normal range',
      copy: 'Steady, gentle changes work best. Consider a check-in with a clinician for personalized guidance.',
      steps: ['Aim for 0.5–1.0 kg loss per week', 'Replace sugary drinks with water', 'Walk 30 minutes after meals'],
    },
  }[cat.key];

  return (
    <div style={{ position: 'absolute', inset: 0, background: COLORS.bgCanvas, overflow: 'auto', paddingTop: 54, paddingBottom: 34, zIndex: 50 }}>
      <ScreenHeader
        title="Your result"
        leading={<Button variant="ghost" size="sm" icon="chevron-left" onClick={onClose}></Button>}
        trailing={<Button variant="ghost" size="sm" icon="share" onClick={onShare}></Button>}
      />
      <div style={{ display: 'flex', justifyContent: 'center', padding: '8px 0 24px' }}>
        <BMIGauge value={bmi} size={240} />
      </div>

      <div style={{ padding: '0 20px', display: 'flex', flexDirection: 'column', gap: 14 }}>
        {/* Recommendation card */}
        <Card padding={20} elevation={1}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 8 }}>
            <span style={{ font: '600 11px/1 ' + FONT_STACK, letterSpacing: '0.08em', textTransform: 'uppercase', color: COLORS.fg3 }}>Recommendation</span>
            <span style={{ flex: 1 }} />
            <StatusPill category={cat} solid />
          </div>
          <h3 style={{ margin: '4px 0 6px', font: '600 19px/1.3 ' + FONT_STACK, letterSpacing: '-0.015em', color: COLORS.fg1 }}>{advice.headline}</h3>
          <p style={{ margin: '0 0 14px', font: '400 15px/1.5 ' + FONT_STACK, color: COLORS.fg2 }}>{advice.copy}</p>
          <ul style={{ margin: 0, padding: 0, listStyle: 'none', display: 'flex', flexDirection: 'column', gap: 10 }}>
            {advice.steps.map((s, k) => (
              <li key={k} style={{ display: 'flex', gap: 10, alignItems: 'flex-start' }}>
                <span style={{ marginTop: 4, width: 18, height: 18, borderRadius: 999, background: cat.tint, color: cat.ink, display: 'flex', alignItems: 'center', justifyContent: 'center', flex: 'none' }}>
                  <Icon name="check" size={12} strokeWidth={3} />
                </span>
                <span style={{ font: '400 14px/1.45 ' + FONT_STACK, color: COLORS.fg1 }}>{s}</span>
              </li>
            ))}
          </ul>
        </Card>

        {/* Range card */}
        <Card padding={18} tint={COLORS.bgTint}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 12 }}>
            <span style={{ font: '600 11px/1 ' + FONT_STACK, letterSpacing: '0.08em', textTransform: 'uppercase', color: COLORS.fg3 }}>Healthy range</span>
            <span style={{ font: '600 13px/1 ' + FONT_STACK, color: COLORS.normalInk, fontVariantNumeric: 'tabular-nums' }}>18.5 – 24.9</span>
          </div>
          {/* mini range bar */}
          <div style={{ position: 'relative', height: 10, borderRadius: 999, background: COLORS.bgSurface, overflow: 'hidden' }}>
            <div style={{ position: 'absolute', left: '17%', width: '25%', top: 0, bottom: 0, background: COLORS.normal, opacity: 0.65 }} />
            <div style={{
              position: 'absolute',
              left: `${Math.max(0, Math.min(100, ((bmi - 14) / (40 - 14)) * 100))}%`,
              top: -3, width: 4, height: 16, borderRadius: 4, background: cat.color,
              transform: 'translateX(-2px)',
            }} />
          </div>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 8, font: '500 11px/1 ' + FONT_STACK, color: COLORS.fg3, fontVariantNumeric: 'tabular-nums' }}>
            <span>14</span><span>18.5</span><span>25</span><span>30</span><span>40</span>
          </div>
        </Card>
      </div>

      {/* Action row */}
      <div style={{ padding: '24px 20px 16px', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
        <Button variant="secondary" icon="bookmark" onClick={onSave}>Save result</Button>
        <Button variant="secondary" icon="target" onClick={onSetGoal}>Set goal</Button>
      </div>
      <div style={{ padding: '0 20px' }}>
        <Button variant="primary" size="lg" full icon="share" onClick={onShare}>Share result</Button>
      </div>
    </div>
  );
}

// ─── 10. SHARE CARD ─────────────────────────────────────────
function ShareCardScreen({ bmi, onClose }) {
  const cat = bmiCategory(bmi);
  return (
    <div style={{ position: 'absolute', inset: 0, background: '#0E1411', display: 'flex', flexDirection: 'column', paddingTop: 54, zIndex: 50 }}>
      <ScreenHeader
        title="Share"
        leading={<Button variant="ghost" size="sm" icon="x" onClick={onClose} style={{ color: '#fff' }}></Button>}
      />
      <div style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '0 20px' }}>
        {/* Instagram-ready 4:5 card */}
        <div style={{
          width: 320, aspectRatio: '4 / 5', borderRadius: 24, overflow: 'hidden',
          background: `linear-gradient(160deg, ${cat.color} 0%, #0E1411 100%)`,
          color: '#fff', padding: '28px 26px', display: 'flex', flexDirection: 'column',
          boxShadow: '0 24px 48px rgba(0,0,0,0.5)', position: 'relative',
        }}>
          {/* Header: wordmark */}
          <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
            <div style={{ width: 22, height: 22, borderRadius: 7, background: 'rgba(255,255,255,0.15)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <img src="../../assets/logomark.svg" width={14} height={14} style={{ filter: 'brightness(0) invert(1)' }} />
            </div>
            <span style={{ font: '600 13px/1 ' + FONT_STACK, letterSpacing: '-0.005em' }}>BMI Health</span>
          </div>
          {/* Hero number */}
          <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center', gap: 4, marginTop: 24 }}>
            <span style={{ font: '600 11px/1 ' + FONT_STACK, letterSpacing: '0.12em', textTransform: 'uppercase', opacity: 0.7 }}>{cat.label}</span>
            <span style={{ font: '700 96px/0.95 ' + FONT_STACK, letterSpacing: '-0.04em', fontVariantNumeric: 'tabular-nums' }}>{bmi.toFixed(1)}</span>
            <span style={{ font: '500 13px/1 ' + FONT_STACK, opacity: 0.7 }}>kg/m²  ·  today</span>
          </div>
          {/* Footer message */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
            <span style={{ font: '500 14px/1.4 ' + FONT_STACK, opacity: 0.9 }}>
              {cat.key === 'normal' ? 'Within the healthy range — keeping it up.' : 'Tracking my body, one week at a time.'}
            </span>
            <span style={{ font: '500 11px/1 ' + FONT_STACK, opacity: 0.5, marginTop: 8 }}>bmihealth.app</span>
          </div>
        </div>
      </div>
      <div style={{ padding: '20px 20px 48px', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
        <Button variant="light" icon="download" onClick={onClose}>Save image</Button>
        <Button variant="primary" icon="share" onClick={onClose}>Share</Button>
      </div>
    </div>
  );
}

Object.assign(window, {
  SplashScreen, OnboardingScreen, HomeScreen, ResultScreen, ShareCardScreen,
});
