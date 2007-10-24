From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH] memory cgroup enhancements updated [8/10] add
 pre_destroy handler
Date: Wed, 24 Oct 2007 20:19:34 +0530
Message-ID: <471F5B7E.2020007@linux.vnet.ibm.com>
References: <20071019182436.485e20cd.kamezawa.hiroyu@jp.fujitsu.com>
	<20071019183544.0f5172b2.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071019183544.0f5172b2.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
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
Cc: "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org" <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

KAMEZAWA Hiroyuki wrote:
> My main purpose of this patch is for memory controller..
> 
> This patch adds a handler "pre_destroy" to cgroup_subsys.
> It is called before cgroup_rmdir() checks all subsys's refcnt.
> 
> I think this is useful for subsyses which have some extra refs
> even if there are no tasks in cgroup.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
> 
>  include/linux/cgroup.h |    1 +
>  kernel/cgroup.c        |    7 +++++++
>  2 files changed, 8 insertions(+)
> 
> Index: devel-2.6.23-mm1/include/linux/cgroup.h
> ===================================================================
> --- devel-2.6.23-mm1.orig/include/linux/cgroup.h
> +++ devel-2.6.23-mm1/include/linux/cgroup.h
> @@ -233,6 +233,7 @@ int cgroup_is_descendant(const struct cg
>  struct cgroup_subsys {
>  	struct cgroup_subsys_state *(*create)(struct cgroup_subsys *ss,
>  						  struct cgroup *cont);
> +	void (*pre_destroy)(struct cgroup_subsys *ss, struct cgroup *cont);
>  	void (*destroy)(struct cgroup_subsys *ss, struct cgroup *cont);
>  	int (*can_attach)(struct cgroup_subsys *ss,
>  			  struct cgroup *cont, struct task_struct *tsk);
> Index: devel-2.6.23-mm1/kernel/cgroup.c
> ===================================================================
> --- devel-2.6.23-mm1.orig/kernel/cgroup.c
> +++ devel-2.6.23-mm1/kernel/cgroup.c
> @@ -2158,6 +2158,13 @@ static int cgroup_rmdir(struct inode *un
>  	parent = cont->parent;
>  	root = cont->root;
>  	sb = root->sb;
> +	/*
> +	 * Notify subsyses that rmdir() request comes.
> +	 */
> +	for_each_subsys(root, ss) {
> +		if ((cont->subsys[ss->subsys_id]) && ss->pre_destroy)
> +			ss->pre_destroy(ss, cont);
> +	}
> 

Is pre_destroy really required? Can't we do what we do here in destroy?

>  	if (cgroup_has_css_refs(cont)) {
>  		mutex_unlock(&cgroup_mutex);
> 


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
