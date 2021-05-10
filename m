Received: from mail-qk1-f179.google.com (mail-qk1-f179.google.com [209.85.222.179])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5DFD672
	for <containers@lists.linux.dev>; Mon, 10 May 2021 17:22:54 +0000 (UTC)
Received: by mail-qk1-f179.google.com with SMTP id f29so3839800qka.0
        for <containers@lists.linux.dev>; Mon, 10 May 2021 10:22:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=iG5ORSr0tp4Kp2mLVlTS2Pl/UeKyobnaxc6VNZQHUqM=;
        b=GxNnVmiZo/F5Mb/Q/FprCJSVUHvBh9nTwGKOYNHjIlmCzZ8LJYZDJCwWMc7bntzll9
         hmB75LtmlUqcv7EXNQQc4EShaV9xaixq1QrXkfjGXtD4+wwNKeZQaz3dHV/jvK69v58N
         KS2091VjWgjXtytJ7GHj+OkhAotbYJ/46j/E32vz6w+zjn4w+5Ao6mWWnkleKijPFsps
         Dvkc++WuHLEkMV9xIwg22QaK0Z7nA4OyqiJVSRR4YytIbcmQqqpZQEbFwJaldQzQKGUD
         I4yqlmzGBpVkPGPWxphWurbtRRH8cISCPCW00VDYgQ7aCk+b/VY007ZzvW/I6RuoUlkc
         Rf8w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=iG5ORSr0tp4Kp2mLVlTS2Pl/UeKyobnaxc6VNZQHUqM=;
        b=fNFkx8y5YMkMDrNtyn0dVl8xkmbhh6lBzsjM0QJgopxrQm0W9eRCYKaARyW58N/HTK
         V/xiaWX0eUBkGxCb0jE/l0/rQghXUozoTPl1gpd0E2QhUR7q5laSk/6UPyBJCse9D/MD
         lTCdfjnw9XQkmVI6eQe4rTHGHv97btl5PkrA2igj5zUr+vToNhkdA3gZXnj8rBCFYc1y
         m4gfAlw/Qo9u3Flupeg0qysayT1gPTy2xiOa5r1cmVtPXbHsNUjvO3zhT7B3hJ+W7zi2
         FWAD1Q3b6mteVYxJ+wWoTHOPcTpasHW3PhyQG7PZImc+Qr//MlbTr3mcpXS2DdQwx8E2
         1cDg==
X-Gm-Message-State: AOAM533kyLotqNciJvk3iMtKgavMDDNexoaHXB/e3j7qUAj+CXN02V90
	8fiMQ3Nt9rfvrdmL7E/G5h/vnA9x+6oRXg==
X-Google-Smtp-Source: ABdhPJyu5NVCx2/cSF+kf8FXQ5H/89SQH7HfJwdpOgLjGbA+VbP2nCMJgZvMOvRlrY15XVF1eqJfrQ==
X-Received: by 2002:a37:43d4:: with SMTP id q203mr24177461qka.124.1620667373115;
        Mon, 10 May 2021 10:22:53 -0700 (PDT)
Received: from localhost.localdomain (host-173-230-99-154.tnkngak.clients.pavlovmedia.com. [173.230.99.154])
        by smtp.gmail.com with ESMTPSA id q7sm11924367qki.17.2021.05.10.10.22.51
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 10 May 2021 10:22:52 -0700 (PDT)
From: YiFei Zhu <zhuyifei1999@gmail.com>
To: containers@lists.linux.dev,
	bpf@vger.kernel.org
Cc: YiFei Zhu <yifeifz2@illinois.edu>,
	linux-security-module@vger.kernel.org,
	Alexei Starovoitov <ast@kernel.org>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Austin Kuo <hckuo2@illinois.edu>,
	Claudio Canella <claudio.canella@iaik.tugraz.at>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Daniel Gruss <daniel.gruss@iaik.tugraz.at>,
	Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
	Giuseppe Scrivano <gscrivan@redhat.com>,
	Hubertus Franke <frankeh@us.ibm.com>,
	Jann Horn <jannh@google.com>,
	Jinghao Jia <jinghao7@illinois.edu>,
	Josep Torrellas <torrella@illinois.edu>,
	Kees Cook <keescook@chromium.org>,
	Sargun Dhillon <sargun@sargun.me>,
	Tianyin Xu <tyxu@illinois.edu>,
	Tobin Feldman-Fitzthum <tobin@ibm.com>,
	Tom Hromatka <tom.hromatka@oracle.com>,
	Will Drewry <wad@chromium.org>
Subject: [RFC PATCH bpf-next seccomp 00/12] eBPF seccomp filters
Date: Mon, 10 May 2021 12:22:37 -0500
Message-Id: <cover.1620499942.git.yifeifz2@illinois.edu>
X-Mailer: git-send-email 2.31.1
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: YiFei Zhu <yifeifz2@illinois.edu>

Based on: https://lists.linux-foundation.org/pipermail/containers/2018-February/038571.html

This patchset enables seccomp filters to be written in eBPF.
Supporting eBPF filters has been proposed a few times in the past.
The main concerns were (1) use cases and (2) security. We have
identified many use cases that can benefit from advanced eBPF
filters, such as:

  * exec-only-once filter / apply filter after exec
  * syscall logging (eg. via maps)
  * expressiveness & better tooling (no need for DSLs like easyseccomp)
  * contained syscall fault injection
  * Temporal System Call Specialization [1] with restrictive
    initialization phases (serving phase syscalls are filtered)
  * possible future extensions such as syscall serialization and
    argument rewriting

These features can also be achieved by user notifier + ptrace but
unfortunately user notifier is a lot of context switches (see the
benchmark results below), and hence much less efficient than eBPF.

