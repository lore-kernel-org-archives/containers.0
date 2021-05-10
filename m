Received: from mail-qt1-f172.google.com (mail-qt1-f172.google.com [209.85.160.172])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CF8F22FB2
	for <containers@lists.linux.dev>; Mon, 10 May 2021 17:23:06 +0000 (UTC)
Received: by mail-qt1-f172.google.com with SMTP id p6so12490033qtk.13
        for <containers@lists.linux.dev>; Mon, 10 May 2021 10:23:06 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=K3otKcjGXfjWujyWqX/osHKgxcZ3uGxMRgh0AOnNm6I=;
        b=a0pr0Zp/V5LIkK7DZ5qYMqwhfxJTX4jV0thP237XqVBG921rrjNLIlYZu1JzlNGddL
         qQIMee2LaKlyuOu5NDCGgwH50E7uyBA8GD0EbvfJIrGubDbHwFuF/p+T0+kVLIJ1EwvN
         swLjNOXUqLxRr9TiVhE6vjWZVih6Ks8jSu6IjVIukycta2XwAFtU96/m9UkHgMN7JJh4
         2zKeZSgBjQLSlltoBwK6Mt7dQ+ifE3WtuswzKD9TqLRxKfJUtLYqEYxNLD+HgBRk3qUP
         DlO1RNCbwtovBleWnMF6HJeO64kWhIGNbN4nJ705M2nxpkJV0tuwIT+k/650fGikWVIA
         GP/A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=K3otKcjGXfjWujyWqX/osHKgxcZ3uGxMRgh0AOnNm6I=;
        b=oS+GaL05RmMoaYXPrqg3BkFf3Q4MIqdHahNJRoltXj/nW9yRgW5QtKByvfkiZojkaQ
         1T4VN7dIPliD5Slp3Xyq3POUABJdTjwSp4UQhiCoWnT1djaMLkarlHPwU+wOpxQrejrZ
         OAi81zZqH68kBBMMPuZ3h3/23Xd/0L6GtLmTgIYaWtBhpjrSf8PpY+CcHCxaQqD+q6ce
         ApqqL2+bj9DvbGO5mpse5DIF4v05iJEOW2OTkYPGuykwe47tsDihU+xIT9LvmEuWf+6h
         UXozdyJR4wJ3AeMjuMCdTZb5lB0ZA7DK1dPp5LMsqudH3e7xsFjSbRD04q6XAaTnpLN2
         t7Ow==
X-Gm-Message-State: AOAM533aqOtUNF8RlvnfY0wvdmdwiOHHDDu6/yEH3wYqgvGmJxneHYiG
	IKtqpQjJ6+QhvUw06QiQPyb+wCNUbIPtNzVV
X-Google-Smtp-Source: ABdhPJwsd4Zm2OVHC0R53PhH+5KNiVxBFUs2f4MCxN96ZtiOvVI6wTHsG/6npaoZbnprA9G3U09SNQ==
X-Received: by 2002:a05:622a:10e:: with SMTP id u14mr23252719qtw.229.1620667385799;
        Mon, 10 May 2021 10:23:05 -0700 (PDT)
Received: from localhost.localdomain (host-173-230-99-154.tnkngak.clients.pavlovmedia.com. [173.230.99.154])
        by smtp.gmail.com with ESMTPSA id q7sm11924367qki.17.2021.05.10.10.23.04
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 10 May 2021 10:23:05 -0700 (PDT)
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
Subject: [RFC PATCH bpf-next seccomp 10/12] seccomp-ebpf: Add ability to read user memory
Date: Mon, 10 May 2021 12:22:47 -0500
Message-Id: <53db70ed544928d227df7e3f3a1f8c53e3665c65.1620499942.git.yifeifz2@illinois.edu>
X-Mailer: git-send-email 2.31.1
In-Reply-To: <cover.1620499942.git.yifeifz2@illinois.edu>
References: <cover.1620499942.git.yifeifz2@illinois.edu>
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: YiFei Zhu <yifeifz2@illinois.edu>

This uses helpers bpf_probe_read_user{,str}. To repect unprivileged
users may also load filters, when the loader of the filter does not
have CAP_SYS_PTRACE, attempting to read user memory when current mm
is non-dumpable results in -EPERM.

Right now this is not sleepable, -EFAULT may happen for valid memory
addresses. Future work might be adding support to bpf_copy_from_user
via sleepable filters.

