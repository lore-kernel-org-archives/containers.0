From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: Testing lxc 0.6.5 in Fedora 13
Date: Fri, 26 Mar 2010 12:11:31 +0100
Message-ID: <20100326111131.GA8604__8588.50900917805$1269602042$gmane$org@redhat.com>
References: <20100321195044.GA23757@megiteam.pl>
	<20100323212834.GH20796@count0.beaverton.ibm.com>
	<20100325213356.GB20541@megiteam.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100325213356.GB20541-yp6mvK3Bdd2rDJvtcaxF/A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 03/25, Grzegorz Nosek wrote:
>
> On wto, mar 23, 2010 at 02:28:34 -0700, Matt Helsley wrote:
> > On Sun, Mar 21, 2010 at 08:50:44PM +0100, Grzegorz Nosek wrote:
> >
> > <snip>
> >
> > > 2. Weird strace behaviour across pidns boundary
> > >
> > > When strace'ing (with -ff) lxc-start, I get a proper strace for the
> > > directly spawned process and the container init. However, any processes
> > > spawned by the container's init are not straced properly

Yes, this is broken. More precisely, this wasn't even supposed to work.

Even stracing of the sub-init itself (or global init btw) has problems,
the straced init is not protected from unwanted signals.

> > I'm suprised strace of ls works across pid namespaces. I've been looking
> > at strace and it seemed to me that one kernel change and a bunch of strace
> > changes are needed to make strace'ing in child pid namespaces work.

Yes. First of all, tracehook_report_clone_complete() reports the wrong pid nr,
as it seen inside the init's namespace. This is easy to fix, but I doubt this
can help. IIRC strace doesn't use PTRACE_GETEVENTMSG at all, it looks at eax
after syscall.

> Eric
> > Biederman's setns() patches also might help.
>
> Thanks for the patch and the detailed explanation.

which patch?

Oleg.
