Return-Path: <SRS0=50w+=DC=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9FE60C4727F
	for <containers@archiver.kernel.org>; Fri, 25 Sep 2020 19:51:28 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id E8AF023888
	for <containers@archiver.kernel.org>; Fri, 25 Sep 2020 19:51:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=amacapital-net.20150623.gappssmtp.com header.i=@amacapital-net.20150623.gappssmtp.com header.b="TlNuh8jK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8AF023888
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 898A186DE7;
	Fri, 25 Sep 2020 19:51:27 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id dGISetY00EKM; Fri, 25 Sep 2020 19:51:26 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id D294A86DE5;
	Fri, 25 Sep 2020 19:51:26 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id B9DD1C0859;
	Fri, 25 Sep 2020 19:51:26 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 59674C0051
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 19:51:26 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 4231B86DE7
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 19:51:26 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id ygs_QK_YGenD
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 19:51:25 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pf1-f193.google.com (mail-pf1-f193.google.com
 [209.85.210.193])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 6CCD686DE5
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 19:51:25 +0000 (UTC)
Received: by mail-pf1-f193.google.com with SMTP id f18so4209275pfa.10
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 12:51:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amacapital-net.20150623.gappssmtp.com; s=20150623;
 h=content-transfer-encoding:from:mime-version:subject:date:message-id
 :references:cc:in-reply-to:to;
 bh=aYpiTmID4xsc+ZXtbTi7xqB4g/9TSoL/gRDfcYQ3WKY=;
 b=TlNuh8jKztqtHSgOPSYIlkOX1FTDl+cnTYUAwpxIptGVTCsGY4WRbLjD2aDt03E2Wn
 nHvfTgO7vJqjtFAK1e26mA66Ozrw1EGrYkDalDgsBN48SudGkQINpwB/Lt8hFyCgCYqq
 Vb9AHgPIttAdVZTC8H1da8kayPqB2UnS1M7k+nbWdQcJ7pzUlQ7vBeP5Qh63nYns4Mad
 4x1WvEMAkUyiyh6C9/2KAahWn3gjb2qRtMoqeg1qE6nv++BYJ4lHiq8FM/cX9yc/29+C
 vOp6cvtfp74HcMOfX2HHqeVem6JqdQ75pShl05yR3iblYG0Y/fmM/ga0WRqblniaLdGo
 UWWQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:content-transfer-encoding:from:mime-version
 :subject:date:message-id:references:cc:in-reply-to:to;
 bh=aYpiTmID4xsc+ZXtbTi7xqB4g/9TSoL/gRDfcYQ3WKY=;
 b=d/TrTHU0wNfPOMLJFVCG+nX+mXZDxYTIOhIlzjWapyqiNaKb0sZllc3LIYacwTirLn
 QR5PfkC2I9sTtGajqRw3kGSa43uKq1YOXNW5c93lGfCxImKZfWy4NGKMPQj4jA5RutSO
 k6r0XVqVMWLfv3hqnwljX6XYybVuyskuUKoU8sxw4Xq9kj4d580miH2RYOwCK/ZOhJ0Q
 EvhgplZUKlffKF+6LvKCWVHLwNOgjFJUvqCh0UdKrulUWre5OyUEVu9VqSx58CoYb9IC
 Up7dIJYbkFMvXTuAcJbGoqflVremeYTD5+YOPTXUMdi/vlFUkmwkTDtpupI7VF49kLxf
 E7fg==
X-Gm-Message-State: AOAM530vUX3vlqUslj3wNSdZwtC/xxbMmAIq0xyVHlqqJDI/VRCuQYMC
 zCWt5Yga74S/C96fUEHSsZIwtA==
X-Google-Smtp-Source: ABdhPJykXwy5rOFCXbWLe1OsALxqFcpr3ferzywXG9nW2p19GlogMjQ7EdTLxEQAGEIYAT2NGp+mkQ==
X-Received: by 2002:a63:3ec9:: with SMTP id l192mr478784pga.316.1601063484980; 
 Fri, 25 Sep 2020 12:51:24 -0700 (PDT)
