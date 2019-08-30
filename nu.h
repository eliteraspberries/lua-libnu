/* Copyright 2018, 2019, Mansour Moufid <mansourmoufid@gmail.com> */

#ifndef NU_H
#define NU_H

#include <stddef.h>
#include <stdint.h>

typedef struct {uint32_t a, b;} nu_tuple32;
typedef struct {float a, b;} nu_tuplefloat;
typedef struct {float r, i;} nu_complex;

float nu_cos(float);
float nu_exp(float);
float nu_log(float);
float nu_sin(float);

void *nu_array_alloc(size_t, size_t);
void nu_array_free(void *);
size_t nu_array_argmax(const float [], size_t);
size_t nu_array_argmin(const float [], size_t);
float nu_array_max(const float [], size_t);
float nu_array_min(const float [], size_t);
void nu_array_add(float [], const float [], const float [], size_t);
void nu_array_mul(float [], const float [], const float [], size_t);
void nu_array_cadd(
    nu_complex [],
    const nu_complex [],
    const nu_complex [],
    size_t
);
void nu_array_cmul(
    nu_complex [],
    const nu_complex [],
    const nu_complex [],
    size_t
);
void nu_array_conj(nu_complex [], const nu_complex [], size_t);
void nu_array_cos(float [], const float [], size_t);
void nu_array_exp(float [], const float [], size_t);
void nu_array_log(float [], const float [], size_t);
void nu_array_sin(float [], const float [], size_t);
void nu_array_linspace(float [], float, float, size_t);

int nu_clock_tick(uint64_t *);
int nu_clock_tock(uint64_t *);

struct nu_random_state {
    uint64_t s0;
    uint64_t s1;
    uint64_t s2;
    uint64_t s3;
};
void nu_random_seed256(struct nu_random_state *, const uint64_t [4]);
void nu_random_seed(struct nu_random_state *, uint64_t);
void nu_random_jump(struct nu_random_state *);
uint64_t nu_random(struct nu_random_state *);
float nu_random_float(struct nu_random_state *);
float nu_random_gauss(struct nu_random_state *);
void nu_random_array(struct nu_random_state *, uint64_t [], size_t);
void nu_random_array_float(struct nu_random_state *, float [], size_t);
void nu_random_array_gauss(struct nu_random_state *, float [], size_t);

struct nu_sum_state {
    float sp[256];
    float sn[256];
};
void nu_sum_init(struct nu_sum_state *);
void nu_sum_add(struct nu_sum_state *, float);
float nu_sum_sum(struct nu_sum_state *);
float nu_sum(const float [], size_t);
float nu_dot(const float [], const float [], size_t);
float nu_sumsqr(const float [], size_t);
nu_tuplefloat nu_meanvar(const float [], size_t);

extern const size_t nu_diff_kmax;
void nu_diff(float, size_t, float [], const float [], size_t);

#endif
