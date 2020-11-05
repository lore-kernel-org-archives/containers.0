Return-Path: <SRS0=lEQp=EL=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3AB7C2D0A3
	for <containers@archiver.kernel.org>; Thu,  5 Nov 2020 00:14:23 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 4A4FC20825
	for <containers@archiver.kernel.org>; Thu,  5 Nov 2020 00:14:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="EGG9f+GB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4A4FC20825
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id E6BD2870BD;
	Thu,  5 Nov 2020 00:14:22 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id dcav3wstJh6b; Thu,  5 Nov 2020 00:14:21 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id BC8E38709F;
	Thu,  5 Nov 2020 00:14:21 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id A9837C088B;
	Thu,  5 Nov 2020 00:14:21 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 4BCCDC0051
 for <containers@lists.linux-foundation.org>;
 Thu,  5 Nov 2020 00:14:20 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 061DB85B12
 for <containers@lists.linux-foundation.org>;
 Thu,  5 Nov 2020 00:14:20 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id widH1Iy8OJpf
 for <containers@lists.linux-foundation.org>;
 Thu,  5 Nov 2020 00:14:19 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from us-smtp-delivery-124.mimecast.com
 (us-smtp-delivery-124.mimecast.com [63.128.21.124])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 0F1E285B73
 for <containers@lists.linux-foundation.org>;
 Thu,  5 Nov 2020 00:14:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
 s=mimecast20190719; t=1604535257;
 h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
 to:to:cc:cc:mime-version:mime-version:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=YpxN4DkuIzAbt2hDdqNcN1aOeH/92/gcdneAJlXM470=;
 b=EGG9f+GBQAVKIORm068z/LONBezQoakGWlE9Y2a4xppDCgRlonC2RfmUL3N/YcLm9vYp0T
 UIpGb54C2Pg/E0UyYsMZ6J3c5xZ/k/W193x9FepSyC5VnTeAqR6OeFrSaO61UeCnR0zn6R
 NnpqiKjVO98ZTl33xZb4e7N3ElQeGyY=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-96-eOsDhTjSPN-qDjb6vQQW8w-1; Wed, 04 Nov 2020 19:14:13 -0500
X-MC-Unique: eOsDhTjSPN-qDjb6vQQW8w-1
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com
 [10.5.11.22])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 4C5531084C80;
 Thu,  5 Nov 2020 00:14:11 +0000 (UTC)
Received: from mail (ovpn-116-241.rdu2.redhat.com [10.10.116.241])
 by smtp.corp.redhat.com (Postfix) with ESMTPS id B5B571007608;
 Thu,  5 Nov 2020 00:14:06 +0000 (UTC)
From: Andrea Arcangeli <aarcange@redhat.com>
To: Thomas Gleixner <tglx@linutronix.de>
Subject: [PATCH 0/1] x86: deduplicate the spectre_v2_user documentation
Date: Wed,  4 Nov 2020 19:14:05 -0500
Message-Id: <20201105001406.13005-1-aarcange@redhat.com>
In-Reply-To: <20201104234047.GA18850@redhat.com>
References: <20201104234047.GA18850@redhat.com>
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

Hello,

Could you help checking if this incremental doc cleanup is possible?

After the previous patch is applied, there's still a leftover mention
of seccomp that should be removed in a duped bit of documentation, so
I tentatively referred the original documentation already updated in
sync, instead of keeping the dup around and applying the same update
to the dup.

Note: as far as I can tell spec_store_bypass_disable= documentation is
not duplicated in spectre.rst, that's better in my view. The more dups
we have the more one goes out of sync..

Andrea Arcangeli (1):
  x86: deduplicate the spectre_v2_user documentation

 Documentation/admin-guide/hw-vuln/spectre.rst | 51 +------------------
 1 file changed, 2 insertions(+), 49 deletions(-)

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
