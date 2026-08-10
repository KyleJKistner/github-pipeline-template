# Conservative fixed-radius Rouché disk.
# The base-point scan showed the global worst sheet is optimized at
# denominator 32.  Using this same denominator everywhere removes the
# 30-candidate search.  Every actual segment inequality and endpoint
# containment remains certified; adaptive subdivision handles smaller bounds.
FIXED_ROUCHE_DENOMINATOR=32


def factor_rouche_data(i, centers, boxes):
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
    denom=FIXED_ROUCHE_DENOMINATOR
    r=clearance/denom
    own=r-self_error
    if not own>0:
        raise CertificationFailure('fixed Rouche radius misses own root box')
    lower=own
    for j,dij in enumerate(distances):
        if i==j:
            continue
        factor=dij-r
        if not factor>0:
            raise CertificationFailure('fixed Rouche disk loses root separation')
        lower*=factor
    if not lower>0:
        raise CertificationFailure('fixed Rouche lower bound is not positive')
    upper=VARIATION_LEAD
    for root,mult in VARIATION_FACTORS:
        upper*=(RBF((CBF(zi)-root).abs().upper())+r)**mult
    allowed=lower/upper
    if not allowed>0:
        raise CertificationFailure('fixed Rouche parameter allowance is not positive')
    return {
        'center':zi,
        'radius':r,
        'denominator':denom,
        'boundary_lower':lower,
        'variation_upper':upper,
        'allowed':allowed,
    }
