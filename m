Return-Path: <SRS0=7tMn=HH=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3999C433DB
	for <containers@archiver.kernel.org>; Fri,  5 Feb 2021 08:25:47 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3C87F64FBB
	for <containers@archiver.kernel.org>; Fri,  5 Feb 2021 08:25:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C87F64FBB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id E6DE986ACF;
	Fri,  5 Feb 2021 08:25:46 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ZyPpQPkHb9ke; Fri,  5 Feb 2021 08:25:46 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 8768586ACC;
	Fri,  5 Feb 2021 08:25:46 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 6C6FFC0174;
	Fri,  5 Feb 2021 08:25:46 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id CFE45C013A
 for <containers@lists.linux-foundation.org>;
 Fri,  5 Feb 2021 08:25:44 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id B6EB28730D
 for <containers@lists.linux-foundation.org>;
 Fri,  5 Feb 2021 08:25:44 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id w3BZYT1LvaHD
 for <containers@lists.linux-foundation.org>;
 Fri,  5 Feb 2021 08:25:44 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from us-smtp-delivery-124.mimecast.com
 (us-smtp-delivery-124.mimecast.com [63.128.21.124])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 1B21F8730C
 for <containers@lists.linux-foundation.org>;
 Fri,  5 Feb 2021 08:25:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
 s=mimecast20190719; t=1612513541;
 h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
 in-reply-to:in-reply-to:references:references;
 bh=LxANOstSwBXrn0OC3M8r/TM5reax6AnMqz1DHOK0g18=;
 b=WSZe6rygF69/TC70HWqdvhtRlruRIAS8eTPospz97Dn4BcaL6gPc8J1XyzrA9z2L3pmajW
 ru/CCceyVl9w92VZI9jdBcSmv1zGIg3Jw+77G8WcEcWtX1JV5zuhTjoVpyFmNfX+SvDPVy
 PWGLSQznbfgJh/NQCMI5UrtHAA2Mlqc=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-98-Aund-JwENnm_luJEaMImoA-1; Fri, 05 Feb 2021 03:25:40 -0500
X-MC-Unique: Aund-JwENnm_luJEaMImoA-1
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com
 [10.5.11.23])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by mimecast-mx01.redhat.com (Postfix) with ESMTPS id AAAB81800D50;
 Fri,  5 Feb 2021 08:25:38 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-115-23.rdu2.redhat.com
 [10.10.115.23])
 by smtp.corp.redhat.com (Postfix) with ESMTP id B582D1970A;
 Fri,  5 Feb 2021 08:25:36 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
 Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
 Kingdom.
 Registered in England and Wales under Company Registration No. 3798903
From: David Howells <dhowells@redhat.com>
In-Reply-To: <YByxkDi0Ruhb0AA8@kernel.org>
References: <YByxkDi0Ruhb0AA8@kernel.org>
 <161246085160.1990927.13137391845549674518.stgit@warthog.procyon.org.uk>
 <161246085966.1990927.2555272056564793056.stgit@warthog.procyon.org.uk>
To: Jarkko Sakkinen <jarkko@kernel.org>
Subject: Re: [PATCH 1/2] Add namespace tags that can be used for matching
 without pinning a ns
MIME-Version: 1.0
Content-ID: <2094923.1612513535.1@warthog.procyon.org.uk>
Date: Fri, 05 Feb 2021 08:25:35 +0000
Message-ID: <2094924.1612513535@warthog.procyon.org.uk>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
Cc: selinux@vger.kernel.org, linux-api@vger.kernel.org,
 containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
 dhowells@redhat.com, linux-security-module@vger.kernel.org,
 keyrings@vger.kernel.org, sprabhu@redhat.com, linux-fsdevel@vger.kernel.org,
 christian@brauner.io
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

Jarkko Sakkinen <jarkko@kernel.org> wrote:

> > + * init_ns_common - Initialise the common part of a namespace
> 
> Nit: init_ns_common()

Interesting.  The majority of code doesn't put the brackets in.

> I've used lately (e.g. arch/x86/kernel/cpu/sgx/ioctl.c) along the lines:
> 
> * Return:
> * - 0:          Initialization was successful.
> * - -ENOMEM:    Out of memory.

Actually, looking at kernel-doc.rst, this isn't necessarily the recommended
approach as it will much everything into one line, complete with dashes, and
can't handle splitting over lines.  You probably meant:

      * Return:
      * * 0		- OK to runtime suspend the device
      * * -EBUSY	- Device should not be runtime suspended

> * Return:
> * - 0:          Initialization was successful.
> * - -ENOMEM:    Out of memory.
> 
> Looking at the implementation, I guess this is a complete representation of
> what it can return?

It isn't.  It can return at least -ENOSPC as well, but it's awkward detailing
the errors from functions it calls since they can change and then the
description here is wrong.  I'm not sure there's a perfect answer to that.

David

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
