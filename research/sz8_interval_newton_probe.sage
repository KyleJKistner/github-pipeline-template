from sage.all import *

load('/tmp/sz8_surface_data.sage')

PREC = 512
CBF = ComplexBallField(PREC)
RBF = RealBallField(PREC)
CF = ComplexField(PREC)

Ab=A.change_ring(CBF); Bb=B.change_ring(CBF); Qb=Q2.change_ring(CBF)
dAb=A.derivative().change_ring(CBF)
dBb=B.derivative().change_ring(CBF)
dQb=Q2.derivative().change_ring(CBF)
Ac=A.change_ring(CF); Bc=B.change_ring(CF); Qc=Q2.change_ring(CF)
dAc=A.derivative().change_ring(CF)
dBc=B.derivative().change_ring(CF)
dQc=Q2.derivative().change_ring(CF)

def F_ball(z,x):
    a=Ab(z); b=Bb(z); q=Qb(z)
    return (1-x)*q*a^3+x*b^2

def dF_ball(z,x):
    a=Ab(z); ap=dAb(z); b=Bb(z); bp=dBb(z); q=Qb(z); qp=dQb(z)
    return (1-x)*(qp*a^3+3*q*a^2*ap)+x*(2*b*bp)

def F_num(z,x):
    a=Ac(z); b=Bc(z); q=Qc(z)
    return (1-x)*q*a^3+x*b^2

def dF_num(z,x):
    a=Ac(z); ap=dAc(z); b=Bc(z); bp=dBc(z); q=Qc(z); qp=dQc(z)
    return (1-x)*(qp*a^3+3*q*a^2*ap)+x*(2*b*bp)

def strict_box_contains(outer, inner):
    orl,oru=outer.real().endpoints(); oil,oiu=outer.imag().endpoints()
    irl,iru=inner.real().endpoints(); iil,iiu=inner.imag().endpoints()
    return orl<irl and iru<oru and oil<iil and iiu<oiu

def certify(z,x,sep):
    last=None
    for k in range(3,41):
        r=RBF(sep/(2^k))
        V=CBF(z).add_error(r)
        der=dF_ball(V,CBF(x))
        if der.contains_zero():
            last=('derivative',k,r,der)
            continue
        image=CBF(z)-F_ball(CBF(z),CBF(x))/der
        if strict_box_contains(V,image):
            return V,k,image
        last=('inclusion',k,r,image)
    raise RuntimeError('no certified radius: %r' % (last,))

x0=QQ(1)/2
F0=Q2*A^3+x0*(B^2-Q2*A^3)
centers=F0.roots(ring=CF,multiplicities=False)
assert len(centers)==110
centers=sorted(centers,key=lambda z:(z.real(),z.imag()))
for i,z in enumerate(centers):
    for _ in range(24): z-=F_num(z,CF(x0))/dF_num(z,CF(x0))
    centers[i]=z
seps=[min(abs(z-w) for j,w in enumerate(centers) if i!=j) for i,z in enumerate(centers)]
base_balls=[]; ks=[]
for i,(z,sep) in enumerate(zip(centers,seps)):
    try:
        V,k,image=certify(z,x0,sep)
    except Exception:
        print('BASE_FAILURE',i,'SEP',sep,'RESIDUAL',abs(F_num(z,CF(x0))),flush=True)
        raise
    base_balls.append(V); ks.append(k)
assert all(not base_balls[i].overlaps(base_balls[j]) for i in range(110) for j in range(i+1,110))
print('BASE_ROOTS_CERTIFIED',len(base_balls),flush=True)
print('MIN_BASE_SEPARATION',min(seps),flush=True)
print('BASE_RADIUS_EXPONENT_RANGE',min(ks),max(ks),flush=True)

x1=QQ(499)/1000
z0=centers[0]
z1=z0
for _ in range(24): z1-=F_num(z1,CF(x1))/dF_num(z1,CF(x1))
F1=Q2*A^3+x1*(B^2-Q2*A^3)
all1=F1.roots(ring=CF,multiplicities=False)
sep=min(abs(z1-w) for w in all1 if abs(z1-w)>RealField(PREC)(2)^(-PREC/3))
V1,k1,N1=certify(z1,x1,sep)
print('VERTEX_RADIUS_EXPONENT',k1,flush=True)

mid=(z0+z1)/2
for factor in [QQ(3)/4,QQ(7)/8,QQ(1),QQ(5)/4,QQ(3)/2,QQ(2),QQ(3),QQ(4)]:
    rad=RBF(abs(z1-z0)*factor)+max(base_balls[0].rad(),V1.rad())*4
    Z=CBF(mid).add_error(rad)
    xr=RBF((x0+x1)/2).add_error(RBF(abs(x1-x0)/2))
    X=CBF(xr,RBF(0))
    der=dF_ball(Z,X)
    if der.contains_zero():
        continue
    Nt=CBF(mid)-F_ball(CBF(mid),X)/der
    if strict_box_contains(Z,Nt):
        print('TUBE_FACTOR',factor,flush=True)
        print('TUBE_STRICT',True,flush=True)
        break
else:
    raise RuntimeError('no certified tube')
print('[PASS] certified interval-Newton probe',flush=True)
