Return-Path: <SRS0=U9nl=DH=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2524EC4363D
	for <containers@archiver.kernel.org>; Wed, 30 Sep 2020 23:40:02 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 9038420B1F
	for <containers@archiver.kernel.org>; Wed, 30 Sep 2020 23:40:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="VcrLyK8w"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9038420B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id EF04D85ADB;
	Wed, 30 Sep 2020 23:40:00 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id pkY1OETrezz4; Wed, 30 Sep 2020 23:40:00 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 6EB0886016;
	Wed, 30 Sep 2020 23:40:00 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 54937C0889;
	Wed, 30 Sep 2020 23:40:00 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id ECE71C0051
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 23:39:58 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id D56B987234
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 23:39:58 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id QAHn0d0+6dWX
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 23:39:58 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pg1-f169.google.com (mail-pg1-f169.google.com
 [209.85.215.169])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 3C2528720E
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 23:39:58 +0000 (UTC)
Received: by mail-pg1-f169.google.com with SMTP id s31so2329047pga.7
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 16:39:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:content-transfer-encoding:in-reply-to;
 bh=2SYnU6v3oYukgTaFaNXeSl70n5vT6dh4JdPhOcC+8tg=;
 b=VcrLyK8wd1YNEoEWQO1ETxp/ZpFdndf0Wn9IS/g8DF0Ee8PrUlTweuExL+J+4UveTt
 w/fw16Rtl+RQJ2aZZix8mnKbuiNc2DhbHWyKMUF6TR7KSyq1pOWNX40rF0hOESH412SO
 3stnOYszARI3yHzCOhIuv8Z4vSibAzlmf2acY=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:content-transfer-encoding
 :in-reply-to;
 bh=2SYnU6v3oYukgTaFaNXeSl70n5vT6dh4JdPhOcC+8tg=;
 b=V1ks6/HQZUXkM8sA/DxCTy8QJIoddCBaSZBifdQbyldnucF+iArcq9kfvQP4YuwFil
 crNgT+LaYP06+wl0mZPk1FmVxMyivAMGhCyUZxIPC9RKq8NBvMXW3R/giwNua/PLOUsf
 51gAayRybX96ZJTjJiH8Dd8l4lZzm3KAg1uJEshnd5Rkl1YZPEdF7UKKL4dlf5rg8J+I
 GZoApXH5l+5Q+b5Xcs328ImGkr/Pc4cy6ZHYnpI3hROB4S2lPTQaqUURsH0OXZ9lmy5T
 TmSocXjPLoTY97QhKDIgfE8C4d1wDUl1Z4kwVGlByilyos2ErPhJqxG21bZormY/Ij6M
 hpNQ==
X-Gm-Message-State: AOAM532pkvIObTeLQC7vGFOIqZ9jSB9ZCuDyEtCCfud/SZyNsul3Na5s
 zv0668280thQeJnM/L6f00fA2g==
X-Google-Smtp-Source: ABdhPJyFwc3ugp2XFqXW0tVKhPDF858qVZdH+Z14wkvfqCD1QYK4zPVuxZsn9UlnreLBhlFB11X6kg==
X-Received: by 2002:a17:902:8c8b:b029:d2:6356:8b43 with SMTP id
 t11-20020a1709028c8bb02900d263568b43mr4617767plo.34.1601509197774; 
 Wed, 30 Sep 2020 16:39:57 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id j9sm3322670pfc.175.2020.09.30.16.39.56
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Wed, 30 Sep 2020 16:39:56 -0700 (PDT)
Date: Wed, 30 Sep 2020 16:39:55 -0700
From: Kees Cook <keescook@chromium.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Subject: Re: For review: seccomp_user_notif(2) manual page
Message-ID: <202009301632.9C6A850272@keescook>
References: <45f07f17-18b6-d187-0914-6f341fe90857@gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <45f07f17-18b6-d187-0914-6f341fe90857@gmail.com>
Cc: linux-man <linux-man@vger.kernel.org>, Song Liu <songliubraving@fb.com>,
 wad@chromium.org, Robert Sesek <rsesek@google.com>,
 Daniel Borkmann <daniel@iogearbox.net>, Jann Horn <jannh@google.com>,
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

