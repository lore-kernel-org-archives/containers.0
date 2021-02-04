Return-Path: <SRS0=sP+a=HG=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83BFCC4332D
	for <containers@archiver.kernel.org>; Thu,  4 Feb 2021 17:47:42 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 2793D64F60
	for <containers@archiver.kernel.org>; Thu,  4 Feb 2021 17:47:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2793D64F60
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id EDD2E871FF;
	Thu,  4 Feb 2021 17:47:41 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id kyF9JRhntJPu; Thu,  4 Feb 2021 17:47:41 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 459D5871FB;
	Thu,  4 Feb 2021 17:47:41 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 2B6D7C07FD;
	Thu,  4 Feb 2021 17:47:41 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 4DF8DC013A
 for <containers@lists.linux-foundation.org>;
 Thu,  4 Feb 2021 17:47:40 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 3BDA086CB4
 for <containers@lists.linux-foundation.org>;
 Thu,  4 Feb 2021 17:47:40 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id cnKfHB7HA+Au
 for <containers@lists.linux-foundation.org>;
 Thu,  4 Feb 2021 17:47:39 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from us-smtp-delivery-124.mimecast.com
 (us-smtp-delivery-124.mimecast.com [216.205.24.124])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 72F3E86C8C
 for <containers@lists.linux-foundation.org>;
 Thu,  4 Feb 2021 17:47:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
 s=mimecast20190719; t=1612460858;
 h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding;
 bh=WoCQGzrOsnk55IaG+1UEwkLjcE8h9OKWofQDyL0qDdM=;
 b=J2YMKWdeY1P4mb0FQtRzSf2MNhbqfSKX4vVy5tCxA1MFl4EOFk6zbMWyfueV2pcfHrL0wn
 hjuGtTujVBJp6OB6gEUz/khgX3/y9l8uTeHczgV9k78x4FEDWqSrrKJA0ZBFZ02yVAkkgB
 w54PHTf3dCWZ6h5iNuEgbOJpOti6Zc4=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-195-lEo22RTJPJKzB2hJMUlSNw-1; Thu, 04 Feb 2021 12:47:36 -0500
X-MC-Unique: lEo22RTJPJKzB2hJMUlSNw-1
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com
 [10.5.11.15])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 6D5A8107ACE3;
 Thu,  4 Feb 2021 17:47:34 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-115-23.rdu2.redhat.com
 [10.10.115.23])
 by smtp.corp.redhat.com (Postfix) with ESMTP id 81C4062679;
 Thu,  4 Feb 2021 17:47:32 +0000 (UTC)
Subject: [RFC][PATCH 0/2] keys: request_key() interception in containers
From: David Howells <dhowells@redhat.com>
To: sprabhu@redhat.com
Date: Thu, 04 Feb 2021 17:47:31 +0000
Message-ID: <161246085160.1990927.13137391845549674518.stgit@warthog.procyon.org.uk>
User-Agent: StGit/0.23
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
Cc: selinux@vger.kernel.org, linux-api@vger.kernel.org,
 containers@lists.linux-foundation.org, linux-security-module@vger.kernel.org,
 linux-kernel@vger.kernel.org, dhowells@redhat.com,
 Jarkko Sakkinen <jarkko@kernel.org>, keyrings@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, christian@brauner.io
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


Here's a rough draft of a facility by which keys can be intercepted.

There are two patches:

 (1) Add tags to namespaces that can be used to find out, when we're
     looking for an intercept, if a namespace that an intercept is
     filtering on is the same as namespace of the caller of request_key()
     without the need for the intercept record to pin the namespaces that
     it's using as filters (which would also cause a dependency cycle).

     Tags contain only a refcount and are compared by address.

 (2) Add a new keyctl:

            keyctl(KEYCTL_SERVICE_INTERCEPT,
                   int queue_keyring, int userns_fd,
                   const char *type_name, unsigned int ns_mask);

     that allows a request_key() intercept to be added to the specified
     user namespace.  The authorisation key for an intercepted request is
     placed in the queue_keyring, which can be watched to gain a
     notification of this happening.  The watcher can then examine the auth
     key to determine what key is to be instantiated.

     A simple sample is provided that can be used to try this.

Some things that need to be worked out:

 (*) Intercepts are linked to the lifetime of the user_namespace on which
     they're placed, but not the daemon or the queue keyring.  Probably
     they should be removed when the queue keyring is removed, but they
     currently pin it.

 (*) Setting userns_fd to other than -1 is not yet supported (-1 indicates
     the current user namespace).

 (*) Multiple threads can monitor a queue keyring, but they will all get
     woken.  They can use keyctl_move() to decide who gets to process it.


The patches can be found on the following branch:

	https://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git/log/?h=keys-intercept

David
---
David Howells (2):
      Add namespace tags that can be used for matching without pinning a ns
      keys: Allow request_key upcalls from a container to be intercepted


 include/linux/key-type.h                |   4 +-
 include/linux/user_namespace.h          |   2 +
 include/uapi/linux/keyctl.h             |  13 +
 kernel/user.c                           |   3 +
 kernel/user_namespace.c                 |   2 +
 samples/watch_queue/Makefile            |   2 +
 samples/watch_queue/key_req_intercept.c | 271 +++++++++++++++++++
 security/keys/Makefile                  |   2 +
 security/keys/compat.c                  |   3 +
 security/keys/internal.h                |   5 +
 security/keys/keyctl.c                  |   6 +
 security/keys/keyring.c                 |   1 +
 security/keys/process_keys.c            |   2 +-
 security/keys/request_key.c             |  16 +-
 security/keys/request_key_auth.c        |   3 +
 security/keys/service.c                 | 337 ++++++++++++++++++++++++
 16 files changed, 663 insertions(+), 9 deletions(-)
 create mode 100644 samples/watch_queue/key_req_intercept.c
 create mode 100644 security/keys/service.c


_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
