from sage.all import *

load('/tmp/sz8_surface_data.sage')

PREC = 384
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

x0=QQ(1)/2
F0=P0+x0*P1
centers=F0.roots(ring=CF,multiplicities=False)
assert len(centers)==110
centers=sorted(centers,key=lambda z:(z.real(),z.imag()))
for i,z in enumerate(centers):
    for _ in range(10): z-=F_num(z,CF(x0))/dF_num(z,CF(x0))
    centers[i]=z
seps=[min(abs(z-w) for j,w in enumerate(centers) if i!=j) for i,z in enumerate(centers)]
base_balls=[]
for z,sep in zip(centers,seps):
    V=CBF(z).add_error(RBF(sep/1024))
    image=CBF(z)-F_ball(CBF(z),CBF(x0))/dF_ball(V,CBF(x0))
    assert strict_box_contains(V,image)
    base_balls.append(V)
assert all(not base_balls[i].overlaps(base_balls[j]) for i in range(110) for j in range(i+1,110))
print('BASE_ROOTS_CERTIFIED',len(base_balls))
print('MIN_BASE_SEPARATION',min(seps))

x1=QQ(499)/1000
z0=centers[0]
z1=z0
for _ in range(10): z1-=F_num(z1,CF(x1))/dF_num(z1,CF(x1))
sep=min(abs(z1-w) for w in centers[1:])
r=RBF(sep/1024)
V1=CBF(z1).add_error(r)
N1=CBF(z1)-F_ball(CBF(z1),CBF(x1))/dF_ball(V1,CBF(x1))
print('VERTEX_STRICT',strict_box_contains(V1,N1))
assert strict_box_contains(V1,N1)

mid=(z0+z1)/2
rad=RBF(abs(z1-z0)*13/20)+r*4
Z=CBF(mid).add_error(rad)
xmid=RBF((x0+x1)/2).add_error(RBF(abs(x1-x0)/2))
X=CBF(xmid,RBF(0))
Nt=CBF(mid)-F_ball(CBF(mid),X)/dF_ball(Z,X)
print('TUBE_STRICT',strict_box_contains(Z,Nt))
assert strict_box_contains(Z,Nt)
print('[PASS] certified interval-Newton probe')
