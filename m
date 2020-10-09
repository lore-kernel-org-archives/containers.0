Return-Path: <SRS0=NhOQ=DQ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7871C433DF
	for <containers@archiver.kernel.org>; Fri,  9 Oct 2020 04:47:32 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 231022223C
	for <containers@archiver.kernel.org>; Fri,  9 Oct 2020 04:47:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="n8ueQNqT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 231022223C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 664BF875D0;
	Fri,  9 Oct 2020 04:47:31 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id wszcJulDFsKa; Fri,  9 Oct 2020 04:47:30 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 95BCF875CF;
	Fri,  9 Oct 2020 04:47:30 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 823E5C07FF;
	Fri,  9 Oct 2020 04:47:30 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 9B7ACC0051
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 04:47:29 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 81E6486F32
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 04:47:29 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id y9SEHqBuOnvs
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 04:47:28 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pg1-f193.google.com (mail-pg1-f193.google.com
 [209.85.215.193])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id E7FDC86E71
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 04:47:28 +0000 (UTC)
Received: by mail-pg1-f193.google.com with SMTP id b193so5300198pga.6
 for <containers@lists.linux-foundation.org>;
 Thu, 08 Oct 2020 21:47:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc:content-transfer-encoding;
 bh=ewguY3pcuJUASJZKtryI+WUb/DfgApGMQzDJ1fqU0+s=;
 b=n8ueQNqTvGIUJVNHoxh4SFdLgsw++GL5jkvpig+fbUhC5PMJAd3TgvHkQBsWvunzCI
 XQ9ny8J1lCPOVHZE7Usf28ExAzdi3OFL/TJAC2cgftvQmcpXMo7qaLPx/Nh5PuRiBxMg
 mMga0NGw/RaUsQioWXkOGCMI0f1tyW2oVhEJePeCD+7MAPTzUUMnFmhZJZROVIFS/Wud
 h86/8Q8F7Bfp8z5gxwYb4Yn8W7MzBs3T15PQEuXpq8+tGA5mKy0IR0PDk5ENL86Gd6nY
 qri/KRW0OEBYnxdR2jMf70KgL5wy+D7/HKIs0NbfQDSkfJhSIR8eXpTl07XitTz707ed
 DwAQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc:content-transfer-encoding;
 bh=ewguY3pcuJUASJZKtryI+WUb/DfgApGMQzDJ1fqU0+s=;
 b=WuB+3LuPlk2f99OlmpV1dM1jJQK8GNayNO8ixsy6Qsb7Zv32JVm4zoi9RhoiaWFirX
 IPYWi+ejd+t1Xkt6v8dMxyzUaQv0w5mxDEsSBXBPyLS6IF9UOQL5IfJ+VS0HsH3jvlIM
 R3mMekqK+NIwxcOpNZ96RNVPUC6I3mxoWPoNSgxdXz0HPcM6hrUTqPT7E+Obxgu4jw7R
 9Uw/oSdZoy1yNsStFCUGaSIFLOijazTHHyqqZqKjNVgN52s7hOF75b0LtqpFLhnQp6Xl
 CEAbAUcFk/KPApVW7C43SgOZIGKgN3wRDF6BGo8hGC7sydnpS0Y8PQeD2/OJWsfO/vsl
 zxbQ==
X-Gm-Message-State: AOAM530p5DPRtU1zDDPItXhlK8Bs6eqWiBtlvCavlfxIjZbk237L6zwa
 L2v9XiO798a1rZMc28VU3oftqrQGrdVQSKrTH7KpsccrNMcrDQ==
X-Google-Smtp-Source: ABdhPJwqvDp2jodGpXwCgBFAUggX4v5IU8dK3stZ6mSV5NnDUKTZ/xg2YWnS0x4Vgqv+kJ/xYRxiRWfDf+l1pqRItGI=
X-Received: by 2002:a62:750a:0:b029:152:4d07:aec6 with SMTP id
 q10-20020a62750a0000b02901524d07aec6mr10505669pfc.48.1602218848174; Thu, 08
 Oct 2020 21:47:28 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1601478774.git.yifeifz2@illinois.edu>
 <b16456e8dbc378c41b73c00c56854a3c30580833.1601478774.git.yifeifz2@illinois.edu>
