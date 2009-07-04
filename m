From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/2] Adds a read-only "procs" file similar to "tasks" that
	shows only unique tgids
Date: Sat, 4 Jul 2009 09:10:58 -0700
Message-ID: <6599ad830907040910k5c9d720bqafdf596bbc005783__14137.8185981468$1246723912$gmane$org@mail.gmail.com>
References: <20090702231814.3969.44308.stgit@menage.mtv.corp.google.com>
	<20090702232620.3969.16680.stgit@menage.mtv.corp.google.com>
	<20090702164649.303c4952.akpm@linux-foundation.org>
	<2f86c2480907021731h13e0bb95q94f06829eded9aa6@mail.gmail.com>
	<20090702175341.fd2e26d5.akpm@linux-foundation.org>
	<6599ad830907021808o6f3bb51eh324e4bf13544d83e@mail.gmail.com>
	<20090702183004.1e3f4315.akpm@linux-foundation.org>
	<20090703145441.f526793f.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830907030852p2cd667e3m353d68448e0cdc6a@mail.gmail.com>
	<3f9558558c68d9e2fe00f7c7681c3764.squirrel@webmail-b.css.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <3f9558558c68d9e2fe00f7c7681c3764.squirrel-n3SY6/QrmYVJe+uFzlzAcYO9/linGGC/AL8bYrjMMd8@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, lizf-BthXqXjhjHXBeW8qKU6YJg@public.gmane.org, Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

2009/7/3 KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>:
> Anyway, above algorithm shows that it's enough to have per-cgroup bitmap
> (size can be dinamically changed) rather than big table and ugly sort().
> How about adding per-cgroup taskid bitmap ?
> clear/set is very easy.
>

A per-cgroup bitmap of task ids would mean (assuming that it's
implemented as a sparse tree like an IDA) that you'd add extra
allocations and possible failure points in the fork path - right now
the fork overhead imposed by the cgroups framework itself is just
linking yourself into your parent's css_set and bumping its refcount.
I guess there probably are workloads where doing more work at
fork/exit time and less at "tasks" scan time is a win, but that has to
be balanced against those where fork/exit performance is more
critical, and the fact that it would be adding another way that fork
could fail.

Paul
