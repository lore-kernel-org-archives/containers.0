From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH v6 4/5] fuse: Ensure posix acls are translated outside of
	init_user_ns
Date: Mon, 26 Feb 2018 10:35:17 -0600
Message-ID: <87zi3v1zga.fsf@xmission.com>
References: <878tbmf5vl.fsf@xmission.com>
	<20180221202908.17258-4-ebiederm@xmission.com>
	<CAOssrKeNLBeMkMrrCeRBO9Z80zFxCCEygKL3DErnQ9xBoLkH0g@mail.gmail.com>
	<87inao6dfa.fsf@xmission.com> <87mv004p0t.fsf@xmission.com>
	<CAOssrKd+c0Mx+=S-+zr1QS8a37Pm=VGki=FVR+LXQZBsk3byqA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAOssrKd+c0Mx+=S-+zr1QS8a37Pm=VGki=FVR+LXQZBsk3byqA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Miklos Szeredi's message of "Mon, 26 Feb 2018 08:47:21 +0100")
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

Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> On Thu, Feb 22, 2018 at 11:50 PM, Eric W. Biederman
> <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>
>> So if we could figure out how to use the generic acl support for the old
>> brand of fuse filesystems that don't set FUSE_POSIX_ACL it would be much
>> easier to support them long term.
>
> Simplest and most robust way seems to be to do everything the same (as
> with FUSE_POSIX_ACL) but tell the vfs not to cache the acl.

Good point.  That sounds like for the !fc->posix_acl case we just
need a careful use of "forget_all_cached_acls(inode)".

I will take a quick look at that, and see if that is easy/sufficient to
cover the legacy fuse case.  Otherwise I will go with what I already
have here.

That feels like a better path.  And internally I would call what is
today fc->posix_acl fc->cached_posix_acl.  To better convey the intent.
Fingers crossed.

Eric
