From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 07/11] fs: Allow CAP_SYS_ADMIN in s_user_ns to freeze and
	thaw filesystems
Date: Mon, 19 Feb 2018 16:56:56 -0600
Message-ID: <87mv04mvuv.fsf@xmission.com>
References: <cover.1512741134.git.dongsu@kinvolk.io>
	<61a37f0b159dd56825696d8d3beb8eaffdf1f72f.1512041070.git.dongsu@kinvolk.io>
	<CAOssrKeSTY1pAhpmegFWdGh7irNbT4veG5JaYFj8Q1JjMynadw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAOssrKeSTY1pAhpmegFWdGh7irNbT4veG5JaYFj8Q1JjMynadw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Miklos Szeredi's message of "Wed, 14 Feb 2018 13:28:12 +0100")
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> On Fri, Dec 22, 2017 at 3:32 PM, Dongsu Park <dongsu-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org> wrote:
>> From: Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
>>
>> The user in control of a super block should be allowed to freeze
>> and thaw it. Relax the restrictions on the FIFREEZE and FITHAW
>> ioctls to require CAP_SYS_ADMIN in s_user_ns.
>
> Why is this required for unprivileged fuse?
>
> Fuse doesn't support freeze, so this seems to make no sense in the
> context of this patchset.

This isn't required to support fuse.  It is a relaxation in permissions
so it isn't strictly necessary for anything.

Until just recently Seth and I work working through the vfs looking at
what we need in general for unprivileged mounts.  With fuse as our focus
but we were not limiting ourselves to fuse.

I have been putting off relaxation of permissions like this because they
are not necessary for safety.  But in general they do make sense.

In practice I think all we need to worry about for fuse is the last 4 patches.


Eric
