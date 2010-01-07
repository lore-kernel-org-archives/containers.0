From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v5 1/4] cgroup: implement eventfd-based generic API for
	notifications
Date: Wed, 6 Jan 2010 17:01:21 -0800
Message-ID: <6599ad831001061701x72098dacn7a5d916418396e33__47345.963252201$1262826123$gmane$org@mail.gmail.com>
References: <cover.1262186097.git.kirill@shutemov.name>
	<9411cbdd545e1232c916bfef03a60cf95510016d.1262186098.git.kirill@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <9411cbdd545e1232c916bfef03a60cf95510016d.1262186098.git.kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
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
Cc: Alexander Shishkin <virtuoso-0lOfPCoBze7YtjvyW6yDsg@public.gmane.org>, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Dan Malek <dan-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Vladislav Buzov <vbuzov-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Dec 30, 2009 at 7:57 AM, Kirill A. Shutemov
<kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org> wrote:
> This patch introduces write-only file "cgroup.event_control" in every
> cgroup.

This looks like a nice generic API for doing event notifications - thanks!

Sorry I hadn't had a chance to review it before now, due to travelling
and day-job pressures.


> +}
> +
> +static int cgroup_event_wake(wait_queue_t *wait, unsigned mode,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int sync, void *key)

Maybe some comments here indicating how/when it gets called? (And more
comments for each function generally?)

> + =A0 =A0 =A0 if (flags & POLLHUP) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&cgrp->event_list_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del(&event->list);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&cgrp->event_list_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 schedule_work(&event->remove);

Comment saying why we can't do the remove immediately in this context?

> +
> +fail:
> + =A0 =A0 =A0 if (!IS_ERR(cfile))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 fput(cfile);

cfile is either valid or NULL - it never contains an error value.

> +
> + =A0 =A0 =A0 if (!IS_ERR(efile))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 fput(efile);

While this is OK currently, it's a bit fragile. efile starts as NULL,
and IS_ERR(NULL) is false. So if we jump to fail: before trying to do
the eventfd_fget() then we'll try to fput(NULL), which will oops. This
works because we don't currently jump to fail: until after
eventfd_fget(), but someone could add an extra setup step between the
kzalloc() and the eventfd_fget() which could fail.

Paul
