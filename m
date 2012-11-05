From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/8] cgroup: kill
	cgroup_subsys->__DEPRECATED_clear_css_refs
Date: Mon, 5 Nov 2012 13:34:27 +0800
Message-ID: <50974FE3.60102__32236.7718130865$1352093773$gmane$org@huawei.com>
References: <1351712650-23709-1-git-send-email-tj@kernel.org>
	<1351712650-23709-2-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1351712650-23709-2-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

On 2012/11/1 3:44, Tejun Heo wrote:
> 2ef37d3fe4 ("memcg: Simplify mem_cgroup_force_empty_list error
> handling") removed the last user of __DEPRECATED_clear_css_refs.  This
> patch removes __DEPRECATED_clear_css_refs and mechanisms to support
> it.
> 
> * Conditionals dependent on __DEPRECATED_clear_css_refs removed.
> 
> * cgroup_clear_css_refs() can no longer fail.  All that needs to be
>   done are deactivating refcnts, setting CSS_REMOVED and putting the
>   base reference on each css.  Remove cgroup_clear_css_refs() and the
>   failure path, and open-code the loops into cgroup_rmdir().
> 
> This patch keeps the two for_each_subsys() loops separate while open
> coding them.  They can be merged now but there are scheduled changes
> which need them to be separate, so keep them separate to reduce the
> amount of churn.
> 
> local_irq_save/restore() from cgroup_clear_css_refs() are replaced
> with local_irq_disable/enable() for simplicity.  This is safe as
> cgroup_rmdir() is always called with IRQ enabled.  Note that this IRQ
> switching is necessary to make CSS deactivation and CSS_REMOVED
> assertion atomic against css_tryget() and will be removed by future
> changes.
> 
> v2: cgroup_call_pre_destroy() removal dropped per Michal.  Commit
>     message updated to explain local_irq_disable/enable() conversion.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Reviewed-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>

Acked-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
