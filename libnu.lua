-- Copyright 2019, Mansour Moufid <mansourmoufid@gmail.com>

local libnu = {}

local ffi = require('ffi')
local nu = ffi.load('nu')

ffi.cdef([[
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

]])

libnu.float = 'float'
libnu.complex = 'nu_complex'

local array = {}

function array.alloc(ctype, n)
    return nu.nu_array_alloc(n, ffi.sizeof(ctype))
end

function array.gc(x)
    return ffi.gc(x, nu.nu_array_free)
end

function array.new(ctype, n)
    local ptr = array.alloc(ctype, n)
    if ptr == nil then
        return nil
    end
    local a = ffi.cast(ctype .. ' *', ptr)
    return array.gc(a)
end

local function scalar(cfunction)
    return function(x, n)
        if x == nil then
            error('nil argument', 2)
        end
        if n == 0 then
            error('zero size argument', 2)
        end
        return tonumber(cfunction(x, n))
    end
end

local function binary(cfunction)
    return function(z, x, y, n)
        if z == nil or x == nil or y == nil then
            error('nil argument', 2)
        end
        cfunction(z, x, y, n)
    end
end

local function unary(cfunction)
    return function(z, x, n)
        if z == nil or x == nil then
            error('nil argument', 2)
        end
        cfunction(z, x, n)
    end
end

local function tuple(cfunction)
    return function(x, n)
        if x == nil then
            error('nil argument', 2)
        end
        local z = cfunction(x, n)
        local a = z.a
        local b = z.b
        return tonumber(a), tonumber(b)
    end
end

array.argmax = scalar(nu.nu_array_argmax)

array.argmin = scalar(nu.nu_array_argmin)

array.max = scalar(nu.nu_array_max)

array.min = scalar(nu.nu_array_min)

array.add = binary(nu.nu_array_add)

array.mul = binary(nu.nu_array_mul)

array.cadd = binary(nu.nu_array_cadd)

array.cmul = binary(nu.nu_array_cmul)

array.conj = unary(nu.nu_array_conj)

array.cos = unary(nu.nu_array_cos)

array.exp = unary(nu.nu_array_exp)

array.log = unary(nu.nu_array_log)

array.sin = unary(nu.nu_array_sin)

function array.linspace(x, start, stop, n)
    if x == nil then
        error('nil argument', 2)
    end
    nu.nu_array_linspace(x, start, stop, n)
end

local sum = {}

sum.sum = scalar(nu.nu_sum)

sum.meanvar = tuple(nu.nu_meanvar)

libnu.array = array
libnu.sum = sum
return libnu
