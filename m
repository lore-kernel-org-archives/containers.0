From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH] userns: Allow the unprivileged users to mount mqueue fs
Date: Sun, 27 Jan 2013 19:43:25 -0800
Message-ID: <87bocayntu.fsf@xmission.com>
References: <1359342541-383-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1359342541-383-1-git-send-email-gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> (Gao
	feng's message of "Mon, 28 Jan 2013 11:09:01 +0800")
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> writes:

> This patch allow the unprivileged user to mount mqueuefs in
> user ns.
>
> If two userns share the same ipcns,the files in mqueue fs
> should be seen in both these two userns.
>
> If the userns has its own ipcns,it has its own mqueue fs too.
> ipcns has already done this job well.

I am a little dense.  When does userspace actually mount a mqueuefs?
My impression was that user space never needed to mount and actually
never could mount a mqueuefs.  MS_NO_USER isn't set so mounting a
mqueuefs is possible but when does it happen and why?

I am trying to think through the logic here and I think this is safe
but since I don't understand why we would mount an mqueue fs I am
having trouble verifying that there are no silly reasons why this might
be a bad idea.

But from what I can tell so far this seems like a good patch.

Eric


> Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
>  ipc/mqueue.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/ipc/mqueue.c b/ipc/mqueue.c
> index 71a3ca1..023c986 100644
> --- a/ipc/mqueue.c
> +++ b/ipc/mqueue.c
> @@ -1383,6 +1383,7 @@ static struct file_system_type mqueue_fs_type = {
>  	.name = "mqueue",
>  	.mount = mqueue_mount,
>  	.kill_sb = kill_litter_super,
> +	.fs_flags = FS_USERNS_MOUNT,
>  };
>  
>  int mq_init_ns(struct ipc_namespace *ns)