Received: from localhost.localdomain ([2601:646:c200:1ef2:54:c5e4:89e0:b741])
 by smtp.gmail.com with ESMTPSA id
 k2sm3291458pfi.169.2020.09.25.12.51.23
 (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
 Fri, 25 Sep 2020 12:51:23 -0700 (PDT)
From: Andy Lutomirski <luto@amacapital.net>
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH v2 seccomp 3/6] seccomp/cache: Add "emulator" to check if
 filter is arg-dependent
Date: Fri, 25 Sep 2020 12:51:20 -0700
Message-Id: <2FA23A2E-16B0-4E08-96D5-6D6FE45BBCF6@amacapital.net>
References: <202009251223.8E46C831E2@keescook>
In-Reply-To: <202009251223.8E46C831E2@keescook>
To: Kees Cook <keescook@chromium.org>
X-Mailer: iPhone Mail (18A373)
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Jann Horn <jannh@google.com>,
 YiFei Zhu <yifeifz2@illinois.edu>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>,
 kernel list <linux-kernel@vger.kernel.org>,
 Hubertus Franke <frankeh@us.ibm.com>, Jack Chen <jianyan2@illinois.edu>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
 Josep Torrellas <torrella@illinois.edu>, Will Drewry <wad@chromium.org>,
 bpf <bpf@vger.kernel.org>, Tianyin Xu <tyxu@illinois.edu>
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

