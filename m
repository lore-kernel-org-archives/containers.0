From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/2] Send a SIGCHLD to the init's pid namespace parent
	when reboot
Date: Thu, 25 Aug 2011 17:37:32 +0200
Message-ID: <20110825153732.GA4784__37126.0769585662$1314286977$gmane$org@redhat.com>
References: <20110819152416.GA17034@redhat.com> <4E524B73.3050704@free.fr>
	<20110822154448.GA8527@redhat.com>
	<20110822183134.10390b46@neptune.home>
	<20110822173949.GA13242@redhat.com>
	<20110822211716.7c141d5c@neptune.home>
	<20110823133302.GA19582@redhat.com>
	<1314108566.3465.29.camel@bahia.local>
	<20110823142914.GA22593@redhat.com>
	<20110824214418.474b24c6@neptune.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110824214418.474b24c6-hY15tx4IgV39zxVx7UNMDg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Bruno =?iso-8859-1?Q?Pr=E9mont?= <bonbons-ud5FBsm0p/xEiooADzr8i9i2O/JbrIOy@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 08/24, Bruno Pr=E9mont wrote:
>
> On Tue, 23 August 2011 Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> >
> > Just in case... instead of WIFSIGNALED/WTERMSIG we can also report
> > the exit code in the upper bits. I mean,
> >
> > 	switch (reboot_cmd) {
> > 	case LINUX_REBOOT_CMD_RESTART:
> > 		code =3D 1 << 16;
> > 		break;
> > 	case LINUX_REBOOT_CMD_HALT:
> > 		code =3D 2 << 16;
> > 		break;
> > 	}
>
> That looks nice and simple!

Great. To me, WIFSIGNALED() looks better, but this is subjective and
in any case this is up to you.

> > this can't be confused with the normal exit(code), just the parent
> > should be careful, I am not sure this can't confuse WIFEXITED/WEXITSTAT=
US
> > user-space macroses.
>
> For recent glibc (2.12.2):
> sys/wait.h and stdlib.h:
> # define WIFEXITED(status) __WIFEXITED (__WAIT_INT (status))
> # define WEXITSTATUS(status)       __WEXITSTATUS (__WAIT_INT (status))
> bits/waitstatus.h:
> #define     __WIFEXITED(status)     (__WTERMSIG(status) =3D=3D 0)
> #define     __WTERMSIG(status)      ((status) & 0x7f)
> #define     __WEXITSTATUS(status)   (((status) & 0xff00) >> 8)

... and note that __WEXITSTATUS() does "& 0xff00", it uses the
lower 16 bits.

So the parent should read status "by hand". Not a problem, I think.
Say, a traced task reports the additional info this way.

Oleg.
