from sage.all import *

load('/tmp/sz8_surface_data.sage')

PREC = 256
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

def ccenter(z):
    return CF(z.real().center(), z.imag().center())

x0=QQ(1)/2
F0=P0+x0*P1
roots=F0.roots(ring=CBF,multiplicities=False)
assert len(roots)==110
assert all(not roots[i].overlaps(roots[j]) for i in range(110) for j in range(i+1,110))
centers=sorted([ccenter(r) for r in roots], key=lambda z:(z.real(),z.imag()))
print('BASE_ROOTS',len(centers))
print('MAX_BASE_RAD',max(r.rad().upper() for r in roots))

x1=QQ(499)/1000
z0=centers[0]
z1=z0
for _ in range(8):
    z1 -= F_num(z1,CF(x1))/dF_num(z1,CF(x1))
sep=min(abs(z1-w) for w in centers[1:])
r=RBF(sep/100)
V1=CBF(z1).add_error(r)
N1=CBF(z1)-F_ball(CBF(z1),CBF(x1))/dF_ball(V1,CBF(x1))
print('VERTEX_RADIUS',r)
print('VERTEX_IMAGE',N1)
print('VERTEX_STRICT',strict_box_contains(V1,N1))
assert strict_box_contains(V1,N1)

mid=(z0+z1)/2
rad=RBF(abs(z1-z0)*3/4)+r*2
Z=CBF(mid).add_error(rad)
xmid=RBF((x0+x1)/2).add_error(RBF(abs(x1-x0)/2))
X=CBF(xmid,RBF(0))
Nt=CBF(mid)-F_ball(CBF(mid),X)/dF_ball(Z,X)
print('TUBE_RADIUS',rad)
print('TUBE_IMAGE',Nt)
print('TUBE_STRICT',strict_box_contains(Z,Nt))
assert strict_box_contains(Z,Nt)
print('[PASS] certified interval-Newton probe')
