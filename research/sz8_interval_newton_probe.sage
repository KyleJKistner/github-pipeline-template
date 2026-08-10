from sage.all import *

load('/tmp/sz8_surface_data.sage')

PREC = 512
CBF = ComplexBallField(PREC)
RBF = RealBallField(PREC)
CF = ComplexField(PREC)
RF = RealField(PREC)

print('ISOLATING_FACTOR_ROOTS', flush=True)
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

def product_and_derivative_ball(z, roots):
    dif = [z-r for r in roots]
    if any(d.contains_zero() for d in dif):
        raise ZeroDivisionError('factor box meets a certified root')
    p = prod(dif, CBF(1))
    return p, p*sum((1/d for d in dif), CBF(0))

def product_and_derivative_num(z, roots):
    dif = [z-r for r in roots]
    p = prod(dif, CF(1))
    return p, p*sum((1/d for d in dif), CF(0))

def F_ball(z, x):
    a, ap = product_and_derivative_ball(z, AR)
    b, bp = product_and_derivative_ball(z, BR)
    q, qp = product_and_derivative_ball(z, QR)
    return (1-x)*q*a^3 + x*b^2

def dF_ball(z, x):
    a, ap = product_and_derivative_ball(z, AR)
    b, bp = product_and_derivative_ball(z, BR)
    q, qp = product_and_derivative_ball(z, QR)
    return (1-x)*(qp*a^3 + 3*q*a^2*ap) + x*(2*b*bp)

def F_num(z, x):
    a, ap = product_and_derivative_num(z, ARC)
    b, bp = product_and_derivative_num(z, BRC)
    q, qp = product_and_derivative_num(z, QRC)
    return (1-x)*q*a^3 + x*b^2

def dF_num(z, x):
    a, ap = product_and_derivative_num(z, ARC)
    b, bp = product_and_derivative_num(z, BRC)
    q, qp = product_and_derivative_num(z, QRC)
    return (1-x)*(qp*a^3 + 3*q*a^2*ap) + x*(2*b*bp)

def strict_box_contains(outer, inner):
    orl, oru = outer.real().endpoints(); oil, oiu = outer.imag().endpoints()
    irl, iru = inner.real().endpoints(); iil, iiu = inner.imag().endpoints()
    return orl < irl and iru < oru and oil < iil and iiu < oiu

def certify(z, x, sep):
    last = None
    for k in range(30, 2, -1):
        r = RBF(sep/(2^k))
        V = CBF(z).add_error(r)
        try:
            der = dF_ball(V, CBF(x))
        except ZeroDivisionError:
            last = ('factor', k, r)
            continue
        if der.contains_zero():
            last = ('derivative', k, r, der)
            continue
        image = CBF(z) - F_ball(CBF(z), CBF(x))/der
        if strict_box_contains(V, image):
            return V, k, image
        last = ('inclusion', k, r, image)
    raise RuntimeError('no certified radius: %r' % (last,))

x0 = QQ(1)/2
F0 = Q2*A^3 + x0*(B^2-Q2*A^3)
centers = F0.roots(ring=CF, multiplicities=False)
assert len(centers) == 110
centers = sorted(centers, key=lambda z:(z.real(),z.imag()))
for i,z in enumerate(centers):
    for _ in range(24):
        z -= F_num(z,CF(x0))/dF_num(z,CF(x0))
    centers[i] = z
seps = [min(abs(z-w) for j,w in enumerate(centers) if i != j)
        for i,z in enumerate(centers)]
base_balls = []; ks = []
for i,(z,sep) in enumerate(zip(centers,seps)):
    V,k,image = certify(z,x0,sep)
    base_balls.append(V); ks.append(k)
assert all(not base_balls[i].overlaps(base_balls[j])
           for i in range(110) for j in range(i+1,110))
print('BASE_ROOTS_CERTIFIED',len(base_balls),flush=True)
print('MIN_BASE_SEPARATION',min(seps),flush=True)
print('BASE_RADIUS_EXPONENT_RANGE',min(ks),max(ks),flush=True)

def try_krawczyk_segment(power):
    dx = QQ(1)/(2^power)
    x1 = x0-dx
    z0 = centers[0]
    z1 = z0
    for _ in range(24):
        z1 -= F_num(z1,CF(x1))/dF_num(z1,CF(x1))
    V1,k1,_ = certify(z1,x1,seps[0]/2)

    xr = RBF((x0+x1)/2).add_error(RBF(dx/2))
    X = CBF(xr,RBF(0))
    slope_num = (z1-z0)/CF(x1-x0)
    slope = CBF(slope_num)
    L = CBF(z0)+slope*(X-CBF(x0))
    xmid = CF((x0+x1)/2)
    cmid = (z0+z1)/2
    for _ in range(24):
        cmid -= F_num(cmid,xmid)/dF_num(cmid,xmid)
    Lmid = CBF(z0)+slope*(CBF(xmid)-CBF(x0))
    y0 = CBF(cmid)-Lmid
    preconditioner = CBF(1/dF_num(cmid,xmid))
    endpoint_rad = max(RBF(base_balls[0].rad()),RBF(V1.rad()))
    base_radius = max(endpoint_rad, RBF(y0.abs().upper()))
    if base_radius == 0:
        base_radius = RBF(2)^(-PREC//2)

    predicted1 = CBF(z0)+slope*(CBF(x1)-CBF(x0))
    for j in range(0,30):
        factor = 2^j
        Y = CBF(y0).add_error(base_radius*factor)
        if not ((base_balls[0]-CBF(z0)) in Y):
            continue
        if not ((V1-predicted1) in Y):
            continue
        try:
            J = dF_ball(L+Y,X)
        except ZeroDivisionError:
            continue
        K = y0-preconditioner*F_ball(L+y0,X)+(1-preconditioner*J)*(Y-y0)
        if strict_box_contains(Y,K):
            return True, {
                'power': power,
                'dx': dx,
                'vertex_k': k1,
                'factor': factor,
                'base_radius': base_radius,
                'Y': Y,
                'K': K,
            }
    return False, {'power':power,'dx':dx,'vertex_k':k1,'base_radius':base_radius}

for power in range(10,31):
    ok, data = try_krawczyk_segment(power)
    print('STEP_TEST',power,'DX',data['dx'],'PASS',ok,'BASE_RADIUS',data['base_radius'],flush=True)
    if ok:
        print('KRAWCZYK_FACTOR',data['factor'],flush=True)
        print('KRAWCZYK_Y',data['Y'],flush=True)
        print('KRAWCZYK_IMAGE',data['K'],flush=True)
        print('[PASS] certified Krawczyk continuation probe',flush=True)
        break
else:
    raise RuntimeError('no certified dyadic Krawczyk step through 2^-30')