Use of memory data to implement policy is discouraged until there is
a solution for time-of-check to time-of-use.

Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
---
 include/linux/bpf.h      |  4 ++++
 kernel/seccomp.c         |  8 ++++++++
 kernel/trace/bpf_trace.c | 42 ++++++++++++++++++++++++++++++++++++++++
 3 files changed, 54 insertions(+)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 86f3e8784e43..2019c0893250 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -1965,6 +1965,10 @@ extern const struct bpf_func_proto bpf_get_socket_ptr_cookie_proto;
 extern const struct bpf_func_proto bpf_task_storage_get_proto;
 extern const struct bpf_func_proto bpf_task_storage_delete_proto;
 extern const struct bpf_func_proto bpf_for_each_map_elem_proto;
+extern const struct bpf_func_proto bpf_probe_read_user_proto;
+extern const struct bpf_func_proto bpf_probe_read_user_dumpable_proto;
+extern const struct bpf_func_proto bpf_probe_read_user_str_proto;
+extern const struct bpf_func_proto bpf_probe_read_user_dumpable_str_proto;
 
 const struct bpf_func_proto *bpf_tracing_func_proto(
 	enum bpf_func_id func_id, const struct bpf_prog *prog);
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index b9ed9951a05b..330e9c365cdc 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -2449,6 +2449,14 @@ seccomp_func_proto(enum bpf_func_id func_id, const struct bpf_prog *prog)
 		return &bpf_get_current_uid_gid_proto;
 	case BPF_FUNC_get_current_pid_tgid:
 		return &bpf_get_current_pid_tgid_proto;
+	case BPF_FUNC_probe_read_user:
+		return ns_capable(current_user_ns(), CAP_SYS_PTRACE) ?
+			&bpf_probe_read_user_proto :
+			&bpf_probe_read_user_dumpable_proto;
+	case BPF_FUNC_probe_read_user_str:
+		return ns_capable(current_user_ns(), CAP_SYS_PTRACE) ?
+			&bpf_probe_read_user_str_proto :
+			&bpf_probe_read_user_dumpable_str_proto;
 	default:
 		break;
 	}
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index d2d7cf6cfe83..a1d6d64bde08 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -175,6 +175,27 @@ const struct bpf_func_proto bpf_probe_read_user_proto = {
 	.arg3_type	= ARG_ANYTHING,
 };
 
+BPF_CALL_3(bpf_probe_read_user_dumpable, void *, dst, u32, size,
+	   const void __user *, unsafe_ptr)
+{
+	int ret = -EPERM;
+
+	if (get_dumpable(current->mm))
+		ret = copy_from_user_nofault(dst, unsafe_ptr, size);
+	if (unlikely(ret < 0))
+		memset(dst, 0, size);
+	return ret;
+}
+
+const struct bpf_func_proto bpf_probe_read_user_dumpable_proto = {
+	.func		= bpf_probe_read_user_dumpable,
+	.gpl_only	= true,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_PTR_TO_UNINIT_MEM,
+	.arg2_type	= ARG_CONST_SIZE_OR_ZERO,
+	.arg3_type	= ARG_ANYTHING,
+};
+
 static __always_inline int
 bpf_probe_read_user_str_common(void *dst, u32 size,
 			       const void __user *unsafe_ptr)
@@ -212,6 +233,27 @@ const struct bpf_func_proto bpf_probe_read_user_str_proto = {
 	.arg3_type	= ARG_ANYTHING,
 };
 
+BPF_CALL_3(bpf_probe_read_user_dumpable_str, void *, dst, u32, size,
+	   const void __user *, unsafe_ptr)
+{
+	int ret = -EPERM;
+
+	if (get_dumpable(current->mm))
+		ret = strncpy_from_user_nofault(dst, unsafe_ptr, size);
+	if (unlikely(ret < 0))
+		memset(dst, 0, size);
+	return ret;
+}
+
+const struct bpf_func_proto bpf_probe_read_user_dumpable_str_proto = {
+	.func		= bpf_probe_read_user_dumpable_str,
+	.gpl_only	= true,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_PTR_TO_UNINIT_MEM,
+	.arg2_type	= ARG_CONST_SIZE_OR_ZERO,
+	.arg3_type	= ARG_ANYTHING,
+};
+
 static __always_inline int
 bpf_probe_read_kernel_common(void *dst, u32 size, const void *unsafe_ptr)
 {
-- 
2.31.1

