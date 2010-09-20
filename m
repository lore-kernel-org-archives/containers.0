From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] exec: move core_pattern pipe helper into the
	crashing namespace
Date: Mon, 20 Sep 2010 20:50:01 +0200
Message-ID: <20100920185001.GA955__4835.42735823921$1285012966$gmane$org@redhat.com>
References: <20100917152639.0e88341a@basil.nowhere.org>
	<1284736618-27153-2-git-send-email-wad@chromium.org>
	<20100918012939.GA25046@redhat.com>
	<AANLkTimsNtoT2GGCv1Zk2cGCsZ17zsOqV1DiF7D5tV=L@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AANLkTimsNtoT2GGCv1Zk2cGCsZ17zsOqV1DiF7D5tV=L@mail.gmail.com>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Eugene Teo <eteo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

On 09/17, Will Drewry wrote:
>
> On Fri, Sep 17, 2010 at 8:29 PM, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> >
> > This looks overcomplicated to me, or I missed something.
> >
> > I do not understand why should we do this beforehand, and why we need
> > copy_namespaces_unattached().
> >
> > Can't you just pass current to umh_pipe_setup() (or another helper) as
> > the argument? Then this helper can copy ->fs and ->nsproxy itself.
>
> I wasn't sure if it was reasonable to pass the current task_struct
> over, but I certainly can.

Why not? current calls call_usermodehelper_exec(), it can't go away
until subprocess_info->init() returns, it sleeps on wait_for_completion().

> In practice, this seems to amount to just adding a refcount to all the
> namespaces and creating a new nsproxy which isn't really needed.  Most
> likely, doing what you've suggested above plus the copy_fs_struct and
> the swap out will do the trick.  I'll try it out and see.  That's make
> it much clearer I think.

Yes, just get_nsproxy() (like fork() does) should be fine in this case.

As for copying ->fs, I am not sure actually. core_pattern is global,
say it is "|/coredumper". If you change ->root, then exec can fail
because that binary is not visible to the coredumping process?

Probably we should move core_pattern into ->pid_ns, I dunno.

Oleg.
