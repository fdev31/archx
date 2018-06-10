#!/bin/env python
import os
BLACKLIST=set(['login_manager.sh'])
print(BLACKLIST)
nums = set()
names = set()
for root, dirs, files in os.walk(os.path.curdir):
    for f in files:
        if '_' in f and f[0] != '.':
            if os.path.islink(f) or f in BLACKLIST:
                continue
            if not '/alternatives' in root:
                if f not in names:
                    names.add(f)
                else:
                    print("DUPLICATED!", f, "in", root)
            try:
                nums.add( int(f.split('_', 1)[0] ) )
            except Exception:
                print(f, "in", root)
                import traceback
                traceback.print_exc()

for num in sorted(nums):
    print(num)
