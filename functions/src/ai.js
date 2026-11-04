'use strict';

// AI coach and food-photo estimate (ROADMAP 4.4 / 4.5).
// Pure request logic: the Anthropic client and the usage store are passed
// in, so tests run without network or cost.

const MODEL = 'claude-opus-5-5';

// Server-side refusal fallback ("default" routing by refusal category).
const FALLBACK = { betas: ['server-side-fallback-2026-07-01'], fallbacks: 'default' };

// Per install per UTC day. Generous for real use, caps runaway cost.
const LIMITS = { coach: 30, food: 15 };

class BadRequest extends Error {}
class RateLimited extends Error {}

// ── Safety ─────────────────────────────────────────────────────────────────
// Emergencies get a fixed answer without calling the model: fastest, and
// never depends on model behaviour.
const EMERGENCY = [
  /chest pain/i, /can'?t breathe|cannot breathe|difficulty breathing/i,
  /faint(ed|ing)?\b/i, /suicid/i, /kill myself/i, /self[- ]?harm/i,
  /overdos/i, /stroke/i, /heart attack/i,
];

const EMERGENCY_REPLY =
  'This sounds like it could be urgent. Please stop exercising and contact ' +
  'emergency services or a doctor right now (in Pakistan, call 1122; ' +
  'elsewhere, your local emergency number). If you are thinking about ' +
  'harming yourself, please reach out to someone you trust or a local ' +
  'crisis line now. I can only help with general fitness questions.';

function isEmergency(text) {
  return EMERGENCY.some((re) => re.test(text));
}

const COACH_SYSTEM = `You are the in-app fitness and nutrition coach of BMI Health, a general wellness app.

Help with: training plans and technique, progressive overload, recovery, healthy eating, calories and protein, hydration, sleep habits, staying motivated.

Rules:
- You are not a doctor. Do not diagnose, interpret symptoms, lab results or medication, or advise on medical conditions, pregnancy complications, eating disorders or injuries beyond "rest and see a professional". For those, say briefly that a doctor or physiotherapist should advise, then offer general wellness help if useful.
- Never recommend extreme calorie restriction (below about 1200 kcal/day for women or 1500 for men), crash diets, or unsupervised supplements beyond basics (protein, creatine, vitamin D).
- Respect the user's gender, goal and experience from the profile, but never make assumptions based on gender beyond what the profile says.
- Keep answers short and practical: usually under 150 words, plain sentences or a short list. Use kg and metric units unless the user uses others.
- Reply in the user's language (English or Urdu).
- If asked about anything unrelated to fitness, nutrition or wellbeing, politely say you can only help with those.`;

// ── Validation ─────────────────────────────────────────────────────────────
function checkInstallId(id) {
  if (typeof id !== 'string' || !/^[A-Za-z0-9-]{16,64}$/.test(id)) {
    throw new BadRequest('bad install id');
  }
}

function checkMessages(messages) {
  if (!Array.isArray(messages) || messages.length < 1 || messages.length > 20) {
    throw new BadRequest('bad messages');
  }
  messages.forEach((m, i) => {
    const role = i % 2 === 0 ? 'user' : 'assistant';
    if (!m || m.role !== role || typeof m.content !== 'string' ||
        m.content.trim().length === 0 || m.content.length > 2000) {
      throw new BadRequest('bad messages');
    }
  });
  if (messages[messages.length - 1].role !== 'user') throw new BadRequest('bad messages');
}

/** Short, non-identifying profile line for the system prompt. */
function profileLine(p) {
  if (!p || typeof p !== 'object') return '';
  const parts = [];
  const pick = (k, re) => (typeof p[k] === 'string' && re.test(p[k]) ? p[k] : null);
  const num = (k, lo, hi) => (typeof p[k] === 'number' && p[k] >= lo && p[k] <= hi ? p[k] : null);
  const sex = pick('sex', /^(male|female|other)$/);
  const goal = pick('goal', /^[a-zA-Z]{3,20}$/);
  const exp = pick('experience', /^[a-zA-Z]{3,20}$/);
  const age = num('age', 13, 100);
  const kg = num('weightKg', 25, 300);
  const days = num('trainingDays', 0, 7);
  if (sex) parts.push(`sex: ${sex}`);
  if (age) parts.push(`age: ${age}`);
  if (kg) parts.push(`weight: ${kg} kg`);
  if (goal) parts.push(`goal: ${goal}`);
  if (exp) parts.push(`experience: ${exp}`);
  if (days !== null) parts.push(`training days/week: ${days}`);
  return parts.length ? `\n\nUser profile: ${parts.join(', ')}.` : '';
}

