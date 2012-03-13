From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] cgroup: removing css reference drain wait during cgroup
	removal
Date: Tue, 13 Mar 2012 14:45:26 -0700
Message-ID: <20120313214526.GG19584__41112.8716812984$1331675186$gmane$org@count0.beaverton.ibm.com>
References: <20120312213155.GE23255@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120312213155.GE23255-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
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
Cc: linux-mm-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Mar 12, 2012 at 02:31:55PM -0700, Tejun Heo wrote:
> Hello, guys.
> 
> While working on blkcg, I learned that cgroup removal path tries to
> drain all internal references synchronously before proceeding with
> removal, and may be aborted by by pre_destroy() failing.
> 
> I find both quite unusual.  While there are some occassions where we
> try to drain reference counts synchronously, the norm is deactivating
> the target and then releasing it when the reference count hits zero
> and exposing this synchronous behavior directly to userland makes it
> worse.  This also requires allowing rmdir to be aborted from userland.
> 
> pre_destroy() being allowed to veto rmdir might be okay if there's
> only one subsystem using it or it implemented proper
> prepare-commit/cancel transaction, but as it currently stands,
> pre_destroy() operations are not reversible and even within memcg
> itself the state wouldn't be consistent after failure (some moved to
> parent while the rest on child).  Note that abort from userland also
> has the same problem.
> 
> It also complicates and adds even more subtleties to cgroup code.  A
> lot of it was just me being dumb but making sense of
> cgroup_exclude_rmdir() and cgroup_release_and_wakeup_rmdir() usages in
> memcontrol took me quite some time even with Hugh's help.
> 
> In general, IMHO, it's a bad idea to expose purely internal
> implementation details to userland directly.  Internal ref counts can
> be kept around for whatever reason (e.g. blkcg does it for lookup
> caching), such details shouldn't be visible to userland.  Midlayers
> like cgroup which sit between userland and mechanism implementations
> should provide isolation between the two so that each mechanism
> implementation doesn't have to worry about things like that.
> 
> It seems cgroup is going through a lot of the same growing pains that
> sysfs went through years ago and would probably benefit from using
> sysfs for userland interfacing rather than trying to replicate
> features that sysfs already provides.  Well, that's another long term
> thing, I guess.  For now, I'd like to make cgroup rmdir path more
> conventional so that rmdir behaves like the following.

If you want to spend your time doing archaeology there are some old threads
that touch on this idea (roughly around 2003-2005). One point against the
idea that I distinctly recall:

Somewhat like configfs, object lifetimes in cgroups are determined
primarily by the user whereas sysfs object lifetimes are primarily
determined by the kernel. I think the closest we come to user-determined
objects in sysfs occur through debugfs, and module loading/unloading.
However those involve mount/umount and modprobe/rmmod rather than
mkdir/rmdir to create and remove the objects.

Cheers,
	-Matt Helsley
