From: Krister Johansen <kjlx-6woCzk5+qv5TrMCiz+cRkdBPR1lH4CV8@public.gmane.org>
Subject: Re: Possible bug: detached mounts difficult to cleanup
Date: Wed, 11 Jan 2017 22:15:39 -0800
Message-ID: <20170112061539.GA2345@templeofstupid.com>
References: <20170111012454.GB2497@templeofstupid.com>
	<87fukqwcue.fsf@xmission.com> <87shoqtj7z.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87shoqtj7z.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Jan 11, 2017 at 03:37:36PM +1300, Eric W. Biederman wrote:
> ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman) writes:
> > So if the code is working correctly that should already happen.
> >
> > The design is for the parent mount to hold a reference to the submounts.
> > And when the reference on the parent drops to 0.  The references on
> > all of the submounts will also be dropped.
> >
> > I was hoping to read the code and point it out to you quickly, but I am
> > not seeing it now.  I am wondering if in all of the refactoring of that
> > code something was dropped/missed :(
> >
> > Somewhere there is supposed to be the equivalent of:
> > 	pin_insert_group(&p->mnt_umount, &p->mnt_parent->mnt, &unmounted);
> > when we unhash those mounts because the last count has gone away.
> > Either it is very sophisticated or I am missing it.  Grr....
> 
> Ok.  I see the code now, and it should be doing the right thing.
> 
> During umount_tree the code calls pin_insert_group(...) with the
> last paramenter being NULL.  That adds the mount to one or two
> lists.  The mnt_pins list of the parent mount and the &unmounted
> hlist.
> 
> Then later when the parent's cleanup_mnt is called if the mnt_pins
> still has entries mnt_pin_kill is called.  For every mount on the
> mnt_pins list drop_mountpoint is called.  Which calls dput and
> mntput.
> 
> So that is how your references are supposed to be freed.  Which leaves
> the question why aren't your mounts being freed?  Is a file descriptor
> perhaps from a mmaped executable holding a mount reference?

Was that test case of any use?  I'm afraid that I'm still failing to
communicate the problem.  The parent's cleanup_mnt isn't getting called
for the detached and locked mounts, and I can explain why.  The only
time I'm seeing them free'd is via the __detach_mounts() path, which is
only invoked for d_invalidate, vfs_rmdir, vfs_unlink, and vfs_rename:

rm 14633 [013] 29947.047071:         probe:nsfs_evict: (ffffffff81254fb0)
            7fff81256fb1 nsfs_evict+0x80007f002001 ([kernel.kallsyms])
            7fff8123e4c6 iput+0x80007f002196 ([kernel.kallsyms])
            7fff8123944c __dentry_kill+0x80007f00219c ([kernel.kallsyms])
            7fff81239611 dput+0x80007f002151 ([kernel.kallsyms])
            7fff81241bb6 cleanup_mnt+0x80007f002036 ([kernel.kallsyms])
            7fff81242beb mntput_no_expire+0x80007f00212b ([kernel.kallsyms])
            7fff81242c54 mntput+0x80007f002024 ([kernel.kallsyms])
            7fff81242c9a drop_mountpoint+0x80007f00202a ([kernel.kallsyms])
            7fff81256df7 pin_kill+0x80007f002077 ([kernel.kallsyms])
            7fff81256ede group_pin_kill+0x80007f00201e ([kernel.kallsyms])
            7fff812416e3 namespace_unlock+0x80007f002073 ([kernel.kallsyms])
            7fff81243e03 __detach_mounts+0x80007f0020d3 ([kernel.kallsyms])
            7fff8122f0cd vfs_unlink+0x80007f00217d ([kernel.kallsyms])
            7fff81231ce3 do_unlinkat+0x80007f002263 ([kernel.kallsyms])
            7fff812327ab sys_unlinkat+0x80007f00201b ([kernel.kallsyms])
            7fff81005b12 do_syscall_64+0x80007f002062 ([kernel.kallsyms])
            7fff81735b21 return_from_SYSCALL_64+0x80007f002000 ([kernel.kallsyms])
                   e90ed unlinkat+0xffff012b930e800d (/usr/lib64/libc-2.17.so)

So that's the stack where I see it work, but I never see it go through
the cleanup_mnt() path, and here's why.  First, the code to for loop
in umount_tree():

        while (!list_empty(&tmp_list)) {
                struct mnt_namespace *ns;
                bool disconnect;
                p = list_first_entry(&tmp_list, struct mount, mnt_list);
                list_del_init(&p->mnt_expire);
                list_del_init(&p->mnt_list);
                ns = p->mnt_ns;
                if (ns) {
                        ns->mounts--;
                        __touch_mnt_namespace(ns);
                }
                p->mnt_ns = NULL;
                if (how & UMOUNT_SYNC)
                        p->mnt.mnt_flags |= MNT_SYNC_UMOUNT;
                        
  #1 --->       disconnect = disconnect_mount(p, how);

  #2 --->       pin_insert_group(&p->mnt_umount, &p->mnt_parent->mnt,
                                 disconnect ? &unmounted : NULL);
                if (mnt_has_parent(p)) {
                        mnt_add_count(p->mnt_parent, -1);
                        if (!disconnect) {
                                /* Don't forget about p */
                                list_add_tail(&p->mnt_child, &p->mnt_parent->mnt_mounts);
                        } else {
                                umount_mnt(p);
                        }       
                }
  #3 --->       change_mnt_propagation(p, MS_PRIVATE);
        }


So at #1 disconnect is false if p has MNT_LOCKED set.
At #2 p isn't added to the s_list on 'unmounted' if disconnect is false.

The mount gets hidden from the host container at #3, but that's not
germane to the invocation of pin_kill.

This is namespace_unlock:

        hlist_move_list(&unmounted, &head);

        up_write(&namespace_sem);

        if (likely(hlist_empty(&head)))
                return;

        synchronize_rcu();

        group_pin_kill(&head);

So unmounted is moved to head, and group_pin_kill is invoked on that.
Only the mounts we marked for disconnect go through the cleanup_mnt path
that way.

So that's the fundamental question I'm trying to ask.  If we have a
mount tree that's umount(MNT_DETACH)'d immediately after a pivot_root,
but it's never getting those mounts cleaned up except when their
mountpoints get rm'd or mv'd, is there a better way to clean up this
tree?

-K
