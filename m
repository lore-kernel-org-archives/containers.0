Return-Path: <SRS0=U9nl=DH=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0222DC4727E
	for <containers@archiver.kernel.org>; Wed, 30 Sep 2020 15:11:41 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 5427820657
	for <containers@archiver.kernel.org>; Wed, 30 Sep 2020 15:11:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5427820657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tycho.pizza
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id F36648462A;
	Wed, 30 Sep 2020 15:11:39 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id fJNPKG9QrCuQ; Wed, 30 Sep 2020 15:11:39 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 998AB84FB0;
	Wed, 30 Sep 2020 15:11:39 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 875BEC016F;
	Wed, 30 Sep 2020 15:11:39 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id A2EB3C0051
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 15:11:38 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 91261866B3
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 15:11:38 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 7Uz5o1W9By+3
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 15:11:38 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from wnew4-smtp.messagingengine.com (wnew4-smtp.messagingengine.com
 [64.147.123.18])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 177D685BE4
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 15:11:38 +0000 (UTC)
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
 by mailnew.west.internal (Postfix) with ESMTP id AE4DB95D;
 Wed, 30 Sep 2020 11:11:36 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
 by compute4.internal (MEProxy); Wed, 30 Sep 2020 11:11:37 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tycho.pizza; h=
 date:from:to:cc:subject:message-id:references:mime-version
 :content-type:content-transfer-encoding:in-reply-to; s=fm1; bh=E
 L5sx8RuoZj7gSNiP+bO7IO5IrlnZDRHjiqW2UexN58=; b=lgrCTRBQtI384ttJB
 EaGaSORN9CO37k0pE2HgpZNdxHdwjNi10UapsjMN0DY00HuchKB2uzbu3+pfJIxO
 +2GPHGN/phwh4AejNbUT4+nr3Ppm9izphP48wYOT5NR+W1v8/ryHsg0lQ7fjAQ7D
 zKFOt2mbDTMex2+4A44biJNLvWeH2tdzs0NU3XiTJlJcy8FHOwXJSmBvuuTZJmeV
 zASWiV3TSuWEGG3g1WcFb/cb29JHeTZ30OoXisdY2T7UnECSu88TbeneEg51hk0F
 ZQkzCzegvnvepyhSBlOaM7nSZAkgzNO3JdCX+OddV7H/+3oouE78wE9I7YQ/25lw
 BRKHw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
 messagingengine.com; h=cc:content-transfer-encoding:content-type
 :date:from:in-reply-to:message-id:mime-version:references
 :subject:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender
 :x-sasl-enc; s=fm3; bh=EL5sx8RuoZj7gSNiP+bO7IO5IrlnZDRHjiqW2UexN
 58=; b=AzJgziXqSAm35rHR7EaqtWZiZ2nD7s1lJLEeZmIZw6dDL6RdI7abMEAYD
 WP5u96RaWrf2gC0sCP2JJR66/npDkKI0+YJnuCnCVJDhTeRc42Y2VcZmwn+vtziY
 4YHYqMbpEjgGERlXjsuqb7aVBraJEh4AmLKQDXLqbvChffZczBOnm2HqopJO7J9u
 ySa3Dsxe71+EPquOYR0x7UqRyPDRYwr5nkE2ZvrfrFpeh+sBhoIfmRyk8IwHQVW5
 ioNTEp4G75dfh3M7948pMtsxDFm8GN+ypDr0cO+O3TMdDGkSu48VJ2BxQiWsYqIO
 +gYtNhT003hOMlIaJfgAp4RFgcz2Q==
X-ME-Sender: <xms:JqB0X4e6PWppnCqXxNxF3mOm5ttPwy8W2GT79Ii_CxvLLNkP-KMPaQ>
 <xme:JqB0X6PRRwAux96_7JVGDN7gWPdnLYIJN7dGRkn-jY7xvFKFBlQyKhzIMu7C6OwOT
 qlnwB_EY0kMcN8zCQM>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedujedrfedvgdekvdcutefuodetggdotefrodftvf
 curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
 uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
 fjughrpeffhffvuffkfhggtggugfgjsehtkeertddttdejnecuhfhrohhmpefvhigthhho
 ucetnhguvghrshgvnhcuoehthigthhhosehthigthhhordhpihiiiigrqeenucggtffrrg
 htthgvrhhnpefhuedvvdelieevgeegjeeukeeuleejtdejfeetfeeujeefvdeltdethffh
 ueekffenucfkphepuddvkedruddtjedrvdeguddrudekgeenucevlhhushhtvghrufhiii
 gvpedtnecurfgrrhgrmhepmhgrihhlfhhrohhmpehthigthhhosehthigthhhordhpihii
 iigr
