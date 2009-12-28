From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH RFC] c/r mounts ns.  Except not really.
Date: Mon, 28 Dec 2009 09:27:40 -0600
Message-ID: <20091228152740.GC5720@us.ibm.com>
References: <20091215023945.GA12100@us.ibm.com>
	<20091215201928.GA20037@us.ibm.com>
	<4B317003.2060706@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4B317003.2060706-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> 
> 
> Serge E. Hallyn wrote:
> > Quoting Serge E. Hallyn (serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> >> We only c/r a mounts ns with objref 0, meaning inherit the existing
> >> mounts ns.  We do intend to implement c/r of mounts and mounts
> >> namespaces in the kernel.  It shouldn't be ugly or complicate locking
> >> to do so.  Just haven't gotten around to it.
> >>
> >> Why did I bother with this?  Because we can't re-create private
> >> mounts yet, and while I don't expect trouble doing so, I think
> >> it's more than we want to take on now for v19.  But I'd like
> >> as much as possible for everything which we don't support, to not
> >> be checkpointable, since not doing so has in the past invited
> >> slanderous accusations of being a toy implementation  :)
> >>
> >> Comments?
> 
> This seems to me like the proper intermediary step.
> 
> >>
> >> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> 
> [...]
> 
> >> @@ -2323,3 +2324,37 @@ void put_mnt_ns(struct mnt_namespace *ns)
> >>  	kfree(ns);
> >>  }
> >>  EXPORT_SYMBOL(put_mnt_ns);
> >> +
> >> +#ifdef CONFIG_CHECKPOINT
> >> +int checkpoint_mounts_ns(struct ckpt_ctx *ctx, struct mnt_namespace *mnt_ns)
> >> +{
> >> +	if (mnt_ns == ctx->root_nsproxy->mnt_ns)
> >> +		return 0;
> 
> As you mention below, this should be CKPT_MNT_NS_INHERIT.
> 
> > 
> > Technically note that this is not even correct.  If the container
> > being checkpointed had a mnt_ns private from its parents, then
> > it could have its own mounts which are not checkpointed (and therefore
> > can't even be generically restored by userspace).  So really this should
> > be returning 0 (which should be CKPT_MNT_NS_INHERIT) only if mnt_ns
> > == ctx->root_task->parent->nsproxy->mnt_ns (requiring more careful
> > dereferencing since we don't have it pinned).
> > 
> > Whatever we do here for v19, I intend to do the same thing for
> > network devices for v19.  The question is, are we being unprofessional,
> > or are we being useful+flexible, by simply ignoring these things at
> > checkpoint when we know we won't restore them?
> 
> IIRC we agreed that so-called "external" mounts - whatever is mounted
> at the root of the container is the responsibility of userspace to have
> prepared properly before restart.

Right, but your description (and my code) misrepresent "external"
mounts.  External mounts are those which are shared with the *parent*
of the container init.  If the container init has a private namespace,
then things mounted at the root of the container can in fact be
internal mounts.

> So I don't see an issue with ignoring these at checkpoint, with one
> exception: leak detection in full-container checkpoint should complain
> if the root container fs is shared with parent (above container) tasks.
> 
> I think about it this way: at checkpoint, we care about container (or
> checkpoint) root and below. Then at restart, we should decide whether
> the root task (of the restore) should inherit its initial FS, or
> whether it should start with a private one.

As a specific example:  let's say container root did:
	unshare(CLONE_NEWNS)
	mkdir privtmp
	mount --bind privtmp /tmp

With the code I have, and with what you describe above - or put another
way, if we define "whatever is mounted at the root of the container" as
an external mount - then we won't reproduce this mount at restart.

> Recall that we had/have this dilemma also with UTS namespace, and with
> IPC namespace.

I don't think we can draw many comparisons with those, because those
namespaces are fully isolated.  The mounts namespaces have all sorts
of funky relationships:  not only mounts which were inherited from
the parent ns at copy time vs. new private mounts, but also slave
and shared mounts.  Heck, if a stupid application started on a system
where /var/spool/mail was bind-mounted to /var/mail does:

	unshare(CLONE_NEWNS)
	umount /var/mail
	mount --bind /var/spool/mail

Then (a) will we be able to tell that the umount/mount happened vs
whether it didn't happen, and (b) do we care?  Now yes, we actually
don't care in that case, but the point is that we don't have any real
way to compare two mountpoints between mounts namespaces.  We may have
to 'color' mounts at mnt_ns clone, so that at checkpoint we can
distinguish private mounts by a unique color.

(I'm not certain, but I think we could produce a case which we couldn't
detect but which we do care about by doing something like:
	unshare(CLONE_NEWNS)
	umount /var/mail
	mount --bind /var/spool /var/spool
	mount --bind /var/spool/mail /var/mail
now a simple dentry-based duplicate mount detection algorithm might
think the /var/spool/mail->/var/mail mount was the same as the
original?)

> Here is one way to do it:  (consider ipc-ns) at checkpoint, for the
> kernel will compare every task's ipc-ns to the container's _parent_'s
> ipc-ns, and if equal will save CKPT_OBJ_NS_INHERIT. If --inherit-ipc
> is given, it will not the state of the parent's namespace, otherwise
> it will.
> 
> At restart, if --inherit-ipc then whenever the kernel sees objref
> that is CKPT_OBJ_NS_INHERIT, it will use the container's parent's
> ipc-ns. Otherwise, it will create a new, private namespace for it.
> (Also, with --inherit-ipc, if there is namespace state following
> the CKPT_OBJ_NS_INHERIT, it should skip it without using it).
> 
> Oren.
