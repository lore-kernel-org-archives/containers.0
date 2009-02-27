From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 1/2] cgroup allow subsys to set default mode of its own
	file
Date: Fri, 27 Feb 2009 10:42:25 +0530
Message-ID: <20090227051225.GR11421__32908.7778380655$1235711904$gmane$org@balbir.in.ibm.com>
References: <20090225163555.d2a0b24c.kamezawa.hiroyu@jp.fujitsu.com>
	<20090226130005.3282cb02.akpm@linux-foundation.org>
	<20090227092031.f42cbbbe.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090227092031.f42cbbbe.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

* KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> [2009-02-27 09:20:31]:

> On Thu, 26 Feb 2009 13:00:05 -0800
> Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:
> 
> > On Wed, 25 Feb 2009 16:35:55 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> > 
> > >  When I wrote tools for maintain cgroup, I can't find which file is
> > >  writable intarfece or not via cgroup file systems. (finally, I did
> > >  dirty approach.)
> > >  IMHO, showing "this file is read-only" in explicit way is useful
> > >  for user-land (tools). In other story, a file whose name sounds read-only
> > >  may have "trigger" operation and support reseting. In this case,
> > >  "writable" is informative.
> > 
> > Well, we have compatibility issues here.  If we make this change, and
> > people write tools which depend upon that change then those tools might
> > break when run upon older kernels.  Or they need back-compatibility
> > additions, which increases the testing burden of those tools.
> > 
> > One way in which we could improve this situation is to backport these
> > changes into earlier kernels, although I don't know which versions.
> > 
> > What do we think?
> > 
> It sounds problem to me.
> 
> Hmm..1st commit to kernel/cgroup.c is 2007-10-19, then 2.6.24 is the oldest one.
> But I think distro's tools for cgroup is not as old as...
> Hmm, backport to 2.6.25 is enough ?
> Balbir, how do you think ? I think you are familiar with libcgroup.
>

Actually this problem fixes an issue that we've seen in libcgroup,
where a file would have read permission (force_empty), but reading it
would fail, Porting back to 2.6.25 would be nice (since the memcg
merge) 

-- 
	Balbir
