From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [net-next v3 0/2] eBPF seccomp filters
Date: Tue, 27 Feb 2018 04:19:49 +0000
Message-ID: <CALCETrXNODxWkcwF-LbXBn+Ju7QJEyi3JR+spsRX4ecg8d1iMQ@mail.gmail.com>
References: <20180226072651.GA27045@ircssh-2.c.rugged-nimbus-611.internal>
	<20180226230418.46nczgkh5csakyu7@ast-mbp>
	<CAGXu5jLdOcrn16q9pQ7JwTf88AVsL0o5LMJ=4P6vRN36u-_k_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAGXu5jLdOcrn16q9pQ7JwTf88AVsL0o5LMJ=4P6vRN36u-_k_g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>, Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

> On Feb 26, 2018, at 3:20 PM, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org> wrote:
>
> On Mon, Feb 26, 2018 at 3:04 PM, Alexei Starovoitov
> <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>>> On Mon, Feb 26, 2018 at 07:26:54AM +0000, Sargun Dhillon wrote:
>>> This patchset enables seccomp filters to be written in eBPF. Although, this
>>> [...]
>> The main statement I want to hear from seccomp maintainers before
>> proceeding any further on this that enabling eBPF in seccomp won't lead
>> to seccomp folks arguing against changes in bpf core (like verifier)
>> just because it's used by seccomp.
>> It must be spelled out in the commit log with explicit Ack.
>
> The primary thing I'm concerned about with eBPF and seccomp is
> side-effects from eBPF programs running at syscall time. This is an
> extremely sensitive area, and I want to be sure there won't be
> feature-creep here that leads to seccomp getting into a bad state.
>
> As long as seccomp can continue have its own verifier, I *think* this
> will be fine, though, again I remain concerned about maps, etc. I'm
> still reviewing these patches and how they might provide overlap with
> Tycho's needs too, etc.

I'm not sure I see this as a huge problem.  As far as I can see, there
are three ways that a verifier change could be problematic:

1. Addition of a new type of map.  But seccomp would just not allow
new map types by default, right?

2. Addition of a new BPF_CALLable helper.  Seccomp wants a way to
whitelist BPF_CALL targets.  That should be straightforward.

3. Straight-up bugs.  Those are exactly as problematic as verifier
bugs in any other unprivileged eBPF program type, right?  I don't see
why seccomp is special here.
