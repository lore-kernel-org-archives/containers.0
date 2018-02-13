From: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH net-next 0/3] eBPF Seccomp filters
Date: Tue, 13 Feb 2018 07:47:33 -0800
Message-ID: <CAGXu5jLiYh0rSRuJ_-2xLB03Wod5G07njpoESR4SnmsmiUnsEw__32633.4561490969$1518536904$gmane$org@mail.gmail.com>
References: <20180213154244.GA3292@ircssh-2.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20180213154244.GA3292-du9IEJ8oIxHXYT48pCVpJ3c7ZZ+wIVaZYkHkVr5ML8kVGlcevz2xqA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>
Cc: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>, Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Feb 13, 2018 at 7:42 AM, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org> wrote:
> This patchset enables seccomp filters to be written in eBPF. Although,
> this patchset doesn't introduce much of the functionality enabled by
> eBPF, it lays the ground work for it.
>
> It also introduces the capability to dump eBPF filters via the PTRACE
> API in order to make it so that CHECKPOINT_RESTORE will be satisifed.
> In the attached samples, there's an example of this. One can then use
> BPF_OBJ_GET_INFO_BY_FD in order to get the actual code of the program,
> and use that at reload time.
>
> The primary reason for not adding maps support in this patchset is
> to avoid introducing new complexities around PR_SET_NO_NEW_PRIVS.
> If we have a map that the BPF program can read, it can potentially
> "change" privileges after running. It seems like doing writes only
> is safe, because it can be pure, and side effect free, and therefore
> not negatively effect PR_SET_NO_NEW_PRIVS. Nonetheless, if we come
> to an agreement, this can be in a follow-up patchset.

What's the reason for adding eBPF support? seccomp shouldn't need it,
and it only makes the code more complex. I'd rather stick with cBPF
until we have an overwhelmingly good reason to use eBPF as a "native"
seccomp filter language.

-Kees

>
>
> Sargun Dhillon (3):
>   bpf, seccomp: Add eBPF filter capabilities
>   seccomp, ptrace: Add a mechanism to retrieve attached eBPF seccomp
>     filters
>   bpf: Add eBPF seccomp sample programs
>
>  arch/Kconfig                 |   7 ++
>  include/linux/bpf_types.h    |   3 +
>  include/linux/seccomp.h      |  12 +++
>  include/uapi/linux/bpf.h     |   2 +
>  include/uapi/linux/ptrace.h  |   5 +-
>  include/uapi/linux/seccomp.h |  15 ++--
>  kernel/bpf/syscall.c         |   1 +
>  kernel/ptrace.c              |   3 +
>  kernel/seccomp.c             | 185 ++++++++++++++++++++++++++++++++++++++-----
>  samples/bpf/Makefile         |   9 +++
>  samples/bpf/bpf_load.c       |   9 ++-
>  samples/bpf/seccomp1_kern.c  |  17 ++++
>  samples/bpf/seccomp1_user.c  |  34 ++++++++
>  samples/bpf/seccomp2_kern.c  |  24 ++++++
>  samples/bpf/seccomp2_user.c  |  66 +++++++++++++++
>  15 files changed, 362 insertions(+), 30 deletions(-)
>  create mode 100644 samples/bpf/seccomp1_kern.c
>  create mode 100644 samples/bpf/seccomp1_user.c
>  create mode 100644 samples/bpf/seccomp2_kern.c
>  create mode 100644 samples/bpf/seccomp2_user.c
>
> --
> 2.14.1
>



-- 
Kees Cook
Pixel Security
