# Runtime-only patch.  Complex-field Newton iterates merely propose centers;
# every accepted root box is independently certified by interval Newton.
NEWTON_STEPS=8


def certify_rouche_segment(x0,centers0,boxes0,x1,centers1,boxes1):
    dx=exact_parameter_distance(x0,x1)
    X=parameter_box(x0,x1)
    update_min('minimum_parameter_clearance',
               min(X.abs().lower(),(X-CBF(1)).abs().lower()))
    data=[factor_rouche_data(i,centers0,boxes0) for i in range(110)]
    allowed_lower=min((RBF(d['allowed'].lower()) for d in data),
                      key=lambda v:v.lower())
    if not dx < allowed_lower:
        raise CertificationFailure('segment exceeds Rouche step bound')

    for i in range(110):
        for j in range(i+1,110):
            dist=RBF((CBF(centers0[i])-CBF(centers0[j])).abs().lower())
            if not data[i]['radius']+data[j]['radius'] < dist:
                raise CertificationFailure('Rouche disks overlap')

    # Numerical continuation preserves the list index only provisionally.
    # The proof accepts it exactly when the certified endpoint box with that
    # index is wholly contained in the corresponding Rouché disk.  A Newton
    # jump therefore causes subdivision, never a false sheet identification.
    for i,d in enumerate(data):
        if not RBF((boxes1[i]-CBF(d['center'])).abs().upper()) < d['radius']:
            raise CertificationFailure('same-index endpoint box leaves Rouche disk')

    margin=min((d['boundary_lower']-dx*d['variation_upper'] for d in data),
               key=lambda v:v.lower())
    update_min('minimum_rouche_boundary_margin',margin)
    update_min('minimum_rouche_allowed_step',allowed_lower)
    update_min('minimum_rouche_disk_radius',
               min((d['radius'] for d in data),key=lambda v:v.lower()))
    stats['maximum_rouche_disk_denominator']=max(
        stats['maximum_rouche_disk_denominator'],
        max(d['denominator'] for d in data))
    return centers1,boxes1
