local libnu = {}

local ffi = require('ffi')
local nu = ffi.load('nu')

ffi.cdef([[
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

function array.argmax(x, n)
    return nu.nu_array_argmax(x, n)
end

function array.argmin(x, n)
    return nu.nu_array_argmin(x, n)
end

function array.max(x, n)
    return nu.nu_array_max(x, n)
end

function array.min(x, n)
    return nu.nu_array_min(x, n)
end

local function binary(cfunction)
    return function(z, x, y, n)
        cfunction(z, x, y, n)
    end
end

local function unary(cfunction)
    return function(z, x, n)
        cfunction(z, x, n)
    end
end

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
    nu.nu_array_linspace(x, start, stop, n)
end

libnu.array = array
return libnu
