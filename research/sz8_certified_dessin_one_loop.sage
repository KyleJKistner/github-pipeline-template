from sage.all import *
from collections import deque
import json, os, time

load('research/sz8_certified_dessin_core_1.sage')
load('research/sz8_certified_dessin_core_2.sage')
load('research/sz8_certified_dessin_core_3.sage')
load('research/sz8_certified_dessin_exact_step.sage')
load('research/sz8_certified_dessin_core_4.sage')


def json_safe(x):
    if isinstance(x,dict):
        return {str(k):json_safe(v) for k,v in x.items()}
    if isinstance(x,(list,tuple)):
        return [json_safe(v) for v in x]
    if isinstance(x,Integer):
        return int(x)
    return x

loop_name=os.environ.get('SZ8_LOOP')
if loop_name not in ('zero','one'):
    raise RuntimeError('SZ8_LOOP must be zero or one')

base_x=(QQ(1)/2,QQ(0))
print('[1/4] certifying all 110 roots above x=1/2',flush=True)
base_poly=(P_BLACK+P_WHITE)/2
base_centers=base_poly.roots(ring=CF,multiplicities=False)
assert len(base_centers)==110
base_centers=sorted(base_centers,key=lambda z:(z.real(),z.imag()))
base_centers,base_boxes=certify_vertex(base_centers,base_x)
assert len(base_boxes)==110 and pairwise_disjoint(base_boxes)

gamma0=[
    base_x,
    (QQ(1)/4,QQ(0)),
    (QQ(1)/4,QQ(1)/4),
    (-QQ(1)/4,QQ(1)/4),
    (-QQ(1)/4,-QQ(1)/4),
    (QQ(1)/4,-QQ(1)/4),
    (QQ(1)/4,QQ(0)),
    base_x,
]
gamma1=[
    base_x,
    (QQ(3)/4,QQ(0)),
    (QQ(3)/4,-QQ(1)/4),
    (QQ(5)/4,-QQ(1)/4),
    (QQ(5)/4,QQ(1)/4),
    (QQ(3)/4,QQ(1)/4),
    (QQ(3)/4,QQ(0)),
    base_x,
]
vertices=gamma0 if loop_name=='zero' else gamma1
print('[2/4] certifying the %s generator' % loop_name,flush=True)
start=time.time()
perm=follow_loop(loop_name,vertices,base_centers,base_boxes)
expected={1:2,3:36} if loop_name=='zero' else {2:55}
assert cycle_type(perm)==expected
print('[3/4] certified cycle type',cycle_type(perm),flush=True)

result={
    'loop':loop_name,
    'method':'Sage ComplexBallField interval Newton vertices + exact factorized Rouche continuation',
    'sage_precision_bits':PREC,
    'initial_subdivisions_per_polygon_edge':INITIAL_SUBDIVISIONS,
    'maximum_adaptive_depth_allowed':MAX_DEPTH,
    'accepted_segments':stats['accepted_segments'],
    'subdivision_failures':stats['subdivision_failures'],
    'maximum_depth_used':stats['maximum_depth'],
    'minimum_vertex_inclusion_margin':str(stats['minimum_vertex_margin']),
    'minimum_derivative_modulus_lower_bound':str(stats['minimum_derivative_lower_bound']),
    'minimum_rouche_boundary_margin':str(stats['minimum_rouche_boundary_margin']),
    'minimum_rouche_allowed_step':str(stats['minimum_rouche_allowed_step']),
    'minimum_rouche_disk_radius':str(stats['minimum_rouche_disk_radius']),
    'maximum_rouche_disk_denominator':stats['maximum_rouche_disk_denominator'],
    'minimum_parameter_clearance_from_0_or_1':str(stats['minimum_parameter_clearance']),
    'minimum_vertex_root_separation':str(stats['minimum_vertex_separation']),
    'maximum_vertex_radius_exponent':stats['maximum_vertex_radius_exponent'],
    'cycle_type':cycle_type(perm),
    'permutation':list(perm),
    'elapsed_seconds':time.time()-start,
}
result=json_safe(result)
path='sz8_certified_loop_%s.json' % loop_name
open(path,'w').write(json.dumps(result,indent=2,sort_keys=True))
print('[4/4] PASS:',loop_name,'generator certified; output',path,flush=True)
print(json.dumps({k:result[k] for k in (
    'loop','accepted_segments','subdivision_failures','maximum_depth_used',
    'minimum_rouche_boundary_margin','minimum_rouche_allowed_step',
    'minimum_parameter_clearance_from_0_or_1','elapsed_seconds')},indent=2),flush=True)
