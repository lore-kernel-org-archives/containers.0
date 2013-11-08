From: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Subject: Re: [REVIEW][PATCH 1/4] vfs: Don't allow overwriting mounts in the
	current mount namespace
Date: Fri, 8 Nov 2013 21:35:51 +0000
Message-ID: <20131108213551.GR13318__38581.0604239397$1383946581$gmane$org@ZenIV.linux.org.uk>
References: <87li23trll.fsf@tw-ebiederman.twitter.com>
	<CAJfpegv+h7xh_2e-X7is9dq1Fp06A0eKwsyWFMPX=azbbDCX5Q@mail.gmail.com>
	<87vc15mjuw.fsf@xmission.com>
	<CAJfpegvF89LzAvNB0h0otv7sKoS3rewZzQKAauQx3P+rCkCcSg@mail.gmail.com>
	<87iox38fkv.fsf@xmission.com> <87d2nb8dxy.fsf@xmission.com>
	<87iowyxpci.fsf_-_@xmission.com> <87d2n6xpan.fsf_-_@xmission.com>
	<20131103035406.GA8537@ZenIV.linux.org.uk>
	<87bo1u8vmf.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87bo1u8vmf.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Linux-Fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Matthias Schniedermeyer <ms-QGhoYOTWWTg@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Nov 08, 2013 at 12:51:52PM -0800, Eric W. Biederman wrote:

> The return value of d_mountpoint can be obsolete as soon as it returns
> as well, so I don't see this as being significantly different.

Not if the ->i_mutex of that sucker is held.  And it *is* held in
vfs_unlink/vfs_rmdir/vfs_rename.  Note that we only care about a mountpoint
being falsely assumed to be a non-mountpoint - in the other direction we
can just shrug and say that we'd won the race and got EBUSY for that.

> In 3.12 vfs_rmdir checks d_mountpoint with the
> dentry->d_inode->i_mutex and
> dentry->d_parent->d_inode->i_mutex held.
> 
> In 3.12 vfs_unlink checks d_mountpoint with the
> dentry->d_inode->i_mutex and
> dentry->d_parent->d_inode->i_mutex hel.d
> 
> In 3.12 vfs_rename_dir and vfs_rename_other checks d_mountpint with the
> target->i_mutex, new_dir->i_mutex, and old_dir->i_mutex held.
> 
> 
> Therefore the guarantees in 3.12 are:
> - unlink versus mount races are prevented by the
>   dentry->d_inode->i_mutex of the dentry being removed.
> - unlink versus umount races are uninteresting.
> - mount versus rename races in testing of d_mountpoint are ignored.

Read what you've written a few lines above.  The part about target->i_mutex
being held.

> So comparing this to how I have implemented covered the test is at a
> slightly different location in the call path so there may be a slightly
> larger race in rename.

You've got a race in unlink.  You've got a race in rename.  You've got a race
in rmdir.  And none of those had that race in 3.12 (including rename()).

BTW, could you describe the races with umount in a bit more details?  Races
with mount are simple - rmdir() sees that victim isn't a mountpoint and
proceeds, mount() sees that victim is still alive and proceeds, despite
the fact that victim is irretrievably on the way to removal.  And that's
what ->i_mutex on victim prevents, making "check for d_mountpoint / remove /
call dont_mount()" atomic wrt mount().  What is the problem you are seeing
with umount()?  rmdir() getting EBUSY because it hasn't noticed umount()
happening in parallel with it?  Legitimate behaviour, as far I can see...
Or is it about something different?
