From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH v5 00/11] FUSE mounts from non-init user namespaces
Date: Fri, 16 Feb 2018 15:53:19 -0600
Message-ID: <87y3jssisw.fsf__1650.19566561586$1518817941$gmane$org@xmission.com>
References: <cover.1512741134.git.dongsu@kinvolk.io>
	<CAOssrKey+oxahrXHO5d6Lu1ZD=r1t-b0i4iZM_Ke9ToqTckjkQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAOssrKey+oxahrXHO5d6Lu1ZD=r1t-b0i4iZM_Ke9ToqTckjkQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Miklos Szeredi's message of "Tue, 13 Feb 2018 12:32:09 +0100")
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>
List-Id: containers.vger.kernel.org

Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> On Fri, Dec 22, 2017 at 3:32 PM, Dongsu Park <dongsu-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org> wrote:
>
>> Patches 1-2 deal with an additional flag of lookup_bdev() to check for
>> additional inode permission.
>
> fuse_blk is less suitable for unprivileged mounting than plain fuse.
> fusermount doesn't allow mounting fuse_blk unprivileged, so there's
> little data about that usecase (IIRC ntfs3g guys did that, or at least
> tried to do it, but I don't remember the details).
>
> As such, I think we should leave it out of the initial version.  Which
> means you can drop patches 1-2 from this series.  Unless there's a
> strong use case for this.  In which case we should look hard at the
> differences between fuse_blk and fuse and how that affects
> unprivileged operation.   There are a few assumptions about fuse_blk
> filesystem being more "well behaved", I think.

Especially to start with I am fine with that.

It makes a lot of sense to get the obvious cases first.

Eric
