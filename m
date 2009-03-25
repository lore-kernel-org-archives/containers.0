From: anqin <anqin.qin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Can not remove the subdirectory in cgroup pseudo-filesystem
Date: Thu, 26 Mar 2009 00:24:16 +0800
Message-ID: <d95d44a20903250924p2fb28afdq7ac47cac372c7de3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Dear all,

I have met a straight problem in my recent operation.
Previously, I can do the following operations:

# mount -t cgroup cgroup /mnt/cgrp
# cd /mnt/cgrp
# mkdir test
# echo $$ > test/tasks
# rm  -rf test

but now I met the straight permission with the same
operation while I am root:

# mount -t cgroup cgroup /mnt/cgrp
# cd /mnt/cgrp
# mkdir test
# echo $$ > test/tasks
-bash: echo: write error: No space left on device
# rm  -rf test
rm: cannot remove `/mnt/cgrp/test/cpuset.memory_spread_slab':
Operation not permitted
rm: cannot remove `/mnt/cgrp/test/cpuset.memory_spread_page':
Operation not permitted
rm: cannot remove `/mnt/cgrp/test/cpuset.memory_pressure': Operation
not permitted
...

I guess maybe the permission attributes block my operation, but I
checked with lsattr
and got the following message:

# lsattr /mnt/cgrp/test
lsattr: Inappropriate ioctl for device While reading flags on
/mnt/cgrp/test/cpuset.memory_spread_slab
lsattr: Inappropriate ioctl for device While reading flags on
/mnt/cgrp/test/cpuset.memory_spread_page
lsattr: Inappropriate ioctl for device While reading flags on
/mnt/cgrp/test/cpuset.memory_pressure
...

I have no idea how to fix it. Any help?

Thank you very much,

Anqin
