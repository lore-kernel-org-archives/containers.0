Return-Path: <SRS0=9Lh8=ER=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.3 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5E66C388F9
	for <containers@archiver.kernel.org>; Wed, 11 Nov 2020 13:34:36 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 23728206D9
	for <containers@archiver.kernel.org>; Wed, 11 Nov 2020 13:34:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="YJSxGfIb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 23728206D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 52BEE87439;
	Wed, 11 Nov 2020 13:34:33 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Uafbta8UgQLi; Wed, 11 Nov 2020 13:34:32 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 8DEBA8736E;
	Wed, 11 Nov 2020 13:34:32 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 6BC42C0889;
	Wed, 11 Nov 2020 13:34:32 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 490D9C016F
 for <containers@lists.linux-foundation.org>;
 Wed, 11 Nov 2020 13:34:31 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 3E07C86191
 for <containers@lists.linux-foundation.org>;
 Wed, 11 Nov 2020 13:34:31 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 2nCHFkpS_PEr
 for <containers@lists.linux-foundation.org>;
 Wed, 11 Nov 2020 13:34:30 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-qt1-f196.google.com (mail-qt1-f196.google.com
 [209.85.160.196])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 87A38860B2
 for <containers@lists.linux-foundation.org>;
 Wed, 11 Nov 2020 13:34:30 +0000 (UTC)
Received: by mail-qt1-f196.google.com with SMTP id j31so1226169qtb.8
 for <containers@lists.linux-foundation.org>;
 Wed, 11 Nov 2020 05:34:30 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=from:to:cc:subject:date:message-id:mime-version
 :content-transfer-encoding;
 bh=ADY2JmYxE9Xly9S24Z1LRnTUA3RyY71p6BFzajWHuao=;
 b=YJSxGfIbb1UUIY/29x8l4T1Jgc/yvQs31iNrz+gq8lShwrVPuHybhNR6GJR2b7ujTh
 QXkNda2M3eSKkjAcLLD3C+040OUac/TeqxIQ4kKWh1L61WubktOhPd4WOSZc7To8b+sR
 jcvHPDdLofNDeZQFZI6zTyzwiTZI58E4j7EHZSBLV1AVXppIZtxsLNOxs1YSHzxtaIyi
 /8HpFYA+y+MUg78ZtzBB1bfvaT8TL/NlfNctAizFSHUGW5eGeI6PDGrklFXYAAJQKgEB
 E8onifEyVUdSHl7UZUr5Lsm3j3fv9Fv5friHKntdo5FtOXwpCVL7DFWbsNCOMCfZLyYf
 O7Sg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
 :content-transfer-encoding;
 bh=ADY2JmYxE9Xly9S24Z1LRnTUA3RyY71p6BFzajWHuao=;
 b=cX1/squc/eJkuTY/aXAW/0a3tz4/EkooSAg1BiwRz+umgYVGxXYZOk0+9i+KdYLvG2
 tue+EXT2LL+FmTao8M4VcHbt4MvKuiGuMCyb47lo4nr6cq+Oft2FkKAg+1EBeG3kKYD6
 +TQBrgLu/dyhBAPSvEkWGdna2FgB4kLmTYgsawtPmevayixLOH/VmMgOWImqNmhw7VrY
 dBhQzg/J7xaGur7RVuP7AqPCbRHxaRnsULOMiGnu8K5OrXgXif5NMg41wdRJD6yEnThA
 VtUSnswGQPG0jaI6xZTzmjq4okDM8wffS+wRLLBncO/VU2K/EXTt4EINpS//fZAAi9bv
 7ybg==
X-Gm-Message-State: AOAM531/SNMNHgdTcH8Y7ZkkPJqB7264JyKKrn5t2AokR0HZvlY8FJpm
 TZ93PWkgj1ZYaphGr2TfZs7N4dJmBzFHaQ==
X-Google-Smtp-Source: ABdhPJzHUfo2j/Nsf18vB+1vJm4vfXG7t/Ethu+Cj5/ykTWucn6CwriV6xUlfxlPz1n756bgw31C9g==
X-Received: by 2002:ac8:130d:: with SMTP id e13mr23000296qtj.3.1605101669342; 
 Wed, 11 Nov 2020 05:34:29 -0800 (PST)
