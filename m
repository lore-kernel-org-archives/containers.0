Return-Path: <SRS0=lEQp=EL=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A6AFC2D0A3
	for <containers@archiver.kernel.org>; Thu,  5 Nov 2020 00:14:20 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id C2FBA2080D
	for <containers@archiver.kernel.org>; Thu,  5 Nov 2020 00:14:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="DEVDRcJ2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C2FBA2080D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 5DED320412;
	Thu,  5 Nov 2020 00:14:19 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id gdRqF6aHIm1C; Thu,  5 Nov 2020 00:14:18 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id A635B203F1;
	Thu,  5 Nov 2020 00:14:18 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 8176DC088B;
	Thu,  5 Nov 2020 00:14:18 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id BADBFC0051
 for <containers@lists.linux-foundation.org>;
 Thu,  5 Nov 2020 00:14:17 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 9FD6385F53
 for <containers@lists.linux-foundation.org>;
 Thu,  5 Nov 2020 00:14:17 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id td8AyRmXjhfP
 for <containers@lists.linux-foundation.org>;
 Thu,  5 Nov 2020 00:14:16 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from us-smtp-delivery-124.mimecast.com
 (us-smtp-delivery-124.mimecast.com [63.128.21.124])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 9FD7085C20
 for <containers@lists.linux-foundation.org>;
 Thu,  5 Nov 2020 00:14:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
 s=mimecast20190719; t=1604535255;
 h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
 to:to:cc:cc:mime-version:mime-version:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=WgNzPrMRWMTkptqOa05ejOci8goRgD8ij+h1kCV7zHo=;
 b=DEVDRcJ2OJJ1Fj5C432+51FWBKZUWSWYTMrXI8BlzhDC3u2b4e3kpHtXO1g2hLdMva3tHK
 wLulOJJ5eO/tEGIC0uG29l8Hb3RI7pgbEssTWXHENgFpGS/5kVfnQ74IgZ6TZleGGEoRTu
 44nzSx8WRsy7fjMrZQBk/qG1USMF1Ug=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-244-ex9LEUj8M7ub4_d0L-DgDQ-1; Wed, 04 Nov 2020 19:14:13 -0500
X-MC-Unique: ex9LEUj8M7ub4_d0L-DgDQ-1
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com
 [10.5.11.22])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 2481C10082E8;
 Thu,  5 Nov 2020 00:14:11 +0000 (UTC)
Received: from mail (ovpn-116-241.rdu2.redhat.com [10.10.116.241])
 by smtp.corp.redhat.com (Postfix) with ESMTPS id B3E1D1007600;
 Thu,  5 Nov 2020 00:14:06 +0000 (UTC)
From: Andrea Arcangeli <aarcange@redhat.com>
To: Thomas Gleixner <tglx@linutronix.de>
Subject: [PATCH 1/1] x86: deduplicate the spectre_v2_user documentation
Date: Wed,  4 Nov 2020 19:14:06 -0500
Message-Id: <20201105001406.13005-2-aarcange@redhat.com>
In-Reply-To: <20201105001406.13005-1-aarcange@redhat.com>
References: <20201104234047.GA18850@redhat.com>
 <20201105001406.13005-1-aarcange@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
Cc: Josep Torrellas <torrella@illinois.edu>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>, Hubertus Franke <frankeh@us.ibm.com>,
 Jack Chen <jianyan2@illinois.edu>, Giuseppe Scrivano <gscrivan@redhat.com>,
 Andi Kleen <ak@linux.intel.com>, YiFei Zhu <yifeifz2@illinois.edu>,
 Waiman Long <longman@redhat.com>, Tianyin Xu <tyxu@illinois.edu>,
 Jann Horn <jannh@google.com>, Jiri Kosina <jikos@kernel.org>,
 Valentin Rothberg <vrothber@redhat.com>, Josh Poimboeuf <jpoimboe@redhat.com>,
 Will Drewry <wad@chromium.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 kernel list <linux-kernel@vger.kernel.org>,
 Andy Lutomirski <luto@amacapital.net>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
 David Laight <David.Laight@aculab.com>, bpf <bpf@vger.kernel.org>
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

This would need updating to make prctl be the new default, but it's
simpler to delete it and refer to the dup.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 Documentation/admin-guide/hw-vuln/spectre.rst | 51 +------------------
 1 file changed, 2 insertions(+), 49 deletions(-)

diff --git a/Documentation/admin-guide/hw-vuln/spectre.rst b/Documentation/admin-guide/hw-vuln/spectre.rst
index 19b897cb1d45..ab7d402c1677 100644
--- a/Documentation/admin-guide/hw-vuln/spectre.rst
+++ b/Documentation/admin-guide/hw-vuln/spectre.rst
@@ -593,61 +593,14 @@ kernel command line.
 		Not specifying this option is equivalent to
 		spectre_v2=auto.
 
-For user space mitigation:
-
-        spectre_v2_user=
-
-		[X86] Control mitigation of Spectre variant 2
-		(indirect branch speculation) vulnerability between
-		user space tasks
-
-		on
-			Unconditionally enable mitigations. Is
-			enforced by spectre_v2=on
-
-		off
-			Unconditionally disable mitigations. Is
-			enforced by spectre_v2=off
-
-		prctl
-			Indirect branch speculation is enabled,
-			but mitigation can be enabled via prctl
-			per thread. The mitigation control state
-			is inherited on fork.
-
-		prctl,ibpb
-			Like "prctl" above, but only STIBP is
-			controlled per thread. IBPB is issued
-			always when switching between different user
-			space processes.
-
-		seccomp
-			Same as "prctl" above, but all seccomp
-			threads will enable the mitigation unless
-			they explicitly opt out.
-
-		seccomp,ibpb
-			Like "seccomp" above, but only STIBP is
-			controlled per thread. IBPB is issued
-			always when switching between different
-			user space processes.
-
-		auto
-			Kernel selects the mitigation depending on
-			the available CPU features and vulnerability.
-
-		Default mitigation:
-		If CONFIG_SECCOMP=y then "seccomp", otherwise "prctl"
-
-		Not specifying this option is equivalent to
-		spectre_v2_user=auto.
-
 		In general the kernel by default selects
 		reasonable mitigations for the current CPU. To
 		disable Spectre variant 2 mitigations, boot with
 		spectre_v2=off. Spectre variant 1 mitigations
 		cannot be disabled.
 
+For spectre_v2_user see :doc:`/admin-guide/kernel-parameters`.
+
 Mitigation selection guide
 --------------------------
 

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
