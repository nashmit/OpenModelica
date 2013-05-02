/*
 * This file is part of OpenModelica.
 *
 * Copyright (c) 1998-CurrentYear, Linköping University,
 * Department of Computer and Information Science,
 * SE-58183 Linköping, Sweden.
 *
 * All rights reserved.
 *
 * THIS PROGRAM IS PROVIDED UNDER THE TERMS OF GPL VERSION 3
 * AND THIS OSMC PUBLIC LICENSE (OSMC-PL).
 * ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS PROGRAM CONSTITUTES RECIPIENT'S
 * ACCEPTANCE OF THE OSMC PUBLIC LICENSE.
 *
 * The OpenModelica software and the Open Source Modelica
 * Consortium (OSMC) Public License (OSMC-PL) are obtained
 * from Linköping University, either from the above address,
 * from the URLs: http://www.ida.liu.se/projects/OpenModelica or
 * http://www.openmodelica.org, and in the OpenModelica distribution.
 * GNU version 3 is obtained from: http://www.gnu.org/copyleft/gpl.html.
 *
 * This program is distributed WITHOUT ANY WARRANTY; without
 * even the implied warranty of  MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE, EXCEPT AS EXPRESSLY SET FORTH
 * IN THE BY RECIPIENT SELECTED SUBSIDIARY LICENSE CONDITIONS
 * OF OSMC-PL.
 *
 * See the full OSMC Public License conditions for more details.
 *
 */


#include "base_array.h"
#include "index_spec.h"
#include "memory_pool.h"

#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <stdarg.h>

/** function: base_array_create
 **
 ** sets all fields in a base_array, i.e. data, ndims and dim_size.
 **/

void base_array_create(base_array_t *dest, void *data, int ndims, va_list ap)
{
    int i;

    dest->data = data;
    dest->ndims = ndims;

    dest->dim_size = size_alloc(ndims);

    for(i = 0; i < ndims; ++i) {
        dest->dim_size[i] = va_arg(ap, int);
    }

    /* uncomment for debugging!
    fprintf(stderr, "created array ndims[%d] (", ndims);
    for(i = 0; i < ndims; ++i) {
      fprintf(stderr, "size(%d)=[%d], ", i, (int)dest->dim_size[i]);
    }
    fprintf(stderr, ")\n"); fflush(stderr);
    */
}

int base_array_ok(const base_array_t *a)
{
    int i;
    if(a == NULL) {
      fprintf(stderr, "base_array.c: array is NULL!\n"); fflush(stderr);
      return 0;
    }
    if(a->ndims < 0) {
      fprintf(stderr, "base_array.c: the number of array dimensions are < 0!\n"); fflush(stderr);
      return 0;
    }
    if(a->dim_size == NULL) {
      fprintf(stderr, "base_array.c: array dimensions sizes are NULL!\n"); fflush(stderr);
      return 0;
    }
    for(i = 0; i < a->ndims; ++i) {
        if(a->dim_size[i] < 0) {
          fprintf(stderr, "base_array.c: array dimension size for dimension %d is %d < 0!\n", i, (int) a->dim_size[i]); fflush(stderr);
          return 0;
        }
    }
    return 1;
}

/* help function to e.g. array_alloc_real_array
 * Checks that all arrays have the same number of dimensions and same
 * dimension sizes.
 */
void check_base_array_dim_sizes(const base_array_t * const *elts, int n)
{
    int i, curdim, dimsize;
    int ndims = elts[0]->ndims;
    for(i = 1; i < n; ++i) {
        assert(elts[i]->ndims == ndims && "Not same number of dimensions");
    }
    for(curdim = 0; curdim < ndims; ++curdim) {
        dimsize = elts[0]->dim_size[curdim];
        for(i = 1; i < n; ++i) {
            assert(dimsize == elts[i]->dim_size[curdim]
                   && "Dimensions size not same");
        }
    }
}

/* help function to e.g. cat_alloc_real_array.
 * Checks that all arrays have the same number of dimensions and same
 * dimension sizes  for all sizes except for dimension k.
 */
void check_base_array_dim_sizes_except(int k, const base_array_t * const *elts, int n)
{
    int i, curdim, dimsize;
    int k_loc = k - 1;
    int ndims = elts[0]->ndims;
    for(i = 1; i < n; ++i) {
        assert(elts[i]->ndims == ndims && "Not same number of dimensions");
    }
    for(curdim = 0; curdim < ndims; ++curdim) {
        if(curdim != k_loc) {
            assert(elts[0]);
            assert(elts[0]->dim_size[curdim]);
            dimsize = elts[0]->dim_size[curdim];

            for(i = 1; i < n; ++i) {
                assert(dimsize == elts[i]->dim_size[curdim]
                       && "Dimensions size not same");
            }
        }
    }
}

int base_array_shape_eq(const base_array_t *a, const base_array_t *b)
{
    int i;

    if(a->ndims != b->ndims) {
        fprintf(stderr, "a->ndims != b->ndims, %d != %d\n", a->ndims, b->ndims);
        return 0;
    }

    for(i = 0; i < a->ndims; ++i) {
        if(a->dim_size[i] != b->dim_size[i]) {
            fprintf(stderr, "a->dim_size[%d] != b->dim_size[%d], %d != %d\n",
                    i, i, (int) a->dim_size[i], (int) b->dim_size[i]);
            return 0;
        }
    }

    return 1;
}

int base_array_one_element_ok(const base_array_t *a)
{
    int i;

    for(i = 0; i < a->ndims; ++i) {
        if(a->dim_size[i] != 1) {
            return 0;
        }
    }
    return 1;
}

