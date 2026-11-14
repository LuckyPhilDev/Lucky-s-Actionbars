local script = arg[0]:gsub("\\", "/")
local root = script:match("^(.*)/tests/[^/]+$") .. "/"

LuckyActionbars = {}
dofile(root .. "src/features/RowDirection.lua")
local RowLengths = LuckyActionbars.RowDirection.RowLengths

local function check(expected, count, rows, first)
    local got = table.concat(RowLengths(count, rows, first), ",")
    assert(got == expected, ("%s icons over %s rows, first %s: wanted %s, got %s"):format(count, rows, tostring(first), expected, got))
end

check("6,4", 10, 2, 6)
check("6,3,3", 12, 3, 6)
check("6,6", 12, 2, nil)
check("4,4,2", 10, 3, nil)
check("10", 10, 1, 4)
check("6,6", 12, 2, 12)
print("RowDirection tests passed")
