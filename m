From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH] namespace:unmount pid_namespace's proc_mnt when
	copy_net_ns failed
Date: Fri, 02 Nov 2012 00:02:57 -0700
Message-ID: <87ehkcij1a.fsf@xmission.com>
References: <1351816703-8805-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1351816703-8805-1-git-send-email-gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> (Gao
	feng's message of "Fri, 2 Nov 2012 08:38:23 +0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> writes:

> we should call pid_ns_release_proc to unmount pid_namespace's
> proc_mnt when copy_net_ns failed in function create_new_namespaces.
>
> otherwise,the proc_mnt will not be freed and because the super_block
> of proc_mnt also add the reference of the pid_namespace,so this
> pid_namespace will never be released too.

Ouch!

Have you encountered this failure in practice or is this just from
review?

I'm trying to gauge the severity of this leak.

Eric


> Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
>  kernel/nsproxy.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)
>
> diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
> index b576f7f..d536480 100644
> --- a/kernel/nsproxy.c
> +++ b/kernel/nsproxy.c
> @@ -99,8 +99,11 @@ static struct nsproxy *create_new_namespaces(unsigned long flags,
>  	return new_nsp;
>  
>  out_net:
> -	if (new_nsp->pid_ns)
> +	if (new_nsp->pid_ns) {
> +		if (flags & CLONE_NEWPID)
> +			pid_ns_release_proc(new_nsp->pid_ns);
>  		put_pid_ns(new_nsp->pid_ns);
> +	}
>  out_pid:
>  	if (new_nsp->ipc_ns)
>  		put_ipc_ns(new_nsp->ipc_ns);
