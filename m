From: Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH net-next 0/3] eBPF Seccomp filters
Date: Tue, 13 Feb 2018 09:31:42 -0800
Message-ID: <CAMp4zn-Lw0grNrCyjHJZUje1Aznaj03iAUWZ86ki68MZMN1-zA__9132.65612111918$1518543057$gmane$org@mail.gmail.com>
References: <20180213154244.GA3292@ircssh-2.c.rugged-nimbus-611.internal>
	<CAGXu5jLiYh0rSRuJ_-2xLB03Wod5G07njpoESR4SnmsmiUnsEw@mail.gmail.com>
	<CAMp4zn8VNurTjmrUtHnaK21A4hUQQz5tnarj15vmTU+TjY79XA@mail.gmail.com>
	<CAEk6tEw3ty0kBH+06TYt4=Ywt-4_cHBa9f8p3ajMghtjRkHmMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAEk6tEw3ty0kBH+06TYt4=Ywt-4_cHBa9f8p3ajMghtjRkHmMg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jessie Frazelle <me-XvZkT8t+Da5Wk0Htik3J/w@public.gmane.org>
Cc: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>, Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Feb 13, 2018 at 9:02 AM, Jessie Frazelle <me-XvZkT8t+Da5Wk0Htik3J/w@public.gmane.org> wrote:
> On Tue, Feb 13, 2018 at 11:29 AM, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org> wrote:
>> On Tue, Feb 13, 2018 at 7:47 AM, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org> wrote:
>>> On Tue, Feb 13, 2018 at 7:42 AM, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org> wrote:
>>>> This patchset enables seccomp filters to be written in eBPF. Although,
>>>> this patchset doesn't introduce much of the functionality enabled by
>>>> eBPF, it lays the ground work for it.
>>>>
>>>> It also introduces the capability to dump eBPF filters via the PTRACE
>>>> API in order to make it so that CHECKPOINT_RESTORE will be satisifed.
>>>> In the attached samples, there's an example of this. One can then use
>>>> BPF_OBJ_GET_INFO_BY_FD in order to get the actual code of the program,
>>>> and use that at reload time.
>>>>
>>>> The primary reason for not adding maps support in this patchset is
>>>> to avoid introducing new complexities around PR_SET_NO_NEW_PRIVS.
>>>> If we have a map that the BPF program can read, it can potentially
>>>> "change" privileges after running. It seems like doing writes only
>>>> is safe, because it can be pure, and side effect free, and therefore
>>>> not negatively effect PR_SET_NO_NEW_PRIVS. Nonetheless, if we come
>>>> to an agreement, this can be in a follow-up patchset.
>>>
>>> What's the reason for adding eBPF support? seccomp shouldn't need it,
>>> and it only makes the code more complex. I'd rather stick with  -- cBPF
>>> until we have an overwhelmingly good reason to use eBPF as a "native"
>>> seccomp filter language.
>>>
>>> -Kees
>>>
>> Three reasons:
>> 1) The userspace tooling for eBPF is much better than the user space
>> tooling for cBPF. Our use case is specifically to optimize Docker
>> policies. This is roughly what their seccomp policy looks like:
>> https://github.com/moby/moby/blob/master/profiles/seccomp/default.json.
>> It would be much nicer to be able to leverage eBPF to write this in C,
>> or any other the other languages targetting eBPF. In addition, if we
>> have write-only maps, we can exfiltrate information from seccomp, like
>> arguments, and errors in a relatively cheap way compared to cBPF, and
>> then extract this via the bcc stack. Writing cBPF via C macros is a
>> pain, and the off the shelf cBPF libraries are getting no love. The
>> eBPF community is *exploding* with contributions.
>
> Is stage two of this getting runc to support eBPF and docker to change
> the default to be written as eBPF, because I foresee that being a
> problem mainly with the kernel versions people use. The point of that
> patch was to help the most people and as your point in (2) is made
> about performance, that is a trade-off I would be willing to make in
> order to have this functionality on more kernel versions.
>
> The other alternative would be to have docker translate to use eBPF if
).> the kernel supported it, but that amount of complexity seems a bit
> unnecessary for a feature that was trying to also be "simple".
>
> Or do you plan on wrapping filters onto processes tangentially from
> the runtime, in which case, that should be totally fine :)
>
> Anyways this is kinda a tangent from the main point of getting it in
> the kernel, just I would hate to see someone having to maintain this
> without there being a path to getting it upstream elsewhere.
>
We (me) intend to do the work to get it into Docker / Moby /
Containerd / Runc / Whatever the kids call it these days. It already
has the idea of multiple security modules, like seccomp, apparmor,
etc.. I can imagine that the first approach would be just to let
people pass eBPF filters as code, in the same way. Afterwards, there
could be more sophisticated approaches in order to transparently
upgrade people's filters, and give them performance upgrades.

