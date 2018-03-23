From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [REGRESSION v4.16-rc6] [PATCH] mqueue: forbid unprivileged user
	access to internal mount
Date: Fri, 23 Mar 2018 01:31:41 -0500
Message-ID: <87k1u3ti9e.fsf@xmission.com>
References: <20180323060457.sxgsd3j2obi33fyw@gordon>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20180323060457.sxgsd3j2obi33fyw@gordon> (Aleksa Sarai's message
	of "Fri, 23 Mar 2018 17:04:57 +1100")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org> writes:

> Hi all,
>
> Felix reported weird behaviour on 4.16.0-rc6 with regards to mqueue[1],
> which was introduced by 36735a6a2b5e ("mqueue: switch to on-demand
> creation of internal mount").
>
> Basically, the reproducer boils down to being able to mount mqueue if
> you create a new user namespace, even if you don't unshare the IPC
> namespace.
>
> Previously this was not possible, and you would get an -EPERM. The mount
> is the *host* mqueue mount, which is being cached and just returned from
> mqueue_mount(). To be honest, I'm not sure if this is safe or not (or if
> it was intentional -- since I'm not familiar with mqueue).
>
> To me it looks like there is a missing permission check. I've included a
> patch below that I've compile-tested, and should block the above case.
> Can someone please tell me if I'm missing something? Is this actually
> safe?

I think it may be safe by luck.  If mqueuefs had any mount options this
would allow them to be changed.  

Looking at the code there is another issue. sb->s_user_ns is getting
set to &init_user_ns instead of ns->user_ns.  That will cause other
operations to fail like mount -o remount to fail that should not.

So I think the fix needs a little more work.

Eric




>
> [1]: https://github.com/docker/docker/issues/36674
>
> --8<--------------------------------------------------------------------
>
> Fix a regression caused by 36735a6a2b5e ("mqueue: switch to on-demand
> creation of internal mount"), where an unprivileged user is permitted to
> mount mqueue even if they don't have CAP_SYS_ADMIN in the ipcns's
> associated userns. This can be reproduced as in the following.
>
>   % unshare -Urm                       # ipc isn't unshare'd
>   # mount -t mqueue mqueue /dev/mqueue # should have failed
>   # echo $?
>   0
>
> Previously the above would error out with an -EPERM, as the mount was
> protected by mount_ns(), but the patch in question switched to
> kern_mount_data() which doesn't do this necessary permission check. So
> add it explicitly to mq_internal_mount().
>
> Fixes: 36735a6a2b5e ("mqueue: switch to on-demand creation of internal mount")
> Reported-by: Felix Abecassis <fabecassis-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org>
> ---
>  ipc/mqueue.c | 6 ++++++
>  1 file changed, 6 insertions(+)
>
> diff --git a/ipc/mqueue.c b/ipc/mqueue.c
> index d7f309f74dec..ddb85091398d 100644
> --- a/ipc/mqueue.c
> +++ b/ipc/mqueue.c
> @@ -353,6 +353,12 @@ static struct vfsmount *mq_internal_mount(void)
>  {
>  	struct ipc_namespace *ns = current->nsproxy->ipc_ns;
>  	struct vfsmount *m = ns->mq_mnt;
> +	/*
> +	 * Match the semantics of mount_ns, to avoid unprivileged users from being
> +	 * able to mount mqueue from an IPC namespace they don't have ownership of.
> +	 */
> +	if (!ns_capable(ns->user_ns, CAP_SYS_ADMIN))
> +		return ERR_PTR(-EPERM);
>  	if (m)
>  		return m;
>  	m = kern_mount_data(&mqueue_fs_type, ns);
> -- 
> 2.16.2
