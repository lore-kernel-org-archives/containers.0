Return-Path: <SRS0=3EFz=CT=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3513DC43461
	for <containers@archiver.kernel.org>; Thu, 10 Sep 2020 15:06:47 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 368352078B
	for <containers@archiver.kernel.org>; Thu, 10 Sep 2020 15:06:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=yandex.ru header.i=@yandex.ru header.b="V/ytugEo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 368352078B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ioremap.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id CA3198762C;
	Thu, 10 Sep 2020 15:06:45 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id vR0KDNATHjBF; Thu, 10 Sep 2020 15:06:44 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 91DCF87530;
	Thu, 10 Sep 2020 15:06:44 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 7FB1EC0052;
	Thu, 10 Sep 2020 15:06:44 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 833A7C0051
 for <containers@lists.linux-foundation.org>;
 Thu, 10 Sep 2020 15:06:42 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 7F1938747A
 for <containers@lists.linux-foundation.org>;
 Thu, 10 Sep 2020 15:06:42 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id gpuGGDb-QmSI
 for <containers@lists.linux-foundation.org>;
 Thu, 10 Sep 2020 15:06:39 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from forward501o.mail.yandex.net (forward501o.mail.yandex.net
 [37.140.190.203])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 96A9D86FBB
 for <containers@lists.linux-foundation.org>;
 Thu, 10 Sep 2020 15:06:38 +0000 (UTC)
Received: from mxback22j.mail.yandex.net (mxback22j.mail.yandex.net
 [IPv6:2a02:6b8:0:1619::222])
 by forward501o.mail.yandex.net (Yandex) with ESMTP id 2F9F91E813E1;
 Thu, 10 Sep 2020 18:04:58 +0300 (MSK)
Received: from localhost (localhost [::1])
 by mxback22j.mail.yandex.net (mxback/Yandex) with ESMTP id yuFJ0ZBXym-4ufqTEsk;
 Thu, 10 Sep 2020 18:04:57 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex.ru; s=mail;
 t=1599750297; bh=0ftwVo7c7d1m6Nvsrwk4WUedFSZ31xbE99QkGp7/EPo=;
 h=Message-Id:Cc:Subject:In-Reply-To:Date:References:To:From;
 b=V/ytugEo5j0Ogzikpry5dGp1yRKidd1wMYJpGIoOWi4GuO6xYvCHVRftU7Sn+p4Tn
 W8aqDjxrp3f1506374YessluSU+Tcev12Azm7PeK/XZuceXLMn08Phm0xKI9HVDtq6
 vZSVChSFukLkTXNAQ6anajY4q/iw2a3M9n0zqiT8=
Authentication-Results: mxback22j.mail.yandex.net;
 dkim=pass header.i=@yandex.ru
Received: by iva5-0eec708f962b.qloud-c.yandex.net with HTTP;
 Thu, 10 Sep 2020 18:04:56 +0300
From: Evgeniy Polyakov <zbr@ioremap.net>
Envelope-From: drustafa@yandex.ru
To: "ebiederm@xmission.com" <ebiederm@xmission.com>,
 Matt Bennett <matt.bennett@alliedtelesis.co.nz>
In-Reply-To: <87lfjn9s3v.fsf@x220.int.ebiederm.org>
References: <20200702002635.8169-1-matt.bennett@alliedtelesis.co.nz>
 <87k0zlspxs.fsf@x220.int.ebiederm.org>
 <94defa61204731d7dce37edeb98069c8647722c2.camel@alliedtelesis.co.nz>
 <87lfjn9s3v.fsf@x220.int.ebiederm.org>
