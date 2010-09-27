From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH 0/3][V2] remove the ns_cgroup
Date: Mon, 27 Sep 2010 12:57:41 -0700
Message-ID: <20100927125741.0df22f09.akpm@linux-foundation.org>
References: <1285582453-6127-1-git-send-email-daniel.lezcano@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1285582453-6127-1-git-send-email-daniel.lezcano-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 27 Sep 2010 12:14:10 +0200
Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org> wrote:

> The ns_cgroup is a control group interacting with the namespaces.
> When a new namespace is created, a corresponding cgroup is 
> automatically created too. The cgroup name is the pid of the process
> who did 'unshare' or the child of 'clone'.
> 
> This cgroup is tied with the namespace because it prevents a
> process to escape the control group and use the post_clone callback,
> so the child cgroup inherits the values of the parent cgroup.
> 
> Unfortunately, the more we use this cgroup and the more we are facing
> problems with it:
> 
>  (1) when a process unshares, the cgroup name may conflict with a previous
>  cgroup with the same pid, so unshare or clone return -EEXIST
> 
>  (2) the cgroup creation is out of control because there may have an
>  application creating several namespaces where the system will automatically
>  create several cgroups in his back and let them on the cgroupfs (eg. a vrf
>  based on the network namespace).
> 
>  (3) the mix of (1) and (2) force an administrator to regularly check and
>  clean these cgroups.
> 
> This patchset removes the ns_cgroup by adding a new flag to the cgroup
> and the cgroupfs mount option. It enables the copy of the parent cgroup
> when a child cgroup is created. We can then safely remove the ns_cgroup as
> this flag brings a compatibility. We have now to manually create and add the
> task to a cgroup, which is consistent with the cgroup framework.

So this is a non-backward-compatible userspace-visible change?

What are the implications of this?
