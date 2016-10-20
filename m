From: Andrei Vagin <avagin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
Subject: Re: [REVIEW][PATCH] mount: In propagate_umount handle overlapping
	mount propagation trees
Date: Thu, 20 Oct 2016 14:30:53 -0700
Message-ID: <20161020213052.GA25226@outlook.office365.com>
References: <1476141965-21429-1-git-send-email-avagin@openvz.org>
	<877f9c6ui8.fsf@x220.int.ebiederm.org>
	<87pon458l1.fsf_-_@x220.int.ebiederm.org>
	<20161013214650.GB19836@outlook.office365.com>
	<CANaxB-xPkgdyeg0z6TvExMfyy4uOC+Nu4Q99WpCscNKMWz8VPg@mail.gmail.com>
	<87wphb4pjn.fsf@x220.int.ebiederm.org>
	<8737jy3htt.fsf_-_@x220.int.ebiederm.org>
	<20161018024000.GA4901@outlook.office365.com>
	<87r37e9mnj.fsf@xmission.com> <877f95ngpr.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <877f95ngpr.fsf_-_-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Oct 18, 2016 at 10:46:40PM -0500, Eric W. Biederman wrote:
> 
> Adrei Vagin pointed out that time to executue propagate_umount can go
> non-linear (and take a ludicrious amount of time) when the mount
> propogation trees of the mounts to be unmunted by a lazy unmount
> overlap.
> 
> While investigating the horrible performance I realized that in
> the case overlapping mount trees since the addition of locked
> mount support the code has been failing to unmount all of the
> mounts it should have been unmounting.
> 
> Make the walk of the mount propagation trees nearly linear by using
> MNT_MARK to mark pieces of the mount propagation trees that have
> already been visited, allowing subsequent walks to skip over
> subtrees.
> 
> Make the processing of mounts order independent by adding a list of
> mount entries that need to be unmounted, and simply adding a mount to
> that list when it becomes apparent the mount can safely be unmounted.
> For mounts that are locked on other mounts but otherwise could be
> unmounted move them from their parnets mnt_mounts to mnt_umounts so
> that if and when their parent becomes unmounted these mounts can be
> added to the list of mounts to unmount.
> 
> Add a final pass to clear MNT_MARK and to restore mnt_mounts
> from mnt_umounts for anything that did not get unmounted.
> 
> Add the functions propagation_visit_next and propagation_revisit_next
> to coordinate walking of the mount tree and setting and clearing the
> mount mark.
> 
> The skipping of already unmounted mounts has been moved from
> __lookup_mnt_last to mark_umount_candidates, so that the new
> propagation functions can notice when the propagation tree passes
> through the initial set of unmounted mounts.  Except in umount_tree as
> part of the unmounting process the only place where unmounted mounts
> should be found are in unmounted subtrees.  All of the other callers
> of __lookup_mnt_last are from mounted subtrees so the not checking for
> unmounted mounts should not affect them.
> 
> A script to generate overlapping mount propagation trees:
> $ cat run.sh
> mount -t tmpfs test-mount /mnt
> mount --make-shared /mnt
> for i in `seq $1`; do
>         mkdir /mnt/test.$i
>         mount --bind /mnt /mnt/test.$i
> done
> cat /proc/mounts | grep test-mount | wc -l
> time umount -l /mnt
> $ for i in `seq 10 16`; do echo $i; unshare -Urm bash ./run.sh $i; done
> 
> Here are the performance numbers with and without the patch:
> 
> mhash  |  8192   |  8192  |  8192       | 131072 | 131072      | 104857 | 104857
> mounts | before  | after  | after (sys) | after  | after (sys) |  after | after (sys)
> -------------------------------------------------------------------------------------
>   1024 |  0.071s | 0.020s | 0.000s      | 0.022s | 0.004s      | 0.020s | 0.004s
>   2048 |  0.184s | 0.022s | 0.004s      | 0.023s | 0.004s      | 0.022s | 0.008s
>   4096 |  0.604s | 0.025s | 0.020s      | 0.029s | 0.008s      | 0.026s | 0.004s
>   8912 |  4.471s | 0.053s | 0.020s      | 0.051s | 0.024s      | 0.047s | 0.016s
>  16384 | 34.826s | 0.088s | 0.060s      | 0.081s | 0.048s      | 0.082s | 0.052s
>  32768 |         | 0.216s | 0.172s      | 0.160s | 0.124s      | 0.160s | 0.096s
>  65536 |         | 0.819s | 0.726s      | 0.330s | 0.260s      | 0.338s | 0.256s
> 131072 |         | 4.502s | 4.168s      | 0.707s | 0.580s      | 0.709s | 0.592s
> 
> Andrei Vagin reports fixing the performance problem is part of the
> work to fix CVE-2016-6213.
> 
> A script for a pathlogical set of mounts:
> 
> $ cat pathological.sh
> 
> mount -t tmpfs base /mnt
> mount --make-shared /mnt
> mkdir -p /mnt/b
> 
> mount -t tmpfs test1 /mnt/b
> mount --make-shared /mnt/b
> mkdir -p /mnt/b/10
> 
> mount -t tmpfs test2 /mnt/b/10
> mount --make-shared /mnt/b/10
> mkdir -p /mnt/b/10/20
> 
> mount --rbind /mnt/b /mnt/b/10/20
> 
> unshare -Urm sleep 2
> umount -l /mnt/b
> wait %%
> 
> $ unsahre -Urm pathlogical.sh
> 
> Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Fixes: a05964f3917c ("[PATCH] shared mounts handling: umount")
> Fixes: 0c56fe31420c ("mnt: Don't propagate unmounts to locked mounts")
> Reported-by: Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> ---
> 
> Barring some stupid mistake this looks like it fixes both the performance
> and the correctness issues I was able to spot earlier.  Andrei if you
> could give this version a look over I would appreciate it.

