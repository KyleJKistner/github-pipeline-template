def certify_vertex(centers, x):
    centers=refine_centers(centers,x)
    n=len(centers)
    seps=[min(abs(centers[i]-centers[j]) for j in range(n) if i!=j)
          for i in range(n)]
    update_min('minimum_vertex_separation', min(seps))
    boxes=[]; exponents=[]; margins=[]; derivatives=[]
    xx=xcbf(x)
    for i,(z,sep) in enumerate(zip(centers,seps)):
        success=False
        last=None
        for k in range(30,2,-1):
            radius=RBF(sep/(2**k))
            V=CBF(z).add_error(radius)
            try:
                der=dF_ball(V,xx)
            except ZeroDivisionError:
                last=('factor',k)
                continue
            if der.contains_zero():
                last=('derivative',k)
                continue
            image=CBF(z)-F_ball(CBF(z),xx)/der
            if strict_box_contains(V,image):
                boxes.append(V)
                exponents.append(k)
                margins.append(containment_margin(V,image))
                derivatives.append(der.abs().lower())
                success=True
                break
            last=('inclusion',k)
        if not success:
            raise CertificationFailure('vertex root %s failed: %r' % (i,last))
    if not pairwise_disjoint(boxes):
        raise CertificationFailure('vertex boxes overlap')
    update_min('minimum_vertex_margin', min(margins))
    update_min('minimum_derivative_lower_bound', min(derivatives))
    stats['maximum_vertex_radius_exponent']=max(
        stats['maximum_vertex_radius_exponent'],max(exponents))
    return centers,boxes


def factor_rouche_data(i, centers, boxes):
    """Return a certified disk and parameter-step bound for sheet i.

    On |z-z_i|=r, the current polynomial is bounded below directly from
    its 110 certified roots.  The parameter variation is bounded above
    from the exact factorization -C^(-1)uD4^4D5^5D7^7.
    """
    zi=centers[i]
    self_error=RBF((boxes[i]-CBF(zi)).abs().upper())
    distances=[None]*len(boxes)
    clearance=None
    for j,Vj in enumerate(boxes):
        if i==j:
            continue
        dij=RBF((CBF(zi)-Vj).abs().lower())
        distances[j]=dij
        if clearance is None or dij.lower()<clearance.lower():
            clearance=dij
    best=None
    # r <= clearance/3 guarantees pairwise disjoint disks for all sheets.
    for denom in range(3,33):
        r=clearance/denom
        own=r-self_error
        if not own>0:
            continue
        lower=own
        valid=True
        for j,dij in enumerate(distances):
            if i==j:
                continue
            factor=dij-r
            if not factor>0:
                valid=False
                break
            lower*=factor
        if not valid or not lower>0:
            continue
        upper=VARIATION_LEAD
        for root,mult in VARIATION_FACTORS:
            upper*=(RBF((CBF(zi)-root).abs().upper())+r)**mult
        allowed=lower/upper
        if best is None or allowed.lower()>best['allowed'].lower():
            best={
                'center':zi,
                'radius':r,
                'denominator':denom,
                'boundary_lower':lower,
                'variation_upper':upper,
                'allowed':allowed,
            }
    if best is None:
        raise CertificationFailure('no factorized Rouche disk for root %s' % i)
    return best


def certify_rouche_segment(x0,centers0,boxes0,x1,centers1,boxes1):
    dx=RBF(abs(xcf(x1)-xcf(x0)))
    X=parameter_box(x0,x1)
    update_min('minimum_parameter_clearance',
               min(X.abs().lower(),(X-CBF(1)).abs().lower()))
    data=[factor_rouche_data(i,centers0,boxes0) for i in range(110)]
    allowed_lower=min((RBF(d['allowed'].lower()) for d in data),
                      key=lambda v:v.lower())
    if not dx < allowed_lower:
        raise CertificationFailure('segment exceeds Rouche step bound')

    # Every starting disk contains exactly one current root and, by Rouche,
    # exactly one root throughout the parameter segment.
    for i in range(110):
        for j in range(i+1,110):
            dist=RBF((CBF(centers0[i])-CBF(centers0[j])).abs().lower())
            if not data[i]['radius']+data[j]['radius'] < dist:
                raise CertificationFailure('Rouche disks overlap')

    # Match endpoint root boxes to the certified starting disks.  This is
    # the rigorous sheet continuation; no nearest-root inference is used.
    matching=[]
    used=set()
    for i,d in enumerate(data):
        matches=[]
        for j,Vj in enumerate(boxes1):
            if RBF((Vj-CBF(d['center'])).abs().upper()) < d['radius']:
                matches.append(j)
        if len(matches)!=1 or matches[0] in used:
            raise CertificationFailure(
                'endpoint root matching failed for disk %s: %r' % (i,matches))
        matching.append(matches[0]); used.add(matches[0])
    if len(used)!=110:
        raise CertificationFailure('endpoint matching is not a bijection')

    margin=min((d['boundary_lower']-dx*d['variation_upper'] for d in data),
               key=lambda v:v.lower())
    update_min('minimum_rouche_boundary_margin',margin)
    update_min('minimum_rouche_allowed_step',allowed_lower)
    update_min('minimum_rouche_disk_radius',
               min((d['radius'] for d in data),key=lambda v:v.lower()))
    stats['maximum_rouche_disk_denominator']=max(
        stats['maximum_rouche_disk_denominator'],
        max(d['denominator'] for d in data))
    return ([centers1[j] for j in matching],
            [boxes1[j] for j in matching])


def certify_segment(x0,centers0,boxes0,x1,depth=0):
    stats['maximum_depth']=max(stats['maximum_depth'],depth)
    try:
        # Numerical Newton only proposes endpoint roots.  Interval Newton
        # certifies each endpoint root; Rouché disks certify the connections.
        centers1,boxes1=certify_vertex(centers0,x1)
        centers1,boxes1=certify_rouche_segment(
            x0,centers0,boxes0,x1,centers1,boxes1)
        stats['accepted_segments']+=1
        return centers1,boxes1
    except CertificationFailure:
        if depth>=MAX_DEPTH:
            raise
        stats['subdivision_failures']+=1
        xm=midpoint(x0,x1)
        centersm,boxesm=certify_segment(x0,centers0,boxes0,xm,depth+1)
        return certify_segment(xm,centersm,boxesm,x1,depth+1)

