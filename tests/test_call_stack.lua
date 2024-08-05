local p = require('pimp')
  :enableType()
  :enableTableAddr()
  :enableVisibility()
  :enableCallStackLadder()

local test_1 = function(arg1)
  local test_2 = function(arg2)
    local test_3 = function(arg3)
      local test_4 = function(arg4
        )
        p('Stack test')
      end
      test_4()
    end
    test_3()
  end
  test_2()
end