int index_spec_fit_base_array(const index_spec_t *s, const base_array_t *a)
{
    int i, j;

    if(s->ndims != a->ndims) {
        fprintf(stderr, "index spec dimensions and array dimensions do not agree %d != %d\n",
                (int)s->ndims, (int)a->ndims); fflush(stderr);
        return 0;
    }
    for(i = 0; i < s->ndims; ++i) {
        if(s->dim_size[i] == 0) {
            if((s->index[i][0] <= 0) || (s->index[i][0] > a->dim_size[i])) {
                fprintf(stderr,
                        "scalar s->index[%d][0] == %d incorrect, a->dim_size[%d] == %d\n",
                        i, (int) s->index[i][0], i, (int) a->dim_size[i]); fflush(stderr);
                return 0;
            }
        }

        if(s->index[i] != NULL)
        {
            for(j = 0; j < s->dim_size[i]; ++j) {
                if((s->index[i][j] <= 0) || (s->index[i][j] > a->dim_size[i])) {
                    fprintf(stderr,
                            "array s->index[%d][%d] == %d incorrect, a->dim_size[%d] == %d\n",
                            i, j, (int) s->index[i][j], i, (int) a->dim_size[i]); fflush(stderr);
                    return 0;
                }
            }
        }
    }

    return 1;
}

size_t base_array_nr_of_elements(const base_array_t *a)
{
  int i;
  size_t nr_of_elements = 1;
  for(i = 0; i < a->ndims; ++i)
  {
     nr_of_elements *= a->dim_size[i];
  }
  return nr_of_elements;
}

void simple_alloc_1d_base_array(base_array_t *dest, int n, void *data)
{
    dest->ndims = 1;
    dest->dim_size = size_alloc(1);
    dest->dim_size[0] = n;
    dest->data = data;
}

void simple_alloc_2d_base_array(base_array_t *dest, int r, int c, void *data)
{
    dest->ndims = 2;
    dest->dim_size = size_alloc(2);
    dest->dim_size[0] = r;
    dest->dim_size[1] = c;
    dest->data = data;
}

size_t alloc_base_array(base_array_t *dest, int ndims, va_list ap)
{
    int i;
    size_t nr_of_elements = 1;

    dest->ndims = ndims;
    dest->dim_size = size_alloc(ndims);

    for(i = 0; i < ndims; ++i) {
        dest->dim_size[i] = va_arg(ap, _index_t);
        nr_of_elements *= dest->dim_size[i];
    }

    /* uncomment for debugging!
    fprintf(stderr, "alloc array ndims[%d] (", ndims);
    for(i = 0; i < ndims; ++i) {
        fprintf(stderr, "size(%d)=[%d], ", i, (int)dest->dim_size[i]);
    }
    fprintf(stderr, ")\n"); fflush(stderr);
    */

    return nr_of_elements;
}

void clone_base_array_spec(const base_array_t *source, base_array_t *dest)
{
    int i;
    assert(base_array_ok(source));

    dest->ndims = source->ndims;
    dest->dim_size = size_alloc(dest->ndims);
    assert(dest->dim_size);

    for(i = 0; i < dest->ndims; ++i) {
        dest->dim_size[i] = source->dim_size[i];
    }
}

/*
 a[1:3] := b;
*/

size_t calc_base_index_spec(int ndims, const _index_t *idx_vec,
                            const base_array_t *arr, const index_spec_t *spec)
{
    /* idx_vec is zero based */
    /* spec is one based */
    int i;
    int d,d2;
    size_t index = 0;

    assert(base_array_ok(arr));
    assert(index_spec_ok(spec));
    assert(index_spec_fit_base_array(spec, arr));
    assert((ndims == arr->ndims) && (ndims == spec->ndims));

    index = 0;
    for(i = 0; i < ndims; ++i) {
        d = idx_vec[i];
        if(spec->index[i] != NULL) {
            d2 = spec->index[i][d] - 1;
        } else {
            d2 = d;
        }
        index = (index * arr->dim_size[i]) + d2;
    }

    return index;
}

/* Uses zero based indexing */
size_t calc_base_index(int ndims, const _index_t *idx_vec, const base_array_t *arr)
{
    int i;
    size_t index = 0;
    assert(ndims == arr->ndims);

    for(i = 0; i < ndims; ++i) {
        /* Assert that idx_vec[i] is not out of bounds */
        index = (index * arr->dim_size[i]) + idx_vec[i];
    }

    return index;
}

/* One based index*/
size_t calc_base_index_va(const base_array_t *source, int ndims, va_list ap)
{
    int i;
    size_t index;
    int dim_i;

    index = 0;
    for(i = 0; i < ndims; ++i) {
        dim_i = va_arg(ap, _index_t) - 1;
        index = (index * source->dim_size[i]) + dim_i;
    }

    return index;
}

int ndims_base_array(const base_array_t* a)
{
    assert(base_array_ok(a));
    return a->ndims;
}

int size_of_dimension_base_array(const base_array_t a, int i)
{
    assert(base_array_ok(&a));
    assert((i > 0) && (i <= a.ndims));
    return a.dim_size[i-1];
}

void clone_reverse_base_array_spec(const base_array_t* source, base_array_t* dest)
{
    int i;
    assert(base_array_ok(source));

    dest->ndims = source->ndims;
    dest->dim_size = size_alloc(dest->ndims);
    assert(dest->dim_size);

    for(i = 0; i < dest->ndims; ++i) {
        dest->dim_size[i] = source->dim_size[dest->ndims - 1 - i];
    }
}
