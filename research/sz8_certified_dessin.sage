load('research/sz8_certified_dessin_core_1.sage')
load('research/sz8_certified_dessin_core_2.sage')
load('research/sz8_certified_dessin_core_3.sage')
load('research/sz8_certified_dessin_core_4.sage')

print('[2/7] certifying all 110 roots above the base point x=1/2',flush=True)
base_x=(QQ(1)/2,QQ(0))
base_poly=(P_BLACK+P_WHITE)/2
base_centers=base_poly.roots(ring=CF,multiplicities=False)
assert len(base_centers)==110
base_centers=sorted(base_centers,key=lambda z:(z.real(),z.imag()))
base_centers,base_boxes=certify_vertex(base_centers,base_x)
assert len(base_boxes)==110 and pairwise_disjoint(base_boxes)

# Positively oriented square loops, based at 1/2.
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

start=time.time()
print('[3/7] certifying monodromy around 0',flush=True)
sigma0=follow_loop('zero',gamma0,base_centers,base_boxes)
print('[4/7] certifying monodromy around 1',flush=True)
sigma1=follow_loop('one',gamma1,base_centers,base_boxes)
sigma_inf=inverse(compose(sigma0,sigma1))

assert cycle_type(sigma0)=={1:2,3:36}
assert cycle_type(sigma1)=={2:55}
assert cycle_type(sigma_inf)=={1:1,4:3,5:7,7:7,13:1}
print('[5/7] certified cycle types:',cycle_type(sigma0),cycle_type(sigma1),cycle_type(sigma_inf),flush=True)


def intertwiner(source,target,image0):
    n=len(source[0])
    qmap=[None]*n
    qmap[0]=image0
    queue=deque([0])
    pairs=[]
    for s,t in zip(source,target):
        pairs.extend(((s,t),(inverse(s),inverse(t))))
    while queue:
        i=queue.popleft(); qi=qmap[i]
        for s,t in pairs:
            ni=s[i]; nq=t[qi]
            if qmap[ni] is None:
                qmap[ni]=nq; queue.append(ni)
            elif qmap[ni]!=nq:
                return None
    if any(x is None for x in qmap) or len(set(qmap))!=n:
        return None
    return tuple(qmap)


print('[6/7] checking simultaneous conjugacy with the Sz(8) quotient triple',flush=True)
conjugator=None; variant=None
for s0name,s0 in (('sigma0',sigma0),('sigma0^-1',inverse(sigma0))):
    for trname,tr in (('R',TARGET_R),('R^-1',inverse(TARGET_R))):
        for tsname,ts in (('S',TARGET_S),('S^-1',inverse(TARGET_S))):
            for image0 in range(110):
                qmap=intertwiner((s0,sigma1),(tr,ts),image0)
                if qmap is not None:
                    conjugator=qmap
                    variant=(s0name,trname,tsname,image0)
                    break
            if conjugator is not None: break
        if conjugator is not None: break
    if conjugator is not None: break
assert conjugator is not None

elapsed=time.time()-start
result={
    'method':'Sage ComplexBallField interval Newton vertices + factorized Rouche continuation',
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
    'cycle_types':{
        'zero':cycle_type(sigma0),
        'one':cycle_type(sigma1),
        'infinity':cycle_type(sigma_inf),
    },
    'simultaneous_conjugacy_variant':variant,
    'conjugator':list(conjugator),
    'sigma0':list(sigma0),
    'sigma1':list(sigma1),
    'sigma_infinity':list(sigma_inf),
    'elapsed_seconds':elapsed,
}
open('sz8_certified_dessin_result.json','w').write(json.dumps(result,indent=2,sort_keys=True))
print('[7/7] PASS: certified complex-ball/Rouche monodromy equals the Sz(8) quotient dessin',flush=True)
print(json.dumps({
    'accepted_segments':result['accepted_segments'],
    'maximum_depth_used':result['maximum_depth_used'],
    'minimum_vertex_inclusion_margin':result['minimum_vertex_inclusion_margin'],
    'minimum_rouche_boundary_margin':result['minimum_rouche_boundary_margin'],
    'minimum_rouche_allowed_step':result['minimum_rouche_allowed_step'],
    'minimum_parameter_clearance_from_0_or_1':result['minimum_parameter_clearance_from_0_or_1'],
    'simultaneous_conjugacy_variant':result['simultaneous_conjugacy_variant'],
    'elapsed_seconds':elapsed,
},indent=2),flush=True)
