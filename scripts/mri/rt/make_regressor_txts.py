"""
Generate per-condition SPM regressor txt files from regressors.csv + regressor_video_age_gender.txt.
Columns output: rt_centered  group  age_centered  gender
Tab-separated, no header (SPM multi_cov format).
"""
import csv, os

base    = os.path.dirname(os.path.abspath(__file__))
csv_fp  = os.path.join(base, 'regressors.csv')
reg_fp  = os.path.join(base, '..', 'original', 'regressor_video_age_gender.txt')

# Subject lists (same order as Fullfact_VideoMask.m)
HC = [
    'sub-004','sub-006','sub-010','sub-011','sub-014','sub-015','sub-016','sub-017','sub-018','sub-019',
    'sub-022','sub-024','sub-025','sub-027','sub-028','sub-029','sub-030','sub-031','sub-032','sub-033','sub-034','sub-041',
    'sub-043','sub-045','sub-046','sub-047','sub-050','sub-051','sub-052','sub-053','sub-054','sub-056','sub-057','sub-059',
    'sub-062','sub-068','sub-069','sub-070','sub-071','sub-073','sub-074','sub-079','sub-080','sub-083','sub-085','sub-086',
    'sub-089','sub-090','sub-091','sub-093','sub-096','sub-101','sub-103','sub-105','sub-119','sub-123','sub-125','sub-126','sub-127'
]
MDD = [
    'sub-007','sub-008','sub-009','sub-012','sub-020','sub-035','sub-036','sub-037','sub-038','sub-039',
    'sub-042','sub-044','sub-048','sub-049','sub-061','sub-064','sub-065','sub-066','sub-072','sub-075','sub-076','sub-077',
    'sub-081','sub-082','sub-084','sub-087','sub-092','sub-094','sub-095','sub-097','sub-098','sub-100','sub-102','sub-104',
    'sub-106','sub-107','sub-108','sub-109','sub-110','sub-111','sub-113','sub-114','sub-115','sub-116','sub-117','sub-118',
    'sub-121','sub-122','sub-124','sub-128','sub-129','sub-130','sub-131'
]
HC_set  = set(HC)
MDD_set = set(MDD)

# ── Build gender lookup from regressor_video_age_gender.txt ─────────────────
# File has no header; columns: age, gender
# Ordering (same as Fullfact scans):
#   rows 0..(nHC-1)          → HC subjects (cell 1: HC happy_happy)
#   rows nHC*4..(nHC*4+nMDD-1) → MDD subjects (cell 5: MDD happy_happy)
with open(reg_fp) as f:
    reg_rows = [line.strip().split(',') for line in f if line.strip()]

nHC  = len(HC)    # 59
nMDD = len(MDD)   # 53

gender = {}
for i, sub in enumerate(HC):
    gender[sub] = int(float(reg_rows[i][1]))
mdd_start = nHC * 4          # 236
for i, sub in enumerate(MDD):
    gender[sub] = int(float(reg_rows[mdd_start + i][1]))

print("Gender lookup (first 3 HC, first 3 MDD):")
for s in HC[:3] + MDD[:3]:
    print("  %s: %d" % (s, gender[s]))

# ── Read regressors.csv ──────────────────────────────────────────────────────
rows = list(csv.DictReader(open(csv_fp)))

from collections import defaultdict
by_cond = defaultdict(list)
for r in rows:
    by_cond[r['Condition']].append(r)

conditions = ['happy_happy', 'happy_sad', 'sad_sad', 'sad_happy']

for cond in conditions:
    cond_rows = by_cond[cond]
    rts  = [float(r['rt'])  for r in cond_rows]
    ages = [float(r['Age']) for r in cond_rows]
    rt_mean  = sum(rts)  / len(rts)
    age_mean = sum(ages) / len(ages)

    out_path = os.path.join(base, 'regressors_' + cond + '.txt')
    missing_gender = []
    with open(out_path, 'w') as f:
        for r in cond_rows:
            sub   = r['ID']
            rt_c  = float(r['rt'])  - rt_mean
            age_c = float(r['Age']) - age_mean
            grp   = 0 if sub in HC_set else 1
            gen   = gender.get(sub, -1)
            if gen == -1:
                missing_gender.append(sub)
            f.write("%.6f\t%d\t%.6f\t%d\n" % (rt_c, grp, age_c, gen))

    print("Written: regressors_%s.txt  (%d rows)" % (cond, len(cond_rows)))
    if missing_gender:
        print("  WARNING: gender missing for: %s" % missing_gender)

print("Done.")
