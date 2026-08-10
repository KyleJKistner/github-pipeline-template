from sage.all import *

load('/tmp/sz8_surface_data.sage')

PREC = 512
CBF = ComplexBallField(PREC)
RBF = RealBallField(PREC)
CF = ComplexField(PREC)

P0 = Q2*A^3
P1 = B^2-P0
dP0 = P0.derivative()
dP1 = P1.derivative()
P0b=P0.change_ring(CBF); P1b=P1.change_ring(CBF)
dP0b=dP0.change_ring(CBF); dP1b=dP1.change_ring(CBF)
P0c=P0.change_ring(CF); P1c=P1.change_ring(CF)
dP0c=dP0.change_ring(CF); dP1c=dP1.change_ring(CF)

def F_ball(z,x): return P0b(z)+x*P1b(z)
def dF_ball(z,x): return dP0b(z)+x*dP1b(z)
def F_num(z,x): return P0c(z)+x*P1c(z)
def dF_num(z,x): return dP0c(z)+x*dP1c(z)

def strict_box_contains(outer, inner):
    orl,oru=outer.real().endpoints(); oil,oiu=outer.imag().endpoints()
    irl,iru=inner.real().endpoints(); iil,iiu=inner.imag().endpoints()
    return orl<irl and iru<oru and oil<iil and iiu<oiu

def certify(z,x,sep):
    last=None
    for k in range(3,31):
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
F0=P0+x0*P1
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
    except Exception as exc:
        print('BASE_FAILURE',i,'SEP',sep,'RESIDUAL',abs(F_num(z,CF(x0))))
        raise
    base_balls.append(V); ks.append(k)
assert all(not base_balls[i].overlaps(base_balls[j]) for i in range(110) for j in range(i+1,110))
print('BASE_ROOTS_CERTIFIED',len(base_balls))
print('MIN_BASE_SEPARATION',min(seps))
print('BASE_RADIUS_EXPONENT_RANGE',min(ks),max(ks))

x1=QQ(499)/1000
z0=centers[0]
z1=z0
for _ in range(24): z1-=F_num(z1,CF(x1))/dF_num(z1,CF(x1))
all1=(P0+x1*P1).roots(ring=CF,multiplicities=False)
sep=min(abs(z1-w) for w in all1 if abs(z1-w)>RDF(1e-30))
V1,k1,N1=certify(z1,x1,sep)
print('VERTEX_RADIUS_EXPONENT',k1)

mid=(z0+z1)/2
for factor in [QQ(3)/4,QQ(7)/8,QQ(1),QQ(5)/4,QQ(3)/2,QQ(2),QQ(3),QQ(4)]:
    rad=RBF(abs(z1-z0)*factor)+max(base_balls[0].rad(),V1.rad())*4
    Z=CBF(mid).add_error(rad)
    xmid=RBF((x0+x1)/2).add_error(RBF(abs(x1-x0)/2))
    X=CBF(xmid,RBF(0))
    der=dF_ball(Z,X)
    if der.contains_zero():
        continue
    Nt=CBF(mid)-F_ball(CBF(mid),X)/der
    if strict_box_contains(Z,Nt):
        print('TUBE_FACTOR',factor)
        print('TUBE_STRICT',True)
        break
else:
    raise RuntimeError('no certified tube')
print('[PASS] certified interval-Newton probe')
