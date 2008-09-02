From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 0/8][v2]: Enable multiple mounts of devpts
Date: Tue, 2 Sep 2008 10:52:11 -0500
Message-ID: <20080902155211.GF8524@us.ibm.com>
References: <20080821031028.GB30205@us.ibm.com> <48ACDDC7.3000704@zytor.com>
	<48AD991F.9010906@fr.ibm.com> <48AD9A97.6000807@zytor.com>
	<48AD9DCD.3060306@fr.ibm.com> <m1fxoys1ng.fsf@frodo.ebiederm.org>
	<48ADD7D3.7080400@fr.ibm.com> <48B7BB3C.5080404@fr.ibm.com>
	<20080902030426.GB12277@us.ibm.com>
	<m1vdxeeuk0.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m1vdxeeuk0.fsf-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, Dave Hansen <dave-gkUM19QKKo4@public.gmane.org>, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:
> 
> >>     (3.2) mnt namespace maybe ?
> >
> > I think the last one is the way to go.
> >
> > mnt_namespace points to mq_ns.
> >
> > At clone(CLONE_NEWMNT), the new mnt namespace receives a copy of the
> > parent's mq_ns.
> >
> > If a task does
> > 	mount -o newinstance -t mqueue none /dev/mqueue
> > then its current->nsproxy->mnt_namespace->mqns is switched
> > to point to a new instance of the mq_ns.
> >
> > mnt_ns->mq_ns has pointers to the sb (and hence root dentry) of the
> > devpts fs.
> >
> > When a task does mq_open(name, flag), then name is in the mqueuefs
> > found in current->nsproxy->mnt_namespace->mqns.
> >
> > But if a task does
> >
> > 	clone(CLONE_NEWMNT);
> > 	mount --move /dev/mqueue /oldmqueue
> > 	mount -o newinstance -t mqueue none /dev/mqueue
> >
> > then that task can find files for the old mqueuefs under
> > /oldmqueue, while mq_open() uses /dev/mqueue since that's
> > what it finds through its mnt_namespace.
> 
> Serge if we can make the lookup a pure mount namespace operation
> i.e. a well known path.  Than I don't have any problems with it.
> Otherwise it looks like abuse of the mount namespace.

Why?

Actually it may work to just put mq_ns straight in the nsproxy.

So let's see:

	mq_open(name, flag): opens name under the dentry pointed
		to by current->nsproxy->mq_ns->mq_dentry
	mount -t mqueue none /dev/mqueue: either returns -EBUSY
		or just mounts current->nsproxy->mq_ns->mq_sb
		under /dev/mqueue
	mount -o newinstance -t mqueue none /dev/mqueue: mounts
		 a new mq_ns instance under /dev/mqueue

While doing
	mount --make-rshared /vs1
	mount --bind /dev/mqueue /vs1/dev/mqueue
	create_a_new_container_chrooted_at(/vs1)
		mount -o newinstance -t mqueue none /dev/mqueue
would allow the host to see the child's /dev/mqueue under
/vs1/dev/mqueue while having its own mqueuefs continue to be
mounted under /dev/mqueue.

> In particular.  The best approximation I have is to change the
> kernel to simply lookup "/dev/mqueue" and if not found fallback
> to the initial kernel instance.

Having the kernel walk a hard-coded pathname to find it?  That I really
don't like.

> I'm staring at the code as I really haven't looked at it enough
> but it sure looks like we can transform it into a proper filesystem
> with just a touch of backwards compatibility logic.
> - put the current mq_namespace in the superblock.
> - Have open/unlink lookup "/dev/mqueue" to find the filesystem
>   if nothing is found fallback to the internal mount otherwise error.
> - Possibly put the tunables in a subdirectory? and 
>   bind mount that subdirectory on top of /proc/sys/fs/mqueue/
> 
>   I'm too thrilled about the tunables but still.

If mq_ns is stored under nsproxy, then so long as the task has
remounted /proc for its pidns anyway, we should be able to show
the right tunables under /proc as well, right?

> Are there any security holes or other oddness we would encounter
> if we did that?
> 
> If we can turn the posix mqueue stuff into an honest to goodness
> filesystem then we completely avoid nsproxy,

I am assuming that mq_open() is posix-defined?  So the only way
we could do that is, as you suggest, to have the kernel look up the
hard-coded /dev/mqueue path which IMO is a non-starter, and not
worth it to avoid nsproxy.

> and have something
> that is much nicer to deal with long term.
> 
> Eric