For security, for an unprivileged caller, our implementation is as
restrictive as user notifier + ptrace, in regards to capabilities.
eBPF helpers follow the privilege model of original eBPF helpers.

Advanced eBPF feature (maps & helpers) is restricted by a new LSM
hook seccomp_extended. If LSM permits these features, then all standard
bpf helpers are permitted, and tracing helpers are permitted too if the
loader is bpf_capable and perfmon_capable. Mutable privileges should
not be a concern because if seccomp-eBPF is used to implement a mutable
policy of privileges, such policy can be implemented using user
notifier anyhow (which does not require seccomp-eBPF).

Moreover, a mechanism for reading user memory is added. The same
prototypes of bpf_probe_read_user{,str} from tracing are used. However,
when the loader of bpf program does not have CAP_PTRACE, the helper
will return -EPERM if the task under seccomp filter is non-dumpable.
The reason for this is that if we perform reduction from seccomp-eBPF
to user notifier + ptrace, ptrace requires CAP_PTRACE to read from
a non-dumpable process. However, eBPF does not solve the TOCTOU problem
of user notifier, so users should not use this to enforce a policy
based on memory contents.

In addition, a mechanism for storing process states between filter runs
is added. This uses the BPF-LSM task storage. However, since
unprivileged bpf loaders do not have access to ptr to BTF ID for use as
the task parameter to the helpers, the workaround is to use NULL as the
parameter, and the helper will fallback to current's group leader. This
is insufficient, unfortunately, because of the BTF enforcement in
bpf_local_storage_map_alloc_check, and the fact that tasks without
bpf_capable cannot load map BTFs. (Can I ask why this is restricted
this way?)

Giuseppe Scrivano shows how to support eBPF filters in crun [2], based
on which we have tested a number of stateful filters.

Performance wise, Jinghao did a test of 1,000,000 getpid() calls on an
Intel i7-9700K, with stock Ubuntu config. The syscalls are half EPERM
and half passthrough to the getpid() syscall handler [3]. The tests
are done recording a median of 10:

                user notif      eBPF            ratio
QEMU            6808104 us      80508.5 us      84.6
Bare Metal      3403667.5 us    80316 us        42.4

[1] https://www.usenix.org/conference/usenixsecurity20/presentation/ghavamnia
[2] https://github.com/giuseppe/crun/commit/3906b4fbcb671f8f188deef08c94ceae86a80120
[3] https://github.com/xlab-uiuc/seccomp-ebpf-upstream/tree/perf-test

Patch 1 moves no_new_privs check in filter loading.
Patch 2 implements basic support for seccomp-eBPF in the kernel.
Patch 3 enables a ptracer to get a fd to the eBPF for CRIU.
Patch 4 enables libbpf to recognize the section "seccomp".
Patch 5 adds a sample program test_seccomp to samples/bpf.

Patch 6 adds an LSM hook seccomp_extended.
Patch 7 allows bpf verifier hooks to restrict direct map access.
Patch 8 implements restrictions for eBPF filters depending on LSM hooks.
Patch 9 lets Yama LSM restrict seccomp-ebpf based on ptrace_scope.

Patch 10 enables seccomp-ebpf to read user memory.
Patch 11 allows bpf helpers to have nullable ptr to BTF ID as argument.
Patch 12 implements process storage using BPF-LSM task storage.

Sargun Dhillon (3):
  bpf, seccomp: Add eBPF filter capabilities
  seccomp, ptrace: Add a mechanism to retrieve attached eBPF seccomp
    filters
  samples/bpf: Add eBPF seccomp sample programs

YiFei Zhu (9):
  seccomp: Move no_new_privs check to after prepare_filter
  libbpf: recognize section "seccomp"
  lsm: New hook seccomp_extended
  bpf/verifier: allow restricting direct map access
  seccomp-ebpf: restrict filter to almost cBPF if LSM request such
  yama: (concept) restrict seccomp-eBPF with ptrace_scope
  seccomp-ebpf: Add ability to read user memory
  bpf/verifier: support NULL-able ptr to BTF ID as helper argument
  seccomp-ebpf: support task storage from BPF-LSM, defaulting to group
    leader

 arch/Kconfig                    |   7 +
 include/linux/bpf.h             |   8 ++
 include/linux/bpf_types.h       |   4 +
 include/linux/lsm_hook_defs.h   |   4 +
 include/linux/seccomp.h         |  15 +-
 include/linux/security.h        |  13 ++
 include/uapi/linux/bpf.h        |   1 +
 include/uapi/linux/ptrace.h     |   2 +
 include/uapi/linux/seccomp.h    |   1 +
 kernel/bpf/bpf_task_storage.c   |  64 +++++++--
 kernel/bpf/syscall.c            |   1 +
 kernel/bpf/verifier.c           |  15 +-
 kernel/ptrace.c                 |   4 +
 kernel/seccomp.c                | 235 ++++++++++++++++++++++++++++----
 kernel/trace/bpf_trace.c        |  42 ++++++
 samples/bpf/Makefile            |   3 +
 samples/bpf/test_seccomp_kern.c |  41 ++++++
 samples/bpf/test_seccomp_user.c |  49 +++++++
 security/security.c             |   8 ++
 security/yama/yama_lsm.c        |  30 ++++
 tools/include/uapi/linux/bpf.h  |   1 +
 tools/lib/bpf/libbpf.c          |   1 +
 22 files changed, 511 insertions(+), 38 deletions(-)
 create mode 100644 samples/bpf/test_seccomp_kern.c
 create mode 100644 samples/bpf/test_seccomp_user.c

--
2.31.1
