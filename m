From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH] NOOP cgroup subsystem
Date: Mon, 19 Jan 2009 17:52:36 -0800
Message-ID: <6599ad830901191752o53926bdbve593301aeff7330f__17556.1961172663$1232416490$gmane$org@mail.gmail.com>
References: <20090109143226.b79d21b4.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830901082226h6d47053cp801dafb67b6e2bc9@mail.gmail.com>
	<20090109153219.dd8c153d.kamezawa.hiroyu@jp.fujitsu.com>
	<1232072445.7955.40.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1232072445.7955.40.camel@localhost>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Jan 15, 2009 at 6:20 PM, Matthew Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
>
>        My feeling is this should be a signal subsystem rather than a NOOP
> subsystem. Then, if users want the grouping for something besides
> signaling, it doesn't matter if they don't issue any signals via the
> signal.send file. Also, I think Paul's suggestion would be just as
> useful for a signal subsystem.

The signal subsystem is similar to the "no-op" subsystem in that
neither of them actually need any state - in principle, it could be
useful to attach a signal subsys to multiple mounted hierarchies, to
provide signal semantics for each of them.

Would it make sense to allow a class of subsystem that explicitly has
no state (or at least, has no state that has a global meaning on the
machine), so that it can be multiply-mounted?

Paul
