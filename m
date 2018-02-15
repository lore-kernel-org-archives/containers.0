From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH net-next 0/3] eBPF Seccomp filters
Date: Thu, 15 Feb 2018 08:05:18 -0800
Message-ID: <17F5A58C-AEE3-4E99-A0F9-313533109FD5__23275.84884265$1518710645$gmane$org@amacapital.net>
References: <20180213154244.GA3292@ircssh-2.c.rugged-nimbus-611.internal>
	<CAGXu5jLiYh0rSRuJ_-2xLB03Wod5G07njpoESR4SnmsmiUnsEw@mail.gmail.com>
	<CALCETrV9xUd3XRgobTDgVNRFY_+o=pEDkfjvuxQ7w_UyH324zA@mail.gmail.com>
	<20180214173222.kvos6izqcywkuyi5@cisco>
	<20180215043027.zssmhvfdn7iz3rlz@ast-mbp.dhcp.thefacebook.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20180215043027.zssmhvfdn7iz3rlz-+o4/htvd0TCa6kscz5V53/3mLCh9rsb+VpNB7YpNyf8@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Lorenzo Colitti <lorenzo-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org


> On Feb 14, 2018, at 8:30 PM, Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> 
> On Wed, Feb 14, 2018 at 10:32:22AM -0700, Tycho Andersen wrote:
>>>> 
>>>> What's the reason for adding eBPF support? seccomp shouldn't need it,
>>>> and it only makes the code more complex. I'd rather stick with cBPF
>>>> until we have an overwhelmingly good reason to use eBPF as a "native"
>>>> seccomp filter language.
>>>> 
>>> 
>>> I can think of two fairly strong use cases for eBPF's ability to call
>>> functions: logging and Tycho's user notifier thing.
>> 
>> Worth noting that there is one additional thing that I didn't
>> implement, but which would be nice and is probably not possible with
>> eBPF (at least, not without a bunch of additional infrastructure):
>> passing fds back to the tracee from the manager if you intercept
>> socket(), or accept() or something.
>> 
>> This could again be accomplished via other means, though it would be a
>> lot nicer to have a primitive for it.
> 
> there is bpf_perf_event_output() interface that allows to stream
> arbitrary data from kernel into user space via perf ring buffer.
> User space can epoll on it. We use this in both tracing and networking
> for notifications and streaming data transfers.
> I suspect this can be used for 'logging' too, since it's cheap and fast.

I think this is the right idea but we'd want to tweak it.  We don't want the log messages to go to some systemwide buffer (seccomp can already so this and its annoying) -- we want them to go to the filter's creator.  In fact, the seccomp listener fd concept could easily be extended to do exactly this.

> 
> Also I think the argument that seccomp+eBPF will be faster than
> seccomp+cBPF is a weak one. I bet kpti on/off makes no difference
> under seccomp, since _all_ syscalls are already slow for sandboxed app.

It's been a while since I benchmarked it, but I suspect that a simple seccomp filter is quite a bit faster than a PTI transition.
