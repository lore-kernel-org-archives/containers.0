Received: from mail-qt1-f176.google.com (mail-qt1-f176.google.com [209.85.160.176])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1F7702FAD
	for <containers@lists.linux.dev>; Mon, 10 May 2021 17:22:58 +0000 (UTC)
Received: by mail-qt1-f176.google.com with SMTP id j19so12495005qtp.7
        for <containers@lists.linux.dev>; Mon, 10 May 2021 10:22:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Nm+KuM9ff9d7ka8+7ZtDl8pCOVV7hGgjqFXWjHyaY58=;
        b=fsjib6JFKB1SyB4TqRkLe0oWxCn6a1aMnr343ATb8KbJa7WNWCrgCvWk1DqdmUShU8
         Pv+g+pQxTacxI3WgWyPQv1i2tcRvXE3tWDfxy5HSjnYmZ0y5123dlnOJajG4VXOX8LCm
         PkN3Fqn/x8pg1XHiARTjzmQiHC/tpRSU/6FD5fei9iutaoGdsZDfv4u/vwnIfSYqU4RB
         8NnTOo52srAdZIPVCxkAddbaikyphzE4t5/DqDz2ofo1KgbPtGdDb6E2mHDFmaEwmiLF
         1KFSRo8kBRB3sJOpmaqVnk917oZDw0zYIdOHhLZrQEbLe4NvSCJE4OVdXMJEhL/ZFQj7
         HRlw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=Nm+KuM9ff9d7ka8+7ZtDl8pCOVV7hGgjqFXWjHyaY58=;
        b=e48NwuhOig/U1tttkZ+NPhD+W+XgokYkwWwgCopoFLKJ3MFRc3aeyqKgwr9s5I+naE
         eTlw5Uzo956EjuV7Q7gO0ADhVMJY32gYnV4FQ75uT5g+FLIU90jB15Z9Y0xFBIAxlsnr
         EuMGLGzMhHGgqfzIJsdZ8TIiIJvX1iYRp9oaK6Iet2dN9bId+RV/JUzm4AigJL/hAXog
         FwTG1vsqLQYMSuBPYLd5x/W/WAZTm0+RFDEAvmX1jmCwME7Hr2+aKDtNYvJ1mzOlqtcL
         +IrOr17fuajZXDu9s7J4bUq+xNG/JVnTeu+xf7HxWzUVj0mGCawaWliftIXzqUpYE3Af
         eB8g==
X-Gm-Message-State: AOAM533mwxboHMM4PiW1+Zz0oLe1CfUAW1CiO3K3e7QCGX2hdC+qrDge
	1uRlCIXjNXVZ7sqCUK3WmdWS7H3z4PhNWa+k
X-Google-Smtp-Source: ABdhPJyrRbwmlmB0HmoAXEyUfIQvt7D/1NgpybbDMUmlcNeiDapwTWCT1jz6kOsYOgAoqNEcZWiGSQ==
X-Received: by 2002:ac8:5806:: with SMTP id g6mr24084856qtg.152.1620667377051;
        Mon, 10 May 2021 10:22:57 -0700 (PDT)
Received: from localhost.localdomain (host-173-230-99-154.tnkngak.clients.pavlovmedia.com. [173.230.99.154])
        by smtp.gmail.com with ESMTPSA id q7sm11924367qki.17.2021.05.10.10.22.55
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 10 May 2021 10:22:56 -0700 (PDT)
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
Subject: [RFC PATCH bpf-next seccomp 03/12] seccomp, ptrace: Add a mechanism to retrieve attached eBPF seccomp filters
Date: Mon, 10 May 2021 12:22:40 -0500
Message-Id: <b09d7033ae669b3611edd13899d59d1cc437fbf6.1620499942.git.yifeifz2@illinois.edu>
X-Mailer: git-send-email 2.31.1
In-Reply-To: <cover.1620499942.git.yifeifz2@illinois.edu>
References: <cover.1620499942.git.yifeifz2@illinois.edu>
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Sargun Dhillon <sargun@sargun.me>

This extends the ptrace API to allow fetching eBPF seccomp filters
attached to programs. This is to enable checkpoint / restore cases.
The user will have to use the traditional PTRACE_SECCOMP_GET_FILTER
API call, and if they get an invalid medium type error they can switch
over to the eBPF variant of the API -- PTRACE_SECCOMP_GET_FILTER_EXTENDED.

