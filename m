From: Krister Johansen <kjlx-6woCzk5+qv5TrMCiz+cRkdBPR1lH4CV8@public.gmane.org>
Subject: Possible bug: detached mounts difficult to cleanup
Date: Tue, 10 Jan 2017 17:24:54 -0800
Message-ID: <20170111012454.GB2497__2086.62829031727$1484141242$gmane$org@templeofstupid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Gents,
This is the follow-up e-mail I referenced in our discussion about the
put_mountpoint locking problem.

The problem manifested itself as a situation where our container
provisioner would sometimes fail to re-start a container that it had
made configuration changes.  The IP address chosen by the provisioner
was still in use in another container.  This meant that the system had a
network namespace with an IP address that was still in use, despite the
provisoner having torn down the container as part of the reconfig
operation.

In order to keep the network namespace in use while the container is
alive, the software bind mounts the net and user namespaces out of
/proc/<pid>/ns/ into a directory that's used as the top level for the
container instance.

After forcing a crash dump and looking through the results, I was able
to confirm that the only reference keeping the net namespace alive was
the one held by the dentry on the mountpoint for the nsfs mount of the
network namespace.  The problem was that the container software had
unmounted this mountpoint, so it wasn't even in the host container's
mount namespace.

Since the software was using shared mounts, the nsfs bind mount was
getting copied into the mount namespaces of any container that was
created after the nsfs bind mount was established.  However, this isn't
obvious because each new namespace executes a pivot_root(2), followed by
an immediate and subsequent umount2(MNT_DETACH) on the old part of the
root filesystem that is no longer in use.  These mounts of the nsfs bind
mount weren't visibile in the kernel debugger, because they'd been
detached from the mount namespace's mount tree.

After looking at how iproute handles net namespaces, I ran a test where
every unmount of the net nsfs bind mount was followed by a rm of that
mountpoint.  That always resulted in the mountpoint getting freed and
the refcount on the dentry going to zero.  It wsa enough for to make
forward progress on the other tasks at hand.  I was able to verify that
the nsfs refcount was getting dropped, and we were going through the
__detach_mounts() cleanup path:

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

Over the holiday, I had some more time to debug this and was able to
narrow it down to the following case.

1. The mount namespace that gets a copy of the nsfs bind mount must be
created in a different user namespace than the host container.  This
causes MNT_LOCKED to get set on the cloned mounts.

2. In the container, pivot_root(2) and then umount2(MNT_DETACH) the old
part of the tree from pivot_root.  Ensure that the nsfs mount is beneath
the root of this tree.

3. Umount the nsfs mount in the host container.  If the mount wasn't
locked in the other container, you'll see a kprobe on nsfs_evict trigger
immediately.  If it was MNT_LOCKED, then you'll need to rm the
mountpoint in the host to trigger the nsfs_evict.

For a nsfs mount, it's not particularly problematic to have to rm the
mount to clean it up, but the other mounts in the tree that are detached
and locked are often on mountpoints that can't be easily rm'd from the
host.  These are harder to clean up, and essentially orphaned until the
container's mount ns goes away.

It would be ideal if we could release these mounts sooner, but I'm
unsure of the best approach here.

Debugging further, I was able to see that:

a) The reason the nsfs isn't considere as part of propagate_mount_unlock
is that the 'mnt' passed to that function is the top of the mount tree
and it appears to only be considering mounts directly related to 'mnt'.

b) The change_mnt_propogation(MS_PRIVATE) at the end of the while loop
in umount_tree() is what ends up hiding these mounts from the host
container.  Once they're no longer slaved or shared, we never again
consider them as candiates for unlocking.

c) Also note that these detached mounts that aren't free'd aren't
charged against a container's ns->mounts limit, so it may be possible
for a mount ns to be using more mounts than it has officially accounted
for.

I wondered if a naive solution could re-walk the list of mounts
processed in umount_tree() and if all of the detached but locked mounts
had a refcount that indicated they're unused, they could be unlocked and
unmounted.  At least in the case of the containers I'm dealing with, the
the container software should be ensuring that nothing in the container
has a reference on anything that's under the detached portion of the
tree.  However, there's probably a better way to do this.

Thoughts?

-K