T24gV2VkLCBTZXAgMzAsIDIwMjAgYXQgMDE6MDc6MzhQTSArMDIwMCwgTWljaGFlbCBLZXJyaXNr
IChtYW4tcGFnZXMpIHdyb3RlOgo+IFsuLi5dIEkgZGlkIDotKQoKWWF5ISBUaGFuayB5b3UhCgo+
IFsuLi5dCj4gICAgT3ZlcnZpZXcKPiAgICAgICAgSW4gY29udmVudGlvbmFsIHVzYWdlIG9mIGEg
c2VjY29tcCBmaWx0ZXIsIHRoZSBkZWNpc2lvbiBhYm91dCBob3cKPiAgICAgICAgdG8gIHRyZWF0
ICBhIHBhcnRpY3VsYXIgc3lzdGVtIGNhbGwgaXMgbWFkZSBieSB0aGUgZmlsdGVyIGl0c2VsZi4K
PiAgICAgICAgVGhlIHVzZXItc3BhY2Ugbm90aWZpY2F0aW9uIG1lY2hhbmlzbSBhbGxvd3MgdGhl
IGhhbmRsaW5nIG9mICB0aGUKPiAgICAgICAgc3lzdGVtICBjYWxsICB0byAgaW5zdGVhZCAgYmUg
aGFuZGVkIG9mZiB0byBhIHVzZXItc3BhY2UgcHJvY2Vzcy4KPiAgICAgICAgVGhlIGFkdmFudGFn
ZXMgb2YgZG9pbmcgdGhpcyBhcmUgdGhhdCwgYnkgY29udHJhc3Qgd2l0aCB0aGUgIHNlY+KAkAo+
ICAgICAgICBjb21wICBmaWx0ZXIsICB3aGljaCAgaXMgIHJ1bm5pbmcgb24gYSB2aXJ0dWFsIG1h
Y2hpbmUgaW5zaWRlIHRoZQo+ICAgICAgICBrZXJuZWwsIHRoZSB1c2VyLXNwYWNlIHByb2Nlc3Mg
aGFzIGFjY2VzcyB0byBpbmZvcm1hdGlvbiB0aGF0ICBpcwo+ICAgICAgICB1bmF2YWlsYWJsZSB0
byB0aGUgc2VjY29tcCBmaWx0ZXIgYW5kIGl0IGNhbiBwZXJmb3JtIGFjdGlvbnMgdGhhdAo+ICAg
ICAgICBjYW4ndCBiZSBwZXJmb3JtZWQgZnJvbSB0aGUgc2VjY29tcCBmaWx0ZXIuCgpJIG1pZ2h0
IGNsYXJpZnkgYSBiaXQgd2l0aCBzb21ldGhpbmcgbGlrZSAodGhvdWdoIG1heWJlIHRoZQp0YXJn
ZXQvc3VwZXJ2aXNvciBwYXJhZ3JhcGggbmVlZHMgdG8gYmUgbW92ZWQgdG8gdGhlIHN0YXJ0KToK
CglUaGlzIGlzIHVzZWQgZm9yIHBlcmZvcm1pbmcgc3lzY2FsbHMgb24gYmVoYWxmIG9mIHRoZSB0
YXJnZXQsCglyYXRoZXIgdGhhbiBoYXZpbmcgdGhlIHN1cGVydmlzb3IgbWFrZSBzZWN1cml0eSBw
b2xpY3kgZGVjaXNpb25zCglhYm91dCB0aGUgc3lzY2FsbCwgd2hpY2ggd291bGQgYmUgaW5oZXJl
bnRseSByYWNlLXByb25lLiBUaGUKCXRhcmdldCdzIHN5c2NhbGwgc2hvdWxkIGVpdGhlciBiZSBo
YW5kbGVkIGJ5IHRoZSBzdXBlcnZpc29yIG9yCglhbGxvd2VkIHRvIGNvbnRpbnVlIG5vcm1hbGx5
IGluIHRoZSBrZXJuZWwgKHdoZXJlIHN0YW5kYXJkIHNlY3VyaXR5Cglwb2xpY2llcyB3aWxsIGJl
IGFwcGxpZWQpLgoKSSdsbCBjb21tZW50IG1vcmUgbGF0ZXIsIGJ1dCBJJ3ZlIHJ1biBvdXQgb2Yg
dGltZSB0b2RheSBhbmQgSSBkaWRuJ3Qgc2VlCmFueW9uZSBtZW50aW9uIHRoaXMgZGV0YWlsIHll
dCBpbiB0aGUgZXhpc3RpbmcgdGhyZWFkcy4uLiA6KQoKLS0gCktlZXMgQ29vawpfX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpDb250YWluZXJzIG1haWxpbmcg
bGlzdApDb250YWluZXJzQGxpc3RzLmxpbnV4LWZvdW5kYXRpb24ub3JnCmh0dHBzOi8vbGlzdHMu
bGludXhmb3VuZGF0aW9uLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2NvbnRhaW5lcnM=
