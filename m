Return-Path: <SRS0=NhOQ=DQ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8507FC433E7
	for <containers@archiver.kernel.org>; Fri,  9 Oct 2020 05:41:21 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id EF5812222F
	for <containers@archiver.kernel.org>; Fri,  9 Oct 2020 05:41:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="gLtNphPu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF5812222F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id A4A9B873CB;
	Fri,  9 Oct 2020 05:41:20 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id qF-nObtKlnJb; Fri,  9 Oct 2020 05:41:20 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 1B488873B2;
	Fri,  9 Oct 2020 05:41:20 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 0E059C016F;
	Fri,  9 Oct 2020 05:41:20 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 42B6BC0051
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 05:41:18 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 2BB7B873CB
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 05:41:18 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id zVoWLpEmnMvs
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 05:41:17 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pg1-f193.google.com (mail-pg1-f193.google.com
 [209.85.215.193])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 88F7D873B2
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 05:41:17 +0000 (UTC)
Received: by mail-pg1-f193.google.com with SMTP id g29so6310862pgl.2
 for <containers@lists.linux-foundation.org>;
 Thu, 08 Oct 2020 22:41:17 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:content-transfer-encoding:in-reply-to;
 bh=BtDQZIEMLmhF49jnffnO6s6n101uAcwJbVqfJI9bloU=;
 b=gLtNphPuxO/huMzVOdahNog6vTAfDxOKzwZr8kuLPoDx3zhHExJBFO1FNqXWYHyQB1
 7T1XE/NlhFzFDGSZExn+kdBVZhsW+rVHOhFCneh+yKUT/h46cdWw0qUO4HnlW9dVFynH
 V0rPgGpCr2hIx9M7HyNH1gY3MnOae078/ROgQ=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:content-transfer-encoding
 :in-reply-to;
 bh=BtDQZIEMLmhF49jnffnO6s6n101uAcwJbVqfJI9bloU=;
 b=mGG0nGR7OJnPNqWOjWxZAlsOS4lj64fCkRmjSYdPq5IwJ768j2GpI5P8JcYKBtlKcz
 uyEDpjAVzLgFWuqk0c4a1Dz6SxcFch/jkzCZIN0cES7Lco4RMCxYWTPVTJf7z4pghpLq
 1Om4t1Ymmht4Z4afPtYwY4BvXJZTRmfYznFDpLNT2gZCtPc5VgkJkBqXwcRmBTAEQqyx
 GK4RiJLjNrTw0O0Mv+xeK7IBi5RjcHrA6qh7BgenA3VPWGwqIiFRnI3CuJGeU4yWJzzE
 mFUKyDXsmwR0wkKLsQvGnCM5mdkpAtMZc1SrPIE7yYWVsBtYd6I8Jeby/qEdZQ6oTj2+
 prxQ==
X-Gm-Message-State: AOAM533DS5JBAVfUvcezSUEAU4pSi6Q35x/Hnj6KGurJA7rB3knMFoz/
 8Lk5zmdp+5ao7w3KCCYi1aG5tg==
X-Google-Smtp-Source: ABdhPJx5nhK9QmdRyfBWqhmKPI9k3k7mtwxMc2RozKFPrmPt2YIUBzplio+r3UmWZcjh8f12k2UeKA==
X-Received: by 2002:a17:90a:248:: with SMTP id t8mr3002688pje.64.1602222077073; 
 Thu, 08 Oct 2020 22:41:17 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id z73sm9693620pfc.75.2020.10.08.22.41.15
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Thu, 08 Oct 2020 22:41:15 -0700 (PDT)
Date: Thu, 8 Oct 2020 22:41:14 -0700
From: Kees Cook <keescook@chromium.org>
To: YiFei Zhu <zhuyifei1999@gmail.com>
Subject: Re: [PATCH v3 seccomp 2/5] seccomp/cache: Add "emulator" to check if
 filter is constant allow
Message-ID: <202010082235.3D6A5F2@keescook>
References: <cover.1601478774.git.yifeifz2@illinois.edu>
 <b16456e8dbc378c41b73c00c56854a3c30580833.1601478774.git.yifeifz2@illinois.edu>
 <CABqSeAQELsMP4116LwOY+WMcs9Zjr9fYUZ-pK+yNTGYETLf46w@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CABqSeAQELsMP4116LwOY+WMcs9Zjr9fYUZ-pK+yNTGYETLf46w@mail.gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Jann Horn <jannh@google.com>,
 YiFei Zhu <yifeifz2@illinois.edu>,
 Linux Containers <containers@lists.linux-foundation.org>,
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

