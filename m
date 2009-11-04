From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC] Mount point suggestions for cgroup
Date: Wed, 4 Nov 2009 15:40:24 +0900
Message-ID: <20091104154024.0b8f6123.kamezawa.hiroyu__20086.9180066094$1257317021$gmane$org@jp.fujitsu.com>
References: <20091104063005.GC3560@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091104063005.GC3560-SINUvgVNF2CyUtPGxGje5AC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Jan-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Bharata B Rao <bharata.rao-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, libcg-devel <libcg-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, "menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Safranek <jsafrane-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 4 Nov 2009 12:00:05 +0530
Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:

> Hi, All,
> 
> We've been having a discussion as to what would be the right place to
> mount the cgroup filesystem. Jan has been proactively looking into
> this. The FHS has no recommendation since cgroup filesystem came in
> much later.
> 
> The options are
> 
> 1. /dev/cgroup
> 2. /cgroup
> 3. Some place under /sys
> 
> The problem with (2) is that it is quite non-standard and pollutes the
> root directory. (3) requires some basic support to create a directory
> for cgroup under /sys. (1) seems the most obvious choice since cpusets
> were mounted under /dev/cpuset, but /dev is controlled by udev.
> 
> Given the three choices or any other suggestions, is there a general
> preference as to where we can mount it? The goal is to standardize
> the mount point (if possible).
> 
> BTW, the mounting is expected to be done using cgconfigparser present
> in libcgroup.
> 

IMHO, even if anywhere is ok to me, the suggestion should includes the fact
  - Each cgroup subsystem can be mounted independenty from other cgroup.
  - some cgroup (noop) can be mounted multiple times
etc...there are some points which is different from /proc or /sys.
So, we need multiple mount points.

Then, to say my own not-seriously-considered idea, I vote for
 - /cgroup/[HierarchyName]/
rather than /dev/ or /sys or /opt. This sounds straightforward.

If /sys,  /sys/cgroup/[HierarchyName] will be candidate. But considering
users can use arbitarary combination of subsystem, using /sys may require
much work, I think.

Thanks,
-Kame
