From: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Subject: Re: [PATCH review 11/11] mnt: Honor MNT_LOCKED when detaching mounts
Date: Thu, 8 Jan 2015 22:32:13 +0000
Message-ID: <20150108223212.GF22149@ZenIV.linux.org.uk>
References: <87mw5xq7lt.fsf@x220.int.ebiederm.org>
	<1420490787-14387-11-git-send-email-ebiederm@xmission.com>
	<20150107184334.GZ22149@ZenIV.linux.org.uk>
	<87h9w2gzht.fsf@x220.int.ebiederm.org>
	<20150107205239.GB22149@ZenIV.linux.org.uk>
	<87iogi8dka.fsf@x220.int.ebiederm.org>
	<20150108002227.GC22149@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20150108002227.GC22149-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
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
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Jan 08, 2015 at 12:22:27AM +0000, Al Viro wrote:

> 	* external references countribute
> 	* mnt_parent contributes unless it points to ourselves *or* mnt_ns is
> NULL
> 	* reachable from mount hash => add 1
> 	* in addition to the wart around namespace_unlock(), we have a similar
> wart between mntput_no_expire() and cleanup_mnt(), only there we thread the
> suckers on mnt_child instead of mnt_list and use slightly different logics to
> prevent shutdown of parent fs before the dput(mountpoint).

BTW, there's something I wanted to do for a while - these games with
delaying dput(mountpoint) look a whole lot like a job for mnt_pin_kill().

Look: even now we have (at the exit from umount_tree()) a bunch of remnant
mountpoints associated with ex-parents.  And we want to have them taken
out and shot before said ex-parents shut down.  The tricky part here is
ordering - at the beginning of namespace_unlock() we have a bunch of
mounts about to be dropped; quite a few might be keeping references to
the ex-mountpoints.  We want mntput() on all of those *and* we want
dput() on said ex-mountpoints.  We'd already dropped the references to
ex-parents (in umount_tree()).  The trouble being, some of those ex-mountpoints
might be on other victim mounts and we really do NOT want to drop such a victim
until all dput() within it had been done.

That's why we play those games with bumping ex-parent mount counts first,
so that dput() is immediately followed with matching mntput().

But we don't have to do it that way.  Alternative, and IMO a cleaner one,
would be to embed struct fs_pin into struct mount and, in umount_tree()
simply add that fs_pin->m_list into the ->mnt_pins of parent and ->s_list
into a global list (replacement of 'unmounted').  With ->kill() callback
dropping references to dentry of mountpoint *and* containing mount.  Then
we don't need to care about the ordering at all - we just go through the
global list of fs_pin and do ->kill() on all of them, in whatever order they
happen to be.  If mount gets dropped while there still are ex-mountpoints on
it waiting to be dropped - fine, we'll just drop them there and then (from
mnt_kill_pins()).  No games with refcounts that way, no transiently busy
mounts, which we do have right now.

And that scheme actually covers your "delayed detaching" just fine - if we
want detaching to be delayed until the parent really buys it, all we need to
do is to skip dropping the child from mnt_mounts of parent and putting fs_pin
of child on the global list.  And detach_mount() on all remaining children
at mntput_no_expire() time, as you do, only with removal from child list.

No changes needed in cleanup_mnt() that way - remaining fs_pin of children
will play out, yielding the effect you want.  

The problem with that approach (and the reason why it hadn't been done yet)
is that we'll need some careful tweaking of locking in fs/fs_pin.c.  Back
in 3.17 I really wanted to get the kernel/acct.c crap out of the way, so that
umount-on-rmdir stuff could be done safely.  So the minimal solution went in,
with plans for using it to avoid the headache with ordering left for later.
I had completely missed the possibility to do less eager dissolving of
detached trees that way (and it was a long-standing wishlist thing) back
then, or I probably would've bitten the bullet and gone for it.

What you are proposing is
	a) easily expressed with that scheme (behaviour is almost identical
to what your series does, except that we'd empty mnt_child right in
mntput_no_expire(), rather than keeping it until cleanup_mnt()) and
	b) easily generalized to MNT_DETACH with lazy dissolving; in fact,
the only difference would be to treat *all* submounts as "don't put on
global list, don't remove from child list", not just the MNT_LOCKED ones.

I'll play around with that today and tomorrow; hopefully, I'll have a postable
variant by the weekend...