In-Reply-To: <b16456e8dbc378c41b73c00c56854a3c30580833.1601478774.git.yifeifz2@illinois.edu>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Thu, 8 Oct 2020 23:47:17 -0500
Message-ID: <CABqSeAQELsMP4116LwOY+WMcs9Zjr9fYUZ-pK+yNTGYETLf46w@mail.gmail.com>
Subject: Re: [PATCH v3 seccomp 2/5] seccomp/cache: Add "emulator" to check if
 filter is constant allow
To: Linux Containers <containers@lists.linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Kees Cook <keescook@chromium.org>,
 Jann Horn <jannh@google.com>, YiFei Zhu <yifeifz2@illinois.edu>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>,
 kernel list <linux-kernel@vger.kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Hubertus Franke <frankeh@us.ibm.com>,
 David Laight <David.Laight@aculab.com>, Jack Chen <jianyan2@illinois.edu>,
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

T24gV2VkLCBTZXAgMzAsIDIwMjAgYXQgMTA6MjAgQU0gWWlGZWkgWmh1IDx6aHV5aWZlaTE5OTlA
Z21haWwuY29tPiB3cm90ZToKPiBAQCAtNTQ0LDcgKzU3Nyw4IEBAIHN0YXRpYyBzdHJ1Y3Qgc2Vj
Y29tcF9maWx0ZXIgKnNlY2NvbXBfcHJlcGFyZV9maWx0ZXIoc3RydWN0IHNvY2tfZnByb2cgKmZw
cm9nKQo+ICB7Cj4gICAgICAgICBzdHJ1Y3Qgc2VjY29tcF9maWx0ZXIgKnNmaWx0ZXI7Cj4gICAg
ICAgICBpbnQgcmV0Owo+IC0gICAgICAgY29uc3QgYm9vbCBzYXZlX29yaWcgPSBJU19FTkFCTEVE
KENPTkZJR19DSEVDS1BPSU5UX1JFU1RPUkUpOwo+ICsgICAgICAgY29uc3QgYm9vbCBzYXZlX29y
aWcgPSBJU19FTkFCTEVEKENPTkZJR19DSEVDS1BPSU5UX1JFU1RPUkUpIHx8Cj4gKyAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgIElTX0VOQUJMRUQoQ09ORklHX1NFQ0NPTVBfQ0FDSEVfTlJf
T05MWSk7Cj4KPiAgICAgICAgIGlmIChmcHJvZy0+bGVuID09IDAgfHwgZnByb2ctPmxlbiA+IEJQ
Rl9NQVhJTlNOUykKPiAgICAgICAgICAgICAgICAgcmV0dXJuIEVSUl9QVFIoLUVJTlZBTCk7CgpJ
J20gdHJ5aW5nIHRvIHVzZSBfX2lzX2RlZmluZWQoU0VDQ09NUF9BUkNIX05BVElWRSkgaGVyZSwg
YW5kIGdvdCB0aGlzIG1lc3NhZ2U6CgprZXJuZWwvc2VjY29tcC5jOiBJbiBmdW5jdGlvbiDigJhz
ZWNjb21wX3ByZXBhcmVfZmlsdGVy4oCZOgouLy4vaW5jbHVkZS9saW51eC9rY29uZmlnLmg6NDQ6
NDQ6IGVycm9yOiBwYXN0aW5nICJfX0FSR19QTEFDRUhPTERFUl8iCmFuZCAiKCIgZG9lcyBub3Qg
Z2l2ZSBhIHZhbGlkIHByZXByb2Nlc3NpbmcgdG9rZW4KICAgNDQgfCAjZGVmaW5lIF9fX2lzX2Rl
ZmluZWQodmFsKSAgX19fX2lzX2RlZmluZWQoX19BUkdfUExBQ0VIT0xERVJfIyN2YWwpCiAgICAg
IHwgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIF5+fn5+fn5+fn5+
fn5+fn5+fgouLy4vaW5jbHVkZS9saW51eC9rY29uZmlnLmg6NDM6Mjc6IG5vdGU6IGluIGV4cGFu
c2lvbiBvZiBtYWNybyDigJhfX19pc19kZWZpbmVk4oCZCiAgIDQzIHwgI2RlZmluZSBfX2lzX2Rl
ZmluZWQoeCkgICBfX19pc19kZWZpbmVkKHgpCiAgICAgIHwgICAgICAgICAgICAgICAgICAgICAg
ICAgICBefn5+fn5+fn5+fn5+Cmtlcm5lbC9zZWNjb21wLmM6NjI5OjExOiBub3RlOiBpbiBleHBh
bnNpb24gb2YgbWFjcm8g4oCYX19pc19kZWZpbmVk4oCZCiAgNjI5IHwgICAgICAgICAgIF9faXNf
ZGVmaW5lZChTRUNDT01QX0FSQ0hfTkFUSVZFKTsKICAgICAgfCAgICAgICAgICAgXn5+fn5+fn5+
fn5+CgpMb29raW5nIGF0IHRoZSBpbXBsZW1lbnRhdGlvbiBvZiBfX2lzX2RlZmluZWQsIGl0IGlz
OgoKI2RlZmluZSBfX0FSR19QTEFDRUhPTERFUl8xIDAsCiNkZWZpbmUgX190YWtlX3NlY29uZF9h
cmcoX19pZ25vcmVkLCB2YWwsIC4uLikgdmFsCiNkZWZpbmUgX19pc19kZWZpbmVkKHgpIF9fX2lz
X2RlZmluZWQoeCkKI2RlZmluZSBfX19pc19kZWZpbmVkKHZhbCkgX19fX2lzX2RlZmluZWQoX19B
UkdfUExBQ0VIT0xERVJfIyN2YWwpCiNkZWZpbmUgX19fX2lzX2RlZmluZWQoYXJnMV9vcl9qdW5r
KSBfX3Rha2Vfc2Vjb25kX2FyZyhhcmcxX29yX2p1bmsgMSwgMCkKCkhlbmNlLCB3aGVuIEZPTyBp
cyBkZWZpbmVkIHRvIGJlIDEsIHRoZW4gdGhlIGV4cGFuc2lvbiB3b3VsZCBiZQpfX2lzX2RlZmlu
ZWQoRk9PKSAtPiBfX19pc19kZWZpbmVkKDEpIC0+Cl9fX19pc19kZWZpbmVkKF9fQVJHX1BMQUNF
SE9MREVSXzEpIC0+IF9fdGFrZV9zZWNvbmRfYXJnKDAsIDEsIDApIC0+CjEsCmFuZCB3aGVuIEZP
TyBpcyBub3QgZGVmaW5lZCwgdGhlIGV4cGFuc2lvbiB3b3VsZCBiZSBfX2lzX2RlZmluZWQoRk9P
KQotPiBfX19pc19kZWZpbmVkKEZPTykgLT4gX19fX2lzX2RlZmluZWQoX19BUkdfUExBQ0VIT0xE
RVJfRk9PKSAtPgpfX3Rha2Vfc2Vjb25kX2FyZyhfX0FSR19QTEFDRUhPTERFUl9GT08gMSwgMCkg
LT4gMAoKSG93ZXZlciwgaGVyZSBTRUNDT01QX0FSQ0hfTkFUSVZFIGlzIGFuIGV4cHJlc3Npb24g
ZnJvbSBhbiBPUiBvZiBzb21lCmJpdHMsIGFuZCBfX2lzX2RlZmluZWQoU0VDQ09NUF9BUkNIX05B
VElWRSkgd291bGQgbm90IGV4cGFuZCB0bwpfX0FSR19QTEFDRUhPTERFUl8xIGR1cmluZyBhbnkg
c3RhZ2UgaW4gdGhlIHByZXByb2Nlc3NpbmcuCgpJcyB0aGVyZSBhbnkgYmV0dGVyIHdheSB0byBk
byB0aGlzPyBJJ20gdGhpbmtpbmcgb2YganVzdCBkb2luZyAjaWYKZGVmaW5lZChDT05GSUdfQ0hF
Q0tQT0lOVF9SRVNUT1JFKSB8fCBkZWZpbmVkKFNFQ0NPTVBfQVJDSF9OQVRJVkUpCmxpa2UgaW4g
S2VlJ3MgcGF0Y2guCgpZaUZlaSBaaHUKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX18KQ29udGFpbmVycyBtYWlsaW5nIGxpc3QKQ29udGFpbmVyc0BsaXN0cy5s
aW51eC1mb3VuZGF0aW9uLm9yZwpodHRwczovL2xpc3RzLmxpbnV4Zm91bmRhdGlvbi5vcmcvbWFp
bG1hbi9saXN0aW5mby9jb250YWluZXJz
