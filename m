Return-Path: <SRS0=sUbK=FZ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 956DFC433DB
	for <containers@archiver.kernel.org>; Mon, 21 Dec 2020 17:14:12 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 4602D207CF
	for <containers@archiver.kernel.org>; Mon, 21 Dec 2020 17:14:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4602D207CF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id E994E869AA;
	Mon, 21 Dec 2020 17:14:11 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 7yj85nQQq0Ny; Mon, 21 Dec 2020 17:14:11 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 440DE86968;
	Mon, 21 Dec 2020 17:14:11 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 31AAAC1D9C;
	Mon, 21 Dec 2020 17:14:11 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 9C93CC0893
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Dec 2020 17:14:09 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 99A54869AA
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Dec 2020 17:14:09 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id F477h2iFU9-i
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Dec 2020 17:14:09 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from us-smtp-delivery-124.mimecast.com
 (us-smtp-delivery-124.mimecast.com [63.128.21.124])
 by whitealder.osuosl.org (Postfix) with ESMTPS id C367D86968
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Dec 2020 17:14:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
 s=mimecast20190719; t=1608570847;
 h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
 to:to:cc:cc:in-reply-to:in-reply-to:references:references;
 bh=XKVUppr1rM5syq4MOs0lnpavZ6GSfR5hr9FpW4a0PbI=;
 b=H4M9z65MDieb1X+1wHug/yShHnWcOjIEJk3nB+H8qYO+Idt8q0YZ/aC1frudhRQbTF1Whi
 53ZB6P6XOvvC5vAPCxVct0ObbGYPZsFNOM+P4G581/6TrOMSVmZBVMSrK20aXy1dyL/gOc
 UNRvq9RHxlP8Kvyio6bcS7PinX5ZEbU=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-482-fkmImXeqMb6RWByuNzYJtA-1; Mon, 21 Dec 2020 12:14:03 -0500
X-MC-Unique: fkmImXeqMb6RWByuNzYJtA-1
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com
 [10.5.11.14])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 652BA192CC52;
 Mon, 21 Dec 2020 17:14:02 +0000 (UTC)
Received: from madcap2.tricolour.ca (unknown [10.10.110.9])
 by smtp.corp.redhat.com (Postfix) with ESMTP id F1EBF5D9CA;
 Mon, 21 Dec 2020 17:13:52 +0000 (UTC)
From: Richard Guy Briggs <rgb@redhat.com>
To: Linux Containers List <containers@lists.linux-foundation.org>,
 Linux-Audit Mailing List <linux-audit@redhat.com>,
 LKML <linux-kernel@vger.kernel.org>
Subject: [PATCH ghau51/ghau40 v10 06/11] libaudit: add support to get the task
 audit container identifier
Date: Mon, 21 Dec 2020 12:12:46 -0500
Message-Id: <20201221171251.2610890-7-rgb@redhat.com>
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

Add the audit_get_containerid() call analogous to audit_getloginuid()
and audit_get_session() calls to get our own audit container identifier.

This is intended as a debug patch, not to be upstreamed.

Signed-off-by: Richard Guy Briggs <rgb@redhat.com>
---
 docs/Makefile.am             |  2 +-
 docs/audit_get_containerid.3 | 25 +++++++++++++++++++++++++
 lib/libaudit.c               | 29 +++++++++++++++++++++++++++++
 lib/libaudit.h               |  1 +
 4 files changed, 56 insertions(+), 1 deletion(-)
 create mode 100644 docs/audit_get_containerid.3

diff --git a/docs/Makefile.am b/docs/Makefile.am
index 8fb030c6e5e4..209789bb2051 100644
--- a/docs/Makefile.am
+++ b/docs/Makefile.am
@@ -28,7 +28,7 @@ man_MANS = audit_add_rule_data.3 audit_add_watch.3 auditctl.8 auditd.8 \
 auditd.conf.5 auditd-plugins.5 \
 audit_delete_rule_data.3 audit_detect_machine.3 \
 audit_encode_nv_string.3 audit_getloginuid.3 \
-audit_get_reply.3 audit_get_session.3 \
+audit_get_reply.3 audit_get_session.3 audit_get_containerid.3 \
 audit_log_acct_message.3 audit_log_user_avc_message.3 \
 audit_log_user_command.3 audit_log_user_comm_message.3 \
 audit_log_user_message.3 audit_log_semanage_message.3 \
diff --git a/docs/audit_get_containerid.3 b/docs/audit_get_containerid.3
new file mode 100644
index 000000000000..ef62a25db970
--- /dev/null
+++ b/docs/audit_get_containerid.3
@@ -0,0 +1,25 @@
+.TH "AUDIT_GET_CONTAINERID" "3" "Feb 2018" "Red Hat" "Linux Audit API"
+.SH NAME
+audit_get_containerid \- Get a program's container id value
+.SH SYNOPSIS
+.B #include <libaudit.h>
+.sp
+uin64_t audit_get_containerid(void);
+
+.SH DESCRIPTION
+This function returns the task's audit container identifier attribute.
+
+.SH "RETURN VALUE"
+
+This function returns the audit container identifier value if it was set. It will return a \-1 if the audit container identifier is unset. However, since uint64_t is an unsigned type, you will see the converted value instead of \-1.
+
+.SH "ERRORS"
+
+This function returns \-2 on failure. Additionally, in the event of a real error, errno would be set. The function can set errno based on failures of open, read, or strtoull.
+
+.SH "SEE ALSO"
+
+.BR audit_getloginuid (3).
+
+.SH AUTHOR
+Richard Guy Briggs
diff --git a/lib/libaudit.c b/lib/libaudit.c
index bcef9dc7a2cc..43c166fabbd8 100644
--- a/lib/libaudit.c
+++ b/lib/libaudit.c
@@ -967,6 +967,35 @@ uint32_t audit_get_session(void)
 		return ses;
 }
 
+/*
+ * This function will retrieve the audit container identifier or -2 if
+ * there is an error.
+ */
+uint64_t audit_get_containerid(void)
+{
+	uint64_t containerid;
+	int len, in;
+	char buf[32];
+
+	errno = 0;
+	in = open("/proc/self/audit_containerid", O_NOFOLLOW|O_RDONLY);
+	if (in < 0)
+		return -2;
+	do {
+		len = read(in, buf, sizeof(buf));
+	} while (len < 0 && errno == EINTR);
+	close(in);
+	if (len < 0 || len >= sizeof(buf))
+		return -2;
+	buf[len] = 0;
+	errno = 0;
+	containerid = strtoull(buf, 0, 10);
+	if (errno)
+		return -2;
+	else
+		return containerid;
+}
+
 int audit_rule_syscall_data(struct audit_rule_data *rule, int scall)
 {
 	int word = AUDIT_WORD(scall);
diff --git a/lib/libaudit.h b/lib/libaudit.h
index a252813d1f72..c6f45fdf7abc 100644
--- a/lib/libaudit.h
+++ b/lib/libaudit.h
@@ -602,6 +602,7 @@ extern int  audit_get_reply(int fd, struct audit_reply *rep, reply_t block,
 extern uid_t audit_getloginuid(void);
 extern int  audit_setloginuid(uid_t uid);
 extern uint32_t audit_get_session(void);
+extern uint64_t audit_get_containerid(void);
 extern int  audit_detect_machine(void);
 extern int audit_determine_machine(const char *arch);
 extern char *audit_format_signal_info(char *buf, int len, char *op, struct audit_reply *rep, char *res);
-- 
2.18.4

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
