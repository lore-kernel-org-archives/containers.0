From: Tycho Andersen <tycho-E0fblnxP3wo@public.gmane.org>
Subject: Re: [RFC 1/3] seccomp: add a return code to trap to userspace
Date: Wed, 14 Feb 2018 10:23:00 -0700
Message-ID: <20180214172300.7v2pre4rv4zzrj3s__22896.9174939722$1518628887$gmane$org@cisco>
References: <20180204104946.25559-1-tycho@tycho.ws>
	<20180204104946.25559-2-tycho@tycho.ws>
	<CAGXu5jLAAKY19a9iC1PmXRyuwdn1Zxr2Cb318zdzkqgYt8vtdg@mail.gmail.com>
	<20180214152958.cjgwh2k52zji2jxk@cisco>
	<CALCETrXeZZfVzXh7SwKhyB=+ySDk5fhrrdrXrcABsQ=JpQT7Tg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CALCETrXeZZfVzXh7SwKhyB=+ySDk5fhrrdrXrcABsQ=JpQT7Tg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Akihiro Suda <suda.akihiro-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Paul Moore <pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Tyler Hicks <tyhicks-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Feb 14, 2018 at 05:19:52PM +0000, Andy Lutomirski wrote:
> On Wed, Feb 14, 2018 at 3:29 PM, Tycho Andersen <tycho-E0fblnxP3wo@public.gmane.org> wrote:
> > Hey Kees,
> >
> > Thanks for taking a look!
> >
> > On Tue, Feb 13, 2018 at 01:09:20PM -0800, Kees Cook wrote:
> >> On Sun, Feb 4, 2018 at 2:49 AM, Tycho Andersen <tycho-E0fblnxP3wo@public.gmane.org> wrote:
> >> > This patch introduces a means for syscalls matched in seccomp to notify
> >> > some other task that a particular filter has been triggered.
> >> >
> >> > The motivation for this is primarily for use with containers. For example,
> >> > if a container does an init_module(), we obviously don't want to load this
> >> > untrusted code, which may be compiled for the wrong version of the kernel
> >> > anyway. Instead, we could parse the module image, figure out which module
> >> > the container is trying to load and load it on the host.
> >> >
> >> > As another example, containers cannot mknod(), since this checks
> >> > capable(CAP_SYS_ADMIN). However, harmless devices like /dev/null or
> >> > /dev/zero should be ok for containers to mknod, but we'd like to avoid hard
> >> > coding some whitelist in the kernel. Another example is mount(), which has
> >> > many security restrictions for good reason, but configuration or runtime
> >> > knowledge could potentially be used to relax these restrictions.
> >>
> >> Related to the eBPF seccomp thread, can the logic for these things be
> >> handled entirely by eBPF? My assumption is that you still need to stop
> >> the process to do something (i.e. do a mknod, or a mount) before
> >> letting it continue. Is there some "wait for notification" system in
> >> eBPF?
> >
> > I replied in the other thread
> > (https://patchwork.ozlabs.org/cover/872938/#1856642 for those
> > following along at home), but no, at least not that I know of.
> 
> eBPF can call functions.  One of those functions could put the caller
> to sleep.  In fact, I think I once proposed doing this for the seccomp
> logging action as well.

Yes, true. We could always add a bpf_func_map_lookup_wait or
something. I can look into that if it's preferable.
