From: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [net-next v3 0/2] eBPF seccomp filters
Date: Mon, 26 Feb 2018 15:04:20 -0800
Message-ID: <20180226230418.46nczgkh5csakyu7@ast-mbp>
References: <20180226072651.GA27045@ircssh-2.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20180226072651.GA27045-du9IEJ8oIxHXYT48pCVpJ3c7ZZ+wIVaZYkHkVr5ML8kVGlcevz2xqA@public.gmane.org>
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
Cc: wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Feb 26, 2018 at 07:26:54AM +0000, Sargun Dhillon wrote:
> This patchset enables seccomp filters to be written in eBPF. Although, this
> patchset doesn't introduce much of the functionality enabled by eBPF, it lays
> the ground work for it. Currently, you have to disable CHECKPOINT_RESTORE
> support in order to utilize eBPF seccomp filters, as eBPF filters cannot be
> retrieved via the ptrace GET_FILTER API.

this was discussed multiple times in the past.
In eBPF land it's practically impossible to do checkpoint/restore
of the whole bpf program/map graph.

> Any user can load a bpf seccomp filter program, and it can be pinned and
> reused without requiring access to the bpf syscalls. A user only requires
> the traditional permissions of either being cap_sys_admin, or have
> no_new_privs set in order to install their rule.
> 
> The primary reason for not adding maps support in this patchset is
> to avoid introducing new complexities around PR_SET_NO_NEW_PRIVS.
> If we have a map that the BPF program can read, it can potentially
> "change" privileges after running. It seems like doing writes only
> is safe, because it can be pure, and side effect free, and therefore
> not negatively effect PR_SET_NO_NEW_PRIVS. Nonetheless, if we come
> to an agreement, this can be in a follow-up patchset.

readonly maps already exist. See BPF_F_RDONLY.
Is that not enough?

> A benchmark of this patchset is as follows for a very standard eBPF filter:
> 
> Given this test program:
> for (i = 10; i < 99999999; i++) syscall(__NR_getpid);
> 
> If I implement an eBPF filter with PROG_ARRAYs with a program per syscall,
> and tail call, the numbers are such:
> ebpf JIT 12.3% slower than native
> ebpf no JIT 13.6% slower than native
> seccomp JIT 17.6% slower than native
> seccomp no JIT 37% slower than native

the perf gains are misleading, since patches don't enable bpf_tail_call.

The main statement I want to hear from seccomp maintainers before
proceeding any further on this that enabling eBPF in seccomp won't lead
to seccomp folks arguing against changes in bpf core (like verifier)
just because it's used by seccomp.
It must be spelled out in the commit log with explicit Ack.
