From: Tycho Andersen <tycho-E0fblnxP3wo@public.gmane.org>
Subject: Re: [PATCH net-next 0/3] eBPF Seccomp filters
Date: Tue, 13 Feb 2018 13:50:40 -0700
Message-ID: <20180213205040.h3nsvz5go6lewvuy@smitten>
References: <20180213154244.GA3292@ircssh-2.c.rugged-nimbus-611.internal>
	<CAGXu5jLiYh0rSRuJ_-2xLB03Wod5G07njpoESR4SnmsmiUnsEw@mail.gmail.com>
	<CAMp4zn8VNurTjmrUtHnaK21A4hUQQz5tnarj15vmTU+TjY79XA@mail.gmail.com>
	<CAEk6tEw3ty0kBH+06TYt4=Ywt-4_cHBa9f8p3ajMghtjRkHmMg@mail.gmail.com>
	<CAMp4zn-Lw0grNrCyjHJZUje1Aznaj03iAUWZ86ki68MZMN1-zA@mail.gmail.com>
	<CAGXu5jKv3QFVKLhok1JWiPamE0b4CqLTO-hx8sP0KWED921=6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAGXu5jKv3QFVKLhok1JWiPamE0b4CqLTO-hx8sP0KWED921=6w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Cc: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>, Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Paul Moore <pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Feb 13, 2018 at 12:16:42PM -0800, Kees Cook wrote:
> If the needs Tycho outlined[1] could be addressed fully with eBPF, and
> we can very narrowly scope the use of the "extra" eBPF features, I
> might be more inclined to merge something like this, but I want to
> take it very carefully. Besides creating a dependency on the bpf()
> syscall, this would create side channels (via maps) that make me very
> uncomfortable when dealing with process isolation. (Though, in theory,
> this is already correctly constrained by no-new-privs...)
> 
> Tycho, could you get what you needed from eBPF?

We could get almost all the way there, I think. We could pass the
event via a bpf map, and then have a userspace daemon do:

    while (1) {
        bpf(BPF_MAP_LOOKUP_ELEM, &attr, sizeof(attr));
        if (!syscall_queued(&attr))
            continue;

        do_stuff(&attr);
        set_done(&attr);
        bpf(BPF_MAP_UPDATE_ELEM, &attr, sizeof(attr));
    }

but as you say,

> My impression would be that you'd still need a user notification
> mechanism to stop the process, as the decisions about how to rewrite
> arguments likely cannot be fully characterized by the internal eBPF
> filter.

...there's no way to stop the seccomp'd task until userspace is
finished with whatever thing it needs to do on behalf of the seccomp'd
task (at least, IIUC).

That's of course ignoring the ergonomics from userspace: bpf_map_fops
doesn't implement poll() or anything, so we really do have to use a
while(1), if we want to allow more than one syscall queuing at a time,
we need to poll multiple map elements.

One of the extensions I had been considering floating for v2 of my set
was allowing users to pass fds back across (again, to make userspace
ergonomics a little better), which would be impossible via ebpf.

Cheers,

Tycho
