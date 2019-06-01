local libnu = {}

local ffi = require('ffi')
local nu = ffi.load('nu')

ffi.cdef([[
    typedef struct {float a, b;} nu_tuplefloat;
    typedef struct {float r, i;} nu_complex;
    void *nu_array_alloc(size_t, size_t);
    void nu_array_free(void *);
    size_t nu_array_argmax(float [], size_t);
    size_t nu_array_argmin(float [], size_t);
    float nu_array_max(float [], size_t);
    float nu_array_min(float [], size_t);
    void nu_array_add(float [], float [], float [], size_t);
    void nu_array_mul(float [], float [], float [], size_t);
    void nu_array_cadd(nu_complex [], nu_complex [], nu_complex [], size_t);
    void nu_array_cmul(nu_complex [], nu_complex [], nu_complex [], size_t);
    void nu_array_conj(nu_complex [], nu_complex [], size_t);
    void nu_array_cos(float [], float [], size_t);
    void nu_array_exp(float [], float [], size_t);
    void nu_array_log(float [], float [], size_t);
    void nu_array_sin(float [], float [], size_t);
    void nu_array_linspace(float [], float, float, size_t);
    struct nu_sum_state {
        float sp[256];
        float sn[256];
    };
    void nu_sum_init(struct nu_sum_state *);
    void nu_sum_add(struct nu_sum_state *, float);
    float nu_sum_sum(struct nu_sum_state *);
    float nu_sum(float [], size_t);
    nu_tuplefloat nu_meanvar(float [], size_t);
]])

libnu.float = 'float'
libnu.complex = 'nu_complex'

local array = {}

function array.new(ctype, n)
    local stride = ffi.sizeof(ctype)
    local ptr = nu.nu_array_alloc(n, stride)
    if ptr == nil then
        return nil
    end
    local a = ffi.cast(ctype .. ' *', ptr)
    return ffi.gc(a, nu.nu_array_free)
end

local function scalar(cfunction)
    return function(x, n)
        if x == nil then
            error('nil argument', 2)
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
