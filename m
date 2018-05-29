From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [REVIEW][PATCH 0/6] Wrapping up the vfs support for unprivileged
	mounts
Date: Tue, 29 May 2018 08:12:28 -0500
Message-ID: <8736yar4g3.fsf__5339.96565868637$1527599523$gmane$org@xmission.com>
References: <87o9h6554f.fsf@xmission.com> <20180524214617.GG7712@thunk.org>
	<87y3g8y6x9.fsf@xmission.com> <20180525035716.GE10363@dastard>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20180525035716.GE10363@dastard> (Dave Chinner's message of "Fri,
	25 May 2018 13:57:16 +1000")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
Cc: "Theodore Y. Ts'o" <tytso-3s7WtUTddSA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christian Brauner <christian-STijNZzMWpgWenYVfaLwtA@public.gmane.org>
List-Id: containers.vger.kernel.org

Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org> writes:

> On Thu, May 24, 2018 at 06:23:30PM -0500, Eric W. Biederman wrote:
>> "Theodore Y. Ts'o" <tytso-3s7WtUTddSA@public.gmane.org> writes:
>> 
>> > On Wed, May 23, 2018 at 06:22:56PM -0500, Eric W. Biederman wrote:
>> >> 
>> >> Very slowly the work has been progressing to ensure the vfs has the
>> >> necessary support for mounting filesystems without privilege.
>> >
>> > What's the thinking behind how system administrators and/or file
>> > systems would configure whether or not a particular file system type
>> > will be allowed to be mounted w/o privilege?
>> 
>> The mechanism is .fs_flags in file_system_type.   If the FS_USERNS_MOUNT
>> flag is set then root in a user namespace (AKA an unprivileged user)
>> will be allowed to mount to mount the filesystem.
>> 
>> There are very real concerns about attacking a filesystem with an
>> invalid filesystem image, or by a malicious protocol speaker.  So I
>> don't want to enable anything without the file system maintainers
>> consent and without a reasonable expecation that neither a system wide
>> denial of service attack nor a privilege escalation attack is possible
>> from if the filesystem is enabled.
>> 
>> So at a practical level what we have in the vfs is the non-fuse specific
>> bits that enable unprivileged mounts of fuse.  Things like handling
>> of unmapped uid and gids, how normally trusted xattrs are dealt with,
>> etc.
>> 
>> A big practical one for me is that if either the uid or gid is not
>> mapped the vfs avoids writing to the inode.
>> 
>> Right now my practical goal is to be able to say: "Go run your
>> filesystem in userspace with fuse if you want stronger security
>> guarantees."  I think that will be enough to make removable media
>> reasonably safe from privilege escalation attacks.
>> 
>> There is enough code in most filesystems that I don't know what our
>> chances of locking down very many of them are.  But I figure a few more
>> of them are possible.
>
> I'm not sure we need to - fusefs-lkl gives users the ability to
> mount any of the kernel filesystems via fuse without us needing to
> support unprivileged kernel mounts for those filesystems.

Maybe.

That certainly seems like a good proof of concept for running
ordinary filesystems with fuse.  If we are going to rely on it
someone probably needs to do the work to merge arch/lkl into the
main tree.  My quick look suggests that the lkl port lags behind
a little bit and has just made it to 4.16.

Is fusefs-lkl valuable for testing filesystems?  If xfs-tests were to
have a mode that used that used the fuse protocol for testing and
fuzzing filesystems without the full weight of the kernel in the middle
that might encourage people to suppor this kind of things as well.

Eric
