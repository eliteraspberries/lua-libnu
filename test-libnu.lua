local math = require('math')
local nu = require('libnu')

local function eq(x, y, e)
    if math.abs(x - y) < e then
        return true
    else
        return false
    end
end
assert(eq(1.0, 1.0 + 1e-6, 1e-5) == true)
assert(eq(1.0, 1.0 + 1e-5, 1e-6) == false)

local function test_array_new()
    for n = 1, 10 do
        local x = nu.array.new(nu.float, 2 ^ n)
        assert(x ~= nil)
    end
end

local function test_array_maxmin()
    local n = 10
    local x = nu.array.new(nu.float, n)
    for i = 1, n do
        x[i - 1] = i
    end
    for _, f in pairs({'argmax', 'argmin', 'max', 'min'}) do
        local ok, error = pcall(nu.array[f], nil, 0)
        assert(ok == false, error)
    end
    assert(x[nu.array.argmax(x, n)] == nu.array.max(x, n))
    assert(x[nu.array.argmin(x, n)] == nu.array.min(x, n))
    assert(nu.array.max(x, n) == n)
    assert(nu.array.min(x, n) == 1)
end

local function test_array_add()
    local n = 10
    local x = nu.array.new(nu.float, n)
    local y = nu.array.new(nu.float, n)
    local z = nu.array.new(nu.float, n)
    for i = 1, n do
        x[i - 1] = i
        y[i - 1] = n - i
    end
    local ok, error = pcall(nu.array.add, nil, nil, nil, 0)
    assert(ok == false, error)
    nu.array.add(z, x, y, n)
    for i = 1, n do
        assert(z[i - 1] == n)
    end
end

local function test_array_linspace()
    local n = 10
    local x = nu.array.new(nu.float, n)
    local y = nu.array.new(nu.float, n)
    local ok, error = pcall(nu.array.linspace, nil, 0, 0, 0)
    assert(ok == false, error)
    nu.array.linspace(x, 0.0, 1.0, n)
    nu.array.linspace(y, 1.0, 0.0, n)
    for i = 0, n - 1 do
        assert(eq(x[i] + y[i], 1.0, 1e-6))
    end
end

local function test_sum_sum()
    local n = 10
    local x = nu.array.new(nu.float, n)
    for i = 1, n do
        x[i - 1] = i
    end
    local ok, error = pcall(nu.sum.sum, nil, 0)
    assert(ok == false, error)
    assert(nu.sum.sum(x, n) == n * (n + 1) / 2)
end

local function test_sum_meanvar()
    local n = 10
    local x = nu.array.new(nu.float, n)
    for i = 1, n do
        x[i - 1] = i % 2
    end
    local ok, error = pcall(nu.sum.meanvar, nil, 0)
    assert(ok == false, error)
    local mean, var = nu.sum.meanvar(x, n)
    assert(mean == 0.5)
    assert(var == 0.25)
end

local function test_diff()
    local n = 10
    local h = 1.0 / n
    local x = nu.array.new(nu.float, n)
    local y = nu.array.new(nu.float, n)
    nu.array.linspace(x, 0.0, 1.0, n)
    nu.diff.diff(h, nu.diff.kmax, y, x, n)
    for i = 0, n - 1 do
        assert(eq(y[i], 1.0, 1e-5))
    end
end

test_array_new()
test_array_maxmin()
test_array_add()
test_array_linspace()
test_sum_sum()
test_sum_meanvar()
test_diff()