Eric, could you try out this script:

[root@fc24 mounts]# cat run.sh 
set -e -m

mount -t tmpfs zdtm /mnt
mkdir -p /mnt/1 /mnt/2
mount -t tmpfs zdtm /mnt/1
mount --make-shared /mnt/1
mkdir /mnt/1/1

iteration=30
if [ -n "$1" ]; then
	iteration=$1
fi

for i in `seq $iteration`; do
	mount --bind /mnt/1/1 /mnt/1/1 &
done

ret=0
for i in `seq $iteration`; do
	wait -n || ret=1
done

[ "$ret" -ne 0 ] && {
	time umount -l /mnt/1
	exit 0
}

mount --rbind /mnt/1 /mnt/2
mount --make-slave /mnt/2
mount -t tmpfs zzz /mnt/2/1

nr=`cat /proc/self/mountinfo | grep zdtm | wc -l`
echo -n "umount -l /mnt/1 -> $nr	"
/usr/bin/time -f '%E' umount -l /mnt/1

nr=`cat /proc/self/mountinfo | grep zdtm | wc -l`
echo -n "umount -l /mnt/2 -> $nr	"
/usr/bin/time -f '%E' umount -l /mnt/2

[root@fc24 mounts]# unshare -Urm sh run.sh 4

It hangs up on my host with this patch.

NMI watchdog: BUG: soft lockup - CPU#0 stuck for 22s! [umount:789]
Modules linked in: nfsv3 nfs fscache bridge stp llc ebtable_filter
ebtables ip6table_filter ip6_tables ppdev crct10dif_pclmul crc32_pclmul
ghash_clmulni_intel virtio_balloon i2c_piix4 parport_pc parport
acpi_cpufreq nfsd auth_rpcgss nfs_acl lockd grace sunrpc binfmt_misc
virtio_net virtio_blk virtio_console crc32c_intel serio_raw virtio_pci
virtio_ring virtio ata_generic pata_acpi
CPU: 0 PID: 789 Comm: umount Not tainted 4.9.0-rc1+ #137
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.9.1-1.fc24
04/01/2014
task: ffff88007c11c100 task.stack: ffffc900007c0000
RIP: 0010:[<ffffffff8125bd87>]  [<ffffffff8125bd87>]
__lookup_mnt_last+0x67/0x80
RSP: 0018:ffffc900007c3db0  EFLAGS: 00000286
RAX: ffff88007a5f0900 RBX: ffff88007b136620 RCX: ffff88007a3e2900
RDX: ffff88007a3e2900 RSI: ffff88007b136600 RDI: ffff88007b136600
RBP: ffffc900007c3dc0 R08: ffff880036df5850 R09: ffffffff81249664
R10: ffff88007bd84c38 R11: 0000000100000000 R12: ffff88007bce3f00
R13: ffffc900007c3e00 R14: ffff88007bce3f00 R15: 00007ffe54245328
FS:  00007ff465de0840(0000) GS:ffff88007fc00000(0000)
knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000055f86b328128 CR3: 000000007ba23000 CR4: 00000000003406f0
Stack:
 ffff88007b136600 ffff88007b136480 ffffc900007c3df0 ffffffff8126a70a
 ffffc900007c3e58 ffffc900007c3e10 ffffc900007c3e00 ffff880079f99980
 ffffc900007c3e48 ffffffff8126b0d5 ffff88007a3e2660 ffff88007a3e24e0
