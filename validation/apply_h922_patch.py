#!/usr/bin/env python3
"""Apply the deterministic four-seed gluing trace repair to SQIsign.

Target: SQISign/the-sqisign commit dd133d7aca576c361a270c8e6434832535b42ecc.
The transformation is marker-checked and aborts rather than patching an
unexpected source layout.
"""
from __future__ import annotations

import argparse
from pathlib import Path

HELPERS = r'''
// Return a public-index entry of a 2x2 translation matrix.
static inline const fp2_t *
translation_matrix_entry(const translation_matrix_t *G, unsigned row, unsigned col)
{
    if (row == 0)
        return col == 0 ? &G->g00 : &G->g01;
    return col == 0 ? &G->g10 : &G->g11;
}

static void
translation_matrix_multiplication(translation_matrix_t *out,
                                  const translation_matrix_t *left,
                                  const translation_matrix_t *right)
{
    fp2_t tmp;

    fp2_mul(&out->g00, &left->g00, &right->g00);
    fp2_mul(&tmp, &left->g01, &right->g10);
    fp2_add(&out->g00, &out->g00, &tmp);

    fp2_mul(&out->g01, &left->g00, &right->g01);
    fp2_mul(&tmp, &left->g01, &right->g11);
    fp2_add(&out->g01, &out->g01, &tmp);

    fp2_mul(&out->g10, &left->g10, &right->g00);
    fp2_mul(&tmp, &left->g11, &right->g10);
    fp2_add(&out->g10, &out->g10, &tmp);

    fp2_mul(&out->g11, &left->g10, &right->g01);
    fp2_mul(&tmp, &left->g11, &right->g11);
    fp2_add(&out->g11, &out->g11, &tmp);
}

// Compute one row of the K-trace on
// (X1 X2, X1 Z2, Z1 X2, Z1 Z2).
static void
gluing_trace_row(fp2_t row[4],
                  unsigned seed,
                  const translation_matrix_t Gi[4],
                  const translation_matrix_t products[2])
{
    const unsigned seed1 = seed >> 1;
    const unsigned seed2 = seed & 1;
    fp2_t tmp;

    for (unsigned input = 0; input < 4; input++) {
        const unsigned input1 = input >> 1;
        const unsigned input2 = input & 1;

        if (input == seed)
            fp2_set_one(&row[input]);
        else
            fp2_set_zero(&row[input]);

        fp2_mul(&tmp,
                translation_matrix_entry(&Gi[0], input1, seed1),
                translation_matrix_entry(&Gi[1], input2, seed2));
        fp2_add(&row[input], &row[input], &tmp);

        fp2_mul(&tmp,
                translation_matrix_entry(&Gi[2], input1, seed1),
                translation_matrix_entry(&Gi[3], input2, seed2));
        fp2_add(&row[input], &row[input], &tmp);

        fp2_mul(&tmp,
                translation_matrix_entry(&products[0], input1, seed1),
                translation_matrix_entry(&products[1], input2, seed2));
        fp2_add(&row[input], &row[input], &tmp);
    }
}
'''

NEW_FIRST_ROW = r'''    // The K-trace is a nonzero rank-one operator.  The old code used
    // only the X1*X2 seed, which can vanish.  Compute all four trace rows
    // and select the first nonzero row with constant-time field selection.
    translation_matrix_t products[2];
    translation_matrix_multiplication(&products[0], &Gi[0], &Gi[2]);
    translation_matrix_multiplication(&products[1], &Gi[1], &Gi[3]);

    fp2_t trace_rows[4][4], tmp;
    for (unsigned seed = 0; seed < 4; seed++)
        gluing_trace_row(trace_rows[seed], seed, Gi, products);

    for (unsigned j = 0; j < 4; j++)
        fp2_set_zero(&M->m[0][j]);

    uint32_t found = 0;
    for (unsigned seed = 0; seed < 4; seed++) {
        uint32_t row_zero = fp2_is_zero(&trace_rows[seed][0]);
        for (unsigned j = 1; j < 4; j++)
            row_zero &= fp2_is_zero(&trace_rows[seed][j]);

        const uint32_t take = (~row_zero) & (~found);
        for (unsigned j = 0; j < 4; j++)
            fp2_select(&M->m[0][j], &M->m[0][j], &trace_rows[seed][j], take);
        found |= ~row_zero;
    }
    if (!found)
        return 0;

'''

ANCHOR = "\n// Given the appropriate four torsion, computes the\n"
OLD_START = "    // Computation of the 4x4 matrix from Mij\n"
OLD_END = "    // Compute the action of (0,out.K2_4.P2) for the second row\n"
FUNCTION = "static int\ngluing_change_of_basis("


def apply(path: Path) -> None:
    text = path.read_text()
    if "gluing_trace_row(fp2_t row[4]" in text:
        raise SystemExit("repair already present")
    if text.count(ANCHOR) != 1:
        raise SystemExit("unexpected helper insertion anchor count")
    text = text.replace(ANCHOR, "\n" + HELPERS + ANCHOR, 1)

    fpos = text.find(FUNCTION)
    if fpos < 0:
        raise SystemExit("gluing_change_of_basis not found")
    start = text.find(OLD_START, fpos)
    end = text.find(OLD_END, start)
    if start < 0 or end < 0:
        raise SystemExit("unexpected first-row source layout")
    text = text[:start] + NEW_FIRST_ROW + text[end:]
    path.write_text(text)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "path",
        type=Path,
        nargs="?",
        default=Path("src/hd/ref/lvlx/theta_isogenies.c"),
    )
    args = parser.parse_args()
    apply(args.path)
    print(f"patched {args.path}")


if __name__ == "__main__":
    main()
