"""Writes lib/l10n/app_en.arb and app_ur.arb from a strings table.

Usage: python3 tool/gen_arb.py <strings_module.py>
The table is a list S of (key, en, ur, description, placeholders|None).
Existing keys in the .arb files are kept; keys in the table are added or updated.
"""
import json, runpy, sys, os
S = runpy.run_path(sys.argv[1])['S']
root = os.path.join(os.path.dirname(__file__), '..', 'lib', 'l10n')
def load(name, locale):
    path = os.path.join(root, name)
    return json.load(open(path, encoding='utf-8')) if os.path.exists(path) else {'@@locale': locale}
en, ur = load('app_en.arb', 'en'), load('app_ur.arb', 'ur')
for key, e, u, desc, ph in S:
    en[key] = e
    meta = {'description': desc}
    if ph: meta['placeholders'] = ph
    en['@' + key] = meta
    ur[key] = u
for name, data in (('app_en.arb', en), ('app_ur.arb', ur)):
    with open(os.path.join(root, name), 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write('\n')
print(len(S), 'strings written')
