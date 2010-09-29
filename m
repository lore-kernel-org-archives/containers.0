From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 4/6] [RFC] Split do_linkat() out of sys_linkat
Date: Wed, 29 Sep 2010 16:28:49 -0400
Message-ID: <4CA3A181.7070704@cs.columbia.edu>
References: <1285278812-16972-1-git-send-email-matthltc@us.ibm.com>
	<6987185123220ec2034677299859c5a63eaf2aed.1285278339.git.matthltc@us.ibm.com>
	<d91e3660266d3a2956c4d1aebc9cb618081b21ef.1285278339.git.matthltc@us.ibm.com>
	<59e9d9fe9db11c6e06ef314541b1112f2b720a59.1285278339.git.matthltc@us.ibm.com>
	<9eade1f1ec10c23dae296feda8af9fe87085e843.1285278339.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <9eade1f1ec10c23dae296feda8af9fe87085e843.1285278339.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Jamie Lokier <jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>, Amir Goldstein <amir73il-iA+eEnwkJgzk1uMJSBkQmQ@public.gmane.org>, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org



Reviewed-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
(but see nit below)

On 09/23/2010 05:53 PM, Matt Helsley wrote:
> Separate the __user pathname handling from the bulk of the syscall.
> Since we're doing this to enable relinking of unlinked files by
> sys_checkpoint and not sys_linkat we're not using a sys-wrapper.
>
> Signed-off-by: Matt Helsley<matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> Cc: Oren Laadan<orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> Cc: Amir Goldstein<amir73il-iA+eEnwkJgzk1uMJSBkQmQ@public.gmane.org>
> Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: Al Viro<viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
> Cc: Christoph Hellwig<hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
> Cc: Jamie Lokier<jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>

...

>   /*
>    * Hardlinks are often used in delicate situations.  We avoid
>    * security-related surprises by not following symlinks on the
> @@ -2468,11 +2513,10 @@ int vfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *new_de
>   SYSCALL_DEFINE5(linkat, int, olddfd, const char __user *, oldname,
>   		int, newdfd, const char __user *, newname, int, flags)
>   {
> -	struct dentry *new_dentry;
>   	struct nameidata nd;
>   	struct path old_path;
> -	int error;
>   	char *to;
> +	int error;

This little piece is unnecessary ;)

[...]
