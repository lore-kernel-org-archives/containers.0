Received: from mail-qt1-f174.google.com (mail-qt1-f174.google.com [209.85.160.174])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 89CA32FAD
	for <containers@lists.linux.dev>; Mon, 10 May 2021 17:22:59 +0000 (UTC)
Received: by mail-qt1-f174.google.com with SMTP id p6so12489683qtk.13
        for <containers@lists.linux.dev>; Mon, 10 May 2021 10:22:59 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=rahaQaLyFPP9GGvK15BOl5iZ4PSYmD/vlR06dUAD7e0=;
        b=RJePQanVHTvnYJXjtq/LxIaIBOPhJjnoxA29/o8xMmHwkNv7CtioYcn32Jnr3SwqWQ
         almESooTi22DGCQjJhrwJtY+mrcCKsxmpiB0l4BKhdIscp06rl+ZJvphWiOYy07hRQBp
         +ET28ugKg6/csqDQ9YcfzO8JQYI3Z3AuIn8yxn8L5/HezfUh7pf/QDa/t6dC0uob7xAG
         EXIg+EXqE/ijLiYxCt4djfIa9vOAKQy0xK4dzteIwuNKEU1vmnxy9Gyzit3IxvXfeWJy
         cIQ+yt1Cp3SLgLxTpZdrKQNlDvAz6m3Y0UEkkeDGQ7pOZTX6Yi5qt48S2kirpaNRU30m
         gRsg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=rahaQaLyFPP9GGvK15BOl5iZ4PSYmD/vlR06dUAD7e0=;
        b=CmO0q+lUhz4X1RGsg31KXCsCBh7qG9I0IKFlZF5ICygriJ6cy2Q2ZiqrVHqNHVfq9U
         TM+vk7ayKRFjR/gKr6q/TEbYD8eS9k3ECTly2QE3GvsSzwmopn1oAEx6EJwu/sD4ZPRP
         jrsnXlaRSO63nWOggp/zY1Nua5LHr9SK1QGFKnBypXlAVEsRmoVbSLRDnt/hVhL/gIWx
         9d7+auEQR4gpsh5zDT+LEfuu1/5hhc0+YKtpVb6KDp45REwxhWkaQiAjSq0c4kjUGI/c
         3L06lDpQLxPhkH79h/1EcDp/zx6oVtXVfAL0XDmS2IVQtZ/Z+vPaGoNRoxYox648s0Mm
         ts8w==
X-Gm-Message-State: AOAM531GvZmzZ0JEKQvsEuBYMh9cabu11LFYKIvrwS/DHHUftcHJIbBs
	UBYW31ovDars2pyxhJGlq9+DpeqZWuga9ZxF
X-Google-Smtp-Source: ABdhPJz7dTCeaErW7vArw1fyKmZO4UJ0S1Q0/i4pR56D4pC8rE886IfEcheNNTd/YWEMMzCCas1NRg==
X-Received: by 2002:ac8:7f83:: with SMTP id z3mr14353597qtj.239.1620667378335;
        Mon, 10 May 2021 10:22:58 -0700 (PDT)
Received: from localhost.localdomain (host-173-230-99-154.tnkngak.clients.pavlovmedia.com. [173.230.99.154])
        by smtp.gmail.com with ESMTPSA id q7sm11924367qki.17.2021.05.10.10.22.57
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 10 May 2021 10:22:58 -0700 (PDT)
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
Subject: [RFC PATCH bpf-next seccomp 04/12] libbpf: recognize section "seccomp"
Date: Mon, 10 May 2021 12:22:41 -0500
Message-Id: <78401c1929394e999f154bcecd5aa00d2178d1c5.1620499942.git.yifeifz2@illinois.edu>
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

The section is set to program type BPF_PROG_TYPE_SECCOMP with no
attach type.

Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
---
 tools/lib/bpf/libbpf.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/tools/lib/bpf/libbpf.c b/tools/lib/bpf/libbpf.c
index e2a3cf437814..42ce79b47378 100644
--- a/tools/lib/bpf/libbpf.c
+++ b/tools/lib/bpf/libbpf.c
@@ -8958,6 +8958,7 @@ static const struct bpf_sec_def section_defs[] = {
 	BPF_PROG_SEC("struct_ops",		BPF_PROG_TYPE_STRUCT_OPS),
 	BPF_EAPROG_SEC("sk_lookup/",		BPF_PROG_TYPE_SK_LOOKUP,
 						BPF_SK_LOOKUP),
+	BPF_PROG_SEC("seccomp",			BPF_PROG_TYPE_SECCOMP),
 };
 
 #undef BPF_PROG_SEC_IMPL
-- 
2.31.1

