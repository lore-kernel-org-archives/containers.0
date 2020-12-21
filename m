Return-Path: <SRS0=sUbK=FZ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B03D2C433E6
	for <containers@archiver.kernel.org>; Mon, 21 Dec 2020 17:14:28 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 6F48E22BF3
	for <containers@archiver.kernel.org>; Mon, 21 Dec 2020 17:14:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F48E22BF3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 38ADF8768C;
	Mon, 21 Dec 2020 17:14:28 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id EokfaFs8Kkng; Mon, 21 Dec 2020 17:14:26 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id E97D9875A0;
	Mon, 21 Dec 2020 17:14:26 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id D7173C1825;
	Mon, 21 Dec 2020 17:14:26 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 540C2C0893
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Dec 2020 17:14:25 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 434D887680
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Dec 2020 17:14:25 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id HsxR1I5y27lv
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Dec 2020 17:14:23 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from us-smtp-delivery-124.mimecast.com
 (us-smtp-delivery-124.mimecast.com [63.128.21.124])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 9B1D6875A0
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Dec 2020 17:14:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
 s=mimecast20190719; t=1608570862;
 h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
 to:to:cc:cc:in-reply-to:in-reply-to:references:references;
 bh=uXB/jNXUv9e+Lshpw+I9i6mDdo7p41fM2aDvk6zwKqc=;
 b=FEDK3RkQR686ba7wdWeuun/HCswJ5FpmvCekTYQRRvHNfmhWRIYmp7HrA17/8aSqf8Vbr7
 iWj+Bpr3u0eG2zqZgV1eD4SlrA1dSCcvSozXs1EhPXJ2NjKHTTNpO9HLhCWtsmP6ZsjacV
 xuYstl9ul6gE/OTPkCgVeKjL4ncKXLE=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-204-otHFcp3CMxqSAznnk3uUCw-1; Mon, 21 Dec 2020 12:14:20 -0500
X-MC-Unique: otHFcp3CMxqSAznnk3uUCw-1
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com
 [10.5.11.14])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by mimecast-mx01.redhat.com (Postfix) with ESMTPS id E1C8881F032;
 Mon, 21 Dec 2020 17:14:18 +0000 (UTC)
Received: from madcap2.tricolour.ca (unknown [10.10.110.9])
 by smtp.corp.redhat.com (Postfix) with ESMTP id 2BD255D9CA;
 Mon, 21 Dec 2020 17:14:16 +0000 (UTC)
From: Richard Guy Briggs <rgb@redhat.com>
To: Linux Containers List <containers@lists.linux-foundation.org>,
 Linux-Audit Mailing List <linux-audit@redhat.com>,
 LKML <linux-kernel@vger.kernel.org>
Subject: [PATCH ghau51/ghau40 v10 10/11] ausearch: convert contid to
 comma-sep/carrat-mod cnode/clist
Date: Mon, 21 Dec 2020 12:12:50 -0500
Message-Id: <20201221171251.2610890-11-rgb@redhat.com>
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

