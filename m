Received: from mail-qt1-f177.google.com (mail-qt1-f177.google.com [209.85.160.177])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 388F72FAF
	for <containers@lists.linux.dev>; Mon, 10 May 2021 17:23:08 +0000 (UTC)
Received: by mail-qt1-f177.google.com with SMTP id c11so12421033qth.2
        for <containers@lists.linux.dev>; Mon, 10 May 2021 10:23:08 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=c2CF6wWxSeaRukQXS9D3kYC7ceIBWXkvfZuqNiEOj+o=;
        b=WqAWHZMm6eAK0zTUbLWe79O9z67IcrQBSPAWAl2vBkdQq207NC+4fQfMOWBWf+9vC6
         NWiN+gAnCu62A63Na/yIhG3LvYNpt8VOQcRpLjEWAes1TcFBe7lmtWPjxyWIofsY0sl9
         1lb4wdJ11FOoeiFttrxWzTrKdKzx6KJ3EceY8CP8X8phzDkbfLoHxHogv5USjEDr+KTg
         eOt2NJmwWLCLob252L+Yyxg4ScpxnKVNgjpNohvwmK4jeFlV3ciUN7rGxn8/HL4Zhqxz
         yCaf20VZo3K9d5IQTzK4aBp3Ot+SB5ia8xQy36GzAWrYskbxHTg2oT6S5t6MoFJgbP+Q
         K/7g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=c2CF6wWxSeaRukQXS9D3kYC7ceIBWXkvfZuqNiEOj+o=;
        b=i6e8VAVA4SUvWyoBKDv4gjglEhv8liYwSC5Ci5Tr74x3MsQbN0PNvfDKafsYL8Yjqy
         c9Ue+fNIvlsB7mlfnirIXp++/oeAov+3gD15pwjLrbQSPz85HgDf7QWc4b5Ppr/iJ+gf
         f4ggINZeUXQgsRPgZJvikM4EjSXvuURA3Pwm866oUmg9Lin4gzTVUgd4eXuUGxgU/GaX
         oALD4XxMokRHD3GRmW0+u7apL1NHpdAQb9GmF7NfP6BhEGi3rukTxh3mVhejd2UX4yKO
         6/JVGtpic6Fd1oqvoSgg95AlLTY9g5CkwlLiR5yHqbpOcB3vuIr+xePXhn9066nNU83W
         j4Mw==
X-Gm-Message-State: AOAM533sx3l+IbBl2abw9eSWO0g//rlDSIrnr2ZqKdrwafp3Mq5cZRWR
	8K8mp+mtpixOzgy/KdfrTETtjyBMm0BzMql0
X-Google-Smtp-Source: ABdhPJxRUeU5QumnSTZa/U9nbnrewiDGajrInXlBLwfuKZzvyJZ9ZIJGVPH4dJM4ssLBN7m0dy2cEw==
X-Received: by 2002:a05:622a:486:: with SMTP id p6mr23934227qtx.98.1620667387145;
        Mon, 10 May 2021 10:23:07 -0700 (PDT)
Received: from localhost.localdomain (host-173-230-99-154.tnkngak.clients.pavlovmedia.com. [173.230.99.154])
        by smtp.gmail.com with ESMTPSA id q7sm11924367qki.17.2021.05.10.10.23.06
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 10 May 2021 10:23:06 -0700 (PDT)
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
Subject: [RFC PATCH bpf-next seccomp 11/12] bpf/verifier: support NULL-able ptr to BTF ID as helper argument
Date: Mon, 10 May 2021 12:22:48 -0500
Message-Id: <ca047abace1883f3db0ae009173e3b811085d3e0.1620499942.git.yifeifz2@illinois.edu>
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

This is to allow progs with no access to ptr to BPF ID still be
able to call some helpers, with these arguments set as NULL, so
the helper implementation may set a fallback when NULL is passed in.

Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
---
 include/linux/bpf.h   |  1 +
 kernel/bpf/verifier.c | 12 +++++++++---
 2 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 2019c0893250..efa6444b88d3 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -303,6 +303,7 @@ enum bpf_arg_type {
 	ARG_PTR_TO_SOCKET,	/* pointer to bpf_sock (fullsock) */
 	ARG_PTR_TO_SOCKET_OR_NULL,	/* pointer to bpf_sock (fullsock) or NULL */
 	ARG_PTR_TO_BTF_ID,	/* pointer to in-kernel struct */
+	ARG_PTR_TO_BTF_ID_OR_NULL,	/* pointer to in-kernel struct or NULL */
 	ARG_PTR_TO_ALLOC_MEM,	/* pointer to dynamically allocated memory */
 	ARG_PTR_TO_ALLOC_MEM_OR_NULL,	/* pointer to dynamically allocated memory or NULL */
 	ARG_CONST_ALLOC_SIZE_OR_ZERO,	/* number of allocated bytes requested */
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 8eec1796caaa..8a08a27e0abc 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -484,7 +484,8 @@ static bool arg_type_may_be_null(enum bpf_arg_type type)
 	       type == ARG_PTR_TO_CTX_OR_NULL ||
 	       type == ARG_PTR_TO_SOCKET_OR_NULL ||
 	       type == ARG_PTR_TO_ALLOC_MEM_OR_NULL ||
-	       type == ARG_PTR_TO_STACK_OR_NULL;
+	       type == ARG_PTR_TO_STACK_OR_NULL ||
+	       type == ARG_PTR_TO_BTF_ID_OR_NULL;
 }
 
 /* Determine whether the function releases some resources allocated by another
@@ -4808,6 +4809,7 @@ static const struct bpf_reg_types *compatible_reg_types[__BPF_ARG_TYPE_MAX] = {
 	[ARG_PTR_TO_SOCKET]		= &fullsock_types,
 	[ARG_PTR_TO_SOCKET_OR_NULL]	= &fullsock_types,
 	[ARG_PTR_TO_BTF_ID]		= &btf_ptr_types,
+	[ARG_PTR_TO_BTF_ID_OR_NULL]	= &btf_ptr_types,
 	[ARG_PTR_TO_SPIN_LOCK]		= &spin_lock_types,
 	[ARG_PTR_TO_MEM]		= &mem_types,
 	[ARG_PTR_TO_MEM_OR_NULL]	= &mem_types,
@@ -5436,10 +5438,14 @@ static bool check_btf_id_ok(const struct bpf_func_proto *fn)
 	int i;
 
 	for (i = 0; i < ARRAY_SIZE(fn->arg_type); i++) {
-		if (fn->arg_type[i] == ARG_PTR_TO_BTF_ID && !fn->arg_btf_id[i])
+		if ((fn->arg_type[i] == ARG_PTR_TO_BTF_ID ||
+		     fn->arg_type[i] == ARG_PTR_TO_BTF_ID_OR_NULL) &&
+		    !fn->arg_btf_id[i])
 			return false;
 
-		if (fn->arg_type[i] != ARG_PTR_TO_BTF_ID && fn->arg_btf_id[i])
+		if ((fn->arg_type[i] != ARG_PTR_TO_BTF_ID &&
+		     fn->arg_type[i] != ARG_PTR_TO_BTF_ID_OR_NULL) &&
+		    fn->arg_btf_id[i])
 			return false;
 	}
 
-- 
2.31.1