Received: from localhost.localdomain
 (host-173-230-99-154.tnkngak.clients.pavlovmedia.com. [173.230.99.154])
 by smtp.gmail.com with ESMTPSA id r190sm1997814qkf.101.2020.11.11.05.34.27
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Wed, 11 Nov 2020 05:34:28 -0800 (PST)
From: YiFei Zhu <zhuyifei1999@gmail.com>
To: containers@lists.linux-foundation.org
Subject: [PATCH seccomp v2 0/8] seccomp: add bitmap cache support on remaining
 arches and report cache in procfs
Date: Wed, 11 Nov 2020 07:33:46 -0600
Message-Id: <cover.1605101222.git.yifeifz2@illinois.edu>
X-Mailer: git-send-email 2.29.2
MIME-Version: 1.0
Cc: linux-sh@vger.kernel.org, Tobin Feldman-Fitzthum <tobin@ibm.com>,
 Hubertus Franke <frankeh@us.ibm.com>, Jack Chen <jianyan2@illinois.edu>,
 linux-riscv@lists.infradead.org, Andrea Arcangeli <aarcange@redhat.com>,
 linux-s390@vger.kernel.org, YiFei Zhu <yifeifz2@illinois.edu>,
 linux-csky@vger.kernel.org, Tianyin Xu <tyxu@illinois.edu>,
 linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>,
 Jann Horn <jannh@google.com>, Valentin Rothberg <vrothber@redhat.com>,
 Aleksa Sarai <cyphar@cyphar.com>, Josep Torrellas <torrella@illinois.edu>,
 Will Drewry <wad@chromium.org>, linux-parisc@vger.kernel.org,
 linux-kernel@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
 David Laight <David.Laight@aculab.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, linuxppc-dev@lists.ozlabs.org
X-BeenThere: containers@lists.linux-foundation.org
X-Mailman-Version: 2.1.15
Precedence: list
List-Id: Linux Containers <containers.lists.linuxfoundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers@lists.linux-foundation.org>
List-Help: <mailto:containers-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

From: YiFei Zhu <yifeifz2@illinois.edu>

This patch series enables bitmap cache for the remaining arches with
SECCOMP_FILTER, other than MIPS.

I was unable to find any of the arches having subarch-specific NR_syscalls
macros, so generic NR_syscalls is used. SH's syscall_get_arch seems to
only have the 32-bit subarch implementation. I'm not sure if this is
expected.

This series has not been tested; I have not built all the cross compilers
necessary to build test, let alone run the kernel or benchmark the
performance, so help on making sure the bitmap cache works as expected
(selftests/seccomp/{seccomp_benchmark,seccomp_bpf}) would be appreciated.
The series applies on top of Kees's for-next/seccomp branch.

v1 -> v2:
* ppc, sh: s/__SECCOMP_ARCH_LE_BIT/__SECCOMP_ARCH_LE/
* ppc: add "le" suffix to arch name when the arch is little endian.
* ppc: add explanation of why __LITTLE_ENDIAN__ is used to commit message.

YiFei Zhu (8):
  csky: Enable seccomp architecture tracking
  parisc: Enable seccomp architecture tracking
  powerpc: Enable seccomp architecture tracking
  riscv: Enable seccomp architecture tracking
  s390: Enable seccomp architecture tracking
  sh: Enable seccomp architecture tracking
  xtensa: Enable seccomp architecture tracking
  seccomp/cache: Report cache data through /proc/pid/seccomp_cache

 arch/Kconfig                       | 15 ++++++++
 arch/csky/include/asm/Kbuild       |  1 -
 arch/csky/include/asm/seccomp.h    | 11 ++++++
 arch/parisc/include/asm/Kbuild     |  1 -
 arch/parisc/include/asm/seccomp.h  | 22 +++++++++++
 arch/powerpc/include/asm/seccomp.h | 23 ++++++++++++
 arch/riscv/include/asm/seccomp.h   | 10 +++++
 arch/s390/include/asm/seccomp.h    |  9 +++++
 arch/sh/include/asm/seccomp.h      | 10 +++++
 arch/xtensa/include/asm/Kbuild     |  1 -
 arch/xtensa/include/asm/seccomp.h  | 11 ++++++
 fs/proc/base.c                     |  6 +++
 include/linux/seccomp.h            |  7 ++++
 kernel/seccomp.c                   | 59 ++++++++++++++++++++++++++++++
 14 files changed, 183 insertions(+), 3 deletions(-)
 create mode 100644 arch/csky/include/asm/seccomp.h
 create mode 100644 arch/parisc/include/asm/seccomp.h
 create mode 100644 arch/xtensa/include/asm/seccomp.h


base-commit: 38c37e8fd3d2590c4234d8cfbc22158362f0eb04
--
2.29.2
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
