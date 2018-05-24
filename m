From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [REVIEW][PATCH 0/6] Wrapping up the vfs support for unprivileged
	mounts
Date: Thu, 24 May 2018 18:23:30 -0500
Message-ID: <87y3g8y6x9.fsf__12867.4165382565$1527204123$gmane$org@xmission.com>
References: <87o9h6554f.fsf@xmission.com> <20180524214617.GG7712@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20180524214617.GG7712-AKGzg7BKzIDYtjvyW6yDsg@public.gmane.org> (Theodore Y. Ts'o's message of
	"Thu, 24 May 2018 17:46:17 -0400")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Theodore Y. Ts'o" <tytso-3s7WtUTddSA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christian Brauner <christian-STijNZzMWpgWenYVfaLwtA@public.gmane.org>
List-Id: containers.vger.kernel.org

"Theodore Y. Ts'o" <tytso-3s7WtUTddSA@public.gmane.org> writes:

> On Wed, May 23, 2018 at 06:22:56PM -0500, Eric W. Biederman wrote:
>> 
>> Very slowly the work has been progressing to ensure the vfs has the
>> necessary support for mounting filesystems without privilege.
>
> What's the thinking behind how system administrators and/or file
> systems would configure whether or not a particular file system type
> will be allowed to be mounted w/o privilege?

The mechanism is .fs_flags in file_system_type.   If the FS_USERNS_MOUNT
flag is set then root in a user namespace (AKA an unprivileged user)
will be allowed to mount to mount the filesystem.

There are very real concerns about attacking a filesystem with an
invalid filesystem image, or by a malicious protocol speaker.  So I
don't want to enable anything without the file system maintainers
consent and without a reasonable expecation that neither a system wide
denial of service attack nor a privilege escalation attack is possible
from if the filesystem is enabled.

So at a practical level what we have in the vfs is the non-fuse specific
bits that enable unprivileged mounts of fuse.  Things like handling
of unmapped uid and gids, how normally trusted xattrs are dealt with,
etc.

A big practical one for me is that if either the uid or gid is not
mapped the vfs avoids writing to the inode.

Right now my practical goal is to be able to say: "Go run your
filesystem in userspace with fuse if you want stronger security
guarantees."  I think that will be enough to make removable media
reasonably safe from privilege escalation attacks.

There is enough code in most filesystems that I don't know what our
chances of locking down very many of them are.  But I figure a few more
of them are possible.

Eric
