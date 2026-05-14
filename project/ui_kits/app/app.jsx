// BMI Health — App composer
// Holds nav state and routes between screens. Wraps content in iOS device frame.

function App() {
  const [phase, setPhase] = React.useState('splash'); // splash | onboarding | app
  const [tab, setTab] = React.useState('calculate');
  const [overlay, setOverlay] = React.useState(null); // null | 'result' | 'goal' | 'paywall' | 'share'
  const [theme, setTheme] = React.useState('light');

  const [profile, setProfile] = React.useState({
    height: '172', heightUnit: 'cm',
    weight: '78.4', weightUnit: 'kg',
    age: 32, gender: 'f',
  });

  const [entries, setEntries] = React.useState([
    { date: '12 May', short: '12', weight: 78.4, bmi: 26.5, delta: -0.3 },
    { date: '08 May', short: '08', weight: 78.7, bmi: 26.6, delta: -0.4 },
    { date: '04 May', short: '04', weight: 79.1, bmi: 26.7, delta: -0.6 },
    { date: '29 Apr', short: '29', weight: 79.7, bmi: 26.9, delta: -0.3 },
    { date: '24 Apr', short: '24', weight: 80.0, bmi: 27.0, delta: 0 },
  ]);

  const heightCm = +profile.height || 0;
  const weightKg = +profile.weight || 0;
  const bmi = calcBMI(weightKg, heightCm);
  const safeBmi = bmi || 24.0;

  function onCalculate() {
    setOverlay('result');
  }
  function onSaveResult() {
    const date = new Date();
    const m = date.toLocaleDateString('en', { month: 'short' });
    const d = date.getDate();
    setEntries([
      { date: `${d} ${m}`, short: String(d), weight: weightKg, bmi: safeBmi, delta: entries.length ? +(weightKg - entries[0].weight).toFixed(1) : 0 },
      ...entries,
    ]);
    setOverlay(null);
    setTab('history');
  }

  // ─── Active screen body ─────────────────────────────────
  let body;
  if (phase === 'splash') {
    body = <SplashScreen onDone={() => setPhase('onboarding')} />;
  } else if (phase === 'onboarding') {
    body = <OnboardingScreen onDone={() => setPhase('app')} />;
  } else {
    // tabbed app
    let tabBody = null;
    if (tab === 'calculate') {
      const last = entries[0];
      tabBody = (
        <HomeScreen
          profile={profile} setProfile={setProfile}
          onCalculate={onCalculate}
          lastResult={last && { date: last.date, bmi: last.bmi }}
          openTab={setTab}
        />
      );
    } else if (tab === 'history') {
      tabBody = <HistoryScreen entries={entries} openTab={setTab} />;
    } else if (tab === 'tips') {
      tabBody = <TipsScreen openPaywall={() => setOverlay('paywall')} />;
    } else if (tab === 'settings') {
      tabBody = <SettingsScreen
        profile={profile} setProfile={setProfile}
        theme={theme} setTheme={setTheme}
        openPaywall={() => setOverlay('paywall')}
      />;
    }
    body = (
      <>
        {tabBody}
        {!overlay && <BottomNav tab={tab} onChange={setTab} />}
      </>
    );
  }

  // Overlay layer (full-screen takeovers)
  let overlayBody = null;
  if (overlay === 'result') {
    overlayBody = (
      <ResultScreen bmi={safeBmi}
        onClose={() => setOverlay(null)}
        onSave={onSaveResult}
        onSetGoal={() => setOverlay('goal')}
        onShare={() => setOverlay('share')}
      />
    );
  } else if (overlay === 'goal') {
    overlayBody = (
      <GoalScreen profile={profile} current={weightKg || 78.4}
        onStart={() => { setOverlay(null); setTab('history'); }}
        onClose={() => setOverlay(overlay === 'goal' ? 'result' : null)}
      />
    );
  } else if (overlay === 'paywall') {
    overlayBody = <PaywallScreen onClose={() => setOverlay(null)} />;
  } else if (overlay === 'share') {
    overlayBody = <ShareCardScreen bmi={safeBmi} onClose={() => setOverlay(overlay === 'share' ? 'result' : null)} />;
  }

  // ─── Top-level layout ─────────────────────────────────
  return (
    <div data-screen-label="app">
      <div style={{
        display: 'flex', gap: 56, alignItems: 'flex-start',
        padding: '40px 32px', minHeight: '100vh', background: '#F2F1ED',
      }}>
        {/* Left rail: nav controls */}
        <div style={{ width: 260, position: 'sticky', top: 40, display: 'flex', flexDirection: 'column', gap: 18 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
            <img src="../../assets/logomark.svg" width={32} height={32} />
            <div style={{ display: 'flex', flexDirection: 'column' }}>
              <span style={{ font: '700 17px/1.1 ' + FONT_STACK, letterSpacing: '-0.015em', color: COLORS.fg1 }}>BMI Health</span>
              <span style={{ font: '500 12px/1.2 ' + FONT_STACK, color: COLORS.fg3 }}>Mobile UI kit · 10 screens</span>
            </div>
          </div>

          <NavGroup title="Flow"
            items={[
              { id: 'splash', label: 'Splash', icon: 'play', active: phase === 'splash', onClick: () => { setPhase('splash'); setOverlay(null); } },
              { id: 'onboarding', label: 'Onboarding', icon: 'sparkles', active: phase === 'onboarding', onClick: () => { setPhase('onboarding'); setOverlay(null); } },
            ]}
          />

          <NavGroup title="Tabs"
            items={[
              { id: 'calculate', label: 'Calculator', icon: 'calculator', active: phase === 'app' && tab === 'calculate' && !overlay, onClick: () => { setPhase('app'); setTab('calculate'); setOverlay(null); } },
              { id: 'history', label: 'History', icon: 'line-chart', active: phase === 'app' && tab === 'history' && !overlay, onClick: () => { setPhase('app'); setTab('history'); setOverlay(null); } },
              { id: 'tips', label: 'Daily tips', icon: 'lightbulb', active: phase === 'app' && tab === 'tips' && !overlay, onClick: () => { setPhase('app'); setTab('tips'); setOverlay(null); } },
              { id: 'settings', label: 'Settings', icon: 'settings-2', active: phase === 'app' && tab === 'settings' && !overlay, onClick: () => { setPhase('app'); setTab('settings'); setOverlay(null); } },
            ]}
          />

          <NavGroup title="Overlays"
            items={[
              { id: 'result', label: 'Result', icon: 'gauge', active: overlay === 'result', onClick: () => { setPhase('app'); setOverlay('result'); } },
              { id: 'goal', label: 'Set goal', icon: 'target', active: overlay === 'goal', onClick: () => { setPhase('app'); setOverlay('goal'); } },
              { id: 'paywall', label: 'Paywall', icon: 'sparkles', active: overlay === 'paywall', onClick: () => { setPhase('app'); setOverlay('paywall'); } },
              { id: 'share', label: 'Share card', icon: 'share', active: overlay === 'share', onClick: () => { setPhase('app'); setOverlay('share'); } },
            ]}
          />

          <div style={{
            background: '#fff', borderRadius: 14, padding: 14,
            font: '400 12px/1.5 ' + FONT_STACK, color: COLORS.fg2,
            boxShadow: '0 1px 2px rgba(14,20,17,0.04), 0 1px 3px rgba(14,20,17,0.06)',
          }}>
            <span style={{ font: '600 11px/1 ' + FONT_STACK, letterSpacing: '0.08em', textTransform: 'uppercase', color: COLORS.fg3, display: 'block', marginBottom: 6 }}>Tip</span>
            The phone is interactive. Change inputs, press <strong>Calculate BMI</strong>, save results, switch tabs. The sidebar is for quick jumps during review.
          </div>
        </div>

        {/* Phone */}
        <div style={{ flex: 1, display: 'flex', justifyContent: 'center' }}>
          <IOSDevice width={402} height={874} dark={theme === 'dark'}>
            <div style={{ position: 'relative', height: '100%' }}>
              {body}
              {overlayBody}
            </div>
          </IOSDevice>
        </div>
      </div>
    </div>
  );
}

function NavGroup({ title, items }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
      <span style={{ padding: '0 8px 4px', font: '600 10px/1 ' + FONT_STACK, letterSpacing: '0.1em', textTransform: 'uppercase', color: COLORS.fg3 }}>{title}</span>
      {items.map(it => (
        <button key={it.id} onClick={it.onClick} style={{
          display: 'flex', alignItems: 'center', gap: 10, padding: '8px 12px', borderRadius: 10,
          background: it.active ? '#fff' : 'transparent',
          color: it.active ? COLORS.fg1 : COLORS.fg2,
          boxShadow: it.active ? '0 1px 2px rgba(14,20,17,0.04), 0 1px 3px rgba(14,20,17,0.06)' : 'none',
          border: 'none', cursor: 'pointer', font: '500 14px/1 ' + FONT_STACK,
          textAlign: 'left', WebkitTapHighlightColor: 'transparent',
        }}>
          <Icon name={it.icon} size={16} color={it.active ? COLORS.brand : COLORS.fg3} />
          {it.label}
        </button>
      ))}
    </div>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<App />);