Now that the kernel is able to track container nesting ("audit: track
container nesting"), convert the ausearch internals to parse and track
the compound list of contids stored in their native u64 format for
faster and more efficient processing.

Signed-off-by: Richard Guy Briggs <rgb@redhat.com>
---
 src/Makefile.am        |   6 +-
 src/aureport-options.c |   3 +-
 src/ausearch-contid.c  | 172 +++++++++++++++++++++++++++++++++++++++++
 src/ausearch-contid.h  |  60 ++++++++++++++
 src/ausearch-llist.c   |   8 +-
 src/ausearch-llist.h   |   3 +-
 src/ausearch-match.c   |  36 ++++++++-
 src/ausearch-options.c |  36 ++++++++-
 src/ausearch-options.h |   3 +-
 src/ausearch-parse.c   | 110 ++++++++++++++++++++------
 10 files changed, 402 insertions(+), 35 deletions(-)
 create mode 100644 src/ausearch-contid.c
 create mode 100644 src/ausearch-contid.h

diff --git a/src/Makefile.am b/src/Makefile.am
index fda612b1ccb0..91c29cfbe52e 100644
--- a/src/Makefile.am
+++ b/src/Makefile.am
@@ -25,7 +25,7 @@ SUBDIRS = test
 AM_CPPFLAGS = -I${top_srcdir} -I${top_srcdir}/lib -I${top_srcdir}/src/libev -I${top_srcdir}/auparse -I${top_srcdir}/audisp -I${top_srcdir}/common
 sbin_PROGRAMS = auditd auditctl aureport ausearch autrace
 AM_CFLAGS = -D_GNU_SOURCE -Wno-pointer-sign
-noinst_HEADERS = auditd-config.h auditd-event.h auditd-listen.h ausearch-llist.h ausearch-options.h auditctl-llist.h aureport-options.h ausearch-parse.h aureport-scan.h ausearch-lookup.h ausearch-int.h auditd-dispatch.h ausearch-string.h ausearch-nvpair.h ausearch-common.h ausearch-avc.h ausearch-time.h ausearch-lol.h auditctl-listing.h ausearch-checkpt.h
+noinst_HEADERS = auditd-config.h auditd-event.h auditd-listen.h ausearch-llist.h ausearch-options.h auditctl-llist.h aureport-options.h ausearch-parse.h aureport-scan.h ausearch-lookup.h ausearch-int.h auditd-dispatch.h ausearch-string.h ausearch-nvpair.h ausearch-common.h ausearch-avc.h ausearch-time.h ausearch-lol.h auditctl-listing.h ausearch-checkpt.h ausearch-contid.h
 
 auditd_SOURCES = auditd.c auditd-event.c auditd-config.c auditd-reconfig.c auditd-sendmail.c auditd-dispatch.c
 if ENABLE_LISTENER
@@ -41,10 +41,10 @@ auditctl_CFLAGS = -fPIE -DPIE -g -D_GNU_SOURCE
 auditctl_LDFLAGS = -pie -Wl,-z,relro -Wl,-z,now
 auditctl_LDADD = -L${top_builddir}/lib -laudit -L${top_builddir}/auparse -lauparse -L${top_builddir}/common -laucommon
 
-aureport_SOURCES = aureport.c auditd-config.c ausearch-llist.c aureport-options.c ausearch-string.c ausearch-parse.c aureport-scan.c aureport-output.c ausearch-lookup.c ausearch-int.c ausearch-time.c ausearch-nvpair.c ausearch-avc.c ausearch-lol.c
+aureport_SOURCES = aureport.c auditd-config.c ausearch-llist.c aureport-options.c ausearch-string.c ausearch-parse.c aureport-scan.c aureport-output.c ausearch-lookup.c ausearch-int.c ausearch-time.c ausearch-nvpair.c ausearch-avc.c ausearch-lol.c ausearch-contid.c
 aureport_LDADD = -L${top_builddir}/lib -laudit -L${top_builddir}/auparse -lauparse -L${top_builddir}/common -laucommon
 
-ausearch_SOURCES = ausearch.c auditd-config.c ausearch-llist.c ausearch-options.c ausearch-report.c ausearch-match.c ausearch-string.c ausearch-parse.c ausearch-int.c ausearch-time.c ausearch-nvpair.c ausearch-lookup.c ausearch-avc.c ausearch-lol.c ausearch-checkpt.c
+ausearch_SOURCES = ausearch.c auditd-config.c ausearch-llist.c ausearch-options.c ausearch-report.c ausearch-match.c ausearch-string.c ausearch-parse.c ausearch-int.c ausearch-time.c ausearch-nvpair.c ausearch-lookup.c ausearch-avc.c ausearch-lol.c ausearch-checkpt.c ausearch-contid.c
 ausearch_LDADD = -L${top_builddir}/lib -laudit -L${top_builddir}/auparse -lauparse -L${top_builddir}/common -laucommon
 
 autrace_SOURCES = autrace.c delete_all.c auditctl-llist.c
diff --git a/src/aureport-options.c b/src/aureport-options.c
index 29d267f2d1cb..0aa742c9a1fe 100644
--- a/src/aureport-options.c
+++ b/src/aureport-options.c
@@ -36,6 +36,7 @@
 #include "ausearch-time.h"
 #include "libaudit.h"
 #include "auparse-defs.h"
+#include "ausearch-contid.h"
 
 
 /* Global vars that will be accessed by the main program */
@@ -62,7 +63,7 @@ const char *event_vmname = NULL;
 long long event_exit = 0;
 int event_exit_is_set = 0;
 int event_ppid = -1, event_session_id = -2;
-unsigned long long event_contid = -1;
+clist *event_contid = NULL;
 int event_debug = 0, event_machine = -1;
 
 /* These are used by aureport */
diff --git a/src/ausearch-contid.c b/src/ausearch-contid.c
new file mode 100644
index 000000000000..87a94497ced1
--- /dev/null
+++ b/src/ausearch-contid.c
@@ -0,0 +1,172 @@
+/*
+ * ausearch-contid.c - Minimal linked list library for contid
+ * adapted from ausearch-string.c
+ * Copyright (c) 2005,2008,2014,2019 Red Hat Inc., Durham, North Carolina.
+ * All Rights Reserved.
+ *
+ * This software may be freely redistributed and/or modified under the
+ * terms of the GNU General Public License as published by the Free
+ * Software Foundation; either version 2, or (at your option) any
+ * later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; see the file COPYING. If not, write to the
+ * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor
+ * Boston, MA 02110-1335, USA.
+ *
+ * Authors:
+ *   Steve Grubb <sgrubb@redhat.com>
+ *   Richard Guy Briggs <rgb@redhat.com>
+ */
+
+#include <stdlib.h>
+#include "ausearch-contid.h"
+
+
+void clist_create(clist *l)
+{
+	l->head = NULL;
+	l->cur = NULL;
+	l->cnt = 0;
+}
+
+void clist_last(clist *l)
+{
+	register cnode *cur;
+
+	if (l->head == NULL)
+		return;
+
+	// Try using cur so that we don't have to start at beginnning
+	if (l->cur)
+		cur = l->cur;
+	else
+		cur = l->head;
+
+	// Loop until no next value
+	while (cur->next)
+		cur = cur->next;
+	l->cur = cur;
+}
+
+cnode *clist_next(clist *l)
+{
+	if (l->cur == NULL)
+		return NULL;
+	l->cur = l->cur->next;
+	return l->cur;
+}
+
+void clist_append(clist *l, cnode *node)
+{
+	cnode *newnode;
+
+	newnode = malloc(sizeof(cnode));
+
+	newnode->id = node->id;
+	newnode->hits = node->hits;
+	newnode->next = NULL;
+
+	// Make sure cursor is at the end
+	clist_last(l);
+
+	// if we are at top, fix this up
+	if (l->head == NULL)
+		l->head = newnode;
+	else	// Otherwise add pointer to newnode
+		l->cur->next = newnode;
+
+	// make newnode current
+	l->cur = newnode;
+	l->cnt++;
+}
+
+void clist_clear(clist *l)
+{
+	cnode *nextnode;
+	register cnode *current;
+
+	current = l->head;
+	while (current) {
+		nextnode = current->next;
+		free(current);
+		current = nextnode;
+	}
+	l->head = NULL;
+	l->cur = NULL;
+	l->cnt = 0;
+}
+
+/* This function dominates the timing of aureport. Needs to be more efficient */
+int clist_add_if_uniq(clist *l, const unsigned long long id)
+{
+	cnode cn;
+	register cnode *cur;
+
+	if (id == (unsigned long long)-1)
+		return -1;
+
+	cur = l->head;
+	while (cur) {
+		if (id == cur->id) {
+			cur->hits++;
+			l->cur = cur;
+			return 0;
+		}
+		cur = cur->next;
+	}
+
+	/* No matches, append to the end */
+	cn.id = id;
+	cn.hits = 1;
+	clist_append(l, &cn);
+	return 1;
+}
+
+// If lprev would be NULL, use l->head
+static void swap_nodes(cnode *lprev, cnode *left, cnode *right)
+{
+	cnode *t = right->next;
+
+	if (lprev)
+		lprev->next = right;
+	right->next = left;
+	left->next = t;
+}
+
+// This will sort the list from most hits to least
+void clist_sort_by_hits(clist *l)
+{
+	register cnode *cur, *prev;
+
+	if (l->cnt <= 1)
+		return;
+
+	prev = cur = l->head;
+
+	while (cur && cur->next) {
+		/* If the next node is bigger */
+		if (cur->hits < cur->next->hits) {
+			if (cur == l->head) {
+				// Update the actual list head
+				l->head = cur->next;
+				prev = NULL;
+			}
+			swap_nodes(prev, cur, cur->next);
+
+			// start over
+			prev = cur = l->head;
+			continue;
+		}
+		prev = cur;
+		cur = cur->next;
+	}
+	// End with cur pointing at first record
+	l->cur = l->head;
+}
+
diff --git a/src/ausearch-contid.h b/src/ausearch-contid.h
new file mode 100644
index 000000000000..edc534943398
--- /dev/null
+++ b/src/ausearch-contid.h
@@ -0,0 +1,60 @@
+/*
+ * ausearch-contid.h - Header file for ausearch-contid.c
+ * adapted from ausearch-string.h
+ * Copyright (c) 2005,2008,2019 Red Hat Inc., Durham, North Carolina.
+ * All Rights Reserved.
+ *
+ * This software may be freely redistributed and/or modified under the
+ * terms of the GNU General Public License as published by the Free
+ * Software Foundation; either version 2, or (at your option) any
+ * later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; see the file COPYING. If not, write to the
+ * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor
+ * Boston, MA 02110-1335, USA.
+ *
+ * Authors:
+ *   Steve Grubb <sgrubb@redhat.com>
+ *   Richard Guy Briggs <rgb@redhat.com>
+ */
+
+#ifndef AUCONTID_HEADER
+#define AUCONTID_HEADER
+
+#include "config.h"
+
+/* This is the node of the linked list. message & item are the only elements
+ * at this time. Any data elements that are per item goes here. */
+typedef struct _cnode {
+	unsigned long long id;// The audit container id
+	unsigned int hits;	// Number of times this contid was attempted to be added
+	struct _cnode *next;	// Next contid node pointer
+} cnode;
+
+/* This is the linked list head. Only data elements that are 1 per
+ * event goes here. */
+typedef struct {
+	cnode *head;		// List head
+	cnode *cur;		// Pointer to current node
+	unsigned int cnt;	// How many items in this list
+} clist;
+
+void clist_create(clist *l);
+static inline void clist_first(clist *l) { l->cur = l->head; }
+void clist_last(clist *l);
+cnode *clist_next(clist *l);
+static inline cnode *clist_get_cur(clist *l) { return l->cur; }
+void clist_append(clist *l, cnode *node);
+void clist_clear(clist *l);
+
+/* append a contid if its not already on the list */
+int clist_add_if_uniq(clist *l, const unsigned long long id);
+void clist_sort_by_hits(clist *l);
+
+#endif
diff --git a/src/ausearch-llist.c b/src/ausearch-llist.c
index ade727a9e102..6624398a1b5c 100644
--- a/src/ausearch-llist.c
+++ b/src/ausearch-llist.c
@@ -60,7 +60,7 @@ void list_create(llist *l)
 	l->s.arch = 0;
 	l->s.syscall = 0;
 	l->s.session_id = -2;
-	l->s.contid = -1;
+	l->s.contid = NULL;
 	l->s.uuid = NULL;
 	l->s.vmname = NULL;
 	l->s.tuid = NULL;
@@ -212,7 +212,11 @@ void list_clear(llist* l)
 	l->s.arch = 0;
 	l->s.syscall = 0;
 	l->s.session_id = -2;
-	l->s.contid = -1;
+	if (l->s.contid) {
+		clist_clear(l->s.contid);
+		free(l->s.contid);
+		l->s.contid = NULL;
+	}
 	free(l->s.uuid);
 	l->s.uuid = NULL;
 	free(l->s.vmname);
diff --git a/src/ausearch-llist.h b/src/ausearch-llist.h
index 2d1f52237ce6..f2f004b09630 100644
--- a/src/ausearch-llist.h
+++ b/src/ausearch-llist.h
@@ -31,6 +31,7 @@
 #include <sys/types.h>
 #include "ausearch-string.h"
 #include "ausearch-avc.h"
+#include "ausearch-contid.h"
 #include "ausearch-common.h"
 
 
@@ -56,7 +57,7 @@ typedef struct
   int arch;             // arch
   int syscall;          // syscall
   uint32_t session_id;  // Login session id
-  __u64 contid;         // Container id
+  clist *contid;        // Container id
   long long exit;       // Syscall exit code
   int exit_is_set;      // Syscall exit code is valid
   char *hostname;       // remote hostname
diff --git a/src/ausearch-match.c b/src/ausearch-match.c
index 47c12581a963..e852f1c28d45 100644
--- a/src/ausearch-match.c
+++ b/src/ausearch-match.c
@@ -37,6 +37,7 @@ static int strmatch(const char *needle, const char *haystack);
 static int user_match(llist *l);
 static int group_match(llist *l);
 static int context_match(llist *l);
+static int contid_match(llist *l);
 
 static void load_interpretations(const llist *l)
 {
@@ -113,8 +114,7 @@ int match(llist *l)
 				if ((event_session_id != -2) &&
 					(event_session_id != l->s.session_id))
 					return 0;
-				if ((event_contid != -1) &&
-					(event_contid != l->s.contid))
+				if (contid_match(l) == 0)
 					return 0;
 				if (event_exit_is_set) {
 					if (l->s.exit_is_set == 0)
@@ -417,3 +417,35 @@ static int context_match(llist *l)
 	return 1;
 }
 
+/*
+ * This function compares container ids. It returns a 0 if no match and a 1 if
+ * there is a match
+ */
+static int contid_match(llist *l)
+{
+	if (event_contid) {
+		const cnode *ecn;
+		clist *ecptr = event_contid;
+
+		clist_first(ecptr);
+		ecn = clist_get_cur(ecptr);
+		if (l->s.contid) {
+			while (ecn) {
+				const cnode *cn;
+				clist *cptr = l->s.contid;
+
+				clist_first(cptr);
+				cn = clist_get_cur(cptr);
+				while (cn) {
+					if (cn->id == ecn->id)
+						return 1;
+					cn = clist_next(cptr);
+				}
+				ecn = clist_next(ecptr);
+			}
+		}
+		return 0;
+	}
+	return 1;
+}
+
diff --git a/src/ausearch-options.c b/src/ausearch-options.c
index b45793e88109..0cc5974f8f43 100644
--- a/src/ausearch-options.c
+++ b/src/ausearch-options.c
@@ -60,7 +60,7 @@ int event_syscall = -1, event_machine = -1;
 int event_ua = 0, event_ga = 0, event_se = 0;
 int just_one = 0;
 uint32_t event_session_id = -2;
-unsigned long long event_contid = -1;
+clist *event_contid = NULL;
 long long event_exit = 0;
 int event_exit_is_set = 0;
 int line_buffered = 0;
@@ -1201,22 +1201,52 @@ int check_params(int count, char *vars[])
 			size_t len = strlen(optarg);
 
 			if (isdigit(optarg[0])) {
+				__u64 contid;
+				cnode cn;
+
 				errno = 0;
-				event_contid = strtoull(optarg, NULL, 0);
+				contid = strtoull(optarg, NULL, 0);
 				if (errno) {
 					fprintf(stderr,
 			"Numeric container ID conversion error (%s) for %s\n",
 						strerror(errno), optarg);
 					retval = -1;
+				} else {
+					if (!event_contid) {
+						event_contid = malloc(sizeof(clist));
+						if (!event_contid) {
+							retval = -1;
+							break;
+						}
+						clist_create(event_contid);
+					}
+					cn.id = contid;
+					cn.hits = 0;
+					clist_append(event_contid, &cn);
 				}
 			} else if (len >= 2 && *(optarg) == '-' &&
 					(isdigit(optarg[1]))) {
+				__u64 contid;
+				cnode cn;
+
 				errno = 0;
-				event_contid = strtoll(optarg, NULL, 0);
+				contid = strtoll(optarg, NULL, 0);
 				if (errno) {
 					retval = -1;
 					fprintf(stderr, "Error converting %s\n",
 						optarg);
+				} else {
+					if (!event_contid) {
+						event_contid = malloc(sizeof(clist));
+						if (!event_contid) {
+							retval = -1;
+							break;
+						}
+						clist_create(event_contid);
+					}
+					cn.id = contid;
+					cn.hits = 0;
+					clist_append(event_contid, &cn);
 				}
 			} else {
 				fprintf(stderr,
diff --git a/src/ausearch-options.h b/src/ausearch-options.h
index 085d492d101c..ac4f97d00a83 100644
--- a/src/ausearch-options.h
+++ b/src/ausearch-options.h
@@ -29,6 +29,7 @@
 #include <stdint.h>
 #include "ausearch-common.h"
 #include "ausearch-int.h"
+#include "ausearch-contid.h"
 
 /* Global variables that describe what search is to be performed */
 extern const char *event_key;
@@ -40,7 +41,7 @@ extern int line_buffered;
 extern int event_debug;
 extern pid_t event_ppid;
 extern uint32_t event_session_id;
-extern unsigned long long event_contid;
+extern clist *event_contid;
 extern ilist *event_type;
 
 /* Data type to govern output format */
diff --git a/src/ausearch-parse.c b/src/ausearch-parse.c
index 374b369be7b7..93482be3606e 100644
--- a/src/ausearch-parse.c
+++ b/src/ausearch-parse.c
@@ -79,6 +79,18 @@ static int audit_avc_init(search_items *s)
 	return 0;
 }
 
+static int audit_contid_init(search_items *s)
+{
+	if (s->contid == NULL) {
+		//create
+		s->contid = malloc(sizeof(clist));
+		if (s->contid == NULL)
+			return -1;
+		clist_create(s->contid);
+	}
+	return 0;
+}
+
 /*
  * This function will take the list and extract the searchable fields from it.
  * It returns 0 on success and 1 on failure.
@@ -1489,22 +1501,57 @@ static int parse_container_op(const lnode *n, search_items *s)
 	// skip op
 	// skip opid
 	// get contid
-	if (event_contid != -1) {
+	if (event_contid) {
+		cnode cn;
+		char *comma;
+
 		str = strstr(term, "contid=");
-		if (str == NULL)
+		if (!str)
 			return 46;
-		ptr = str + 7;
-		term = strchr(ptr, ' ');
-		if (term == NULL)
+		if (audit_contid_init(s) < 0)
+			return 48;
+		str += 7;
+		term = strchr(str, ' ');
+		if (!term)
 			return 47;
 		*term = 0;
-		errno = 0;
-		s->contid = strtoull(ptr, NULL, 10);
-		if (errno)
-			return 48;
-		*term = ' ';
+		if (strcmp(str, "-1"))
+			cn.id = strtoull(str, NULL, 10);
+		else
+			cn.id = ULLONG_MAX;
+		cn.hits = 1;
+		clist_append(s->contid, &cn);
+		if (term)
+			*term = ' ';
+	// old-contid
+		str = strstr(term, "old-contid=");
+		if (!str)
+			return 49;
+		str += 11;
+		term = strchr(str, ' ');
+		if (term)
+			*term = 0;
+		comma = strchr(str, ',');
+		if (comma)
+			*comma = 0;
+		do {
+			if (str[0] == '^')
+				str++;
+			if (strcmp(str, "-1"))
+				cn.id = strtoull(str, NULL, 10);
+			else
+				cn.id = ULLONG_MAX;
+			cn.hits = 1;
+			clist_append(s->contid, &cn);
+			if (comma) {
+				str = comma + 1;
+				*comma = ',';
+				comma = strchr(str, ',');
+			}
+		} while (comma);
+		if (term)
+			*term = ' ';
 	}
-	// skip old-contid
 	return 0;
 }
 
@@ -1513,20 +1560,39 @@ static int parse_container_id(const lnode *n, search_items *s)
 	char *ptr, *str, *term = n->message;
 
 	// get contid
-	if (event_contid != -1) {
+	if (event_contid) {
+		cnode cn;
+		char *comma;
+
 		str = strstr(term, "contid=");
-		if (str == NULL)
-			return 49;
-		ptr = str + 7;
-		term = strchr(ptr, ' ');
-		if (term)
+		if (!str)
 			return 50;
-		*term = 0;
-		errno = 0;
-		s->contid = strtoull(ptr, NULL, 10);
-		if (errno)
+		if (audit_contid_init(s) < 0)
 			return 51;
-		*term = ' ';
+		str += 7;
+		term = strchr(str, ' ');
+		if (term)
+			*term = 0;
+		comma = strchr(str, ',');
+		if (comma)
+			*comma = 0;
+		do {
+			if (str[0] == '^')
+				str++;
+			if (strcmp(str, "-1"))
+				cn.id = strtoull(str, NULL, 10);
+			else
+				cn.id = ULLONG_MAX;
+			cn.hits = 1;
+			clist_append(s->contid, &cn);
+			if (comma) {
+				str = comma + 1;
+				*comma = ',';
+				comma = strchr(str, ',');
+			}
+		} while (comma);
+		if (term)
+			*term = ' ';
 	}
 	return 0;
 }
-- 
2.18.4

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
