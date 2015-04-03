From: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Subject: Re: [PATCH review  19/19] vfs: Do not allow escaping from bind mounts.
Date: Fri, 3 Apr 2015 07:20:35 +0100
Message-ID: <20150403062035.GF889__21708.1463699744$1428042050$gmane$org@ZenIV.linux.org.uk>
References: <87a8yqou41.fsf_-_@x220.int.ebiederm.org>
	<1428026183-14879-19-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1428026183-14879-19-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Willy Tarreau <w@1wt.eu>
List-Id: containers.vger.kernel.org

On Thu, Apr 02, 2015 at 08:56:23PM -0500, Eric W. Biederman wrote:
> +static void mark_violated_mounts(struct dentry *dentry, struct dentry *target)
> +{
> +	/* Mark all mountroots that are ancestors of dentry
> +	 * that do not share a common ancestor with target
> +	 *
> +	 * This function assumes both dentries are part of a DAG.
> +	 */
> +	struct dentry *p;
> +
> +	for (p = dentry->d_parent; !IS_ROOT(p); p = p->d_parent) {
> +		if (!d_mountroot(p))
> +			continue;
> +
> +		if (d_ancestor(p, target))
> +			break;

Egads...  You do realize that you'll keep walking the path from target to
root again and again?  It's a tree and we have already walked up to the root.
So we know the depths and tree topology can't change due to the rename_lock
being held by caller.

> +	if (!IS_ROOT(dentry) && !IS_ROOT(target)) {
> +		mark_violated_mounts(dentry, target);
> +		mark_violated_mounts(target, dentry);
> +	}
> +
>  	dentry_lock_for_move(dentry, target);

> +void mnt_set_violated(struct dentry *root, struct dentry *moving)
> +{
> +	struct mountroot *mr;
> +	struct mount *mnt;
> +
> +	lock_mount_hash();
> +	mr = lookup_mountroot(root);
> +	if (!mr)
> +		goto out;
> +
> +	hlist_for_each_entry(mnt, &mr->r_list, mnt_mr_list) {
> +		struct mount *child;
> +		/* Be wary of this mount */
> +		mnt->mnt.mnt_flags |= MNT_VIOLATED;
> +
> +		list_for_each_entry(child, &mnt->mnt_mounts, mnt_child) {
> +			/* Ignore children that will continue to be connected */
> +			if ((child->mnt_mountpoint != moving) &&
> +			    !d_ancestor(moving, child->mnt_mountpoint))
> +				continue;
> +
> +			/* Deal with mounts loosing the connection to
> +			 * their parents
> +			 */
> +			if (!(child->mnt.mnt_flags & MNT_UMOUNT)) {
> +				child->mnt.mnt_flags |= MNT_UNREACHABLE_PARENT;
> +				hlist_add_head(&child->mnt_pending_umount, &pending_umount);
> +				schedule_work(&pending_umount_work);
> +			} else {
> +				umount_mnt(child);
> +			}
> +		}
> +	}
> +out:
> +	unlock_mount_hash();

And that can have non-trivial security implications - ability to expose
something that has been overmounted is potentially very nasty.  I might
be missing something in the rest of the series (I'm half-asleep right now,
so that's certainly possible), but that doesn't look obviously safe.
Note that it's very different from the situation with umount-on-invalidation -
there the thing we are uncovering is dead.  In this one it might be very
much alive and deliberately covered...