A really naive approach is to take the JSON seccomp policy document
and converting it to plain old C with switch / case statements. Then
we can just push that through LLVM and we're in business. Although,
for some reason, I don't think the folks will want to take a hard dep
on llvm at runtime, so maybe there's some mechanism where it first
tries llvm, then tries to create a eBPF application naively, and then
falls back to cBPF. My primary fear with the first two approaches is
that given how the policies are written today, it's not conducive to
the eBPF instruction limit.

Our initial approach for this internally, since we use Docker 1.13.1,
and backporting this can be a bit of a pain. Docker has the ability to
spawn a pid 1 in the container, and we can use that to install the
seccomp filter, while leaving seccomp in the daemon off. Whenever this
is ready for public consumption, we'll share. Anyway, a 5% performance
gain across our fleet is an exciting proposition, and we use Docker,
so it's a problem that we have to figure out anyway.

>>
>> 2) In my testing, which thus so far has been very rudimentary, with
>> rewriting the policy that libseccomp generates from the Docker policy
>> to use eBPF, and eBPF maps performs much better than cBPF. The
>> specific case tested was to use a bpf array to lookup rules for a
>> particular syscall. In a super trivial test, this was about 5% low
>> latency than using traditional branches. If you need more evidence of
>> this, I can work a little bit more on the maps related patches, and
>> see if I can get some more benchmarking. From my understanding, we
>> would need to add "sealing" support for maps, in which they can be
>> marked as read-only, and only at that point should an eBPF seccomp
>> program be able to read from them.
>>
>> 3) Eventually, I'd like to use some more advanced capabilities of
>> eBPF, like being able to rewrite arguments safely (not things referred
>> to by pointers, but just plain old arguments).
>>
>>>>
>>>>
>>>> Sargun Dhillon (3):
>>>>   bpf, seccomp: Add eBPF filter capabilities
>>>>   seccomp, ptrace: Add a mechanism to retrieve attached eBPF seccomp
>>>>     filters
>>>>   bpf: Add eBPF seccomp sample programs
>>>>
>>>>  arch/Kconfig                 |   7 ++
>>>>  include/linux/bpf_types.h    |   3 +
>>>>  include/linux/seccomp.h      |  12 +++
>>>>  include/uapi/linux/bpf.h     |   2 +
>>>>  include/uapi/linux/ptrace.h  |   5 +-
>>>>  include/uapi/linux/seccomp.h |  15 ++--
>>>>  kernel/bpf/syscall.c         |   1 +
>>>>  kernel/ptrace.c              |   3 +
>>>>  kernel/seccomp.c             | 185 ++++++++++++++++++++++++++++++++++++++-----
>>>>  samples/bpf/Makefile         |   9 +++
>>>>  samples/bpf/bpf_load.c       |   9 ++-
>>>>  samples/bpf/seccomp1_kern.c  |  17 ++++
>>>>  samples/bpf/seccomp1_user.c  |  34 ++++++++
>>>>  samples/bpf/seccomp2_kern.c  |  24 ++++++
>>>>  samples/bpf/seccomp2_user.c  |  66 +++++++++++++++
>>>>  15 files changed, 362 insertions(+), 30 deletions(-)
>>>>  create mode 100644 samples/bpf/seccomp1_kern.c
>>>>  create mode 100644 samples/bpf/seccomp1_user.c
>>>>  create mode 100644 samples/bpf/seccomp2_kern.c
>>>>  create mode 100644 samples/bpf/seccomp2_user.c
>>>>
>>>> --
>>>> 2.14.1
>>>>
>>>
>>>
>>>
>>> --
>>> Kees Cook
>>> Pixel Security
>
>
>
> --
>
>
> Jessie Frazelle
> 4096R / D4C4 DD60 0D66 F65A 8EFC  511E 18F3 685C 0022 BFF3
> pgp.mit.edu
