from sage.all import *

CBF = ComplexBallField(192)
RBF = RealBallField(192)
R.<z> = PolynomialRing(QQ)
p = z^2 - 2
print('SAGE_VERSION', version())
roots = p.roots(ring=CBF, multiplicities=False)
print('ROOTS', roots)
r = roots[0]
print('ROOT_RAD', r.rad())
print('ROOT_ENDPOINTS', r.real().endpoints(), r.imag().endpoints())

x = (RBF(1)/2).add_error(RBF(1)/4)
c = CBF(1+I).add_error(RBF(1)/8)
print('RBF_ADD_ERROR', x, x.endpoints())
print('CBF_ADD_ERROR', c, c.real().endpoints(), c.imag().endpoints())

z1 = CBF(1).add_error(RBF(1)/4)
z2 = CBF(1).add_error(RBF(1)/8)
print('OVERLAPS', z1.overlaps(z2))
print('MEMBERSHIP', z2 in z1, z1 in z2)

def strict_box_contains(outer, inner):
    orl, oru = outer.real().endpoints()
    oil, oiu = outer.imag().endpoints()
    irl, iru = inner.real().endpoints()
    iil, iiu = inner.imag().endpoints()
    return orl < irl and iru < oru and oil < iil and iiu < oiu

print('STRICT_BOX_CONTAINS', strict_box_contains(z1,z2), strict_box_contains(z2,z1))

# Parametric interval-Newton probe: z^2-x=0 for x in [1.99,2.01].
X = CBF(2).add_error(RBF(1)/100)
z0 = CBF(RealField(192)(2).sqrt())
Z = z0.add_error(RBF(1)/100)
N = z0 - (z0*z0-X)/(2*Z)
print('NEWTON_X', X)
print('NEWTON_Z', Z)
print('NEWTON_IMAGE', N)
print('NEWTON_STRICT', strict_box_contains(Z,N))
assert strict_box_contains(Z,N)
