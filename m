From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH] user_ns: Use nsown_capable instead of capable in
	net_ctl_permissions
Date: Tue, 24 Jul 2012 09:20:06 -0500
Message-ID: <20120724142006.GA9401@sergelap>
References: <500E815D.4070605@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <500E815D.4070605-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Huang Qiang <h.huangqiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Huang Qiang (h.huangqiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org):
> From: Zhao Hongjiang <zhaohongjiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> 
> HI:

Hi,

> When I use an unprivileged user exec the following command:
> # nsexec -cUn /bin/bash
> to create a container with new user_ns and net_ns.
> 
> Then I exec "echo 4096 4096 4096 > /proc/sys/net/ipv4/tcp_mem",
> the result is Permission Denied which we hope it should be allowed.
> 
> It is because of capable(CAP_NET_ADMIN).
> 
> Even my unprivileged user have the CAP_NET_ADMIN in the new user_ns and the
> tcp_mem is belong to the new net_ns, the capable(CAP_NET_ADMIN) checking is
> that this must in the init_user_ns, so the result is the network administrator
> can't have the same access as root.
> 
> Use nsown_capable(...) the problem is solved.
> 
> PS: I changed lxc almostly like what serge done, then use an unprivileged user

Which time?  :)  FWIW the closest I came to a working patch to lxc to work
with user namespaces was
https://code.launchpad.net/~serge-hallyn/ubuntu/quantal/lxc/lxc-user-ns
but, of course, the missing ns_capable conversions prevented that from
being usable yet.

> to start a container, several Permission Denied occur(such as mount), all this
> is caused by capabale(...), when i use nsown_capable(...) the container is
> running like everything is ok.
> Is this capabale() methed is obsolete? If so, i'll send a new patch to solve
> all this problems.

The intent is to switch many of them over, but we don't want to start
handing out capabilities until we're sure the core conversion is complete.
Eric still has a large patchset which hasn't been merged upstream, which
I'd like to see before this patch or the others you are talking about.

(See
http://git.kernel.org/?p=linux/kernel/git/ebiederm/user-namespace.git;a=summary
and
http://kernel.ubuntu.com/git?p=serge/quantal-userns.git;a=summary
for patches yet to be merged)

But certainly if you want to start queueing such patches in your own
git tree to experiment with exactly what is needed for unprivileged
containers that would be very interesting.

I'll be overrun and then missing for a bit, but in 2 or 3 weeks I
may rebuild and then flesh out my own tree with new patches.  Would
be happy to look at anything you come up with in the meantime, and
work with you then.

> Signed-off-by: Zhao Hongjiang<zhaohongjiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Huang Qiang <h.huangqiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> ---
>  net/sysctl_net.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sysctl_net.c b/net/sysctl_net.c
> index c3e65ae..ee31777 100644
> --- a/net/sysctl_net.c
> +++ b/net/sysctl_net.c
> @@ -47,7 +47,7 @@ static int net_ctl_permissions(struct ctl_table_root *root,
>  			       struct ctl_table *table)
>  {
>  	/* Allow network administrator to have same access as root. */
> -	if (capable(CAP_NET_ADMIN)) {
> +	if (nsown_capable(CAP_NET_ADMIN)) {
>  		int mode = (table->mode >> 6) & 7;
>  		return (mode << 6) | (mode << 3) | mode;
>  	}
> -- 
> 1.7.1
> 
