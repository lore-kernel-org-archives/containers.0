From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v3 3/3] cgroup: implement cgroup.populated for the default
	hierarchy
Date: Thu, 17 Apr 2014 09:23:08 +0800
Message-ID: <534F2CFC.9040706@huawei.com>
References: <1397511846-2904-1-git-send-email-tj@kernel.org>
	<1397511846-2904-4-git-send-email-tj@kernel.org>
	<20140416145047.GC1257@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140416145047.GC1257-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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
Cc: rlove-L7G0xEPcOZbYtjvyW6yDsg@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, kay-tD+1rO4QERM@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org, eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, john-jueV0HHMeujJJrXXpGQQMAC/G2K4zDHf@public.gmane.org
List-Id: containers.vger.kernel.org

> cgroup users often need a way to determine when a cgroup's
> subhierarchy becomes empty so that it can be cleaned up.  cgroup
> currently provides release_agent for it; unfortunately, this mechanism
> is riddled with issues.
> 
> * It delivers events by forking and execing a userland binary
>   specified as the release_agent.  This is a long deprecated method of
>   notification delivery.  It's extremely heavy, slow and cumbersome to
>   integrate with larger infrastructure.
> 
> * There is single monitoring point at the root.  There's no way to
>   delegate management of a subtree.
> 
> * The event isn't recursive.  It triggers when a cgroup doesn't have
>   any tasks or child cgroups.  Events for internal nodes trigger only
>   after all children are removed.  This again makes it impossible to
>   delegate management of a subtree.
> 
> * Events are filtered from the kernel side.  "notify_on_release" file
>   is used to subscribe to or suppress release event.  This is
>   unnecessarily complicated and probably done this way because event
>   delivery itself was expensive.
> 
> This patch implements interface file "cgroup.populated" which can be
> used to monitor whether the cgroup's subhierarchy has tasks in it or
> not.  Its value is 0 if there is no task in the cgroup and its
> descendants; otherwise, 1, and kernfs_notify() notificaiton is
> triggers when the value changes, which can be monitored through poll
> and [di]notify.
> 
> This is a lot ligther and simpler and trivially allows delegating
> management of subhierarchy - subhierarchy monitoring can block further
> propgation simply by putting itself or another process in the root of
> the subhierarchy and monitor events that it's interested in from there
> without interfering with monitoring higher in the tree.
> 
> v2: Patch description updated as per Serge.
> 
> v3: "cgroup.subtree_populated" renamed to "cgroup.populated".  The
>     subtree_ prefix was a bit confusing because
>     "cgroup.subtree_control" uses it to denote the tree rooted at the
>     cgroup sans the cgroup itself while the populated state includes
>     the cgroup itself.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Acked-by: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
> Cc: Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>

Acked-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
