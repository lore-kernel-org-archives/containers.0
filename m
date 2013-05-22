From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/5] cgroup: update iterators to use cgroup_next_sibling()
Date: Wed, 22 May 2013 17:09:02 +0800
Message-ID: <519C8B2E.5040606__36844.8801026263$1369214023$gmane$org@huawei.com>
References: <1369101025-28335-1-git-send-email-tj@kernel.org>
	<1369101025-28335-5-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1369101025-28335-5-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

> @@ -3068,6 +3071,11 @@ EXPORT_SYMBOL_GPL(cgroup_next_descendant_pre);
>   * Return the rightmost descendant of @pos.  If there's no descendant,
>   * @pos is returned.  This can be used during pre-order traversal to skip
>   * subtree of @pos.
> + *
> + * While this function requires RCU read locking, it doesn't require the
> + * whole traversal to be contained in a single RCU critical section.  This
> + * function will return the correct rightmost descendant as long as @pos is
> + * accessible.
>   */
>  struct cgroup *cgroup_rightmost_descendant(struct cgroup *pos)
>  {

Forgot to convert cgroup_rightmost_descendat() to use cgroup_next_sibling()?

        do {
                last = pos;
                /* ->prev isn't RCU safe, walk ->next till the end */
                pos = NULL;
                list_for_each_entry_rcu(tmp, &last->children, sibling)
                        pos = tmp;
        } while (pos);
