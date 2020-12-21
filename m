Return-Path: <SRS0=sUbK=FZ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B0C4C433E6
	for <containers@archiver.kernel.org>; Mon, 21 Dec 2020 17:14:27 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id C969A22CA1
	for <containers@archiver.kernel.org>; Mon, 21 Dec 2020 17:14:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C969A22CA1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 8430E2035D;
	Mon, 21 Dec 2020 17:14:26 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ZDSF5YFHbDqz; Mon, 21 Dec 2020 17:14:25 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id D766F226EA;
	Mon, 21 Dec 2020 17:14:25 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id C575FC1825;
	Mon, 21 Dec 2020 17:14:25 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id AD619C1D9C
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Dec 2020 17:14:24 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 9F0F922817
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Dec 2020 17:14:24 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id HbsDK00K0VGZ
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Dec 2020 17:14:24 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from us-smtp-delivery-124.mimecast.com
 (us-smtp-delivery-124.mimecast.com [63.128.21.124])
 by silver.osuosl.org (Postfix) with ESMTPS id BF47322794
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Dec 2020 17:14:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
 s=mimecast20190719; t=1608570862;
 h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
 to:to:cc:cc:in-reply-to:in-reply-to:references:references;
 bh=wfN0o0JokmbNz9DafEtBUD4PMjxJrKYE3OGEsWN7KpM=;
 b=EeUVgbMXAoaj/NvdCoZq0dSQC4ZvSzSkkYcHtyiF6ZevQYSu87XP95JCY3qnlxcPOU2q0x
 iT+tVGFV2BApyLJRDhQEfjiZFqZ52ugN8VE8a0UVqg711pL6G6Wnw8YgSRE7I2Hmp+/46U
 ceLw0S173bBI+69vye8zVexKYfqoRbQ=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-30-tWC4IxGdNQ-Ac7YKD7fj0g-1; Mon, 21 Dec 2020 12:14:18 -0500
X-MC-Unique: tWC4IxGdNQ-Ac7YKD7fj0g-1
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com
 [10.5.11.14])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by mimecast-mx01.redhat.com (Postfix) with ESMTPS id DACDB1934108;
 Mon, 21 Dec 2020 17:14:16 +0000 (UTC)
Received: from madcap2.tricolour.ca (unknown [10.10.110.9])
 by smtp.corp.redhat.com (Postfix) with ESMTP id 523865D9CA;
 Mon, 21 Dec 2020 17:14:15 +0000 (UTC)
From: Richard Guy Briggs <rgb@redhat.com>
To: Linux Containers List <containers@lists.linux-foundation.org>,
 Linux-Audit Mailing List <linux-audit@redhat.com>,
 LKML <linux-kernel@vger.kernel.org>
Subject: [PATCH ghau51/ghau40 v10 09/11] contid: interpret correctly
 CONTAINER_ID contid field csv
Date: Mon, 21 Dec 2020 12:12:49 -0500
Message-Id: <20201221171251.2610890-10-rgb@redhat.com>
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

The CONTAINER_ID record contid field can contain comma-separated values
when accompanying a NETFILTER_PKT record.  Records appeared interpreted
as such:

Wrong:
	CONTAINER_ID msg=audit(2019-04-10 13:20:18.746:1690) : contid=777 666,333
Right:
	CONTAINER_ID msg=audit(2019-04-10 13:20:18.746:1690) : contid=777,666,333

Signed-off-by: Richard Guy Briggs <rgb@redhat.com>
---
 src/ausearch-report.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/src/ausearch-report.c b/src/ausearch-report.c
index 416c2b13fa6a..754b28af2cb6 100644
--- a/src/ausearch-report.c
+++ b/src/ausearch-report.c
@@ -279,7 +279,7 @@ no_print:
 			if (str && val && (str < val)) {
 			// Value side  has commas and another field exists
 			// Known: LABEL_LEVEL_CHANGE banners=none,none
-			// Known: ROLL_ASSIGN new-role=r,r
+			// Known: ROLE_ASSIGN new-role=r,r
 			// Known: any MAC LABEL can potentially have commas
 				int ftype = auparse_interp_adjust_type(n->type,
 								name, val);
@@ -293,9 +293,11 @@ no_print:
 			} else if (str && (val == NULL)) {
 			// Goes all the way to the end. Done parsing
 			// Known: MCS context in PATH rec obj=u:r:t:s0:c2,c7
+			// Known: CONTAINER_ID/OP old-/contid can be a comma-separated list
 				int ftype = auparse_interp_adjust_type(n->type,
 								name, ptr);
-				if (ftype == AUPARSE_TYPE_MAC_LABEL)
+				if (ftype == AUPARSE_TYPE_MAC_LABEL
+				    || ftype == AUPARSE_TYPE_CONTID)
 					str = NULL;
 				else {
 					*str++ = 0;
-- 
2.18.4

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
