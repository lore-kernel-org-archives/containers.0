From: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Subject: Re: [PATCH 1/9] exec_path 1/9: introduce ->exec_path and switch
	/proc/*/exe
Date: Sat, 6 Jun 2009 08:22:44 +0100
Message-ID: <20090606072244.GA13497__17562.171808868$1244273040$gmane$org@ZenIV.linux.org.uk>
References: <20090526113618.GJ28083@us.ibm.com>
	<20090526162415.fb9cefef.akpm@linux-foundation.org>
	<20090531215427.GA29534@x200.localdomain>
	<20090531151953.8f8b14b5.akpm@linux-foundation.org>
	<20090603230422.GB853@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090603230422.GB853-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Jun 04, 2009 at 03:04:22AM +0400, Alexey Dobriyan wrote:
> diff --git a/fs/binfmt_som.c b/fs/binfmt_som.c
> index eff74b9..6c56262 100644
> --- a/fs/binfmt_som.c
> +++ b/fs/binfmt_som.c
> @@ -174,6 +174,7 @@ static int map_som_binary(struct file *file,
>  	up_write(&current->mm->mmap_sem);
>  	if (retval > 0 || retval < -1024)
>  		retval = 0;
> +	set_task_exec_path(current, &bprm->file->f_path);

Oh?  Even on failure exits?
> +	if (!path->mnt || !path->dentry)
> +		return -ENOENT;

Umm...  I really don't like that.  Note that path with NULL vfsmount
and non-NULL dentry should never happen.  If anything, we ought
to add path_empty(path) (!(path)->mnt) and convert such places to it.

> +static inline void set_task_exec_path(struct task_struct *tsk, struct path *path)
> +{
> +	struct path old_path;
> +
> +	path_get(path);
> +	task_lock(tsk);
> +	old_path = tsk->exec_path;
> +	tsk->exec_path = *path;
> +	task_unlock(tsk);
> +	path_put(&old_path);
> +}

Do we ever have a right to do that to anything other than current?  Note
that fork() is a special case anyway...

> +	set_task_exec_path(tsk, &(struct path){ .mnt = NULL, .dentry = NULL });

Ew...

> +	get_task_exec_path(current, &p->exec_path);
> +

We already have that value sitting there, so why not get_path(&p->exec_path)?

The real problem I have with that we *really* can't umount the filesystem
that used to host the binary anymore.  At all.

Frankly, I'm almost tempted to add explicit way to switch the damn thing
via /proc/self/something - e.g. allow a binary to write a pathname to
/proc/self/set_exec and have that switch the sucker.  The interesting
part, of course, is figuring out the security implications of that...
