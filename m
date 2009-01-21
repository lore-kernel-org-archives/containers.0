From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH] NOOP cgroup subsystem
Date: Tue, 20 Jan 2009 18:36:50 -0800
Message-ID: <1232505410.15636.142.camel__34741.0636408769$1232505586$gmane$org@localhost>
References: <20090109143226.b79d21b4.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830901082226h6d47053cp801dafb67b6e2bc9@mail.gmail.com>
	<20090109153219.dd8c153d.kamezawa.hiroyu@jp.fujitsu.com>
	<1232072445.7955.40.camel@localhost>
	<6599ad830901191752o53926bdbve593301aeff7330f@mail.gmail.com>
	<20090120120728.9be81131.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090120120728.9be81131.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 2009-01-20 at 12:07 +0900, KAMEZAWA Hiroyuki wrote:
> On Mon, 19 Jan 2009 17:52:36 -0800
> Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:

<snip>

> > Would it make sense to allow a class of subsystem that explicitly has
> > no state (or at least, has no state that has a global meaning on the
> > machine), so that it can be multiply-mounted?
> > 
> multilply-mounted means its own hierachy can be created per mount point ?

I suspect that's what Paul meant -- multiple, distinct instances of the
subsystem could be mounted.

> If so, signal subsystem can be used instead of noop.

Agreed.

Cheers,
	-Matt Helsley
