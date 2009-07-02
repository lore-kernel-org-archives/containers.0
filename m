From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH][BUGFIX] cgroups: fix pid namespace bug
Date: Thu, 2 Jul 2009 11:15:49 -0500
Message-ID: <20090702161548.GA13383__29448.6749372028$1246551472$gmane$org@us.ibm.com>
References: <4A4C0C60.4050106@cn.fujitsu.com>
	<6599ad830907011836x5eccc83eyc896a67295a6486d@mail.gmail.com>
	<4A4C18D5.7020806@cn.fujitsu.com>
	<6599ad830907011920r44df4022p53808b574da4a886@mail.gmail.com>
	<4A4C1B33.2030002@cn.fujitsu.com>
	<20090702132659.GA8051@us.ibm.com>
	<6599ad830907020843l7ce75abfq3e78b8f67a407ab9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <6599ad830907020843l7ce75abfq3e78b8f67a407ab9-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Paul Menage (menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org):
> On Thu, Jul 2, 2009 at 6:26 AM, Serge E. Hallyn<serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> > Quoting Li Zefan (lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org):
> >> Paul Menage wrote:
> >> > On Wed, Jul 1, 2009 at 7:17 PM, Li Zefan<lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> >> >> But I guess we are going to fix the bug for 2.6.31? So is it ok to
> >> >> merge a new feature 'cgroup.procs' together into 2.6.31?
> >> >>
> >> >
> >> > Does this bug really need to be fixed for 2.6.31? I didn't think that
> >> > the namespace support in mainline was robust enough yet for people to
> >> > use them for virtual servers in production environments.
> >
> > I don't know where the bar is for 'production environments', but I'd
> > have to claim that pid namespaces are there...
> 
> Well, pid namespaces are marked as experimental, as are user
> namespaces (and were described as "very incomplete" a few months

incomplete (due to signaling issues which have mostly been resolved)
but stable and usable.

user namespace are a completely different story :)

> back). Pid namespaces are useful for process migration (which is still
> under development) or virtual servers (for which user namespaces are
> pretty much essential). So I'm not sure quite what you'd use pid
> namespaces for yet.

You don't need user namespaces to use pid namespaces for virtual
servers (depending on your use).

Now the fact remains this is a hard to trigger bug which doesn't
corrupt the kernel, and - to take back what I said earlier - userspace
can work around it by simply freezing the cgroup before reading its
tasks file.

So I guess I can go either way...  If Li's patch were more complicated
I'd definately be for waiting.  But I do object to the general process
of making a fix of a pretty bad bag depend on an unrelated new feature!

-serge
