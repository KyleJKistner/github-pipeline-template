#!/usr/bin/env python3
"""Patch thetAV's isog_comput point-evaluation map.

Pinned target: AntoineDeq/thetAV commit
    e39215c295202f792eff0609e951345a60a66d88

The quotient theta-null computation is unchanged.  The patch only accumulates
all symplectic-coordinate changes and fixes the returned morphism so points on
the original marked abelian variety can be evaluated on the quotient.
"""
from __future__ import annotations

import argparse
from pathlib import Path

INIT_OLD = """        Bp = cop(self)\n        G1p = cop(G1)\n        xp = cop(x)\n        \n        while not bol:\n"""
INIT_NEW = """        Bp = cop(self)\n        G1p = cop(G1)\n        xp = cop(x)\n        # Accumulate the coordinate changes from the original marking to Bp.\n        from_B_to_Bp = lambda y: y\n        \n        while not bol:\n"""

FIRST_OLD = """            B1p, from_Bp_to_B1p = Bp.action_Sp(M, check = check)\n            G11p = [from_Bp_to_B1p(g1) for g1 in G1p]\n            x1p = from_Bp_to_B1p(xp)\n"""
FIRST_NEW = """            B1p, from_Bp_to_B1p = Bp.action_Sp(M, check = check)\n            previous_from_B_to_Bp = from_B_to_Bp\n            from_B_to_B1p = lambda y, f=from_Bp_to_B1p, previous=previous_from_B_to_Bp: f(previous(y))\n            G11p = [from_Bp_to_B1p(g1) for g1 in G1p]\n            x1p = from_Bp_to_B1p(xp)\n"""

BOL_OLD = """            if bol:\n                Bp = cop(B1p)\n                G1p = cop(G11p)\n                xp = cop(x1p)\n                break\n"""
BOL_NEW = """            if bol:\n                Bp = cop(B1p)\n                G1p = cop(G11p)\n                xp = cop(x1p)\n                from_B_to_Bp = from_B_to_B1p\n                break\n"""

SECOND_OLD = """            Bp, from_B1p_to_Bp = B1p.action_Sp(M, check = check)\n            G1p = [from_B1p_to_Bp(g1) for g1 in G11p]\n            xp = from_B1p_to_Bp(x1p)\n"""
SECOND_NEW = """            Bp, from_B1p_to_Bp = B1p.action_Sp(M, check = check)\n            from_B_to_Bp = lambda y, f=from_B1p_to_Bp, previous=from_B_to_B1p: f(previous(y))\n            G1p = [from_B1p_to_Bp(g1) for g1 in G11p]\n            xp = from_B1p_to_Bp(x1p)\n"""

FINAL_OLD = """        Bpp, from_Bp_to_Bpp = Bp.thet_pt_comp(n, G1p, check = check)\n        G1pp = [from_Bp_to_Bpp(g1p) for g1p in G1p]\n        xpp = from_Bp_to_Bpp(xp)\n"""
FINAL_NEW = """        Bpp, from_Bp_to_Bpp = Bp.thet_pt_comp(n, G1p, check = check)\n        previous_from_B_to_Bp = from_B_to_Bp\n        from_B_to_Bpp = lambda y, f=from_Bp_to_Bpp, previous=previous_from_B_to_Bp: f(previous(y))\n        G1pp = [from_Bp_to_Bpp(g1p) for g1p in G1p]\n        xpp = from_Bp_to_Bpp(xp)\n"""

MORPH_OLD = """        fonc_conv = lambda x:A(isog_comput_fonc(self, n, lst_ai, Bpp, G1t, lambda y:from_Bp_to_Bpp(from_B_to_Bp(y)), x))\n        \n        return A, fonc_conv\n"""
MORPH_NEW = """        fonc_conv = lambda y: A(self.isog_comput_fonc(n, lst_ai, Bpp, G1t, from_B_to_Bpp, y))\n        \n        return A, fonc_conv\n"""

REPLACEMENTS = [
    (INIT_OLD, INIT_NEW, "initial map"),
    (FIRST_OLD, FIRST_NEW, "first symplectic action"),
    (BOL_OLD, BOL_NEW, "early normalized branch"),
    (SECOND_OLD, SECOND_NEW, "second symplectic action"),
    (FINAL_OLD, FINAL_NEW, "level-change map"),
    (MORPH_OLD, MORPH_NEW, "returned isogeny map"),
]


def patch(path: Path) -> None:
    text = path.read_text()
    if "from_B_to_Bpp = lambda y" in text:
        raise SystemExit("thetAV isogeny-evaluation repair already present")
    for old, new, label in REPLACEMENTS:
        count = text.count(old)
        if count != 1:
            raise SystemExit(f"unexpected {label} marker count: {count}")
        text = text.replace(old, new, 1)
    path.write_text(text)
    print(f"patched {path}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "path",
        nargs="?",
        type=Path,
        default=Path("thetAV/theta_null_point.py"),
    )
    args = parser.parse_args()
    patch(args.path)


if __name__ == "__main__":
    main()
