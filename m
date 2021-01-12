Return-Path: <SRS0=YWEV=GP=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BEF82C433E0
	for <containers@archiver.kernel.org>; Tue, 12 Jan 2021 15:11:37 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 64B4A23131
	for <containers@archiver.kernel.org>; Tue, 12 Jan 2021 15:11:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 64B4A23131
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 1CA50861AF;
	Tue, 12 Jan 2021 15:11:37 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Q7UYSAWxJHmk; Tue, 12 Jan 2021 15:11:36 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id AFDBE861A1;
	Tue, 12 Jan 2021 15:11:36 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id AAFE0C088B;
	Tue, 12 Jan 2021 15:11:36 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 3DC00C013A
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 15:11:36 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 3269B2014B
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 15:11:36 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 9WWhFViFt26S
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 15:11:34 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from us-smtp-delivery-124.mimecast.com
 (us-smtp-delivery-124.mimecast.com [216.205.24.124])
 by silver.osuosl.org (Postfix) with ESMTPS id 7C3A420017
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 15:11:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
 s=mimecast20190719; t=1610464293;
 h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
 to:to:cc:cc:in-reply-to:in-reply-to:references:references;
 bh=CEcMeW3r8WIQ8e8BupQyhzcepDHWsTIT5isBpREM2VE=;
 b=C4jwxqOiniQjJ0SIN8ZiJPEaQrI4eWXwlw+54Ef/mFgPgGBQDBRnJr5G+cR7Ty5ExpUTk7
 hTh7/MLMb1vPrrCykJfdHr1WxCTTNsnokMZwWE1Yu4n8vONeGi31EFThpLjgQTAHUKJ6Ac
 glR7deafLGMYY14n5WrFxwa+zVn5aKY=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-593-mqIA9YfLNGisrvaAxwTllQ-1; Tue, 12 Jan 2021 10:11:32 -0500
X-MC-Unique: mqIA9YfLNGisrvaAxwTllQ-1
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com
 [10.5.11.14])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 752B7100C600;
 Tue, 12 Jan 2021 15:11:29 +0000 (UTC)
Received: from madcap2.tricolour.ca (unknown [10.10.110.8])
 by smtp.corp.redhat.com (Postfix) with ESMTP id F36BB5D9CD;
 Tue, 12 Jan 2021 15:11:15 +0000 (UTC)
From: Richard Guy Briggs <rgb@redhat.com>
To: Linux Containers List <containers@lists.linux-foundation.org>,
 Linux API <linux-api@vger.kernel.org>,
 Linux-Audit Mailing List <linux-audit@redhat.com>,
 Linux FSdevel <linux-fsdevel@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>,
 Linux NetDev Upstream Mailing List <netdev@vger.kernel.org>,
 Netfilter Devel List <netfilter-devel@vger.kernel.org>
Subject: [PATCH ghak90 v11 06/11] audit: add containerid support for user
 records
Date: Tue, 12 Jan 2021 10:09:34 -0500
Message-Id: <4a50ebc6f10c2365a04f271160d62b869a02a816.1610399347.git.rgb@redhat.com>
In-Reply-To: <cover.1610399347.git.rgb@redhat.com>
References: <cover.1610399347.git.rgb@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
Cc: Jens Axboe <axboe@kernel.dk>, Kees Cook <keescook@chromium.org>,
 Neil Horman <nhorman@tuxdriver.com>, Richard Guy Briggs <rgb@redhat.com>,
 David Howells <dhowells@redhat.com>,
 "Eric W. Biederman" <ebiederm@xmission.com>, Simo Sorce <simo@redhat.com>,
 Eric Paris <eparis@parisplace.org>, mpatel@redhat.com
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

Add audit container identifier auxiliary record to user event standalone
records.

Signed-off-by: Richard Guy Briggs <rgb@redhat.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>
Reviewed-by: Ondrej Mosnacek <omosnace@redhat.com>
---
 kernel/audit.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/kernel/audit.c b/kernel/audit.c
index 314af418bf67..946fe5862dc7 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -1339,12 +1339,6 @@ static void audit_log_common_recv_msg(struct audit_context *context,
 	audit_log_task_context(*ab);
 }
 
-static inline void audit_log_user_recv_msg(struct audit_buffer **ab,
-					   u16 msg_type)
-{
-	audit_log_common_recv_msg(NULL, ab, msg_type);
-}
-
 int is_audit_feature_set(int i)
 {
 	return af.features & AUDIT_FEATURE_TO_MASK(i);
@@ -1620,6 +1614,7 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		err = audit_filter(msg_type, AUDIT_FILTER_USER);
 		if (err == 1) { /* match or error */
 			char *str = data;
+			struct audit_context *context;
 
 			err = 0;
 			if (msg_type == AUDIT_USER_TTY) {
@@ -1627,7 +1622,8 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 				if (err)
 					break;
 			}
-			audit_log_user_recv_msg(&ab, msg_type);
+			context = audit_alloc_local(GFP_KERNEL);
+			audit_log_common_recv_msg(context, &ab, msg_type);
 			if (msg_type != AUDIT_USER_TTY) {
 				/* ensure NULL termination */
 				str[data_len - 1] = '\0';
@@ -1641,6 +1637,8 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 				audit_log_n_untrustedstring(ab, str, data_len);
 			}
 			audit_log_end(ab);
+			audit_log_container_id_ctx(context);
+			audit_free_context(context);
 		}
 		break;
 	case AUDIT_ADD_RULE:
-- 
2.18.4

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
