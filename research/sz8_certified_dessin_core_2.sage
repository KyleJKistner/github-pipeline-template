stats = {
    'accepted_segments': 0,
    'subdivision_failures': 0,
    'maximum_depth': 0,
    'minimum_vertex_margin': None,
    'minimum_derivative_lower_bound': None,
    'minimum_parameter_clearance': None,
    'minimum_vertex_separation': None,
    'maximum_vertex_radius_exponent': 0,
    'minimum_rouche_boundary_margin': None,
    'minimum_rouche_allowed_step': None,
    'minimum_rouche_disk_radius': None,
    'maximum_rouche_disk_denominator': 0,
}


def update_min(name, value):
    value = RF(value.lower() if hasattr(value,'lower') else value)
    if stats[name] is None or value < stats[name]:
        stats[name] = value


def relative_residual_num(z,x):
    a,ap=product_and_derivative_num(z,ARC)
    b,bp=product_and_derivative_num(z,BRC)
    q,qp=product_and_derivative_num(z,QRC)
    black=(1-x)*q*a**3
    white=x*b**2
    return abs(black+white)/max(RF(1),abs(black)+abs(white))


def refine_centers(centers, x):
    xx=xcf(x)
    out=[]
    tol=RF(2)**(-PREC//3)
    for z0 in centers:
        z=CF(z0)
        previous=None
        for _ in range(NEWTON_STEPS):
            der=dF_num(z,xx)
            if der == 0:
                raise CertificationFailure('numerical derivative vanished')
            dz=F_num(z,xx)/der
            z-=dz
            if abs(dz)<tol:
                break
            if previous is not None and abs(dz)>4*previous:
                raise CertificationFailure('numerical Newton diverged')
            previous=abs(dz)
        if relative_residual_num(z,xx) > RF(2)**(-PREC//4):
            raise CertificationFailure('numerical relative residual too large')
        out.append(z)
    return out

