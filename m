From: Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>
Subject: [PATCH net-next 0/3] eBPF Seccomp filters
Date: Tue, 13 Feb 2018 15:42:46 +0000
Message-ID: <20180213154244.GA3292__7873.55454308472$1518536473$gmane$org@ircssh-2.c.rugged-nimbus-611.internal>
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
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org
List-Id: containers.vger.kernel.org

This patchset enables seccomp filters to be written in eBPF. Although,
this patchset doesn't introduce much of the functionality enabled by
eBPF, it lays the ground work for it.

It also introduces the capability to dump eBPF filters via the PTRACE
API in order to make it so that CHECKPOINT_RESTORE will be satisifed.
In the attached samples, there's an example of this. One can then use
BPF_OBJ_GET_INFO_BY_FD in order to get the actual code of the program,
and use that at reload time.

The primary reason for not adding maps support in this patchset is
to avoid introducing new complexities around PR_SET_NO_NEW_PRIVS.
If we have a map that the BPF program can read, it can potentially
"change" privileges after running. It seems like doing writes only
is safe, because it can be pure, and side effect free, and therefore
not negatively effect PR_SET_NO_NEW_PRIVS. Nonetheless, if we come
to an agreement, this can be in a follow-up patchset.


Sargun Dhillon (3):
  bpf, seccomp: Add eBPF filter capabilities
  seccomp, ptrace: Add a mechanism to retrieve attached eBPF seccomp
    filters
  bpf: Add eBPF seccomp sample programs

 arch/Kconfig                 |   7 ++
 include/linux/bpf_types.h    |   3 +
 include/linux/seccomp.h      |  12 +++
 include/uapi/linux/bpf.h     |   2 +
 include/uapi/linux/ptrace.h  |   5 +-
 include/uapi/linux/seccomp.h |  15 ++--
 kernel/bpf/syscall.c         |   1 +
 kernel/ptrace.c              |   3 +
 kernel/seccomp.c             | 185 ++++++++++++++++++++++++++++++++++++++-----
 samples/bpf/Makefile         |   9 +++
 samples/bpf/bpf_load.c       |   9 ++-
 samples/bpf/seccomp1_kern.c  |  17 ++++
 samples/bpf/seccomp1_user.c  |  34 ++++++++
 samples/bpf/seccomp2_kern.c  |  24 ++++++
 samples/bpf/seccomp2_user.c  |  66 +++++++++++++++
 15 files changed, 362 insertions(+), 30 deletions(-)
 create mode 100644 samples/bpf/seccomp1_kern.c
 create mode 100644 samples/bpf/seccomp1_user.c
 create mode 100644 samples/bpf/seccomp2_kern.c
 create mode 100644 samples/bpf/seccomp2_user.c

-- 
2.14.1
