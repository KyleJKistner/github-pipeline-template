from sage.all import *
from collections import Counter, deque
import json
import time

# Certified complex-ball monodromy certificate for the exact degree-110
# quotient Belyi map attached to the distinguished Sz(8) Hurwitz component.
#
# The exact polynomial data are staged at /tmp/sz8_surface_data.sage from the
# pinned commit 23fdb7c95103a595e6a440595754a15ca1c98104.

load('/tmp/sz8_surface_data.sage')

PREC = 512
INITIAL_SUBDIVISIONS = 32
MAX_DEPTH = 10
NEWTON_STEPS = 24

CBF = ComplexBallField(PREC)
RBF = RealBallField(PREC)
CF = ComplexField(PREC)
RF = RealField(PREC)

load('research/sz8_certified_dessin_targets.sage')

P_BLACK = Q2*A**3
P_WHITE = B**2
assert P_BLACK.degree() == 110 and P_WHITE.degree() == 110

print('[1/7] isolating the exact linear factors of A, B, and Q2', flush=True)
AR = A.roots(ring=CBF, multiplicities=False)
BR = B.roots(ring=CBF, multiplicities=False)
QR = Q2.roots(ring=CBF, multiplicities=False)
assert (len(AR), len(BR), len(QR)) == (36, 55, 2)
assert all(not AR[i].overlaps(AR[j]) for i in range(36) for j in range(i+1,36))
assert all(not BR[i].overlaps(BR[j]) for i in range(55) for j in range(i+1,55))
assert not QR[0].overlaps(QR[1])

ARC = [CF(r.real().center(), r.imag().center()) for r in AR]
BRC = [CF(r.real().center(), r.imag().center()) for r in BR]
QRC = [CF(r.real().center(), r.imag().center()) for r in QR]

# The parameter derivative factors exactly as
# P_WHITE-P_BLACK = -C^(-1) u D4^4 D5^5 D7^7.
D4R = D4.roots(ring=CBF, multiplicities=False)
D5R = D5.roots(ring=CBF, multiplicities=False)
D7R = D7.roots(ring=CBF, multiplicities=False)
assert (len(D4R),len(D5R),len(D7R)) == (3,7,7)
VARIATION_FACTORS = ([(CBF(0),1)] + [(r,4) for r in D4R]
                     + [(r,5) for r in D5R] + [(r,7) for r in D7R])
VARIATION_LEAD = RBF(abs(1/C))


def product_and_derivative_ball(z, roots):
    diffs = [z-r for r in roots]
    if any(d.contains_zero() for d in diffs):
        raise ZeroDivisionError('root tube intersects a certified A/B/Q2 root')
    p = prod(diffs, CBF(1))
    return p, p*sum((1/d for d in diffs), CBF(0))


def product_and_derivative_num(z, roots):
    diffs = [z-r for r in roots]
    p = prod(diffs, CF(1))
    return p, p*sum((1/d for d in diffs), CF(0))


def F_ball(z, x):
    a, ap = product_and_derivative_ball(z, AR)
    b, bp = product_and_derivative_ball(z, BR)
    q, qp = product_and_derivative_ball(z, QR)
    return (1-x)*q*a**3 + x*b**2


def dF_ball(z, x):
    a, ap = product_and_derivative_ball(z, AR)
    b, bp = product_and_derivative_ball(z, BR)
    q, qp = product_and_derivative_ball(z, QR)
    return (1-x)*(qp*a**3 + 3*q*a**2*ap) + x*(2*b*bp)


def F_num(z, x):
    a, ap = product_and_derivative_num(z, ARC)
    b, bp = product_and_derivative_num(z, BRC)
    q, qp = product_and_derivative_num(z, QRC)
    return (1-x)*q*a**3 + x*b**2


def dF_num(z, x):
    a, ap = product_and_derivative_num(z, ARC)
    b, bp = product_and_derivative_num(z, BRC)
    q, qp = product_and_derivative_num(z, QRC)
    return (1-x)*(qp*a**3 + 3*q*a**2*ap) + x*(2*b*bp)


def strict_box_contains(outer, inner):
    orl, oru = outer.real().endpoints()
    oil, oiu = outer.imag().endpoints()
    irl, iru = inner.real().endpoints()
    iil, iiu = inner.imag().endpoints()
    return orl < irl and iru < oru and oil < iil and iiu < oiu


def containment_margin(outer, inner):
    orl, oru = outer.real().endpoints()
    oil, oiu = outer.imag().endpoints()
    irl, iru = inner.real().endpoints()
    iil, iiu = inner.imag().endpoints()
    return min(irl-orl, oru-iru, iil-oil, oiu-iiu)


def pairwise_disjoint(boxes):
    return all(not boxes[i].overlaps(boxes[j])
               for i in range(len(boxes)) for j in range(i+1,len(boxes)))


def cycle_type(p):
    seen = [False]*len(p)
    ans = Counter()
    for i in range(len(p)):
        if not seen[i]:
            j=i; n=0
            while not seen[j]:
                seen[j]=True; j=p[j]; n+=1
            ans[n]+=1
    return dict(sorted(ans.items()))


def compose(p,q):
    return tuple(p[q[i]] for i in range(len(q)))


def inverse(p):
    r=[0]*len(p)
    for i,j in enumerate(p):
        r[j]=i
    return tuple(r)


def xcf(x):
    return CF(x[0],x[1])


def xcbf(x):
    return CBF(x[0],x[1])


def midpoint(x0,x1):
    return ((x0[0]+x1[0])/2, (x0[1]+x1[1])/2)


def parameter_box(x0,x1):
    mr=(x0[0]+x1[0])/2
    mi=(x0[1]+x1[1])/2
    rr=abs(x1[0]-x0[0])/2
    ri=abs(x1[1]-x0[1])/2
    # add_error is outward-rounded; exact rational midpoints/radii are used.
    re=RBF(mr).add_error(RBF(rr))
    im=RBF(mi).add_error(RBF(ri))
    X=CBF(re,im)
    assert xcbf(x0) in X and xcbf(x1) in X
    assert not X.contains_zero()
    assert not (X-CBF(1)).contains_zero()
    return X


class CertificationFailure(RuntimeError):
    pass

