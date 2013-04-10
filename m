From: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
Subject: Re: [PATCHSET] perf, cgroup: implement hierarchy support for
	perf_event controller
Date: Wed, 10 Apr 2013 09:32:26 +0200
Message-ID: <1365579146.30071.24.camel__10397.2932826311$1365581015$gmane$org@laptop>
References: <1365474213-13354-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1365474213-13354-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: namhyung.kim-Hm3cg6mZ9cc@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eranian-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org, acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, 2013-04-08 at 19:23 -0700, Tejun Heo wrote:
> perf_event cgroup controller is one of the remaining few with broken
> hierarchy support.  It turns out it's pretty easy to implement - the
> only thing necessary is making perf_cgroup_match() return %true also
> when the cgroup of the current task is a descendant of the event's
> cgroup.  This patchset implements cgroup_is_descendant() and uses it
> to implement hierarchy support in perf_event controller.
> 
> This patchset contains the following three patches.
> 
>  0001-cgroup-make-sure-parent-won-t-be-destroyed-before-it.patch
>  0002-cgroup-implement-cgroup_is_descendant.patch
>  0003-perf-make-perf_event-cgroup-hierarchical.patch

Thanks, looks simple and straight fwd. 

> Ingo, how should these be routed?
> 
>  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git perf_event-hierarchy-support

Ingo typically likes multi-maintainer sets to be pulled from a common
tree into all relevant maintainer trees so that git merges afterwards
just-work (tm). But I'll let him expand.
