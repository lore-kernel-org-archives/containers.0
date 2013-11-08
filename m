From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [REVIEW][PATCH 1/4] vfs: Don't allow overwriting mounts in the
	current mount namespace
Date: Fri, 08 Nov 2013 12:51:52 -0800
Message-ID: <87bo1u8vmf.fsf@xmission.com>
References: <CALCETrWw=htmgxqq=RQztdJQ-a8c3860vmJh9Ni=Hhs0TkO3YA@mail.gmail.com>
	<20131008161135.GK14242@tucsk.piliscsaba.szeredi.hu>
	<87li23trll.fsf@tw-ebiederman.twitter.com>
	<CAJfpegv+h7xh_2e-X7is9dq1Fp06A0eKwsyWFMPX=azbbDCX5Q@mail.gmail.com>
	<87vc15mjuw.fsf@xmission.com>
	<CAJfpegvF89LzAvNB0h0otv7sKoS3rewZzQKAauQx3P+rCkCcSg@mail.gmail.com>
	<87iox38fkv.fsf@xmission.com> <87d2nb8dxy.fsf@xmission.com>
	<87iowyxpci.fsf_-_@xmission.com> <87d2n6xpan.fsf_-_@xmission.com>
	<20131103035406.GA8537@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20131103035406.GA8537-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org> (Al Viro's message of
	"Sun, 3 Nov 2013 03:54:06 +0000")
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
Cc: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Linux-Fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Matthias Schniedermeyer <ms-QGhoYOTWWTg@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org> writes:

> On Tue, Oct 15, 2013 at 01:16:48PM -0700, Eric W. Biederman wrote:
>
>>  int vfs_rmdir(struct inode *dir, struct dentry *dentry)
>>  {
>>  	int error = may_delete(dir, dentry, 1);
>> @@ -3622,6 +3636,9 @@ retry:
>>  		error = -ENOENT;
>>  		goto exit3;
>>  	}
>> +	error = -EBUSY;
>> +	if (covered(nd.path.mnt, dentry))
>> +		goto exit3;
>
> Ugh...  And it's not racy because of...?  IOW, what's to keep the return
> value of covered() from getting obsolete just as it's being calculated,
> let alone returned?

The return value of d_mountpoint can be obsolete as soon as it returns
as well, so I don't see this as being significantly different.

I would like to say that any changes introduced here do not matter
because all of this is just to keep a semblance of the old semantics.
Unfortunately for me part of keeping that semblance is as much as is
reasonable preserving the existing race guarantees.

In 3.12 we create a mount with:
- The dentry->d_inode mutex held.
- The namespace_sem held.

In 3.12 we remove a mount with just the namespace_sem held.

I call covered in: do_rmdir, do_unlinkat, and renameat.

In 3.12 vfs_rmdir checks d_mountpoint with the
dentry->d_inode->i_mutex and
dentry->d_parent->d_inode->i_mutex held.

In 3.12 vfs_unlink checks d_mountpoint with the
dentry->d_inode->i_mutex and
dentry->d_parent->d_inode->i_mutex hel.d

In 3.12 vfs_rename_dir and vfs_rename_other checks d_mountpint with the
target->i_mutex, new_dir->i_mutex, and old_dir->i_mutex held.


Therefore the guarantees in 3.12 are:
- unlink versus mount races are prevented by the
  dentry->d_inode->i_mutex of the dentry being removed.
- unlink versus umount races are uninteresting.
- mount versus rename races in testing of d_mountpoint are ignored.
- umount versus rename races in testing of d_mountpoint are ignored.

So comparing this to how I have implemented covered the test is at a
slightly different location in the call path so there may be a slightly
larger race in rename.

For unlink there is a race where the mount could happen after testing
covered.  Then the unlink happens.  Then we remove the mount with
detach_mounts.


In the context of the symlink attacks against umounting of fuse I don't
see a difference.

In the only case where there is a new race (unlink versus mount) I see
a narrow window where new behavior will happen the unlink will win and
we unmount the filesystem.  So there is a vary narrow window in which
we might have a stale entry in /etc/mtab.

So after all of that analysis I don't think we care.  If we do care with
a little more work we can pass the mountpoint down and test covered with
dentry->d_inode->i_mutex held, where we test d_mountpoint in 3.12 today.

Eric
