from sage.all import *

CBF = ComplexBallField(192)
RBF = RealBallField(192)
R.<z> = PolynomialRing(QQ)
p = z^2 - 2
print('SAGE_VERSION', version())
print('CBF', CBF)
print('ROOTS_DEFAULT', p.roots(ring=CBF))
roots = p.roots(ring=CBF, multiplicities=False)
r = roots[0]
print('ROOT_TYPE', type(r))
print('ROOT', r)
print('ROOT_REAL', r.real())
print('ROOT_IMAG', r.imag())
print('ROOT_ABS', r.abs())
print('ROOT_CONTAINS_ZERO', r.contains_zero())
print('ROOT_METHODS', [m for m in dir(r) if any(k in m.lower() for k in ['overlap','contain','radius','rad','add_error','absolute','abs'])])
print('REAL_METHODS', [m for m in dir(r.real()) if any(k in m.lower() for k in ['lower','upper','end','radius','rad','add_error','contain'])])
try:
    print('RBF_INTERVAL_STR', RBF('[0, 1]'))
except Exception as exc:
    print('RBF_INTERVAL_STR_ERROR', repr(exc))
try:
    x = RBF(1)/2
    x.add_error(RBF(1)/4)
    print('RBF_ADD_ERROR', x)
except Exception as exc:
    print('RBF_ADD_ERROR_ERROR', repr(exc))
try:
    c = CBF(1+I)
    c.add_error(RBF(1)/8)
    print('CBF_ADD_ERROR', c)
except Exception as exc:
    print('CBF_ADD_ERROR_ERROR', repr(exc))
