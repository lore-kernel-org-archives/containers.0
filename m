From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH review 11/11] mnt: Honor MNT_LOCKED when detaching mounts
Date: Wed, 07 Jan 2015 13:53:12 -0600
Message-ID: <87a91ufjvb.fsf@x220.int.ebiederm.org>
References: <87mw5xq7lt.fsf@x220.int.ebiederm.org>
	<1420490787-14387-11-git-send-email-ebiederm@xmission.com>
	<20150107184334.GZ22149@ZenIV.linux.org.uk>
	<20150107192807.GA22149@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20150107192807.GA22149-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org> (Al Viro's message of
	"Wed, 7 Jan 2015 19:28:07 +0000")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org> writes:

> On Wed, Jan 07, 2015 at 06:43:34PM +0000, Al Viro wrote:
>> On Mon, Jan 05, 2015 at 02:46:27PM -0600, Eric W. Biederman wrote:
>> > Modify umount(MNT_DETACH) to keep mounts in the hash table that are
>> > locked to their parent mounts, when the parent is lazily unmounted.
>> > In doing this invert the reference count so that the parent holds a
>> > reference to the children instead of the children holding a reference
>> > to the parent.
>> > 
>> > Then in mntput_no_expire detach the children and in cleanup_mnt mntput
>> > the children and dput the dentry they were mounted on.
>> > 
>> > In __detach_mounts if there are any mounts that have been unmounted
>> > but still are on the list of mounts of a mountpoint, detach those
>> > mounts and schedule them to be mntput and their reference to the dentry
>> > to be put when it becomes safe to sleep.
>> 
>> Explicit description of your new refcounting rules, please.
>
> I really hate those path_put(&p->mnt_ex_mountpoint) in the resulting code...
> Can you ever get to your mntput_children() with non-NULL ->mnt_ex_mountpoint.mnt
> in one of the survivors?  Looks like it shouldn't be possible at all...

> What's to prevent such a survivor (not contributing to the refcount of
> parent, to be dropped when parent gets killed) in the child list of a parent
> that is still normally mounted?

umount_tree.

In the base case we know the parent is unmounted because we were called
on the parent.

In the propagation case the code goes through one pass to identify trees
where the parent -> child (MNT_LOCKED) state allows the subtree to be
unmounted and we perform the normal are all of the children gone test.

That is what the entire MNT_MARK business is about.

> And what happens if it's hit again,

If I understand the question such a mount won't be hit again because the
case you describe can't happen.

> in addition to "what does /proc/mounts of the namespace the parent's in look
> like"?

These mounts are unmounted so don't show up in /proc/mounts. 

If the umount propagates somewhere the parents can't be detached from
the propagation is discarded.  Just like we discard propagation when the
are additional children.

Eric
