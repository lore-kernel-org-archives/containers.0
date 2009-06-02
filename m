From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] cgroups: forbid noprefix if mounting more than just cpuset
	subsystem
Date: Tue, 02 Jun 2009 14:43:39 +0800
Message-ID: <4A24CA1B.5020604@cn.fujitsu.com>
References: <4A24911F.4070601@cn.fujitsu.com>
	<20090601230251.57411c83.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090601230251.57411c83.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

>> +	/* We allow noprefix only if mounting just the cpuset subsystem */
>> +	if (test_bit(ROOT_NOPREFIX, &opts->flags) &&
>> +	    (opts->subsys_bits & mask))
>> +		return -EINVAL;
>> +
> 
> uh, OK.  I hope that comment is clear enough for anyone who wants to
> understand it.   It doesn't explain _why_ this is done..
> 

I agree more explanation is better..

====

From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH] cgroups: forbid noprefix if mounting more than just cpuset subsystem, fix2

Explain more on the noprefix option.

Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/cgroup.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index ad17f9d..d15432c 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -891,7 +891,11 @@ static int parse_cgroupfs_options(char *data,
 		}
 	}
 
-	/* We allow noprefix only if mounting just the cpuset subsystem */
+	/*
+	 * Option noprefix was introduced just for backward compatibility
+	 * with the old cpuset, so we allow noprefix only if mounting just
+	 * the cpuset subsystem.
+	 */
 	if (test_bit(ROOT_NOPREFIX, &opts->flags) &&
 	    (opts->subsys_bits & mask))
 		return -EINVAL;
-- 
1.5.4.rc3