X-ME-Proxy: <xmx:JqB0X5gMkTgI8miHeoANz2NCls4Ok4OOBXylnLGhmQq3XSx-eg_DHQ>
 <xmx:JqB0X99YFhiYDJmRAeIaKwKmlAoQMVtCpXoRRQpiyKvdTy78EMk-bw>
 <xmx:JqB0X0v1M-F7jEEKW75tPFHWVS12pOR0wTzHdgJJCjYxdSoYBf_CSw>
 <xmx:KKB0X0EglajguDHqeiD-YJxQEdZNi0jAqTy92KB_3QzOlUcnCI6lJyHfrAQO--nl>
Received: from cisco (unknown [128.107.241.184])
 by mail.messagingengine.com (Postfix) with ESMTPA id 9099B3280059;
 Wed, 30 Sep 2020 11:11:31 -0400 (EDT)
Date: Wed, 30 Sep 2020 09:11:28 -0600
From: Tycho Andersen <tycho@tycho.pizza>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Subject: Re: For review: seccomp_user_notif(2) manual page
Message-ID: <20200930151128.GD284424@cisco>
References: <45f07f17-18b6-d187-0914-6f341fe90857@gmail.com>
 <20200930150330.GC284424@cisco>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20200930150330.GC284424@cisco>
Cc: linux-man <linux-man@vger.kernel.org>, Song Liu <songliubraving@fb.com>,
 wad@chromium.org, Kees Cook <keescook@chromium.org>,
 Daniel Borkmann <daniel@iogearbox.net>, Jann Horn <jannh@google.com>,
 Robert Sesek <rsesek@google.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 lkml <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
 Giuseppe Scrivano <gscrivan@redhat.com>, bpf@vger.kernel.org,
 Andy Lutomirski <luto@amacapital.net>,
 Christian Brauner <christian@brauner.io>
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
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

T24gV2VkLCBTZXAgMzAsIDIwMjAgYXQgMDk6MDM6MzZBTSAtMDYwMCwgVHljaG8gQW5kZXJzZW4g
d3JvdGU6Cj4gT24gV2VkLCBTZXAgMzAsIDIwMjAgYXQgMDE6MDc6MzhQTSArMDIwMCwgTWljaGFl
bCBLZXJyaXNrIChtYW4tcGFnZXMpIHdyb3RlOgo+ID4gICAgICAgIOKUjOKUgOKUgOKUgOKUgOKU
gOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKU
gOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKU
gOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUkAo+ID4gICAgICAgIOKUgkZJWE1FICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg4pSCCj4gPiAgICAg
ICAg4pSc4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA
4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA
4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSkCj4g
PiAgICAgICAg4pSCSW50ZXJlc3RpbmdseSwgYWZ0ZXIgdGhlIGV2ZW50ICBoYWQgIGJlZW4gIHJl
Y2VpdmVkLCDilIIKPiA+ICAgICAgICDilIJ0aGUgIGZpbGUgZGVzY3JpcHRvciBpbmRpY2F0ZXMg
YXMgd3JpdGFibGUgKHZlcmlmaWVkIOKUggo+ID4gICAgICAgIOKUgmZyb20gdGhlIHNvdXJjZSBj
b2RlIGFuZCBieSBleHBlcmltZW50KS4gSG93IGlzIHRoaXMg4pSCCj4gPiAgICAgICAg4pSCdXNl
ZnVsPyAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICDilIIKPiAK
PiBZb3UncmUgc2F5aW5nIGl0IHNob3VsZCBqdXN0IGRvIEVQT0xMT1VUIGFuZCBub3QgRVBPTExX
Uk5PUk0/IFNlZW1zCj4gcmVhc29uYWJsZS4KCklmIHdlIG1ha2UgdGhpcyBjaGFuZ2UsIEkgc3Vw
cG9zZSB3ZSBzaG91bGQgYWxzbyBkcm9wIEVQT0xMUkROT1JNIGZyb20KdGhpbmdzIHdoaWNoIGhh
dmUgbm90IGJlZW4gcmVjZWl2ZWQgeWV0LCBzaW5jZSB0aGV5J3JlIG5vdCByZWFsbHkKcmVhZGFi
bGUuCgpUeWNobwpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
XwpDb250YWluZXJzIG1haWxpbmcgbGlzdApDb250YWluZXJzQGxpc3RzLmxpbnV4LWZvdW5kYXRp
b24ub3JnCmh0dHBzOi8vbGlzdHMubGludXhmb3VuZGF0aW9uLm9yZy9tYWlsbWFuL2xpc3RpbmZv
L2NvbnRhaW5lcnM=
