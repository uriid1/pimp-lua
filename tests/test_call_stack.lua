local p = require('pimp')
  :enableType()
  :enableTableAddr()
  :enableVisibility()
  :enableCallStackLadder()

local test_1 = function(arg)
  arg = arg + 1
  local test_2 = function(arg)
    arg = arg + 1
    local test_3 = function(arg)
      arg = arg + 1
      local test_4 = function(arg)
        arg = arg + 1
        p('Stack test')
      end
      test_4(arg)
    end
    test_3(arg)
  end
  test_2(arg)
end

test_1(0)
