From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH v6 4/5] fuse: Ensure posix acls are translated outside of
	init_user_ns
Date: Thu, 22 Feb 2018 16:50:58 -0600
Message-ID: <87mv004p0t.fsf@xmission.com>
References: <878tbmf5vl.fsf@xmission.com>
	<20180221202908.17258-4-ebiederm@xmission.com>
	<CAOssrKeNLBeMkMrrCeRBO9Z80zFxCCEygKL3DErnQ9xBoLkH0g@mail.gmail.com>
	<87inao6dfa.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87inao6dfa.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (Eric W. Biederman's message of
	"Thu, 22 Feb 2018 13:18:33 -0600")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman) writes:

> Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
>
>> On Wed, Feb 21, 2018 at 9:29 PM, Eric W. Biederman
>> <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>>> Ensure the translation happens by failing to read or write
>>> posix acls when the filesystem has not indicated it supports
>>> posix acls.
>>
>> For the first iteration this is fine, but  we could convert the raw
>> xattrs as well, if we later want to, right?
>
> I will say maybe.  This is tricky.   The code would not be too hard,
> and the function to do the work posix_acl_fix_xattr_userns already
> exists in fs/posix_acl.c
>
> I don't actually expect that to work longterm.  I expect the direction
> the kernel internals are moving is that all filesystems that implement
> posix acls will be expected to implement .get_acl and .set_acl.
>
> I would have to reread the old thread that got us to this point with
> posix acls before I could really understand the backwards compatible
> fuse use case, and I would have to reread the rest of the acl processing
> in the kernel before I could recall exactly what makes sense.
>
> If there was an obvious way to whitelist xattrs that fuse can support
> for user namespaces I think I would go for that.  Just to avoid future
> problems with future xattrs.

I am remembering why this is such a sticky issue.

Today when a posix acl is read from user space the code does:
      posix_acl_to_xattr(&init_user_ns, ...) in posix_acl_xattr_get
      posix_acl_fix_xattr_to_user() in getxattr

Similary when a posix acl is written from user space the code does:
      posix_acl_fix_xattr_from_user() in setxattr
      posix_acl_from_xattr(&init_user_us, ...) in posix_acl_xattr_set

If every posix acl supporting filesystem in the kernel would use
posix_acl_access_xattr_handler and posix_acl_default_xattr_handler the
function posix_acl_fix_xattr_to_user and posix_acl_fix_xattr_from_user
and posix_acl_fix_xattr_userns could all be removed and the posix acl
handling could be that little bit simpler and faster.

So if we could figure out how to use the generic acl support for the old
brand of fuse filesystems that don't set FUSE_POSIX_ACL it would be much
easier to support them long term.

Eric
