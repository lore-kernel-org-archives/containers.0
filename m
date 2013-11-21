From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [REVIEW][PATCH 1/4] vfs: Don't allow overwriting mounts in the
	current mount namespace
Date: Thu, 21 Nov 2013 12:49:47 -0800
Message-ID: <87vbzl8opg.fsf@xmission.com>
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

I have been fighting a cold off and on so I have been taking much longer
to dig through all of these issues than I would like.

Aftering having thought through all of the issues I completely agree
that this is a racy bug that needs to be fixed.

The fix needs to be holding i_mutex of the parent directory in do_mount,
and pivot_root.

We need to hold i_mutex in do_mount and pivot_root not because of this
issue but to prevent mount points being renamed before we mount on them.

With todays kernel because of races between when we lookup a mount point
and when we take locks, and which locks we take.  When mount(2) returns
the mount point can be located anywhere.  Which completely defeats
returning -EBUSY mount points from a userspace semantics perspective.

I was really hoping I could think through this and say that this was a
trivial issue that would allow my patches to be good for 3.13.  But that
is clearly not the case.  kern_path_locked(...,LOOKUP_FOLLOW,...) is
non-trivial to implement, and there are issues like having to move
get_fs_type before we take any locks to prevent deadlocks.

I almost have the issues worked through, so hopefully I can send a
rebased set of patches in a few days.

Eric
