From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 2/3] ipc namespaces: implement support for posix
	msqueues
Date: Tue, 27 Jan 2009 15:56:08 -0600
Message-ID: <20090127215608.GA13210@us.ibm.com>
References: <20090117020248.GA8615@us.ibm.com> <20090117020332.GB8708@us.ibm.com> <20090126152839.b35dbb45.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757092AbZA0V43@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090126152839.b35dbb45.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

Quoting Andrew Morton (akpm@linux-foundation.org):
> On Fri, 16 Jan 2009 20:03:32 -0600
> "Serge E. Hallyn" <serue@us.ibm.com> wrote:
> 
> > Implement multiple mounts of the mqueue file system, and
> > link it to usage of CLONE_NEWIPC.
> > 
> > Each ipc ns has a corresponding mqueuefs superblock.  When
> > a user does clone(CLONE_NEWIPC) or unshare(CLONE_NEWIPC), the
> > unshare will cause an internal mount of a new mqueuefs sb
> > linked to the new ipc ns.
> > 
> > When a user does 'mount -t mqueue mqueue /dev/mqueue', he
> > mounts the mqueuefs superblock.
> > 
> > Posix message queues can be worked with both through the
> > mq_* system calls (see mq_overview(7)), and through the VFS
> > through the mqueue mount.  Any usage of mq_open() and friends
> > will work with the acting task's ipc namespace.  Any actions
> > through the VFS will work with the mqueuefs in which the
> > file was created.  So if a user doesn't remount mqueuefs
> > after unshare(CLONE_NEWIPC), mq_open("/ab") will not be
> > reflected in "ls /dev/mqueue".
> > 
> > If task a mounts mqueue for ipc_ns:1, then clones task b with
> > a new ipcns, ipcns:2, and then task a is the last task in
> > ipc_ns:1 to exit, then (1) ipc_ns:1 will be freed, (2) it's
> > superblock will live on until task b umounts the corresponding
> > mqueuefs, and vfs actions will continue to succeed, but (3)
> > sb->s_fs_info will be NULL for the sb corresponding to the
> > deceased ipc_ns:1.
> 
> I suppose that stuff like this should find its way into a manpage one
> day.  That'll be fun for someone.

Nadia wrote an update for the mq_overview.7 page.  But the
semantics have changed a bit since then so I'll need to
revise that.

> > +static int get_sb_single_ns(struct file_system_type *fs_type,
> > +		int flags, void *data,
> > +		int (*fill_super)(struct super_block *, void *, int),
> > +		struct vfsmount *mnt)
> > +{
> > +	struct super_block *s;
> > +	int error;
> > +
> > +	s = sget(fs_type, compare_sb_single_ns, set_sb_single_ns, data);
> > +	if (IS_ERR(s))
> > +		return PTR_ERR(s);
> > +	if (!s->s_root) {
> > +		s->s_flags = flags;
> > +		error = fill_super(s, data, flags & MS_SILENT ? 1 : 0);
> > +		if (error) {
> > +			up_write(&s->s_umount);
> > +			deactivate_super(s);
> > +			return error;
> > +		}
> > +		s->s_flags |= MS_ACTIVE;
> > +	}
> > +	do_remount_sb(s, flags, data, 0);
> > +	return simple_set_mnt(mnt, s);
> >  }
> 
> The above doesn't seem specific to mqueue.  Is it in the best place?

No, I think there is commonality with devpts and perhaps also proc.  Now
that devpts namespaces are upstream i should first move it to using a
more generic helper, then introduce posixmq namespaces as another user.

> > @@ -266,10 +317,12 @@ static void mqueue_delete_inode(struct inode *inode)
> >  	if (user) {
> >  		spin_lock(&mq_lock);
> >  		user->mq_bytes -= mq_bytes;
> > -		ipc_ns->mq_queues_count--;
> > +		if (ipc_ns)
> 
> The reader might be wondering why ipc_ns==NULL is an acceptable state,
> and what that state actually means.  This reader is wondering that.

That's actually a central part of how we resolved the dependency
between the mqfs mount (pinned by vfs) and mqns (pinned by nsproxy).
So the mqns pins its mqfs vfsmount, but the mnt->mnt_sb->s_fs_info
is not pinned by the mqns.  Rather, s_fs_info is protected by the
mq_lock and either non-NULL and valid, or NULL.  The mqns takes
the mq_lock to set it to NULL, and any reader of s_fs_info must
dereference it and pin the mqns under mq_lock.

> > + * put_ipc_ns - drop a reference to an ipc namespace.
> > + * @ns: the namespace to put
> > + *
> > + * If this is the last task in the namespace exiting, and
> > + * it is dropping the refcount to 0, then it can race with
> > + * a task in another ipc namespace but in a mounts namespace
> > + * which has this ipcns's mqueuefs mounted, doing some action
> > + * with one of the mqueuefs files.  That can raise the refcount.
> > + * So dropping the refcount, and raising the refcount when
> > + * accessing it through the VFS, are protected with mq_lock.
> > + *
> > + * (Clearly, a task raising the refcount on its own ipc_ns
> > + * needn't take mq_lock since it can't race with the last task
> > + * in the ipcns exiting).
> > + */
> > +void put_ipc_ns(struct ipc_namespace *ns)
> >  {
> > -	struct ipc_namespace *ns;
> > +	if (ns && atomic_dec_and_lock(&ns->count, &mq_lock)) {
> > +		mq_clear_sbinfo(ns);
> > +		spin_unlock(&mq_lock);
> > +		mq_put_mnt(ns);
> > +		free_ipc_ns(ns);
> > +	}
> > +}
> 
> Why are we supporting calls with a NULL arg here?

Hmm, I'm not sure that's necessary.  Will look into it.

Every other comment I'll fix in the next version.  Thanks
very much.

-serge
