Return-Path: <SRS0=sUbK=FZ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-18.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E443C433DB
	for <containers@archiver.kernel.org>; Mon, 21 Dec 2020 17:13:37 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 2DC7122BF3
	for <containers@archiver.kernel.org>; Mon, 21 Dec 2020 17:13:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2DC7122BF3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id B0BA8226FC;
	Mon, 21 Dec 2020 17:13:36 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id worHyql-yAuv; Mon, 21 Dec 2020 17:13:36 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id BEB59226EA;
	Mon, 21 Dec 2020 17:13:35 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id AAFD9C1825;
	Mon, 21 Dec 2020 17:13:35 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 46E48C0893
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Dec 2020 17:13:34 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 437E887205
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Dec 2020 17:13:34 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id enpN677inMTw
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Dec 2020 17:13:33 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from us-smtp-delivery-124.mimecast.com
 (us-smtp-delivery-124.mimecast.com [63.128.21.124])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 912D186687
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Dec 2020 17:13:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
 s=mimecast20190719; t=1608570812;
 h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
 to:to:cc:cc:in-reply-to:in-reply-to:references:references;
 bh=Pen0iXiYwfSzOz/8kWP8vcu8HMjokSkoBzgkXv/pINU=;
 b=HL1Y89wX6mghuxlKL6ab9EnMcpRRB2wTTZ++avq3h5amLrh/9vZ/xMP/5k7qbj7zcQYp++
 4fd4hB0XdvOHi8DVfGm+cH5+HfRMxQfTcOYCMBkaTVscQ3yNxVfGs9VnT4aVrxZG1e/sqA
 9p/27pUhodBRtwxRXjZhjsDqrzKe6tY=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-508-An2lO8PVPb-aOei3vOxi0w-1; Mon, 21 Dec 2020 12:13:30 -0500
X-MC-Unique: An2lO8PVPb-aOei3vOxi0w-1
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com
 [10.5.11.14])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 74B818144E0;
 Mon, 21 Dec 2020 17:13:29 +0000 (UTC)
Received: from madcap2.tricolour.ca (unknown [10.10.110.9])
 by smtp.corp.redhat.com (Postfix) with ESMTP id 010065D9CA;
 Mon, 21 Dec 2020 17:13:25 +0000 (UTC)
From: Richard Guy Briggs <rgb@redhat.com>
To: Linux Containers List <containers@lists.linux-foundation.org>,
 Linux-Audit Mailing List <linux-audit@redhat.com>,
 LKML <linux-kernel@vger.kernel.org>
Subject: [PATCH ghau51/ghau40 v10 01/11] AUDIT_CONTAINER_OP message type basic
 support
Date: Mon, 21 Dec 2020 12:12:41 -0500
Message-Id: <20201221171251.2610890-2-rgb@redhat.com>
In-Reply-To: <20201221171251.2610890-1-rgb@redhat.com>
References: <20201221171251.2610890-1-rgb@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
Cc: Richard Guy Briggs <rgb@redhat.com>, Eric Paris <eparis@parisplace.org>,
 mpatel@redhat.com, Neil Horman <nhorman@tuxdriver.com>
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
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

This defines the message number for the audit container identifier
registration record should the kernel headers not be up to date, gives
the record number a name for printing and allows the record to be
interpreted since it is in the 1000 range like AUDIT_LOGIN.

See: https://github.com/linux-audit/audit-userspace/issues/51
See: https://github.com/linux-audit/audit-kernel/issues/90
See: https://github.com/linux-audit/audit-testsuite/issues/64
See: https://github.com/linux-audit/audit-kernel/wiki/RFE-Audit-Container-ID
Signed-off-by: Richard Guy Briggs <rgb@redhat.com>
---
 lib/libaudit.h     | 4 ++++
 lib/msg_typetab.h  | 1 +
 lib/netlink.c      | 1 +
 src/ausearch-lol.c | 2 ++
 4 files changed, 8 insertions(+)

diff --git a/lib/libaudit.h b/lib/libaudit.h
index 3a8e8c854fed..7fe56f4c8b22 100644
--- a/lib/libaudit.h
+++ b/lib/libaudit.h
@@ -247,6 +247,10 @@ extern "C" {
 #define AUDIT_GET_FEATURE       1019    /* Get which features are enabled */
 #endif
 
+#ifndef AUDIT_CONTAINER_OP
+#define AUDIT_CONTAINER_OP	1020    /* Container creation notice */
+#endif
+
 #ifndef AUDIT_MMAP
 #define AUDIT_MMAP		1323 /* Descriptor and flags in mmap */
 #endif
diff --git a/lib/msg_typetab.h b/lib/msg_typetab.h
index 4dff2e9c4d40..376e121e1278 100644
--- a/lib/msg_typetab.h
+++ b/lib/msg_typetab.h
@@ -44,6 +44,7 @@ _S(AUDIT_LOGIN,                      "LOGIN"                         )
 //_S(AUDIT_TTY_SET,                    "TTY_SET"                       )
 //_S(AUDIT_SET_FEATURE,                "SET_FEATURE"                   )
 //_S(AUDIT_GET_FEATURE,                "GET_FEATURE"                   )
+_S(AUDIT_CONTAINER_OP,               "CONTAINER_OP"                  )
 _S(AUDIT_USER_AUTH,                  "USER_AUTH"                     )
 _S(AUDIT_USER_ACCT,                  "USER_ACCT"                     )
 _S(AUDIT_USER_MGMT,                  "USER_MGMT"                     )
diff --git a/lib/netlink.c b/lib/netlink.c
index 9525b8d833c0..d660b8f37c79 100644
--- a/lib/netlink.c
+++ b/lib/netlink.c
@@ -182,6 +182,7 @@ static int adjust_reply(struct audit_reply *rep, int len)
 			break;
 		case AUDIT_USER:
 		case AUDIT_LOGIN:
+		case AUDIT_CONTAINER_OP:
 		case AUDIT_KERNEL:
 		case AUDIT_FIRST_USER_MSG...AUDIT_LAST_USER_MSG:
 		case AUDIT_FIRST_USER_MSG2...AUDIT_LAST_USER_MSG2:
diff --git a/src/ausearch-lol.c b/src/ausearch-lol.c
index f0f36e04dd93..05fe80fe3ad6 100644
--- a/src/ausearch-lol.c
+++ b/src/ausearch-lol.c
@@ -248,6 +248,8 @@ static void check_events(lol *lo, time_t sec)
 				ready++;
 			} else if ( cur->l->e.type <  AUDIT_LOGIN            ||
 				   (cur->l->e.type >  AUDIT_LOGIN           &&
+				    cur->l->e.type <  AUDIT_CONTAINER_OP   ) ||
+				   (cur->l->e.type >  AUDIT_CONTAINER_OP    &&
 				    cur->l->e.type <  AUDIT_FIRST_EVENT    ) ||
 				    cur->l->e.type == AUDIT_PROCTITLE        ||
 				   (cur->l->e.type >= AUDIT_MAC_UNLBL_ALLOW &&
-- 
2.18.4

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
