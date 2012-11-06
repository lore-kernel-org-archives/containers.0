From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 3/9] cgroup: implement generic child / descendant walk
	macros
Date: Tue, 6 Nov 2012 12:31:54 -0800
Message-ID: <20121106203154.GV30069__23369.2652000629$1352233934$gmane$org@mtj.dyndns.org>
References: <1351931915-1701-1-git-send-email-tj@kernel.org>
	<1351931915-1701-4-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1351931915-1701-4-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Sat, Nov 03, 2012 at 01:38:29AM -0700, Tejun Heo wrote:
> Currently, cgroup doesn't provide any generic helper for walking a
> given cgroup's children or descendants.  This patch adds the following
> three macros.
> 
> * cgroup_for_each_child() - walk immediate children of a cgroup.
> 
> * cgroup_for_each_descendant_pre() - visit all descendants of a cgroup
>   in pre-order tree traversal.
> 
> * cgroup_for_each_descendant_post() - visit all descendants of a
>   cgroup in post-order tree traversal.
> 
> All three only require the user to hold RCU read lock during
> traversal.  Verifying that each iterated cgroup is online is the
> responsibility of the user.  When used with proper synchronization,
> cgroup_for_each_descendant_pre() can be used to propagate config
> updates to descendants in reliable way.  See comments for details.

Michal, Li, how does this look to you?  Would this be okay for memcg
too?  Li, do you think the comment on cgroup_for_each_descendant_pre()
is correct?

Thanks.

-- 
tejun
