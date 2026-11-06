"""Builds assets/exercises/catalog.json from the per-muscle data files.

Each exercise: X(id, en, ur, primary, secondary, equipment, difficulty, kind,
                steps_en, steps_ur, tips_en, tips_ur, mistakes_en, mistakes_ur,
                high_impact=False, sets=None, reps=None, rest=None)

kind: 'heavy' (barbell compound), 'compound', 'isolation', 'bodyweight', 'hold'
reps: (min, max) — seconds for 'hold'.
Existing English steps for the original 30 exercises are kept verbatim when
steps_en is None.

Run:  python3 tool/exercises/build_catalog.py
"""
import importlib, json, os, sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
OUT = os.path.join(ROOT, 'assets', 'exercises', 'catalog.json')
sys.path.insert(0, HERE)

MUSCLES = {'chest', 'back', 'shoulders', 'biceps', 'triceps', 'quads',
           'hamstrings', 'glutes', 'calves', 'core'}
EQUIP = {'barbell', 'dumbbell', 'machine', 'cable', 'bodyweight', 'band', 'kettlebell'}
DIFF = {'beginner', 'intermediate', 'advanced'}

# Default prescription by kind: (sets, (repMin, repMax), rest seconds)
DEFAULTS = {
    'heavy': (4, (6, 8), 150),
    'compound': (3, (8, 12), 90),
    'isolation': (3, (10, 15), 60),
    'bodyweight': (3, (8, 15), 60),
    'hold': (3, (20, 45), 45),
}

def X(id, en, ur, primary, secondary, equipment, difficulty, kind,
      steps_en, steps_ur, tips_en, tips_ur, mistakes_en, mistakes_ur,
      high_impact=False, sets=None, reps=None, rest=None):
    return dict(id=id, en=en, ur=ur, primary=primary, secondary=secondary,
                equipment=equipment, difficulty=difficulty, kind=kind,
                steps_en=steps_en, steps_ur=steps_ur, tips_en=tips_en,
                tips_ur=tips_ur, mistakes_en=mistakes_en, mistakes_ur=mistakes_ur,
                high_impact=high_impact, sets=sets, reps=reps, rest=rest)

GROUPS = ['chest', 'back', 'shoulders', 'arms', 'legs', 'core']

def main():
    old = {}
    if os.path.exists(OUT):
        for e in json.load(open(OUT))['exercises']:
            old[e['id']] = e
    out, seen = [], set()
    for g in GROUPS:
        for x in importlib.import_module(f'data_{g}').EXERCISES:
            i = x['id']
            assert i not in seen, f'duplicate {i}'
            seen.add(i)
            assert x['primary'] in MUSCLES and set(x['secondary']) <= MUSCLES, i
            assert x['equipment'] in EQUIP and x['difficulty'] in DIFF, i
            assert x['kind'] in DEFAULTS, i
            steps_en = x['steps_en'] or old[i]['steps']['en']
            assert len(steps_en) == len(x['steps_ur']), f'{i}: steps en/ur differ'
            assert len(x['tips_en']) == len(x['tips_ur']) >= 1, i
            assert len(x['mistakes_en']) == len(x['mistakes_ur']) >= 1, i
            sets, reps, rest = DEFAULTS[x['kind']]
            sets = x['sets'] or sets
            reps = x['reps'] or reps
            rest = x['rest'] or rest
            out.append({
                'id': i,
                'name': {'en': x['en'], 'ur': x['ur']},
                'primary': x['primary'],
                'secondary': x['secondary'],
                'equipment': x['equipment'],
                'difficulty': x['difficulty'],
                'steps': {'en': steps_en, 'ur': x['steps_ur']},
                'tips': {'en': x['tips_en'], 'ur': x['tips_ur']},
                'mistakes': {'en': x['mistakes_en'], 'ur': x['mistakes_ur']},
                'prescription': {
                    'sets': sets, 'repMin': reps[0], 'repMax': reps[1],
                    'timed': x['kind'] == 'hold', 'restSec': rest,
                },
                'highImpact': x['high_impact'],
                'videos': old.get(i, {}).get('videos', {'male': None, 'female': None}),
            })
    missing = set(old) - seen
    assert not missing, f'original exercises missing: {missing}'
    json.dump({'version': 2, 'exercises': out}, open(OUT, 'w'), ensure_ascii=False, indent=1)
    print(f'{len(out)} exercises written')

if __name__ == '__main__':
    main()
