# Certification patch: compute every parameter-step length from the exact
# rational real and imaginary increments, with outward-rounded Arb sqrt.
# This replaces the provisional ComplexField absolute value in core_3.


def exact_parameter_distance(x0,x1):
    dr=RBF(x1[0]-x0[0])
    di=RBF(x1[1]-x0[1])
    return (dr^2+di^2).sqrt()


def certify_rouche_segment(x0,centers0,boxes0,x1,centers1,boxes1):
    dx=exact_parameter_distance(x0,x1)
    X=parameter_box(x0,x1)
    update_min('minimum_parameter_clearance',
               min(X.abs().lower(),(X-CBF(1)).abs().lower()))
    data=[factor_rouche_data(i,centers0,boxes0) for i in range(110)]
    allowed_lower=min((RBF(d['allowed'].lower()) for d in data),
                      key=lambda v:v.lower())
    # Both sides are outward-rounded real balls.  The comparison succeeds
    # only when the complete dx enclosure lies below every allowed step.
    if not dx < allowed_lower:
        raise CertificationFailure('segment exceeds Rouche step bound')

    # Every starting disk contains exactly one current root and, by Rouche,
    # exactly one root throughout the parameter segment.
    for i in range(110):
        for j in range(i+1,110):
            dist=(CBF(centers0[i])-CBF(centers0[j])).abs().lower()
            if not data[i]['radius']+data[j]['radius'] < dist:
                raise CertificationFailure('Rouche disks overlap')

    # Match endpoint root boxes to the certified starting disks.  This is
    # the rigorous sheet continuation; no nearest-root inference is used.
    matching=[]
    used=set()
    for i,d in enumerate(data):
        matches=[]
        for j,Vj in enumerate(boxes1):
            if (Vj-CBF(d['center'])).abs().upper() < d['radius']:
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
