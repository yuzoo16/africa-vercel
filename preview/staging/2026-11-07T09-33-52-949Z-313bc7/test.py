import json
d = json.load(open('data/i18n/de-hubs.json'))
if 'southern-africa-safari' in d:
    print('yes')
    print(d['southern-africa-safari'].get('lead','')[:80])
else:
    print('no')
    print(list(d.keys())[-5:])
