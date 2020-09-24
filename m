Return-Path: <SRS0=lkaS=DB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0CAACC4346E
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 23:47:48 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 81F89239CF
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 23:47:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="VFyC5KeN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 81F89239CF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 3EA57874F3;
	Thu, 24 Sep 2020 23:47:47 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 09jCF9NqgWKK; Thu, 24 Sep 2020 23:47:46 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 9FD1F874CB;
	Thu, 24 Sep 2020 23:47:46 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 886CFC0889;
	Thu, 24 Sep 2020 23:47:46 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 49BF8C0051
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 23:47:45 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 387ED861B2
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 23:47:45 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id yPpK4FdEt2Lx
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 23:47:43 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pf1-f195.google.com (mail-pf1-f195.google.com
 [209.85.210.195])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 3E1D78612E
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 23:47:43 +0000 (UTC)
Received: by mail-pf1-f195.google.com with SMTP id x22so1241496pfo.12
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 16:47:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:content-transfer-encoding:in-reply-to;
 bh=dhceond6MhN2R2DQeCMd0g/2xnp3K8y0mvTHC2tschA=;
 b=VFyC5KeNqyRRNwJ2rIqr64ZAdhtd3ZjHKi/FlEg6q1kPOgt6jHtVOG5WenIgUz+WhE
 wPdvUdWlU8OufLk3klwumvuTjCzgSVta9G3tmEHbHyw00UO5g5AmnSaWsmsA1JTkdntn
 +CeaImnE6+DIvQMWrDoXvTu0JKpZVaUbnMIps=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:content-transfer-encoding
 :in-reply-to;
 bh=dhceond6MhN2R2DQeCMd0g/2xnp3K8y0mvTHC2tschA=;
 b=SbUGWAQvI//rW682q3YTozmiuWemjT01JH9aP/jFTdK2cEgfSNhSn5si8G1a6tEIFJ
 l9XNathWzkQSSPHb/7et0PlwDh2YOvyE1olWtrUb99tOMJcKBt74pHh/QNYkXLU15Kwl
 4fc5XVWb9BKPeNzVbgm6fMPb+cZfa12iom0GJ40HQpxvx3/o3DBjl6jkh/G86DB63Mmt
 VXV1nX0uw0f6lnceAEWldMQW9619aziT4FKopGrQUTNayMFXLvvb9btG7NpAoIXoGSfq
 f/K6KIUYwY/eRseqt+fdp76Vs9j7yw4DY2kDQagYywFHd5yNYwef2LNdpPy9JvOE5LkA
 FHpg==
X-Gm-Message-State: AOAM5305YyI4MA6jPF84lJiBi6y3iV8cTKn2ufQkmRG7nv9jQpvOHxwk
 QVYnSCak+uvoLoFTMMx0qbpDoQ==
X-Google-Smtp-Source: ABdhPJxFkZ2rv0mIiwE5o4BC/5A99M3zCAJji9u/yHJrgtSMDtuGx5fu+J4480xg2ZG87UninMdAIQ==
X-Received: by 2002:a17:902:b18f:b029:d2:1ec0:4161 with SMTP id
 s15-20020a170902b18fb02900d21ec04161mr1559187plr.58.1600991262838; 
 Thu, 24 Sep 2020 16:47:42 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id n125sm526792pfn.185.2020.09.24.16.47.41
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Thu, 24 Sep 2020 16:47:42 -0700 (PDT)
Date: Thu, 24 Sep 2020 16:47:41 -0700
From: Kees Cook <keescook@chromium.org>
To: YiFei Zhu <zhuyifei1999@gmail.com>
Subject: Re: [PATCH v2 seccomp 5/6] selftests/seccomp: Compare bitmap vs
 filter overhead