Cgo+IE9uIFNlcCAyNSwgMjAyMCwgYXQgMTI6NDIgUE0sIEtlZXMgQ29vayA8a2Vlc2Nvb2tAY2hy
b21pdW0ub3JnPiB3cm90ZToKPiAKPiDvu79PbiBGcmksIFNlcCAyNSwgMjAyMCBhdCAxMTo0NTow
NUFNIC0wNTAwLCBZaUZlaSBaaHUgd3JvdGU6Cj4+IE9uIFRodSwgU2VwIDI0LCAyMDIwIGF0IDEw
OjA0IFBNIFlpRmVpIFpodSA8emh1eWlmZWkxOTk5QGdtYWlsLmNvbT4gd3JvdGU6Cj4+Pj4gV2h5
IGRvIHRoZSBwcmVwYXJlIGhlcmUgaW5zdGVhZCBvZiBkdXJpbmcgYXR0YWNoPyAoQW5kIG5vdGUg
dGhhdCBpdAo+Pj4+IHNob3VsZCBub3QgYmUgd3JpdHRlbiB0byBmYWlsLikKPj4+IAo+Pj4gUmln
aHQuCj4+IAo+PiBEdXJpbmcgYXR0YWNoIGEgc3BpbmxvY2sgKGN1cnJlbnQtPnNpZ2hhbmQtPnNp
Z2xvY2spIGlzIGhlbGQuIERvIHdlCj4+IHJlYWxseSB3YW50IHRvIHB1dCB0aGUgZW11bGF0b3Ig
aW4gdGhlICJhdG9taWMgc2VjdGlvbiI/Cj4gCj4gSXQncyBhIGdvb2QgcG9pbnQsIGJ1dCBJIGhh
ZCBzb21lIG90aGVyIGlkZWFzIGFyb3VuZCBpdCB0aGF0IGxlYWQgdG8gbWUKPiBhIGRpZmZlcmVu
dCBjb25jbHVzaW9uLiBIZXJlJ3Mgd2hhdCBJJ3ZlIGdvdCBpbiBteSBoZWFkOgo+IAo+IEkgZG9u
J3QgdmlldyBmaWx0ZXIgYXR0YWNoIChub3IgdGhlIHNpZ2xvY2spIGFzIGZhc3RwYXRoOiB0aGUg
bG9jayBpcwo+IHJhcmVseSBjb250ZXN0ZWQgYW5kIHRoZSAibG9uZyB0aW1lIiB3aWxsIG9ubHkg
YmUgZHVyaW5nIGZpbHRlciBhdHRhY2guCj4gCj4gV2hlbiBwZXJmb3JtaW5nIGZpbHRlciBlbXVs
YXRpb24sIGFsbCB0aGUgc3lzY2FsbHMgdGhhdCBhcmUgYWxyZWFkeQo+IG1hcmtlZCBhcyAibXVz
dCBydW4gZmlsdGVyIiBvbiB0aGUgcHJldmlvdXMgZmlsdGVyIGNhbiBiZSBza2lwcGVkIGZvcgo+
IHRoZSBuZXcgZmlsdGVyLCBzaW5jZSBpdCBjYW5ub3QgY2hhbmdlIHRoZSBvdXRjb21lLCB3aGlj
aCBtYWtlcyB0aGUKPiBlbXVsYXRpb24gc3RlcCBmYXN0ZXIuCj4gCj4gVGhlIHByZXZpb3VzIGZp
bHRlcidzIGJpdG1hcCBpc24ndCAic3RhYmxlIiB1bnRpbCBzaWdsb2NrIGlzIGhlbGQuCj4gCj4g
SWYgd2UgZG8gdGhlIGVtdWxhdGlvbiBzdGVwIGJlZm9yZSBzaWdsb2NrLCB3ZSBoYXZlIHRvIGFs
d2F5cyBkbyBmdWxsCj4gZXZhbHVhdGlvbiBvZiBhbGwgc3lzY2FsbHMsIGFuZCB0aGVuIG1lcmdl
IHRoZSBiaXRtYXAgZHVyaW5nIGF0dGFjaC4KPiBUaGF0IG1lYW5zIGFsbCBmaWx0ZXJzIGV2ZXIg
YXR0YWNoZWQgd2lsbCB0YWtlIG1heGltYWwgdGltZSB0byBwZXJmb3JtCj4gZW11bGF0aW9uLgo+
IAo+IEkgcHJlZmVyIHRoZSBpZGVhIG9mIHRoZSBlbXVsYXRpb24gc3RlcCB0YWtpbmcgYWR2YW50
YWdlIG9mIHRoZSBiaXRtYXAKPiBvcHRpbWl6YXRpb24sIHNpbmNlIHRoZSBrZXJuZWwgc3BlbmRz
IGxlc3MgdGltZSBkb2luZyB3b3JrIG92ZXIgdGhlIGxpZmUKPiBvZiB0aGUgcHJvY2VzcyB0cmVl
LiBJdCdzIGNlcnRhaW5seSBtYXJnaW5hbCwgYnV0IGl0IGFsc28gbGV0cyBhbGwgdGhlCj4gYml0
bWFwIG1hbmlwdWxhdGlvbiBzdGF5IGluIG9uZSBwbGFjZSAoYXMgb3Bwb3NlZCB0byBiZWluZyBz
cGxpdCBiZXR3ZWVuCj4gInByZXBhcmUiIGFuZCAiYXR0YWNoIikuCj4gCj4gV2hhdCBkbyB5b3Ug
dGhpbms/Cj4gCj4gCgpJ4oCZbSB3b25kZXJpbmcgaWYgd2Ugc2hvdWxkIGJlIG11Y2ggbXVjaCBs
YXppZXIuIFdlIGNvdWxkIHBvdGVudGlhbGx5IHdhaXQgdW50aWwgc29tZW9uZSBhY3R1YWxseSB0
cmllcyB0byBkbyBhIGdpdmVuIHN5c2NhbGwgYmVmb3JlIHdlIHRyeSB0byBldmFsdWF0ZSB3aGV0
aGVyIHRoZSByZXN1bHQgaXMgZml4ZWQuCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fCkNvbnRhaW5lcnMgbWFpbGluZyBsaXN0CkNvbnRhaW5lcnNAbGlzdHMu
bGludXgtZm91bmRhdGlvbi5vcmcKaHR0cHM6Ly9saXN0cy5saW51eGZvdW5kYXRpb24ub3JnL21h
aWxtYW4vbGlzdGluZm8vY29udGFpbmVycw==
