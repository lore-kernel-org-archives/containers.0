From: Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>
Subject: [net-next v3 0/2] eBPF seccomp filters
Date: Mon, 26 Feb 2018 07:26:54 +0000
Message-ID: <20180226072651.GA27045@ircssh-2.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org
List-Id: containers.vger.kernel.org

This patchset enables seccomp filters to be written in eBPF. Although, this
patchset doesn't introduce much of the functionality enabled by eBPF, it lays
the ground work for it. Currently, you have to disable CHECKPOINT_RESTORE
support in order to utilize eBPF seccomp filters, as eBPF filters cannot be
retrieved via the ptrace GET_FILTER API.

Any user can load a bpf seccomp filter program, and it can be pinned and
reused without requiring access to the bpf syscalls. A user only requires
the traditional permissions of either being cap_sys_admin, or have
no_new_privs set in order to install their rule.

The primary reason for not adding maps support in this patchset is
to avoid introducing new complexities around PR_SET_NO_NEW_PRIVS.
If we have a map that the BPF program can read, it can potentially
"change" privileges after running. It seems like doing writes only
is safe, because it can be pure, and side effect free, and therefore
not negatively effect PR_SET_NO_NEW_PRIVS. Nonetheless, if we come
to an agreement, this can be in a follow-up patchset.

A benchmark of this patchset is as follows for a very standard eBPF filter:

Given this test program:
for (i = 10; i < 99999999; i++) syscall(__NR_getpid);

If I implement an eBPF filter with PROG_ARRAYs with a program per syscall,
and tail call, the numbers are such:
ebpf JIT 12.3% slower than native
ebpf no JIT 13.6% slower than native
seccomp JIT 17.6% slower than native
seccomp no JIT 37% slower than native

The speed of the traditional seccomp filter increases O(n) with the number
of syscalls with discrete rulesets, whereas ebpf is O(1), given any number
of syscall filters.

Changes since v2:
  * Rename sample
  * Code cleanup
Changes since v1:
  * Use a flag to indicate loading an eBPF filter, not a separate command
  * Remove printk helper
  * Remove ptrace patch / restore filter / sample
  * Add some safe helpers

Sargun Dhillon (2):
  bpf, seccomp: Add eBPF filter capabilities
  bpf: Add eBPF seccomp sample programs

 arch/Kconfig                    |   8 ++
 include/linux/bpf_types.h       |   3 +
 include/linux/seccomp.h         |   3 +-
 include/uapi/linux/bpf.h        |   2 +
 include/uapi/linux/seccomp.h    |   7 +-
 kernel/bpf/syscall.c            |   1 +
 kernel/seccomp.c                | 159 ++++++++++++++++++++++++++++++++++------
 samples/bpf/Makefile            |   5 ++
 samples/bpf/bpf_load.c          |   9 ++-
 samples/bpf/test_seccomp_kern.c |  41 +++++++++++
 samples/bpf/test_seccomp_user.c |  46 ++++++++++++
 11 files changed, 255 insertions(+), 29 deletions(-)
 create mode 100644 samples/bpf/test_seccomp_kern.c
 create mode 100644 samples/bpf/test_seccomp_user.c

-- 
2.14.1
