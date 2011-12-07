From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1][V3] Add reboot_pid_ns to handle the reboot syscall
Date: Wed, 7 Dec 2011 16:12:35 +0100
Message-ID: <20111207151235.GA21962@redhat.com>
References: <1323030290-22216-1-git-send-email-daniel.lezcano@free.fr>
	<1323030290-22216-2-git-send-email-daniel.lezcano@free.fr>
	<20111206171617.e31bc3a6.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20111206171617.e31bc3a6.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Ulrich Drepper <drepper-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 12/06, Andrew Morton wrote:
> On Sun,  4 Dec 2011 21:24:50 +0100
> Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org> wrote:
>
> > This patch propose to store the reboot value in the 16 upper bits of the
> > exit code from the processes belonging to a pid namespace which has
> > rebooted. When the reboot syscall is called and we are not in the initial
> > pid namespace, we kill the pid namespace.
> >
> > By this way the parent process of the child pid namespace to know if
> > it rebooted or not and take the right decision.
>
> hm, modifying the exit code in this manner is a strange interface.  I
> didn't see that coming.  Perhaps some additional justification for this
> idea should be added to the changelog, along with discussion of
> alternative schemes.  I don't immediately see any problems with it,
> but, odd...  I wonder what potential it has to upset existing
> userspace.

Alternatively, we could do something like

	switch (reboot) {
	case LINUX_REBOOT_CMD_RESTART:
		exit_code = SIGHUP;
		break;
	case LINUX_REBOOT_CMD_HALT:
		exit_code = SIGINT;
		break;
	...
	}

this way the parent can check WIFSIGNALED/WTERMSIG instead of upper bits.
This was the initial suggestion, and personally I like this more.


But I do not think this can upset existing userspace. __WEXITSTATUS()
reports the lower bits only, it can't see the extra info we add.

> Also, this affects the data delivered by taskstats, I believe.  Please
> check this, test it, document it in the changelog and update
> getdelays.c appropriately.

No, taskstats report ->exit_code. This doesn't look right btw. But
in any case I do not think this can break something.

> Also, glibc might be affected.  For symmetry we might want to add a
> WIFREBOOT() or something.

We already use these upper bits to report the ptrace events, in the
same manner. I do not think this has something to do with libc.

Although it could probably have another macro to read this info.

> And we now expect waitid() to fill in extra
> bits in siginfo_t.si_status, which assumes that glibc (and other
> libc's!) aren't using a u8 in there somewhere.  etcetera.  This all
> should be tested, and reviewed by Uli (please).

Again, ptrace already puts the extra info this way when the tracee
stops.

Oleg.