T24gVGh1LCBPY3QgMDgsIDIwMjAgYXQgMTE6NDc6MTdQTSAtMDUwMCwgWWlGZWkgWmh1IHdyb3Rl
Ogo+IE9uIFdlZCwgU2VwIDMwLCAyMDIwIGF0IDEwOjIwIEFNIFlpRmVpIFpodSA8emh1eWlmZWkx
OTk5QGdtYWlsLmNvbT4gd3JvdGU6Cj4gPiBAQCAtNTQ0LDcgKzU3Nyw4IEBAIHN0YXRpYyBzdHJ1
Y3Qgc2VjY29tcF9maWx0ZXIgKnNlY2NvbXBfcHJlcGFyZV9maWx0ZXIoc3RydWN0IHNvY2tfZnBy
b2cgKmZwcm9nKQo+ID4gIHsKPiA+ICAgICAgICAgc3RydWN0IHNlY2NvbXBfZmlsdGVyICpzZmls
dGVyOwo+ID4gICAgICAgICBpbnQgcmV0Owo+ID4gLSAgICAgICBjb25zdCBib29sIHNhdmVfb3Jp
ZyA9IElTX0VOQUJMRUQoQ09ORklHX0NIRUNLUE9JTlRfUkVTVE9SRSk7Cj4gPiArICAgICAgIGNv
bnN0IGJvb2wgc2F2ZV9vcmlnID0gSVNfRU5BQkxFRChDT05GSUdfQ0hFQ0tQT0lOVF9SRVNUT1JF
KSB8fAo+ID4gKyAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIElTX0VOQUJMRUQoQ09ORklH
X1NFQ0NPTVBfQ0FDSEVfTlJfT05MWSk7Cj4gPgo+ID4gICAgICAgICBpZiAoZnByb2ctPmxlbiA9
PSAwIHx8IGZwcm9nLT5sZW4gPiBCUEZfTUFYSU5TTlMpCj4gPiAgICAgICAgICAgICAgICAgcmV0
dXJuIEVSUl9QVFIoLUVJTlZBTCk7Cj4gCj4gSSdtIHRyeWluZyB0byB1c2UgX19pc19kZWZpbmVk
KFNFQ0NPTVBfQVJDSF9OQVRJVkUpIGhlcmUsIGFuZCBnb3QgdGhpcyBtZXNzYWdlOgo+IAo+IGtl
cm5lbC9zZWNjb21wLmM6IEluIGZ1bmN0aW9uIOKAmHNlY2NvbXBfcHJlcGFyZV9maWx0ZXLigJk6
Cj4gLi8uL2luY2x1ZGUvbGludXgva2NvbmZpZy5oOjQ0OjQ0OiBlcnJvcjogcGFzdGluZyAiX19B
UkdfUExBQ0VIT0xERVJfIgo+IGFuZCAiKCIgZG9lcyBub3QgZ2l2ZSBhIHZhbGlkIHByZXByb2Nl
c3NpbmcgdG9rZW4KPiAgICA0NCB8ICNkZWZpbmUgX19faXNfZGVmaW5lZCh2YWwpICBfX19faXNf
ZGVmaW5lZChfX0FSR19QTEFDRUhPTERFUl8jI3ZhbCkKPiAgICAgICB8ICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICBefn5+fn5+fn5+fn5+fn5+fn4KPiAuLy4vaW5j
bHVkZS9saW51eC9rY29uZmlnLmg6NDM6Mjc6IG5vdGU6IGluIGV4cGFuc2lvbiBvZiBtYWNybyDi
gJhfX19pc19kZWZpbmVk4oCZCj4gICAgNDMgfCAjZGVmaW5lIF9faXNfZGVmaW5lZCh4KSAgIF9f
X2lzX2RlZmluZWQoeCkKPiAgICAgICB8ICAgICAgICAgICAgICAgICAgICAgICAgICAgXn5+fn5+
fn5+fn5+fgo+IGtlcm5lbC9zZWNjb21wLmM6NjI5OjExOiBub3RlOiBpbiBleHBhbnNpb24gb2Yg
bWFjcm8g4oCYX19pc19kZWZpbmVk4oCZCj4gICA2MjkgfCAgICAgICAgICAgX19pc19kZWZpbmVk
KFNFQ0NPTVBfQVJDSF9OQVRJVkUpOwo+ICAgICAgIHwgICAgICAgICAgIF5+fn5+fn5+fn5+fgo+
IAo+IExvb2tpbmcgYXQgdGhlIGltcGxlbWVudGF0aW9uIG9mIF9faXNfZGVmaW5lZCwgaXQgaXM6
Cj4gCj4gI2RlZmluZSBfX0FSR19QTEFDRUhPTERFUl8xIDAsCj4gI2RlZmluZSBfX3Rha2Vfc2Vj
b25kX2FyZyhfX2lnbm9yZWQsIHZhbCwgLi4uKSB2YWwKPiAjZGVmaW5lIF9faXNfZGVmaW5lZCh4
KSBfX19pc19kZWZpbmVkKHgpCj4gI2RlZmluZSBfX19pc19kZWZpbmVkKHZhbCkgX19fX2lzX2Rl
ZmluZWQoX19BUkdfUExBQ0VIT0xERVJfIyN2YWwpCj4gI2RlZmluZSBfX19faXNfZGVmaW5lZChh
cmcxX29yX2p1bmspIF9fdGFrZV9zZWNvbmRfYXJnKGFyZzFfb3JfanVuayAxLCAwKQo+IAo+IEhl
bmNlLCB3aGVuIEZPTyBpcyBkZWZpbmVkIHRvIGJlIDEsIHRoZW4gdGhlIGV4cGFuc2lvbiB3b3Vs
ZCBiZQo+IF9faXNfZGVmaW5lZChGT08pIC0+IF9fX2lzX2RlZmluZWQoMSkgLT4KPiBfX19faXNf
ZGVmaW5lZChfX0FSR19QTEFDRUhPTERFUl8xKSAtPiBfX3Rha2Vfc2Vjb25kX2FyZygwLCAxLCAw
KSAtPgo+IDEsCj4gYW5kIHdoZW4gRk9PIGlzIG5vdCBkZWZpbmVkLCB0aGUgZXhwYW5zaW9uIHdv
dWxkIGJlIF9faXNfZGVmaW5lZChGT08pCj4gLT4gX19faXNfZGVmaW5lZChGT08pIC0+IF9fX19p
c19kZWZpbmVkKF9fQVJHX1BMQUNFSE9MREVSX0ZPTykgLT4KPiBfX3Rha2Vfc2Vjb25kX2FyZyhf
X0FSR19QTEFDRUhPTERFUl9GT08gMSwgMCkgLT4gMAo+IAo+IEhvd2V2ZXIsIGhlcmUgU0VDQ09N
UF9BUkNIX05BVElWRSBpcyBhbiBleHByZXNzaW9uIGZyb20gYW4gT1Igb2Ygc29tZQo+IGJpdHMs
IGFuZCBfX2lzX2RlZmluZWQoU0VDQ09NUF9BUkNIX05BVElWRSkgd291bGQgbm90IGV4cGFuZCB0
bwo+IF9fQVJHX1BMQUNFSE9MREVSXzEgZHVyaW5nIGFueSBzdGFnZSBpbiB0aGUgcHJlcHJvY2Vz
c2luZy4KPiAKPiBJcyB0aGVyZSBhbnkgYmV0dGVyIHdheSB0byBkbyB0aGlzPyBJJ20gdGhpbmtp
bmcgb2YganVzdCBkb2luZyAjaWYKPiBkZWZpbmVkKENPTkZJR19DSEVDS1BPSU5UX1JFU1RPUkUp
IHx8IGRlZmluZWQoU0VDQ09NUF9BUkNIX05BVElWRSkKPiBsaWtlIGluIEtlZSdzIHBhdGNoLgoK
WWVhaCwgSSB0aGluayB0aGF0J3Mgc2ltcGxlc3QuCgotLSAKS2VlcyBDb29rCl9fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCkNvbnRhaW5lcnMgbWFpbGluZyBs
aXN0CkNvbnRhaW5lcnNAbGlzdHMubGludXgtZm91bmRhdGlvbi5vcmcKaHR0cHM6Ly9saXN0cy5s
aW51eGZvdW5kYXRpb24ub3JnL21haWxtYW4vbGlzdGluZm8vY29udGFpbmVycw==