// ── Rate limit ─────────────────────────────────────────────────────────────
/** store.increment(key) → new count (atomic). */
async function consume(store, kind, installId, now = new Date()) {
  const day = now.toISOString().slice(0, 10);
  const count = await store.increment(`${kind}:${installId}:${day}`);
  if (count > LIMITS[kind]) throw new RateLimited(kind);
}

function textOf(response) {
  if (response.stop_reason === 'refusal') return null;
  return response.content
    .filter((b) => b.type === 'text')
    .map((b) => b.text)
    .join('')
    .trim();
}

// ── Coach ──────────────────────────────────────────────────────────────────
async function coach(body, { client, store, now }) {
  const { installId, messages, profile } = body || {};
  checkInstallId(installId);
  checkMessages(messages);

  const last = messages[messages.length - 1].content;
  if (isEmergency(last)) return { reply: EMERGENCY_REPLY, emergency: true };

  await consume(store, 'coach', installId, now);
  const response = await client.beta.messages.create({
    model: MODEL,
    max_tokens: 2000,
    output_config: { effort: 'low' }, // chat: quick, short answers
    system: COACH_SYSTEM + profileLine(profile),
    messages,
    ...FALLBACK,
  });
  const reply = textOf(response);
  return reply
    ? { reply }
    : { reply: 'Sorry, I can’t help with that. I can help with training, food and recovery questions.' };
}

// ── Food photo ─────────────────────────────────────────────────────────────
const FOOD_SCHEMA = {
  type: 'object',
  properties: {
    is_food: { type: 'boolean' },
    items: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          name: { type: 'string' },
          grams: { type: 'number' },
          kcal: { type: 'number' },
          protein_g: { type: 'number' },
        },
        required: ['name', 'grams', 'kcal', 'protein_g'],
        additionalProperties: false,
      },
    },
    confidence: { type: 'string', enum: ['low', 'medium', 'high'] },
  },
  required: ['is_food', 'items', 'confidence'],
  additionalProperties: false,
};

const FOOD_PROMPT =
  'Estimate the food in this photo for a calorie log. List each distinct ' +
  'item with an estimated portion in grams, calories and protein. Use ' +
  'typical South Asian home and restaurant portions when the dish is ' +
  'South Asian (e.g. roti ~40 g, a plate of biryani ~350 g). If the photo ' +
  'does not show food, set is_food to false and return no items. Be honest ' +
  'about uncertainty in the confidence field.';

const MAX_IMAGE_B64 = 2_000_000; // ~1.5 MB JPEG

async function estimateFood(body, { client, store, now }) {
  const { installId, image } = body || {};
  checkInstallId(installId);
  if (typeof image !== 'string' || image.length < 100 || image.length > MAX_IMAGE_B64 ||
      !/^[A-Za-z0-9+/=]+$/.test(image)) {
    throw new BadRequest('bad image');
  }
  await consume(store, 'food', installId, now);

  const response = await client.beta.messages.create({
    model: MODEL,
    max_tokens: 4000,
    output_config: {
      effort: 'medium',
      format: { type: 'json_schema', schema: FOOD_SCHEMA },
    },
    messages: [{
      role: 'user',
      content: [
        { type: 'image', source: { type: 'base64', media_type: 'image/jpeg', data: image } },
        { type: 'text', text: FOOD_PROMPT },
      ],
    }],
    ...FALLBACK,
  });

  const text = textOf(response);
  if (!text) return { is_food: false, items: [], confidence: 'low' };
  const parsed = JSON.parse(text);
  // Clamp anything implausible before it reaches the user's log.
  parsed.items = (parsed.items || []).slice(0, 12).map((i) => ({
    name: String(i.name).slice(0, 60),
    grams: Math.max(0, Math.min(2000, Math.round(i.grams))),
    kcal: Math.max(0, Math.min(3000, Math.round(i.kcal))),
    protein_g: Math.max(0, Math.min(200, Math.round(i.protein_g * 10) / 10)),
  }));
  return parsed;
}

module.exports = {
  coach, estimateFood, isEmergency, profileLine, consume,
  BadRequest, RateLimited, LIMITS, MODEL, COACH_SYSTEM, FOOD_SCHEMA,
};
