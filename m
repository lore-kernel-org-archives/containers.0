From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v4 0/4] cgroup notifications API and memory thresholds
Date: Mon, 4 Jan 2010 05:45:16 +0530
Message-ID: <20100104001516.GE16187__23211.4407736391$1262564166$gmane$org@balbir.in.ibm.com>
References: <cover.1261858972.git.kirill@shutemov.name>
	<20091227124732.GA3601@balbir.in.ibm.com>
	<cc557aab0912271037scb29fe1xcebe9adfaea97b24@mail.gmail.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <cc557aab0912271037scb29fe1xcebe9adfaea97b24-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Cc: Alexander Shishkin <virtuoso-0lOfPCoBze7YtjvyW6yDsg@public.gmane.org>, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Dan Malek <dan-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Vladislav Buzov <vbuzov-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

* Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org> [2009-12-27 20:37:57]:

> On Sun, Dec 27, 2009 at 2:47 PM, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>=
 wrote:
> > * Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org> [2009-12-27 04:08:58]:
> >
> >> This patchset introduces eventfd-based API for notifications in cgroup=
s and
> >> implements memory notifications on top of it.
> >>
> >> It uses statistics in memory controler to track memory usage.
> >>
> >> Output of time(1) on building kernel on tmpfs:
> >>
> >> Root cgroup before changes:
> >> =A0 =A0 =A0 make -j2 =A0506.37 user 60.93s system 193% cpu 4:52.77 tot=
al
> >> Non-root cgroup before changes:
> >> =A0 =A0 =A0 make -j2 =A0507.14 user 62.66s system 193% cpu 4:54.74 tot=
al
> >> Root cgroup after changes (0 thresholds):
> >> =A0 =A0 =A0 make -j2 =A0507.13 user 62.20s system 193% cpu 4:53.55 tot=
al
> >> Non-root cgroup after changes (0 thresholds):
> >> =A0 =A0 =A0 make -j2 =A0507.70 user 64.20s system 193% cpu 4:55.70 tot=
al
> >> Root cgroup after changes (1 thresholds, never crossed):
> >> =A0 =A0 =A0 make -j2 =A0506.97 user 62.20s system 193% cpu 4:53.90 tot=
al
> >> Non-root cgroup after changes (1 thresholds, never crossed):
> >> =A0 =A0 =A0 make -j2 =A0507.55 user 64.08s system 193% cpu 4:55.63 tot=
al
> >>
> >> Any comments?
> >
> > Thanks for adding the documentation, now on to more critical questions
> >
> > 1. Any reasons for not using cgroupstats?
> =

> Could you explain the idea? I don't see how cgroupstats applicable for
> the task.

cgroupstats allows you to notify task statistics or send
notifications, hence the applicability.

> =

> > 2. Is there a user space test application to test this code.
> =

> Attached. It's not very clean, but good enough for testing propose.
> Example of usage:
> =

> $ echo '/cgroups/memory.usage_in_bytes 1G' | ./cgroup_event_monitor
> =


Thanks, I'll test it right now.

> > =A0IIUC,
> > I need to write a program that uses eventfd(2) and then passes
> > the eventfd descriptor and thresold to cgroup.*event* file and
> > then the program will get notified when the threshold is reached?
> =

> You need to pass eventfd descriptor, descriptor of control file to be
> monitored (memory.usage_in_bytes or memory.memsw.usage_in_bytes) and
> threshold.
> =

> Do you want to rename cgroup.event_control to cgroup.event?

No, event_control seems like a good name ATM.


-- =

	Balbir