Message-ID: <202009241646.5739BE3@keescook>
References: <cover.1600951211.git.yifeifz2@illinois.edu>
 <eedf3323eed8615a4be150b39a717de1a68f0c12.1600951211.git.yifeifz2@illinois.edu>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <eedf3323eed8615a4be150b39a717de1a68f0c12.1600951211.git.yifeifz2@illinois.edu>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Jann Horn <jannh@google.com>,
 YiFei Zhu <yifeifz2@illinois.edu>, containers@lists.linux-foundation.org,
 Tobin Feldman-Fitzthum <tobin@ibm.com>, linux-kernel@vger.kernel.org,
 Andy Lutomirski <luto@amacapital.net>, Hubertus Franke <frankeh@us.ibm.com>,
 Jack Chen <jianyan2@illinois.edu>, Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
 Josep Torrellas <torrella@illinois.edu>, Will Drewry <wad@chromium.org>,
 bpf@vger.kernel.org, Tianyin Xu <tyxu@illinois.edu>
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

T24gVGh1LCBTZXAgMjQsIDIwMjAgYXQgMDc6NDQ6MjBBTSAtMDUwMCwgWWlGZWkgWmh1IHdyb3Rl
Ogo+IEZyb206IEtlZXMgQ29vayA8a2Vlc2Nvb2tAY2hyb21pdW0ub3JnPgo+IAo+IEFzIHBhcnQg
b2YgdGhlIHNlY2NvbXAgYmVuY2htYXJraW5nLCBpbmNsdWRlIHRoZSBleHBlY3RhdGlvbnMgd2l0
aAo+IHJlZ2FyZCB0byB0aGUgdGltaW5nIGJlaGF2aW9yIG9mIHRoZSBjb25zdGFudCBhY3Rpb24g
Yml0bWFwcywgYW5kIHJlcG9ydAo+IGluY29uc2lzdGVuY2llcyBiZXR0ZXIuCj4gCj4gRXhhbXBs
ZSBvdXRwdXQgd2l0aCBjb25zdGFudCBhY3Rpb24gYml0bWFwcyBvbiB4ODY6Cj4gCj4gJCBzdWRv
IC4vc2VjY29tcF9iZW5jaG1hcmsgMTAwMDAwMDAwCj4gQ3VycmVudCBCUEYgc3lzY3RsIHNldHRp
bmdzOgo+IG5ldC5jb3JlLmJwZl9qaXRfZW5hYmxlID0gMQo+IG5ldC5jb3JlLmJwZl9qaXRfaGFy
ZGVuID0gMAo+IEJlbmNobWFya2luZyAxMDAwMDAwMDAgc3lzY2FsbHMuLi4KPiA2My44OTYyNTUz
NTggLSAwLjAwODUwNDUyOSA9IDYzODg3NzUwODI5ICg2My45cykKPiBnZXRwaWQgbmF0aXZlOiA2
MzggbnMKPiAxMzAuMzgzMzEyNDIzIC0gNjMuODk3MzE1MTg5ID0gNjY0ODU5OTcyMzQgKDY2LjVz
KQo+IGdldHBpZCBSRVRfQUxMT1cgMSBmaWx0ZXIgKGJpdG1hcCk6IDY2NCBucwo+IDE5Ni43ODkw
ODA0MjEgLSAxMzAuMzg0NDE0OTgzID0gNjY0MDQ2NjU0MzggKDY2LjRzKQo+IGdldHBpZCBSRVRf
QUxMT1cgMiBmaWx0ZXJzIChiaXRtYXApOiA2NjQgbnMKPiAyNjguODQ0NjQzMzA0IC0gMTk2Ljc5
MDIzNDE2OCA9IDcyMDU0NDA5MTM2ICg3Mi4xcykKPiBnZXRwaWQgUkVUX0FMTE9XIDMgZmlsdGVy
cyAoZnVsbCk6IDcyMCBucwo+IDM0Mi42Mjc0NzI1MTUgLSAyNjguODQ1Nzk5MTAzID0gNzM3ODE2
NzM0MTIgKDczLjhzKQo+IGdldHBpZCBSRVRfQUxMT1cgNCBmaWx0ZXJzIChmdWxsKTogNzM3IG5z
Cj4gRXN0aW1hdGVkIHRvdGFsIHNlY2NvbXAgb3ZlcmhlYWQgZm9yIDEgYml0bWFwcGVkIGZpbHRl
cjogMjYgbnMKPiBFc3RpbWF0ZWQgdG90YWwgc2VjY29tcCBvdmVyaGVhZCBmb3IgMiBiaXRtYXBw
ZWQgZmlsdGVyczogMjYgbnMKPiBFc3RpbWF0ZWQgdG90YWwgc2VjY29tcCBvdmVyaGVhZCBmb3Ig
MyBmdWxsIGZpbHRlcnM6IDgyIG5zCj4gRXN0aW1hdGVkIHRvdGFsIHNlY2NvbXAgb3ZlcmhlYWQg
Zm9yIDQgZnVsbCBmaWx0ZXJzOiA5OSBucwo+IEVzdGltYXRlZCBzZWNjb21wIGVudHJ5IG92ZXJo
ZWFkOiAyNiBucwo+IEVzdGltYXRlZCBzZWNjb21wIHBlci1maWx0ZXIgb3ZlcmhlYWQgKGxhc3Qg
MiBkaWZmKTogMTcgbnMKPiBFc3RpbWF0ZWQgc2VjY29tcCBwZXItZmlsdGVyIG92ZXJoZWFkIChm
aWx0ZXJzIC8gNCk6IDE4IG5zCj4gRXhwZWN0YXRpb25zOgo+IAluYXRpdmUg4omkIDEgYml0bWFw
ICg2Mzgg4omkIDY2NCk6IOKclO+4jwo+IAluYXRpdmUg4omkIDEgZmlsdGVyICg2Mzgg4omkIDcy
MCk6IOKclO+4jwo+IAlwZXItZmlsdGVyIChsYXN0IDIgZGlmZikg4omIIHBlci1maWx0ZXIgKGZp
bHRlcnMgLyA0KSAoMTcg4omIIDE4KTog4pyU77iPCj4gCTEgYml0bWFwcGVkIOKJiCAyIGJpdG1h
cHBlZCAoMjYg4omIIDI2KTog4pyU77iPCj4gCWVudHJ5IOKJiCAxIGJpdG1hcHBlZCAoMjYg4omI
IDI2KTog4pyU77iPCj4gCWVudHJ5IOKJiCAyIGJpdG1hcHBlZCAoMjYg4omIIDI2KTog4pyU77iP
Cj4gCW5hdGl2ZSArIGVudHJ5ICsgKHBlciBmaWx0ZXIgKiA0KSDiiYggNCBmaWx0ZXJzIHRvdGFs
ICg3MzIg4omIIDczNyk6IOKclO+4jwo+IAo+IFNpZ25lZC1vZmYtYnk6IEtlZXMgQ29vayA8a2Vl
c2Nvb2tAY2hyb21pdW0ub3JnPgo+IFNpZ25lZC1vZmYtYnk6IFlpRmVpIFpodSA8eWlmZWlmejJA
aWxsaW5vaXMuZWR1PgoKQlRXLCBkaWQgdGhpcyBiZW5jaG1hcmsgdG9vbCdzIHJlc3VsdHMgbWF0
Y2ggeW91ciBleHBlY3RhdGlvbnMgZnJvbSB3aGF0CnlvdSBzYXcgd2l0aCB5b3VyIFJGQz8gKEkg
YXNzdW1lIGl0IGhlbHBlZCBzaW5jZSB5b3UndmUgaW5jbHVkZWQgaW4KaGVyZS4pCgotLSAKS2Vl
cyBDb29rCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCkNv
bnRhaW5lcnMgbWFpbGluZyBsaXN0CkNvbnRhaW5lcnNAbGlzdHMubGludXgtZm91bmRhdGlvbi5v
cmcKaHR0cHM6Ly9saXN0cy5saW51eGZvdW5kYXRpb24ub3JnL21haWxtYW4vbGlzdGluZm8vY29u
dGFpbmVycw==
