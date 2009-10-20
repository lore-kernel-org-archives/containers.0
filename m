From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH] pidns: Fix a leak in /proc inodes and dentries
Date: Tue, 20 Oct 2009 03:27:00 -0700
Message-ID: <m1r5sywebv.fsf__38536.4973023117$1256034846$gmane$org@fess.ebiederm.org>
References: <20091020041337.GA31623@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091020041337.GA31623-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Sukadev Bhattiprolu's
	message of "Mon\, 19 Oct 2009 21\:13\:37 -0700")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: jack-+ZI9xUNit7I@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, andrea-Vyt77T80VFVWk0Htik3J/w@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> writes:

> Fix a leak in /proc dentries and inodes with pid namespaces.
>
> This fix reverts the commit 7766755a2f249e7e0. The leak was reported by
> Daniel Lezcano - see  http://lkml.org/lkml/2009/10/2/159.
>
> To summarize the thread, when container-init is terminated, it sets the
> PF_EXITING flag and then zaps all the other processes in the container.
> When those processes exit, they are expected to be reaped by the container-
> init and as a part of reaping, the container-init should flush any /proc
> dentries associated with the processes. But because the container-init is
> itself exiting and the following PF_EXITING check, the dentires are not
> flushed, resulting in leak in /proc inodes and dentries.

Acked-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

> Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Reported-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
> Cc: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> Cc: Jan Kara <jack-+ZI9xUNit7I@public.gmane.org>
> Cc: Andrea Arcangeli <andrea-Vyt77T80VFVWk0Htik3J/w@public.gmane.org>
>
> ---
>  fs/proc/base.c |    3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> Index: linux-2.6/fs/proc/base.c
> ===================================================================
> --- linux-2.6.orig/fs/proc/base.c	2009-10-19 20:28:51.000000000 -0700
> +++ linux-2.6/fs/proc/base.c	2009-10-19 20:29:03.000000000 -0700
> @@ -2580,8 +2580,7 @@ static void proc_flush_task_mnt(struct v
>  	name.len = snprintf(buf, sizeof(buf), "%d", pid);
>  	dentry = d_hash_and_lookup(mnt->mnt_root, &name);
>  	if (dentry) {
> -		if (!(current->flags & PF_EXITING))
> -			shrink_dcache_parent(dentry);
> +		shrink_dcache_parent(dentry);
>  		d_drop(dentry);
>  		dput(dentry);
>  	}