Subject: Re: [PATCH 0/5] RFC: connector: Add network namespace awareness
X-Mailer: Yamail [ http://yandex.ru ] 5.0
Date: Thu, 10 Sep 2020 18:04:56 +0300
Message-Id: <74141599750086@mail.yandex.ru>
MIME-Version: 1.0
X-Content-Filtered-By: Mailman/MimeDel 2.1.15
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "containers@lists.linux-foundation.org"
 <containers@lists.linux-foundation.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
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

ICAgSGkgZXZlcnlvbmUKCiAgIMOCCgogICAxMy4wNy4yMDIwLCAyMTo0MiwgIkVyaWMgVy4gQmll
ZGVybWFuIiA8ZWJpZWRlcm1AeG1pc3Npb24uY29tPjoKCiAgICAgw4IKICAgICDDgiBXaGljaCBt
ZWFucyBhbiB1bnByaXZpbGVnZWQgdXNlciBjYW4gY3JlYXRlIGEgdXNlciBuYW1lc3BhY2UgYW5k
CiAgICAgZ2V0CiAgICAgw4IgY29ubmVjdG9yIHRvIHJlcG9ydCB3aGljaGV2ZXIgaWRzIHRoZXkg
d2FudCB0byB1c2VycyBpbiBhbm90aGVyCiAgICAgw4IgbmFtZXNwYWNlLiBBS0EgbGllLgogICAg
IMOCCiAgICAgw4IgU28gdGhpcyBhcHBlYXJzIHRvIG1ha2UgY29ubmVjdG9yIGNvbXBsZXRlbHkg
dW5yZWxpYWJsZS4KCiAgIMOCCgogICDDggoKICAgICBNeSBzZW5zZSBpcyB0aGF0IHRoZXJlIGFy
ZSBmZXcgZW5vdWdoIHVzZXMgb2YgY29ubmVjdG9yIHRoYXQgaWYKICAgICBkb24ndAogICAgIG1p
bmQgY2hhbmdpbmcgeW91ciBjb2RlIHNvIHRoYXQgaXQgd29ya3MgaW4gYSBjb250YWluZXIgKGFu
ZCB0aGUKICAgICBwaWRmZAogICAgIHN1cHBvcnQgYXBwZWFycyB0byBhbHJlYWR5IHByb3ZpZGUg
d2hhdCB5b3UgbmVlZCkgdGhhdCBpcyBwcm9iYWJseQogICAgIHRoZQogICAgIHBhc3Qgb2YgbGVh
c3QgcmVzaXN0YW5jZS4KICAgICBJIGRvbid0IHRoaW5rIGl0IG1haW50YWluaW5nIGNvbm5lY3Rv
ciBzdXBwb3J0IHdvdWxkIGJlIG11Y2ggbW9yZQogICAgIHdvcmsKICAgICB0aGFuIGl0IGlzIG5v
dywgaWYgc29tZW9uZSB3ZW50IHRocm91Z2ggYW5kIGRpZCB0aGUgd29yayB0bwogICAgIGNhcmVm
dWxseQogICAgIGNvbnZlcnQgdGhlIGNvZGUuIFNvIGlmIHNvbWVvbmUgcmVhbGx5IHdhbnRzIHRv
IHVzZSBjb25uZWN0b3Igd2UgY2FuCiAgICAgbmFtZXNwYWNlIHRoZSBjb2RlLgogICAgIE90aGVy
d2lzZSBpdCBpcyBwcm9iYWJseSBtYWtlcyBzZW5zZSB0byBsZXQgdGhlIGZldyB1c2VycyBncmFk
dWFsbHkKICAgICBzdG9wCiAgICAgdXNpbmcgY29ubmVjdG9yIHNvIHRoZSBjb2RlIGNhbiBldmVu
dHVhbGx5IGJlIHJlbW92ZWQuCgogICDDggoKICAgU3VjaCBhIG5pY2UgYnJpZ2h0IGZ1dHVyZSBm
b3IgY29ubmVjdG9yIHlvdSBkZXBpY3QgaGVyZSBkaXNyZWdhcmRpbmcKICAgb3RoZXJzIHdvcmsK
CiAgIGFuZCB0aGlzIGNvbnRyaWJ1dGlvbiBFcmljIDopCgogICDDggoKICAgSWYgd2UgY2FuIG92
ZXJjb21lIHNob3dlZCBhYm92ZSBpc3N1ZSB3aXRoIGludmFsaWQgaWRzLCBjb25uZWN0b3Igc3Rp
bGwKICAgY2FuIGdldCBhIGZldyBtb3JlIHllYXJzIHRvIGxpdmUsCgogICBkb24ndCB5b3Ugd2Fu
dCB0byBnaXZlIGl0IGEgY2hhbmNlPwoKICAgw4IKCiAgICAgUGxlYXNlIGNoZWNrb3V0IG91dCB0
aGUgcGlkZmQgc3VwcG9ydCBhbmQgdGVsbCB1cyBob3cgaXQgbWVldHMgeW91cgogICAgIG5lZWRz
LiBJZiB0aGVyZSBpcyBzb21ldGhpbmcgdGhhdCBjb25uZWN0b3IgcmVhbGx5IGRvZXMgYmV0dGVy
IGl0CiAgICAgd291bGQKICAgICBiZSBnb29kIHRvIGtub3cuCl9fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fCkNvbnRhaW5lcnMgbWFpbGluZyBsaXN0CkNvbnRh
aW5lcnNAbGlzdHMubGludXgtZm91bmRhdGlvbi5vcmcKaHR0cHM6Ly9saXN0cy5saW51eGZvdW5k
YXRpb24ub3JnL21haWxtYW4vbGlzdGluZm8vY29udGFpbmVycw==
