From: Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 2/8] cgroup: kill CSS_REMOVED
Date: Fri, 02 Nov 2012 19:02:56 +0900
Message-ID: <50939A50.9060704__22315.636292524$1351850613$gmane$org@jp.fujitsu.com>
References: <1351712650-23709-1-git-send-email-tj@kernel.org>
	<1351712650-23709-3-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1351712650-23709-3-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

(2012/11/01 4:44), Tejun Heo wrote:
> CSS_REMOVED is one of the several contortions which were necessary to
> support css reference draining on cgroup removal.  All css->refcnts
> which need draining should be deactivated and verified to equal zero
> atomically w.r.t. css_tryget().  If any one isn't zero, all refcnts
> needed to be re-activated and css_tryget() shouldn't fail in the
> process.
> 
> This was achieved by letting css_tryget() busy-loop until either the
> refcnt is reactivated (failed removal attempt) or CSS_REMOVED is set
> (committing to removal).
> 
> Now that css refcnt draining is no longer used, there's no need for
> atomic rollback mechanism.  css_tryget() simply can look at the
> reference count and fail if it's deactivated - it's never getting
> re-activated.
> 
> This patch removes CSS_REMOVED and updates __css_tryget() to fail if
> the refcnt is deactivated.  As deactivation and removal are a single
> step now, they no longer need to be protected against css_tryget()
> happening from irq context.  Remove local_irq_disable/enable() from
> cgroup_rmdir().
> 
> Note that this removes css_is_removed() whose only user is VM_BUG_ON()
> in memcontrol.c.  We can replace it with a check on the refcnt but
> given that the only use case is a debug assert, I think it's better to
> simply unexport it.
> 
> v2: Comment updated and explanation on local_irq_disable/enable()
>      added per Michal Hocko.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Reviewed-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
> Cc: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
> Cc: Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>

Thank you.
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
