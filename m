From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH][BUGFIX] cgroups: fix pid namespace bug
Date: Thu, 2 Jul 2009 08:26:59 -0500
Message-ID: <20090702132659.GA8051__29977.3419778377$1246541304$gmane$org@us.ibm.com>
References: <4A4C0C60.4050106@cn.fujitsu.com>
	<6599ad830907011836x5eccc83eyc896a67295a6486d@mail.gmail.com>
	<4A4C18D5.7020806@cn.fujitsu.com>
	<6599ad830907011920r44df4022p53808b574da4a886@mail.gmail.com>
	<4A4C1B33.2030002@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A4C1B33.2030002-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Li Zefan (lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org):
> Paul Menage wrote:
> > On Wed, Jul 1, 2009 at 7:17 PM, Li Zefan<lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> >> But I guess we are going to fix the bug for 2.6.31? So is it ok to
> >> merge a new feature 'cgroup.procs' together into 2.6.31?
> >>
> > 
> > Does this bug really need to be fixed for 2.6.31? I didn't think that
> > the namespace support in mainline was robust enough yet for people to
> > use them for virtual servers in production environments.

I don't know where the bar is for 'production environments', but I'd
have to claim that pid namespaces are there...

> If so, it's ok for me. Unless someone else has objections. Serge?

Well, on the one hand it's not a horrible bug in that at least it
won't crash the kernel.  But what bugs me is that there is no
workaround for userspace, no way for an admin to know that if he
does for t in `cat /cgroup/victim/tasks`; do kill $t; done he
won't kill his mysql server.

I think that's a bad enough risk to make it worth trying to push
Li's patch.  Surely changing Ben's procs file should be pretty
trivial to rebase?

thanks,
-serge
