From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/2] cgroup allow subsys to set default mode of its own
	file
Date: Thu, 26 Feb 2009 16:28:11 -0800
Message-ID: <6599ad830902261628k4ce8e1aflb7981672562801fb__14665.7388694168$1235694784$gmane$org@mail.gmail.com>
References: <20090225163555.d2a0b24c.kamezawa.hiroyu@jp.fujitsu.com>
	<20090226130005.3282cb02.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090226130005.3282cb02.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Feb 26, 2009 at 1:00 PM, Andrew Morton
<akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:
> On Wed, 25 Feb 2009 16:35:55 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
>
>>  When I wrote tools for maintain cgroup, I can't find which file is
>>  writable intarfece or not via cgroup file systems. (finally, I did
>>  dirty approach.)
>>  IMHO, showing "this file is read-only" in explicit way is useful
>>  for user-land (tools). In other story, a file whose name sounds read-only
>>  may have "trigger" operation and support reseting. In this case,
>>  "writable" is informative.
>
> Well, we have compatibility issues here.  If we make this change, and
> people write tools which depend upon that change then those tools might
> break when run upon older kernels.

I don't think that's too big a deal - a write can always fail at the
whim of a cgroups subsystem, so this would just be a hint to a tool
that it shouldn't even bother trying to write to the file. It should
be able to handle a failure.

But I don't see why we can't figure out the mode automatically based
on whether or not there's a write handler defined for the control
file.

Paul