Signed-off-by: Sargun Dhillon <sargun@sargun.me>
Link: https://lists.linux-foundation.org/pipermail/containers/2018-February/038478.html
[YiFei: increase ptrace number to 0x4210]
Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
---
 include/linux/seccomp.h     | 12 ++++++++++++
 include/uapi/linux/ptrace.h |  2 ++
 kernel/ptrace.c             |  4 ++++
 kernel/seccomp.c            | 37 +++++++++++++++++++++++++++++++++++++
 4 files changed, 55 insertions(+)

diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
index c0750dc05de5..7ce9e3b3fa80 100644
--- a/include/linux/seccomp.h
+++ b/include/linux/seccomp.h
@@ -122,6 +122,18 @@ static inline long seccomp_get_metadata(struct task_struct *task,
 	return -EINVAL;
 }
 #endif /* CONFIG_SECCOMP_FILTER && CONFIG_CHECKPOINT_RESTORE */
+#if defined(CONFIG_SECCOMP_FILTER_EXTENDED) && defined(CONFIG_CHECKPOINT_RESTORE)
+extern long seccomp_get_filter_extended(struct task_struct *task,
+					unsigned long n,
+					void __user *data);
+#else
+static inline long seccomp_get_filter_extended(struct task_struct *task,
+					       unsigned long n,
+					       void __user *data)
+{
+	return -EINVAL;
+}
+#endif /* CONFIG_SECCOMP_FILTER_EXTENDED && CONFIG_CHECKPOINT_RESTORE */
 
 #ifdef CONFIG_SECCOMP_CACHE_DEBUG
 struct seq_file;
diff --git a/include/uapi/linux/ptrace.h b/include/uapi/linux/ptrace.h
index 3747bf816f9a..725a03614c28 100644
--- a/include/uapi/linux/ptrace.h
+++ b/include/uapi/linux/ptrace.h
@@ -112,6 +112,8 @@ struct ptrace_rseq_configuration {
 	__u32 pad;
 };
 
+#define PTRACE_SECCOMP_GET_FILTER_EXTENDED	0x4210
+
 /*
  * These values are stored in task->ptrace_message
  * by tracehook_report_syscall_* to describe the current syscall-stop.
diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index 76f09456ec4b..1e8d2155231f 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -1247,6 +1247,10 @@ int ptrace_request(struct task_struct *child, long request,
 		break;
 #endif
 
+	case PTRACE_SECCOMP_GET_FILTER_EXTENDED:
+		ret = seccomp_get_filter_extended(child, addr, datavp);
+		break;
+
 	default:
 		break;
 	}
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 1ef26a5bf93f..8550ae885245 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -2168,6 +2168,43 @@ long seccomp_get_metadata(struct task_struct *task,
 }
 #endif
 
+#if defined(CONFIG_SECCOMP_FILTER_EXTENDED) && defined(CONFIG_CHECKPOINT_RESTORE)
+long seccomp_get_filter_extended(struct task_struct *task,
+				 unsigned long filter_off,
+				 void __user *data)
+{
+	struct seccomp_filter *filter;
+	struct bpf_prog *prog;
+	long ret;
+
+	if (!capable(CAP_SYS_ADMIN) ||
+	    current->seccomp.mode != SECCOMP_MODE_DISABLED) {
+		return -EACCES;
+	}
+
+	filter = get_nth_filter(task, filter_off);
+	if (IS_ERR(filter))
+		return PTR_ERR(filter);
+
+	if (bpf_prog_was_classic(filter->prog)) {
+		ret = -EMEDIUMTYPE;
+		goto out;
+	}
+	prog = bpf_prog_inc_not_zero(filter->prog);
+	if (IS_ERR(prog)) {
+		ret = PTR_ERR(prog);
+		goto out;
+	}
+
+	ret = bpf_prog_new_fd(filter->prog);
+	if (ret < 0)
+		bpf_prog_put(prog);
+out:
+	__put_seccomp_filter(filter);
+	return ret;
+}
+#endif
+
 #ifdef CONFIG_SYSCTL
 
 /* Human readable action names for friendly sysctl interaction */
-- 
2.31.1

