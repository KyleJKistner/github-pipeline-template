def subdivided_edge(p,q,n):
    return [(
        p[0]+(q[0]-p[0])*QQ(k)/n,
        p[1]+(q[1]-p[1])*QQ(k)/n
    ) for k in range(n+1)]


def follow_loop(name,vertices,base_centers,base_boxes):
    print('[loop %s] starting certified continuation' % name,flush=True)
    centers=list(base_centers); boxes=list(base_boxes)
    current=vertices[0]
    assert current==(QQ(1)/2,QQ(0))
    for edge,(p,q) in enumerate(zip(vertices[:-1],vertices[1:])):
        assert p==current
        mesh=subdivided_edge(p,q,INITIAL_SUBDIVISIONS)
        for target in mesh[1:]:
            centers,boxes=certify_segment(current,centers,boxes,target,0)
            current=target
        print('[loop %s] edge %s/%s complete; accepted=%s depth=%s' % (
            name,edge+1,len(vertices)-1,stats['accepted_segments'],stats['maximum_depth']
        ),flush=True)
    assert current==(QQ(1)/2,QQ(0))

    # At the returning base point, identify labels by containment in 110
    # pairwise-disjoint certified Rouche disks around the original roots.
    # This avoids any nearest-neighbour or mere-overlap inference.
    base_disks=[factor_rouche_data(j,base_centers,base_boxes)
                for j in range(110)]
    for i in range(110):
        for j in range(i+1,110):
            dist=RBF((CBF(base_centers[i])-CBF(base_centers[j])).abs().lower())
            if not base_disks[i]['radius']+base_disks[j]['radius'] < dist:
                raise RuntimeError('base Rouche disks overlap')
    perm=[]
    used=set()
    for i,V in enumerate(boxes):
        matches=[j for j,d in enumerate(base_disks)
                 if RBF((V-CBF(d['center'])).abs().upper()) < d['radius']]
        if len(matches)!=1 or matches[0] in used:
            raise RuntimeError('final box %s has base-disk matches %s' % (i,matches))
        perm.append(matches[0]); used.add(matches[0])
    assert len(used)==110
    return tuple(perm)

