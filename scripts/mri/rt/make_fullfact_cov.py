"""
Generate covariate files for Full Factorial + RT model.
SPM scan order: HC_HH, HC_HS, HC_SS, HC_SH, MDD_HH, MDD_HS, MDD_SS, MDD_SH
Output: rt_fullfact_cov.txt  (columns: RT_centered  age_centered  gender)
"""
import csv, os

base   = os.path.dirname(os.path.abspath(__file__))
csv_fp = os.path.join(base, 'regressors.csv')
reg_fp = os.path.join(base, '..', 'original', 'regressor_video_age_gender.txt')

# ── Original subject lists (same order as Fullfact_VideoMask.m) ─────────────
HC_orig = [
    'sub-004','sub-006','sub-010','sub-011','sub-014','sub-015','sub-016','sub-017','sub-018','sub-019',
    'sub-022','sub-024','sub-025','sub-027','sub-028','sub-029','sub-030','sub-031','sub-032','sub-033','sub-034','sub-041',
    'sub-043','sub-045','sub-046','sub-047','sub-050','sub-051','sub-052','sub-053','sub-054','sub-056','sub-057','sub-059',
    'sub-062','sub-068','sub-069','sub-070','sub-071','sub-073','sub-074','sub-079','sub-080','sub-083','sub-085','sub-086',
    'sub-089','sub-090','sub-091','sub-093','sub-096','sub-101','sub-103','sub-105','sub-119','sub-123','sub-125','sub-126','sub-127'
]
MDD_orig = [
    'sub-007','sub-008','sub-009','sub-012','sub-020','sub-035','sub-036','sub-037','sub-038','sub-039',
    'sub-042','sub-044','sub-048','sub-049','sub-061','sub-064','sub-065','sub-066','sub-072','sub-075','sub-076','sub-077',
    'sub-081','sub-082','sub-084','sub-087','sub-092','sub-094','sub-095','sub-097','sub-098','sub-100','sub-102','sub-104',
    'sub-106','sub-107','sub-108','sub-109','sub-110','sub-111','sub-113','sub-114','sub-115','sub-116','sub-117','sub-118',
    'sub-121','sub-122','sub-124','sub-128','sub-129','sub-130','sub-131'
]
HC_set  = set(HC_orig)
MDD_set = set(MDD_orig)

# ── Gender lookup from regressor_video_age_gender.txt ───────────────────────
with open(reg_fp) as f:
    reg_rows = [line.strip().split(',') for line in f if line.strip()]
gender = {}
for i, sub in enumerate(HC_orig):
    gender[sub] = int(float(reg_rows[i][1]))
mdd_start = len(HC_orig) * 4
for i, sub in enumerate(MDD_orig):
    gender[sub] = int(float(reg_rows[mdd_start + i][1]))

# ── Read regressors.csv into lookup: {(sub, condition): row} ────────────────
rows = list(csv.DictReader(open(csv_fp)))
lookup = {}
for r in rows:
    lookup[(r['ID'], r['Condition'])] = r

# Subjects with RT data present in the CSV
rt_subs = set(r['ID'] for r in rows)

# ── Build subject lists for this model (original order, minus missing RT) ───
HC_subs  = [s for s in HC_orig  if s in rt_subs]
MDD_subs = [s for s in MDD_orig if s in rt_subs]
print("HC with RT:  %d  (excluded: %d)" % (len(HC_subs),  len(HC_orig)  - len(HC_subs)))
print("MDD with RT: %d  (excluded: %d)" % (len(MDD_subs), len(MDD_orig) - len(MDD_subs)))
print("Total scans: %d  (= %d subjects x 4 conditions)" % (
    (len(HC_subs)+len(MDD_subs))*4, len(HC_subs)+len(MDD_subs)))

conditions = ['happy_happy', 'happy_sad', 'sad_sad', 'sad_happy']

# ── Build RT vector in SPM scan order ───────────────────────────────────────
# Order: HC_HH, HC_HS, HC_SS, HC_SH, MDD_HH, MDD_HS, MDD_SS, MDD_SH
# Each condition block is sorted by original subject list order

all_rt  = []
all_age = []
all_gen = []
for group_subs in [HC_subs, MDD_subs]:
    for cond in conditions:
        for sub in group_subs:
            key = (sub, cond)
            if key not in lookup:
                raise ValueError("Missing entry in CSV: %s / %s" % (sub, cond))
            r = lookup[key]
            all_rt.append(float(r['rt']))
            all_age.append(float(r['Age']))
            all_gen.append(gender.get(sub, -1))

# Mean-center RT and age
n = len(all_rt)
rt_mean  = sum(all_rt)  / n
age_mean = sum(all_age) / n
print("Total rows written: %d" % n)
print("RT mean: %.4f s" % rt_mean)

# ── Write covariate file ─────────────────────────────────────────────────────
out_path = os.path.join(base, 'rt_fullfact_cov.txt')
with open(out_path, 'w') as f:
    for rt, age, gen in zip(all_rt, all_age, all_gen):
        f.write("%.6f\t%.6f\t%d\n" % (rt - rt_mean, age - age_mean, gen))
print("Written: rt_fullfact_cov.txt")

# ── Write subject ID lists for MATLAB ────────────────────────────────────────
out_hc = os.path.join(base, 'HC_subs_rt.txt')
out_mdd = os.path.join(base, 'MDD_subs_rt.txt')
with open(out_hc, 'w')  as f: f.write('\n'.join(HC_subs)  + '\n')
with open(out_mdd, 'w') as f: f.write('\n'.join(MDD_subs) + '\n')
print("Written: HC_subs_rt.txt (%d subjects)" % len(HC_subs))
print("Written: MDD_subs_rt.txt (%d subjects)" % len(MDD_subs))
