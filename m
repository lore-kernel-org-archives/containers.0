From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH v5 00/11] FUSE mounts from non-init user namespaces
Date: Mon, 19 Feb 2018 17:09:51 -0600
Message-ID: <87inaslgow.fsf@xmission.com>
References: <cover.1512741134.git.dongsu@kinvolk.io>
	<877etbcmnd.fsf@xmission.com>
	<CANxcAMvwwiPXBTKmTM9sEo8Y1T--V7fNaFqzHfyEvwvaYQV60A@mail.gmail.com>
	<CADZs7q438szfwd-kaaRDnpDFrmno3zy7Zq+6EsnotW8bS0vrTA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CADZs7q438szfwd-kaaRDnpDFrmno3zy7Zq+6EsnotW8bS0vrTA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Alban Crequy's message of "Thu, 18 Jan 2018 15:58:41 +0100")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>
Cc: Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>
List-Id: containers.vger.kernel.org

Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org> writes:

> Hi Eric,
>
> Do you have some cycles for this now that it is the new year?
>
> A review on the associated ima issue would also be appreciated:
> https://www.mail-archive.com/linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org/msg1587678.html

It has taken me longer than I expected but I do have time now.  I am
moving through these patches and issues a little slowly I do intend to
get us through the fuse issues this development cycle if at all
possible.

I think for starters we should restrict ourselves to the last 4 patches
aka (8, 9, 10, 11).

In particular we should concentrate on
[8/11] fuse: Support fuse filesystems outside of init_user_ns
[9/11] fuse: Restrict allow_other to the superblock's namespace or a descendant

The tricky issues are handled in the vfs, and I think the remaining
tricky issues are evm and ima.  Which are close enough to be resolved
that we can count them as resolved.

Once we have 8 & 9 reviewed and merged we can double check there isn't
some silly reason not to set FS_USERNS_MOUNT on fuse and then enable it.

I would like to double check and ensure there are not silly issues with
posix acls or anything else in the vfs.  But I think except for a silly
oversight we are good.

I should probably also add a patch that adds to
Documentation/filesystems that explains what the vfs does for
unprivileged mounts.  So that I can point people working on filesystems
and are thinking about enabling user namespace mounts at the
documentation for what the vfs does.  That would also provide a good
checklist to ensure the way the vfs handles things is sufficient for
fuse.

As for the earlier patches that enable things.  Overall they are
good.  They are slightly dangerous as they enable more code paths
to unprivileged users.  But mostly I think they are not immediately
necessary and as such a distraction to getting this code in.

That said once we get the fuse bits reviewed merged I will be more than
happy to merge the relaxation of permission checks that we can perform
now that s_user_ns exists.

Eric
