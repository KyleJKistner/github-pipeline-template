from sage.all import *

# Reuse the already-passing factor-root and base-root certifications.
load('research/sz8_interval_newton_probe.sage')

Pblack = Q2*A^3
Pwhite = B^2
Pdelta = Pwhite-Pblack


def shifted_coefficients(P, center):
    """Certified coefficients of P(center+w), using exact P and a point ball."""
    n = P.degree()
    c = CBF(center)
    powers = [CBF(1)]
    for _ in range(n):
        powers.append(powers[-1]*c)
    out = []
    for k in range(n+1):
        s = CBF(0)
        for i in range(k,n+1):
            s += CBF(P[i])*binomial(i,k)*powers[i-k]
        out.append(s)
    return out


def rouche_data(index, x, centers, boxes):
    z = centers[index]
    Fx = (1-x)*Pblack+x*Pwhite
    ac = shifted_coefficients(Fx,z)
    bc = shifted_coefficients(Pdelta,z)
    clearance = min((CBF(z)-boxes[j]).abs().lower()
                    for j in range(len(boxes)) if j != index)
    box_radius = (boxes[index]-CBF(z)).abs().upper()
    best = None
    # Search from a large disk downward.  Every disk stays disjoint from all
    # other certified root boxes by construction.
    for k in range(2,31):
        r = RBF(clearance/(2^k))
        if not box_radius < r:
            continue
        main = ac[1].abs().lower()*r
        tail = ac[0].abs().upper()
        rp = RBF(1)
        for j in range(2,len(ac)):
            rp *= r if j > 2 else r^2
            if j == 2:
                term_power = r^2
            else:
                term_power *= r
            tail += ac[j].abs().upper()*term_power
        lower = main-tail
        if not lower > 0:
            continue
        variation = RBF(0)
        term_power = RBF(1)
        for j in range(len(bc)):
            if j > 0:
                term_power *= r
            variation += bc[j].abs().upper()*term_power
        if variation == 0:
            allowed = RBF('+inf')
        else:
            allowed = lower/variation
        best = {
            'radius_exponent': k,
            'radius': r,
            'boundary_lower': lower,
            'variation_norm': variation,
            'allowed_parameter_step': allowed,
        }
        break
    if best is None:
        raise RuntimeError('no Rouche disk for root %s' % index)
    return best

print('ROUCHE_BASE_SCAN_START',flush=True)
all_data=[]
for i in range(110):
    d=rouche_data(i,x0,centers,base_balls)
    all_data.append(d)
    if i % 20 == 0:
        print('ROUCHE_PROGRESS',i,'ALLOWED',d['allowed_parameter_step'],flush=True)
minimum=min(d['allowed_parameter_step'] for d in all_data)
worst=[i for i,d in enumerate(all_data) if d['allowed_parameter_step']==minimum][0]
print('ROUCHE_MIN_ALLOWED_STEP',minimum,flush=True)
print('ROUCHE_WORST_ROOT',worst,flush=True)
print('ROUCHE_WORST_DATA',all_data[worst],flush=True)
for p in range(4,25):
    if RBF(QQ(1)/(2^p)) < minimum:
        print('ROUCHE_UNIFORM_DYADIC_POWER',p,flush=True)
        break
assert minimum > 0
print('[PASS] certified Rouché step bound at all 110 base roots',flush=True)
