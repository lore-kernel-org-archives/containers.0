From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 6/9] cgroup_freezer: make freezer->state mask of flags
Date: Thu, 8 Nov 2012 06:38:53 -0800
Message-ID: <20121108143853.GC12973__13294.4926423535$1352385558$gmane$org@htj.dyndns.org>
References: <1351931915-1701-1-git-send-email-tj@kernel.org>
	<1351931915-1701-7-git-send-email-tj@kernel.org>
	<509B371E.9050005@jp.fujitsu.com>
	<20121108044255.GG2660@mtj.dyndns.org>
	<509B3C72.3050904@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <509B3C72.3050904-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: rjw-KKrjLPT3xs0@public.gmane.org, linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, Kamezawa.

On Thu, Nov 08, 2012 at 02:00:34PM +0900, Kamezawa Hiroyuki wrote:
> (2012/11/08 13:42), Tejun Heo wrote:
> >Hello, Kame.
> >
> >On Thu, Nov 08, 2012 at 01:37:50PM +0900, Kamezawa Hiroyuki wrote:
> >>How about
> >>enum {
> >>    __CGROUP_FREEZING,
> >>    __CGROUP_FROZEN,
> >>};
> >>
> >>#define CGROUP_FREEZER_STATE_MASK  0x3
> >>#define CGROUP_FREEZER_STATE(state)	((state) & CGROUP_FREEZER_STATE_MASK)
> >>#define CGROUP_THAW(state)	(CGROUP_FREEZER_STATE(state) == 0)
> >>#define CGROUP_FREEZING(state)	(CGROUP_FREEZER_STATE(state) == __CGROUP_FREEZING)
> >>#define CGROUP_FROZEN(state)\
> >>	(CGROUP_FREEZER_STATE(state) == (__CGROUP_FREEZING | __CGROUP_FROZEN))
> >
> >I think it's a bit overdone and we have cases where we test for
> >FREEZING regardless of FROZEN and cases where test for FREEZING &&
> >!FROZEN.  We can have, say, CGROUP_FREZING() and then
> >CGROUP_FREEZING_BUT_NOT_FROZEN(), but it feels more like obfuscation
> >than anything else.
> >
> 
> Hm, then, I'm glad if I can see what combinations of flags are valid and
> meanings of them in source code comments.

Ooh, the following comment is added by a later patch when the whole
thing is complete.

/*
 * A cgroup is freezing if any FREEZING flags are set.  FREEZING_SELF is
 * set if "FROZEN" is written to freezer.state cgroupfs file, and cleared
 * for "THAWED".  FREEZING_PARENT is set if the parent freezer is FREEZING
 * for whatever reason.  IOW, a cgroup has FREEZING_PARENT set if one of
 * its ancestors has FREEZING_SELF set.
 */

Thanks.

-- 
tejun