Call Trace:
 [<ffffffff8126a70a>] propagation_visit_child.isra.8+0x5a/0xd0
 [<ffffffff8126b0d5>] propagate_umount+0x65/0x2e0
 [<ffffffff8125a76e>] umount_tree+0x2be/0x2d0
 [<ffffffff8125b75f>] do_umount+0x13f/0x340
 [<ffffffff8125c3ce>] SyS_umount+0x10e/0x120
 [<ffffffff817ba837>] entry_SYSCALL_64_fastpath+0x1a/0xa9

Thanks,
Andrei

> 
> Unless we can find a problem I am going to call this the final version.
> 
>  fs/mount.h     |   1 +
>  fs/namespace.c |   7 +-
>  fs/pnode.c     | 198 ++++++++++++++++++++++++++++++++++++++++++++++-----------
>  fs/pnode.h     |   2 +-
>  4 files changed, 165 insertions(+), 43 deletions(-)
> 
> diff --git a/fs/mount.h b/fs/mount.h
> index d2e25d7b64b3..00fe0d1d6ba7 100644
> --- a/fs/mount.h
> +++ b/fs/mount.h
> @@ -58,6 +58,7 @@ struct mount {
>  	struct mnt_namespace *mnt_ns;	/* containing namespace */
>  	struct mountpoint *mnt_mp;	/* where is it mounted */
>  	struct hlist_node mnt_mp_list;	/* list mounts with the same mountpoint */
> +	struct list_head mnt_umounts;	/* list of children that are being unmounted */
>  #ifdef CONFIG_FSNOTIFY
>  	struct hlist_head mnt_fsnotify_marks;
>  	__u32 mnt_fsnotify_mask;
> diff --git a/fs/namespace.c b/fs/namespace.c
> index e6c234b1a645..73801391bb00 100644
> --- a/fs/namespace.c
> +++ b/fs/namespace.c
> @@ -237,6 +237,7 @@ static struct mount *alloc_vfsmnt(const char *name)
>  		INIT_LIST_HEAD(&mnt->mnt_slave_list);
>  		INIT_LIST_HEAD(&mnt->mnt_slave);
>  		INIT_HLIST_NODE(&mnt->mnt_mp_list);
> +		INIT_LIST_HEAD(&mnt->mnt_umounts);
>  #ifdef CONFIG_FSNOTIFY
>  		INIT_HLIST_HEAD(&mnt->mnt_fsnotify_marks);
>  #endif
> @@ -650,13 +651,11 @@ struct mount *__lookup_mnt_last(struct vfsmount *mnt, struct dentry *dentry)
>  	p = __lookup_mnt(mnt, dentry);
>  	if (!p)
>  		goto out;
> -	if (!(p->mnt.mnt_flags & MNT_UMOUNT))
> -		res = p;
> +	res = p;
>  	hlist_for_each_entry_continue(p, mnt_hash) {
>  		if (&p->mnt_parent->mnt != mnt || p->mnt_mountpoint != dentry)
>  			break;
> -		if (!(p->mnt.mnt_flags & MNT_UMOUNT))
> -			res = p;
> +		res = p;
>  	}
>  out:
>  	return res;
> diff --git a/fs/pnode.c b/fs/pnode.c
> index 234a9ac49958..15e30e861a14 100644
> --- a/fs/pnode.c
> +++ b/fs/pnode.c
> @@ -390,56 +390,153 @@ void propagate_mount_unlock(struct mount *mnt)
>  }
>  
>  /*
> - * Mark all mounts that the MNT_LOCKED logic will allow to be unmounted.
> + * get the next mount in the propagation tree (that has not been visited)
> + * @m: the mount seen last
> + * @origin: the original mount from where the tree walk initiated
> + *
> + * Note that peer groups form contiguous segments of slave lists.
> + * We rely on that in get_source() to be able to find out if
> + * vfsmount found while iterating with propagation_next() is
> + * a peer of one we'd found earlier.
>   */
> -static void mark_umount_candidates(struct mount *mnt)
> +static struct mount *propagation_visit_child(struct mount *last_child,
> +					    struct mount *origin_child)
>  {
> -	struct mount *parent = mnt->mnt_parent;
> -	struct mount *m;
> +	struct mount *m = last_child->mnt_parent;
> +	struct mount *origin = origin_child->mnt_parent;
> +	struct dentry *mountpoint = origin_child->mnt_mountpoint;
> +	struct mount *child;
>  
> -	BUG_ON(parent == mnt);
> +	/* Has this part of the propgation tree already been visited? */
> +	if (IS_MNT_MARKED(last_child))
> +		return NULL;
>  
> -	for (m = propagation_next(parent, parent); m;
> -			m = propagation_next(m, parent)) {
> -		struct mount *child = __lookup_mnt_last(&m->mnt,
> -						mnt->mnt_mountpoint);
> -		if (child && (!IS_MNT_LOCKED(child) || IS_MNT_MARKED(m))) {
> -			SET_MNT_MARK(child);
> +	SET_MNT_MARK(last_child);
> +
> +	/* are there any slaves of this mount? */
> +	if (!list_empty(&m->mnt_slave_list)) {
> +		m = first_slave(m);
> +		goto check_slave;
> +	}
> +	while (1) {
> +		struct mount *master = m->mnt_master;
> +
> +		if (master == origin->mnt_master) {
> +			struct mount *next = next_peer(m);
> +			while (1) {
> +				if (next == origin)
> +					return NULL;
> +				child = __lookup_mnt_last(&next->mnt, mountpoint);
> +				if (child && !IS_MNT_MARKED(child))
> +					return child;
> +				next = next_peer(next);
> +			}
> +		} else {
> +			while (1) {
> +				if (m->mnt_slave.next == &master->mnt_slave_list)
> +					break;
> +				m = next_slave(m);
> +			check_slave:
> +				child = __lookup_mnt_last(&m->mnt, mountpoint);
> +				if (child && !IS_MNT_MARKED(child))
> +					return child;
> +			}
>  		}
> +
> +		/* back at master */
> +		m = master;
>  	}
>  }
>  
>  /*
> - * NOTE: unmounting 'mnt' naturally propagates to all other mounts its
> - * parent propagates to.
> + * get the next mount in the propagation tree (that has not been revisited)
> + * @m: the mount seen last
> + * @origin: the original mount from where the tree walk initiated
> + *
> + * Note that peer groups form contiguous segments of slave lists.
> + * We rely on that in get_source() to be able to find out if
> + * vfsmount found while iterating with propagation_next() is
> + * a peer of one we'd found earlier.
>   */
> -static void __propagate_umount(struct mount *mnt)
> +static struct mount *propagation_revisit_child(struct mount *last_child,
> +					       struct mount *origin_child)
>  {
> -	struct mount *parent = mnt->mnt_parent;
> -	struct mount *m;
> +	struct mount *m = last_child->mnt_parent;
> +	struct mount *origin = origin_child->mnt_parent;
> +	struct dentry *mountpoint = origin_child->mnt_mountpoint;
> +	struct mount *child;
>  
> -	BUG_ON(parent == mnt);
> +	/* Has this part of the propgation tree already been revisited? */
> +	if (!IS_MNT_MARKED(last_child))
> +		return NULL;
>  
> -	for (m = propagation_next(parent, parent); m;
> -			m = propagation_next(m, parent)) {
> +	CLEAR_MNT_MARK(last_child);
>  
> -		struct mount *child = __lookup_mnt_last(&m->mnt,
> -						mnt->mnt_mountpoint);
> -		/*
> -		 * umount the child only if the child has no children
> -		 * and the child is marked safe to unmount.
> -		 */
> -		if (!child || !IS_MNT_MARKED(child))
> -			continue;
> -		CLEAR_MNT_MARK(child);
> -		if (list_empty(&child->mnt_mounts)) {
> -			list_del_init(&child->mnt_child);
> -			child->mnt.mnt_flags |= MNT_UMOUNT;
> -			list_move_tail(&child->mnt_list, &mnt->mnt_list);
> +	/* are there any slaves of this mount? */
> +	if (!list_empty(&m->mnt_slave_list)) {
> +		m = first_slave(m);
> +		goto check_slave;
> +	}
> +	while (1) {
> +		struct mount *master = m->mnt_master;
> +
> +		if (master == origin->mnt_master) {
> +			struct mount *next = next_peer(m);
> +			while (1) {
> +				if (next == origin)
> +					return NULL;
> +				child = __lookup_mnt_last(&next->mnt, mountpoint);
> +				if (child && IS_MNT_MARKED(child))
> +					return child;
> +				next = next_peer(next);
> +			}
> +		} else {
> +			while (1) {
> +				if (m->mnt_slave.next == &master->mnt_slave_list)
> +					break;
> +				m = next_slave(m);
> +			check_slave:
> +				child = __lookup_mnt_last(&m->mnt, mountpoint);
> +				if (child && IS_MNT_MARKED(child))
> +					return child;
> +			}
>  		}
> +
> +		/* back at master */
> +		m = master;
>  	}
>  }
>  
> +static void start_umount_propagation(struct mount *child,
> +				     struct list_head *to_umount)
> +{
> +	do {
> +		struct mount *parent = child->mnt_parent;
> +
> +		if ((child->mnt.mnt_flags & MNT_UMOUNT) ||
> +		    !list_empty(&child->mnt_mounts))
> +			return;
> +
> +		if (!IS_MNT_LOCKED(child))
> +			list_move_tail(&child->mnt_child, to_umount);
> +		else
> +			list_move_tail(&child->mnt_child, &parent->mnt_umounts);
> +
> +		child = NULL;
> +		if (IS_MNT_MARKED(parent))
> +			child = parent;
> +	} while (child);
> +}
> +
> +static void end_umount_propagation(struct mount *child)
> +{
> +	struct mount *parent = child->mnt_parent;
> +
> +	if (!list_empty(&parent->mnt_umounts))
> +		list_splice_tail_init(&parent->mnt_umounts, &parent->mnt_mounts);
> +}
> +
> +
>  /*
>   * collect all mounts that receive propagation from the mount in @list,
>   * and return these additional mounts in the same list.
> @@ -447,14 +544,39 @@ static void __propagate_umount(struct mount *mnt)
>   *
>   * vfsmount lock must be held for write
>   */
> -int propagate_umount(struct list_head *list)
> +void propagate_umount(struct list_head *list)
>  {
>  	struct mount *mnt;
> +	LIST_HEAD(to_umount);
> +	LIST_HEAD(tmp_list);
> +
> +	/* Find candidates for unmounting */
> +	list_for_each_entry(mnt, list, mnt_list) {
> +		struct mount *child;
> +		for (child = propagation_visit_child(mnt, mnt); child;
> +		     child = propagation_visit_child(child, mnt))
> +			start_umount_propagation(child, &to_umount);
> +	}
>  
> -	list_for_each_entry_reverse(mnt, list, mnt_list)
> -		mark_umount_candidates(mnt);
> +	/* Begin unmounting */
> +	while (!list_empty(&to_umount)) {
> +		mnt = list_first_entry(&to_umount, struct mount, mnt_child);
>  
> -	list_for_each_entry(mnt, list, mnt_list)
> -		__propagate_umount(mnt);
> -	return 0;
> +		list_del_init(&mnt->mnt_child);
> +		mnt->mnt.mnt_flags |= MNT_UMOUNT;
> +		list_move_tail(&mnt->mnt_list, &tmp_list);
> +
> +		if (!list_empty(&mnt->mnt_umounts))
> +			list_splice_tail_init(&mnt->mnt_umounts, &to_umount);
> +	}
> +
> +	/* Cleanup the mount propagation tree */
> +	list_for_each_entry(mnt, list, mnt_list) {
> +		struct mount *child;
> +		for (child = propagation_revisit_child(mnt, mnt); child;
> +		     child = propagation_revisit_child(child, mnt))
> +			end_umount_propagation(child);
> +	}
> +
> +	list_splice_tail(&tmp_list, list);
>  }
> diff --git a/fs/pnode.h b/fs/pnode.h
> index 550f5a8b4fcf..38c6cdb96b34 100644
> --- a/fs/pnode.h
> +++ b/fs/pnode.h
> @@ -41,7 +41,7 @@ static inline void set_mnt_shared(struct mount *mnt)
>  void change_mnt_propagation(struct mount *, int);
>  int propagate_mnt(struct mount *, struct mountpoint *, struct mount *,
>  		struct hlist_head *);
> -int propagate_umount(struct list_head *);
> +void propagate_umount(struct list_head *);
>  int propagate_mount_busy(struct mount *, int);
>  void propagate_mount_unlock(struct mount *);
>  void mnt_release_group_id(struct mount *);
> -- 
> 2.10.1
> 
