#!/usr/bin/env python3
from collections import Counter, deque
from pathlib import Path
import glob, json


def compose(p,q):
    return tuple(p[q[i]] for i in range(len(q)))


def inverse(p):
    r=[0]*len(p)
    for i,j in enumerate(p): r[j]=i
    return tuple(r)


def cycle_type(p):
    seen=[False]*len(p); ans=Counter()
    for i in range(len(p)):
        if not seen[i]:
            j=i; n=0
            while not seen[j]:
                seen[j]=True; j=p[j]; n+=1
            ans[n]+=1
    return dict(sorted(ans.items()))


def intertwiner(source,target,image0):
    n=len(source[0]); qmap=[None]*n; qmap[0]=image0; queue=deque([0])
    pairs=[]
    for s,t in zip(source,target):
        pairs.extend(((s,t),(inverse(s),inverse(t))))
    while queue:
        i=queue.popleft(); qi=qmap[i]
        for s,t in pairs:
            ni=s[i]; nq=t[qi]
            if qmap[ni] is None:
                qmap[ni]=nq; queue.append(ni)
            elif qmap[ni]!=nq:
                return None
    if any(x is None for x in qmap) or len(set(qmap))!=n:
        return None
    return tuple(qmap)


def load_single(pattern):
    files=glob.glob(pattern,recursive=True)
    if len(files)!=1:
        raise RuntimeError('expected one file for %r, found %r' % (pattern,files))
    return json.loads(Path(files[0]).read_text())

zero=load_single('loops/**/sz8_certified_loop_zero.json')
one=load_single('loops/**/sz8_certified_loop_one.json')
assert zero['loop']=='zero' and one['loop']=='one'
sigma0=tuple(zero['permutation']); sigma1=tuple(one['permutation'])
assert len(sigma0)==len(sigma1)==110
sigma_inf=inverse(compose(sigma0,sigma1))
assert cycle_type(sigma0)=={1:2,3:36}
assert cycle_type(sigma1)=={2:55}
assert cycle_type(sigma_inf)=={1:1,4:3,5:7,7:7,13:1}

ns={}
exec(Path('research/sz8_certified_dessin_targets.sage').read_text(),ns)
TARGET_R=tuple(ns['TARGET_R']); TARGET_S=tuple(ns['TARGET_S'])
conjugator=None; variant=None
for s0name,s0 in (('sigma0',sigma0),('sigma0^-1',inverse(sigma0))):
    for trname,tr in (('R',TARGET_R),('R^-1',inverse(TARGET_R))):
        for tsname,ts in (('S',TARGET_S),('S^-1',inverse(TARGET_S))):
            for image0 in range(110):
                qmap=intertwiner((s0,sigma1),(tr,ts),image0)
                if qmap is not None:
                    conjugator=qmap; variant=(s0name,trname,tsname,image0); break
            if conjugator is not None: break
        if conjugator is not None: break
    if conjugator is not None: break
assert conjugator is not None

result={
    'method':'two independent Sage ComplexBallField/interval-Newton/Rouche loop certificates, exact Python permutation combination',
    'zero_loop':zero,
    'one_loop':one,
    'cycle_types':{
        'zero':cycle_type(sigma0),
        'one':cycle_type(sigma1),
        'infinity':cycle_type(sigma_inf),
    },
    'simultaneous_conjugacy_variant':variant,
    'conjugator':list(conjugator),
    'sigma0':list(sigma0),
    'sigma1':list(sigma1),
    'sigma_infinity':list(sigma_inf),
}
Path('sz8_certified_dessin_parallel_result.json').write_text(
    json.dumps(result,indent=2,sort_keys=True))
print('[PASS] certified loop permutations have the required passport')
print('[PASS] simultaneous conjugacy variant',variant)
print('[PASS] wrote sz8_certified_dessin_parallel_result.json')
