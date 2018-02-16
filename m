From: Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH net-next 0/3] eBPF Seccomp filters
Date: Fri, 16 Feb 2018 10:39:24 -0800
Message-ID: <CAMp4zn-6bKkc539fihgVBbdYW9_ps4ARG_hKwWvcVG0x-hR=7Q__48696.2332194254$1518806317$gmane$org@mail.gmail.com>
References: <20180213154244.GA3292@ircssh-2.c.rugged-nimbus-611.internal>
	<CAGXu5jLiYh0rSRuJ_-2xLB03Wod5G07njpoESR4SnmsmiUnsEw@mail.gmail.com>
	<CALCETrV9xUd3XRgobTDgVNRFY_+o=pEDkfjvuxQ7w_UyH324zA@mail.gmail.com>
	<20180214173222.kvos6izqcywkuyi5@cisco>
	<20180215043027.zssmhvfdn7iz3rlz@ast-mbp.dhcp.thefacebook.com>
Mime-Version: 1.0
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
Cc: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Lorenzo Colitti <lorenzo-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Feb 14, 2018 at 8:30 PM, Alexei Starovoitov
<alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Wed, Feb 14, 2018 at 10:32:22AM -0700, Tycho Andersen wrote:
>> > >
>> > > What's the reason for adding eBPF support? seccomp shouldn't need it,
>> > > and it only makes the code more complex. I'd rather stick with cBPF
>> > > until we have an overwhelmingly good reason to use eBPF as a "native"
>> > > seccomp filter language.
>> > >
>> >
>> > I can think of two fairly strong use cases for eBPF's ability to call
>> > functions: logging and Tycho's user notifier thing.
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
>
> Specifically for android we added bpf_lsm hooks, cookie/uid helpers,
> and read-only maps.
> Lorenzo,
> there was a claim in this thread that bpf is disabled on android.
> Can you please clarify ?
> If it's actually disabled and there is no intent to enable it,
> I'd rather not add any more android specific features to bpf.
>
> What I think is important to understand is that BPF goes through
> very active development. The verifier is constantly getting smarter.
> There is work to add bounded loops, lock/unlock, get/put tracking,
> global/percpu variables, dynamic linking and so on.
> Most of the features are available to root only and unpriv
> has very limited set. Like getting bpf_perf_event_output() to work
> for unpriv will likely require additional verifier work.
>
> So all cool bits will not be usable by seccomp+eBPF and unpriv
> on day one. It's not a lot of work either, but once it's done
> I'd hate to see arguments against adding more verifier features
> just because eBPF is used by seccomp/landlock/other_security_thing.
>
> Also I think the argument that seccomp+eBPF will be faster than
> seccomp+cBPF is a weak one. I bet kpti on/off makes no difference
> under seccomp, since _all_ syscalls are already slow for sandboxed app.
> Instead of making seccomp 5% faster with eBPF, I think it's
> worth looking into extending LSM hooks to cover all syscalls and
> have programmable (bpf or whatever) filtering applied per syscall.
> Like we can have a white list syscall table covered by lsm hooks
> and any other syscall will get into old seccomp-style
> filtering category automatically.
> lsm+bpf would need to follow process hierarchy. It shouldn't be
> a runtime check at syscall entry either, but compile time
> extra branch in SYSCALL_DEFINE for non-whitelisted syscalls.
> There are bunch of other things to figure out, but I think
> the perf win will be bigger than replacing cBPF with eBPF in
> existing seccomp.
>
Given this test program:
for (i = 10; i < 99999999; i++) syscall(__NR_getpid);

If I implement an eBPF filter with PROG_ARRAYs, and tail call, the
numbers are such:
ebpf JIT 12.3% slower than native
ebpf no JIT 13.6% slower than native
seccomp JIT 17.6% slower than native
seccomp no JIT 37% slower than native

This is using libseccomp for the standard seccomp BPF program. There's
no reasonable way for our workload to know which syscalls come
"earlier", so we can't take that optimization. Potentially, libseccomp
can be smarter about ordering cases (using ranges), and use an
O(log(n)) search algorithm, but both of these are microptimizations
that scale with the number of syscalls and per-syscall rules. The
nicety of using a PROG_ARRAY means that adding additional filters
(syscalls) comes at no cost, whereas there's a tradeoff any time you
add another rule in traditional seccomp filters.

This was tested on an Amazon M4.16XL running with pcid, and KPTI.
