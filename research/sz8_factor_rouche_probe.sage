from sage.all import *

# Reuse exact factor-root isolation and certified base roots.
load('research/sz8_interval_newton_probe.sage')

print('ISOLATING_VARIATION_FACTOR_ROOTS',flush=True)
D4R=D4.roots(ring=CBF,multiplicities=False)
D5R=D5.roots(ring=CBF,multiplicities=False)
D7R=D7.roots(ring=CBF,multiplicities=False)
assert (len(D4R),len(D5R),len(D7R))==(3,7,7)
variation_factors=[(CBF(0),1)]+[(r,4) for r in D4R]+[(r,5) for r in D5R]+[(r,7) for r in D7R]
variation_lead=RBF(abs(1/C))


def factor_rouche_data(i,centers,boxes):
    zi=centers[i]
    self_error=RBF((boxes[i]-CBF(zi)).abs().upper())
    distances=[None]*len(boxes)
    clearance=None
    for j,Vj in enumerate(boxes):
        if i==j:
            continue
        dij=RBF((CBF(zi)-Vj).abs().lower())
        distances[j]=dij
        clearance=dij if clearance is None or dij.lower()<clearance.lower() else clearance
    best=None
    # r <= clearance/3 makes all chosen disks pairwise disjoint.
    for denom in range(3,33):
        r=clearance/denom
        own=r-self_error
        if not own>0:
            continue
        lower=own
        valid=True
        for j,dij in enumerate(distances):
            if i==j:
                continue
            f=dij-r
            if not f>0:
                valid=False; break
            lower*=f
        if not valid or not lower>0:
            continue
        upper=variation_lead
        for root,mult in variation_factors:
            d=RBF((CBF(zi)-root).abs().upper())+r
            upper*=d^mult
        allowed=lower/upper
        if best is None or allowed.lower()>best['allowed'].lower():
            best={'radius':r,'denominator':denom,'lower':lower,'variation_upper':upper,'allowed':allowed}
    if best is None:
        raise RuntimeError('no factor Rouche disk for root %s' % i)
    return best

print('FACTOR_ROUCHE_SCAN_START',flush=True)
data=[]
for i in range(110):
    d=factor_rouche_data(i,centers,base_balls)
    data.append(d)
    if i%20==0:
        print('FACTOR_ROUCHE_PROGRESS',i,'ALLOWED',d['allowed'],'DENOM',d['denominator'],flush=True)

# Verify pairwise disjoint selected disks rigorously.
for i in range(110):
    for j in range(i+1,110):
        center_distance=RBF(abs(centers[i]-centers[j]))
        assert data[i]['radius']+data[j]['radius'] < center_distance

worst=min(range(110),key=lambda i:data[i]['allowed'].lower())
minimum=data[worst]['allowed']
minimum_lower=RBF(minimum.lower())
print('FACTOR_ROUCHE_MIN_ALLOWED',minimum,flush=True)
print('FACTOR_ROUCHE_MIN_ALLOWED_LOWER',minimum_lower,flush=True)
print('FACTOR_ROUCHE_WORST_ROOT',worst,flush=True)
print('FACTOR_ROUCHE_WORST_DATA',data[worst],flush=True)
for p in range(1,31):
    if RBF(QQ(1)/(2^p))<minimum_lower:
        print('FACTOR_ROUCHE_UNIFORM_DYADIC_POWER',p,flush=True)
        break
assert minimum_lower>0
print('[PASS] factorized certified Rouche bounds for all 110 sheets',flush=True)
