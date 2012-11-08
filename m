From: Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 8/9] cgroup_freezer: add ->post_create() and
	->pre_destroy() and track online state
Date: Thu, 08 Nov 2012 13:48:25 +0900
Message-ID: <509B3999.6060505__1155.50035047836$1352350143$gmane$org@jp.fujitsu.com>
References: <1351931915-1701-1-git-send-email-tj@kernel.org>
	<1351931915-1701-9-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1351931915-1701-9-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: rjw-KKrjLPT3xs0@public.gmane.org, linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

(2012/11/03 17:38), Tejun Heo wrote:
> A cgroup is online and visible to iteration between ->post_create()
> and ->pre_destroy().  This patch introduces CGROUP_FREEZER_ONLINE and
> toggles it from the newly added freezer_post_create() and
> freezer_pre_destroy() while holding freezer->lock such that a
> cgroup_freezer can be reilably distinguished to be online.  This will
> be used by full hierarchy support.
> 
> ONLINE test is added to freezer_apply_state() but it currently doesn't
> make any difference as freezer_write() can only be called for an
> online cgroup.
> 
> Adjusting system_freezing_cnt on destruction is moved from
> freezer_destroy() to the new freezer_pre_destroy() for consistency.
> 
> This patch doesn't introduce any noticeable behavior change.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> ---
>   kernel/cgroup_freezer.c | 42 ++++++++++++++++++++++++++++++++++++++++--
>   1 file changed, 40 insertions(+), 2 deletions(-)
> 
> diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
> index b8ad93c..4f12d31 100644
> --- a/kernel/cgroup_freezer.c
> +++ b/kernel/cgroup_freezer.c
> @@ -23,6 +23,7 @@
>   #include <linux/seq_file.h>
>   
>   enum freezer_state_flags {
> +	CGROUP_FREEZER_ONLINE	= (1 << 0), /* freezer is fully online */

Could you explain what 'online' means here again, rather than changelog ?
BTW, 'online' is a shared concept, between post_create() and pre_destroy(), among
developpers ? Is it new ?

Anyway, the patch itself is simple.

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
