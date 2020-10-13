Return-Path: <SRS0=kI60=DU=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC08CC43457
	for <containers@archiver.kernel.org>; Tue, 13 Oct 2020 14:06:28 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3B202247B1
	for <containers@archiver.kernel.org>; Tue, 13 Oct 2020 14:06:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="Nmod+Qy5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B202247B1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 9BFB587BA6;
	Tue, 13 Oct 2020 14:06:27 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id BkzxyQlqI+hp; Tue, 13 Oct 2020 14:06:27 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 16B5287AF4;
	Tue, 13 Oct 2020 14:06:27 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 06E47C07FF;
	Tue, 13 Oct 2020 14:06:27 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id CC020C0051
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Oct 2020 14:06:25 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id B905787AF4
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Oct 2020 14:06:25 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 0PlCbW7XEOt0
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Oct 2020 14:06:25 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from us-smtp-delivery-124.mimecast.com
 (us-smtp-delivery-124.mimecast.com [216.205.24.124])
 by whitealder.osuosl.org (Postfix) with ESMTPS id E378C87AD1
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Oct 2020 14:06:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
 s=mimecast20190719; t=1602597983;
 h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
 to:to:cc:cc:mime-version:mime-version:
 content-transfer-encoding:content-transfer-encoding;
 bh=hRhtp39izvKuhb0WGSaB0X6uSAU7cMnTwf7afyntNPA=;
 b=Nmod+Qy5xnTf/vTHk+K95HVagNtMtA1Wr6UK7KH23tK6ZyrxDSNON3wnk299PWhFCVotS+
 qC5APoWpzQbiIDDq9WlZCKXL2UrSZwISFzJ19xUWBJgTZJ7d+WiyPyBnSzX5ibnb/aEGzP
 IQS4+kCfNhbms6IcQhwhc54pqSyYNBA=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-187-pZpXX0C6ONurJD2j-iRD0g-1; Tue, 13 Oct 2020 10:06:21 -0400
X-MC-Unique: pZpXX0C6ONurJD2j-iRD0g-1
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com
 [10.5.11.16])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 1CC66108E1A0;
 Tue, 13 Oct 2020 14:06:20 +0000 (UTC)
Received: from lithium.redhat.com (ovpn-112-43.ams2.redhat.com [10.36.112.43])
 by smtp.corp.redhat.com (Postfix) with ESMTP id 76D885C1C2;
 Tue, 13 Oct 2020 14:06:18 +0000 (UTC)
From: Giuseppe Scrivano <gscrivan@redhat.com>
To: linux-kernel@vger.kernel.org
Subject: [PATCH 0/2] fs, close_range: add flag CLOSE_RANGE_CLOEXEC
Date: Tue, 13 Oct 2020 16:06:07 +0200
Message-Id: <20201013140609.2269319-1-gscrivan@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
Cc: linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org,
 viro@zeniv.linux.org.uk
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

Giuseppe Scrivano (2):
  fs, close_range: add flag CLOSE_RANGE_CLOEXEC
  selftests: add tests for CLOSE_RANGE_CLOEXEC

 fs/file.c                                     | 56 +++++++++++++------
 include/uapi/linux/close_range.h              |  3 +
 .../testing/selftests/core/close_range_test.c | 44 +++++++++++++++
 3 files changed, 86 insertions(+), 17 deletions(-)

-- 
2.26.2

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
