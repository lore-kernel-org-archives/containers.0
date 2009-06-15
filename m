From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/9] exec_path 1/9: introduce ->exec_path and switch
	/proc/*/exe
Date: Tue, 16 Jun 2009 02:10:32 +0400
Message-ID: <20090615221032.GA4884__3894.3103551448$1245103932$gmane$org@x200.localdomain>
References: <20090526113618.GJ28083@us.ibm.com>
	<20090526162415.fb9cefef.akpm@linux-foundation.org>
	<20090531215427.GA29534@x200.localdomain>
	<20090531151953.8f8b14b5.akpm@linux-foundation.org>
	<20090603230422.GB853@x200.localdomain>
	<20090606072244.GA13497@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090606072244.GA13497-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org
List-Id: containers.vger.kernel.org

On Sat, Jun 06, 2009 at 08:22:44AM +0100, Al Viro wrote:
> On Thu, Jun 04, 2009 at 03:04:22AM +0400, Alexey Dobriyan wrote:
> > diff --git a/fs/binfmt_som.c b/fs/binfmt_som.c
> > index eff74b9..6c56262 100644
> > --- a/fs/binfmt_som.c
> > +++ b/fs/binfmt_som.c
> > @@ -174,6 +174,7 @@ static int map_som_binary(struct file *file,
> >  	up_write(&current->mm->mmap_sem);
> >  	if (retval > 0 || retval < -1024)
> >  		retval = 0;
> > +	set_task_exec_path(current, &bprm->file->f_path);
> 
> Oh?  Even on failure exits?

OK.

> > +	if (!path->mnt || !path->dentry)
> > +		return -ENOENT;
> 
> Umm...  I really don't like that.  Note that path with NULL vfsmount
> and non-NULL dentry should never happen.  If anything, we ought
> to add path_empty(path) (!(path)->mnt) and convert such places to it.

Why mntget/mntput handle NULL vfsmount?

> > +static inline void set_task_exec_path(struct task_struct *tsk, struct path *path)
> > +{
> > +	struct path old_path;
> > +
> > +	path_get(path);
> > +	task_lock(tsk);
> > +	old_path = tsk->exec_path;
> > +	tsk->exec_path = *path;
> > +	task_unlock(tsk);
> > +	path_put(&old_path);
> > +}
> 
> Do we ever have a right to do that to anything other than current?  Note
> that fork() is a special case anyway...

Locking wise? Yes, why not.
 
> > +	set_task_exec_path(tsk, &(struct path){ .mnt = NULL, .dentry = NULL });
> 
> Ew...

:^)

> > +	get_task_exec_path(current, &p->exec_path);
> > +
> 
> We already have that value sitting there, so why not get_path(&p->exec_path)?
> 
> The real problem I have with that we *really* can't umount the filesystem
> that used to host the binary anymore.  At all.

OTOH, you can always answer the question what is executing unless task is
sufficiently dead.

Now, I dont' think anyone unmaps old executable except malicious stuff.

> Frankly, I'm almost tempted to add explicit way to switch the damn thing
> via /proc/self/something - e.g. allow a binary to write a pathname to
> /proc/self/set_exec and have that switch the sucker.  The interesting
> part, of course, is figuring out the security implications of that...

I think nobody will use it.

I think /proc/*/exe should stay informational without task being able
to mangle it at will.
