Return-Path: <SRS0=nHAz=EY=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 536A4C5519F
	for <containers@archiver.kernel.org>; Wed, 18 Nov 2020 10:48:03 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 924BB206A5
	for <containers@archiver.kernel.org>; Wed, 18 Nov 2020 10:48:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="STp3Ht+R"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 924BB206A5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id E196F85BD3;
	Wed, 18 Nov 2020 10:48:01 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id o5iR7j2ISrGW; Wed, 18 Nov 2020 10:48:01 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 2958E85B5C;
	Wed, 18 Nov 2020 10:48:01 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 1ED98C0800;
	Wed, 18 Nov 2020 10:48:01 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 103BCC07FF
 for <containers@lists.linux-foundation.org>;
 Wed, 18 Nov 2020 10:48:00 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 0BE3E86FFB
 for <containers@lists.linux-foundation.org>;
 Wed, 18 Nov 2020 10:48:00 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 7TG5veyUkcG6
 for <containers@lists.linux-foundation.org>;
 Wed, 18 Nov 2020 10:47:58 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from us-smtp-delivery-124.mimecast.com
 (us-smtp-delivery-124.mimecast.com [63.128.21.124])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 752D9860FC
 for <containers@lists.linux-foundation.org>;
 Wed, 18 Nov 2020 10:47:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
 s=mimecast20190719; t=1605696477;
 h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
 to:to:cc:cc:mime-version:mime-version:
 content-transfer-encoding:content-transfer-encoding;
 bh=d1ViazE1oJ7ZzrekNrldTatPxa+EknhxU8UIoPVA6q0=;
 b=STp3Ht+R1/3M0HG4Nng1UkPco+thlNJ1VTMX62fK9cOAvKHHiAYa69zYjMQcrnPU77Ak2L
 kSzRLYuh740yozCvDFrR2xASOOhWCd4VxiY3ZX4FfJ8sAUORfBRzkC2tA/J2jSGAnvH9vE
 wtaznxZLR6FzGK7Fz2fy2tPiMd3PFYo=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-286-QPENoFnWNfunk1vroYYsTw-1; Wed, 18 Nov 2020 05:47:54 -0500
X-MC-Unique: QPENoFnWNfunk1vroYYsTw-1
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com
 [10.5.11.12])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by mimecast-mx01.redhat.com (Postfix) with ESMTPS id E76551007B26;
 Wed, 18 Nov 2020 10:47:52 +0000 (UTC)
Received: from lithium.redhat.com (ovpn-113-143.ams2.redhat.com
 [10.36.113.143])
 by smtp.corp.redhat.com (Postfix) with ESMTP id A1F2960C05;
 Wed, 18 Nov 2020 10:47:50 +0000 (UTC)
From: Giuseppe Scrivano <gscrivan@redhat.com>
To: linux-kernel@vger.kernel.org,
	christian.brauner@ubuntu.com
Subject: [PATCH v3 0/2] fs, close_range: add flag CLOSE_RANGE_CLOEXEC
Date: Wed, 18 Nov 2020 11:47:44 +0100
Message-Id: <20201118104746.873084-1-gscrivan@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
Cc: linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org,
 linux@rasmusvillemoes.dk, viro@zeniv.linux.org.uk
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

When the new flag is used, close_range will set the close-on-exec bit
for the file descriptors instead of close()-ing them.

It is useful for e.g. container runtimes that want to minimize the
number of syscalls used after a seccomp profile is installed but want
to keep some fds open until the container process is executed.

v3:
- fixed indentation
- selftests: use ASSERT_EQ instead of EXPECT_EQ for hard failures

v2: https://lkml.kernel.org/lkml/20201019102654.16642-1-gscrivan@redhat.com/
- move close_range(..., CLOSE_RANGE_CLOEXEC) implementation to a separate function.
- use bitmap_set() to set the close-on-exec bits in the bitmap.
- add test with rlimit(RLIMIT_NOFILE) in place.
- use "cur_max" that is already used by close_range(..., 0).

v1: https://lkml.kernel.org/lkml/20201013140609.2269319-1-gscrivan@redhat.com/

Giuseppe Scrivano (2):
  fs, close_range: add flag CLOSE_RANGE_CLOEXEC
  selftests: core: add tests for CLOSE_RANGE_CLOEXEC

 fs/file.c                                     | 44 ++++++++---
 include/uapi/linux/close_range.h              |  3 +
 .../testing/selftests/core/close_range_test.c | 74 +++++++++++++++++++
 3 files changed, 111 insertions(+), 10 deletions(-)

--
2.28.0

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
