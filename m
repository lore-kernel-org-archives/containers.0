From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] Mount point suggestions for cgroup
Date: Wed, 4 Nov 2009 10:11:42 -0600
Message-ID: <20091104161142.GA8825__38923.4541486532$1257351552$gmane$org@us.ibm.com>
References: <20091104063005.GC3560@balbir.in.ibm.com>
	<20091104154024.0b8f6123.kamezawa.hiroyu@jp.fujitsu.com>
	<20091104081618.GD3560@balbir.in.ibm.com>
	<1257348117.31972.4360.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1257348117.31972.4360.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Bharata B Rao <bharata.rao-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, libcg-devel <libcg-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, "menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Jan Safranek <jsafrane-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Dave Hansen (dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> On Wed, 2009-11-04 at 13:46 +0530, Balbir Singh wrote:
> > The reason I liked /dev/cgroup was because cpusets could be
> > mounted at /dev/cpuset or /dev/cgroup/cpuset. My concern with /cgroup
> > is that a ls "/" now becomes larger in size. But I'll take your vote
> > for it as +1 for /cgroup.
> 
> /dev/pts is a decent precedent for doing it under /dev, although it does
> deal with actual devices.  cgroups do not.

Hmm, on whose behalf are you making this decision?

LSB people will want to avoid using /cgroup, but I think a lot of
admins will likely prefer /cgroup (as I do).  On my systems I
always use /cgroup, but would be more likely to use /mnt/cgroup
over /dev/cgroup.

lxc (at lxc.sf.net) rightfully takes the cgroupfs from wherever it
happens to be mounted.  Do you really need a mountpoint decided?

If you do, then while I DETEST the extra typing, I think
/sys/kernel/cgroup makes most sense, since that's where you find
debugfs and securityfs.

-serge
