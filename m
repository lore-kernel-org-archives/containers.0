Return-Path: <SRS0=WbUC=DI=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F00A5C4727E
	for <containers@archiver.kernel.org>; Thu,  1 Oct 2020 15:48:27 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 71BE2206A1
	for <containers@archiver.kernel.org>; Thu,  1 Oct 2020 15:48:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="sY7GNFIv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 71BE2206A1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 109CF82419;
	Thu,  1 Oct 2020 15:48:27 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id N5Th7DGc8yZ6; Thu,  1 Oct 2020 15:48:26 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 2BD2D8214C;
	Thu,  1 Oct 2020 15:48:26 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 0D28AC016F;
	Thu,  1 Oct 2020 15:48:26 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 59E2EC0051
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 15:48:24 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 1C098229D4
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 15:48:24 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id Nmh6yBhRNYvV
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 15:48:22 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-ej1-f68.google.com (mail-ej1-f68.google.com
 [209.85.218.68])
 by silver.osuosl.org (Postfix) with ESMTPS id 6093A226F3
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 15:48:22 +0000 (UTC)
Received: by mail-ej1-f68.google.com with SMTP id gr14so8828188ejb.1
 for <containers@lists.linux-foundation.org>;
 Thu, 01 Oct 2020 08:48:22 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc:content-transfer-encoding;
 bh=8IFUkJPw/kRc69ZxpOZH7IdKr2uNB4GcMACMPjhB0mM=;
 b=sY7GNFIvYaNfMnuHljMi/SlQZ6n4BcGZhCTAkvb73jwrTAP++F0FA96srmG4n+saym
 LPs0Qo1rf+Gc/KbMjrfFVvv0dVBlQo5xErKWSXr8vfIbgudw/fJB81Prkbi9Pii7XtRh
 bwufKgriflGSXWbjmbN1+qvivFzU+VKLk390fTxTMNBo7z+CsZ1XFTp/HjN3R699Gw+C
 vfciTTmpKgNNA11LmOMtAz8ZR9nakBZvoaMyZp8Hz1UVlkM5vLsghRNGZtT0pDQ9PVkF
 +xdKQnhRbsvPbhl29QQtDseBMWcFAJ8tpq31IZJtch0aWdpaPLCLP06UMF/rwp7udtiZ
 WVOg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc:content-transfer-encoding;
 bh=8IFUkJPw/kRc69ZxpOZH7IdKr2uNB4GcMACMPjhB0mM=;
 b=HIJOPfop/GHfS0dezEVXdY3Dk9oFIpXNv/1b4VJOUPTIryheD7fQQRBNDWKGchyMln
 wYYASM0qcZOG4WcoFlnIwsNUsHsVr37mCx2tihF4hZMCabZL9k9WEbKxdU8YKSgGH06v
 PZDyCWH4kYMkC07RFdcyPqlYkilKrwDnd5TrrJERHiD2LVe0k8bHTiMVskrDBAvz14Y5
 MVDH+QUoFnf5V1+9TbWlFHukW56+fOkfcd84xkWcCNfC39/81tYVn2KRA1vHu6RK3P95
 jP+6gMbr7Wf0Bh11CMNx0ZrImT9B1aJbs5H9/VptOd4jWdCn3ebgJk1flv+rvtTuzT5b
 J+fA==
X-Gm-Message-State: AOAM5324b/pq35FAx3x17b2pF4lOGLPhGCztIkdz9EFLrKiq+IqCpEAi
 qZw/DWcQ2FkuVXOxjJt1ItV/g0Dna0blT3226iHnvQ==
X-Google-Smtp-Source: ABdhPJzN5UXlteDmV4gmQvsi+vrDa7wXLtdd0FT669/Cj8yL3OSvmpnW8FNcV9j4cLbSCSgCO88bO4oWC48rzvXf8wo=
X-Received: by 2002:a17:906:1f94:: with SMTP id
 t20mr8931066ejr.493.1601567300584; 
 Thu, 01 Oct 2020 08:48:20 -0700 (PDT)
MIME-Version: 1.0
References: <45f07f17-18b6-d187-0914-6f341fe90857@gmail.com>
 <CAG48ez3aqLs_-xgU0bThOLqRiiDWGObxcg-X9iFe6D5RDnLVJg@mail.gmail.com>
 <20201001125043.dj6taeieatpw3a4w@gmail.com>
In-Reply-To: <20201001125043.dj6taeieatpw3a4w@gmail.com>
Date: Thu, 1 Oct 2020 17:47:54 +0200
Message-ID: <CAG48ez2U1K2XYZu6goRYwmQ-RSu7LkKSOhPt8_wPVEUQfm7Eeg@mail.gmail.com>
Subject: Re: For review: seccomp_user_notif(2) manual page
To: Christian Brauner <christian.brauner@canonical.com>
Cc: linux-man <linux-man@vger.kernel.org>, Song Liu <songliubraving@fb.com>,
 Will Drewry <wad@chromium.org>, Kees Cook <keescook@chromium.org>,
 Daniel Borkmann <daniel@iogearbox.net>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Robert Sesek <rsesek@google.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 lkml <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
 "Michael Kerrisk \(man-pages\)" <mtk.manpages@gmail.com>,
 bpf <bpf@vger.kernel.org>, Andy Lutomirski <luto@amacapital.net>,
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
From: Jann Horn via Containers <containers@lists.linux-foundation.org>
Reply-To: Jann Horn <jannh@google.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

T24gVGh1LCBPY3QgMSwgMjAyMCBhdCAyOjU0IFBNIENocmlzdGlhbiBCcmF1bmVyCjxjaHJpc3Rp
YW4uYnJhdW5lckBjYW5vbmljYWwuY29tPiB3cm90ZToKPiBPbiBXZWQsIFNlcCAzMCwgMjAyMCBh
dCAwNTo1Mzo0NlBNICswMjAwLCBKYW5uIEhvcm4gdmlhIENvbnRhaW5lcnMgd3JvdGU6Cj4gPiBP
biBXZWQsIFNlcCAzMCwgMjAyMCBhdCAxOjA3IFBNIE1pY2hhZWwgS2VycmlzayAobWFuLXBhZ2Vz
KQo+ID4gPG10ay5tYW5wYWdlc0BnbWFpbC5jb20+IHdyb3RlOgo+ID4gPiBOT1RFUwo+ID4gPiAg
ICAgICAgVGhlIGZpbGUgZGVzY3JpcHRvciByZXR1cm5lZCB3aGVuIHNlY2NvbXAoMikgaXMgZW1w
bG95ZWQgd2l0aCB0aGUKPiA+ID4gICAgICAgIFNFQ0NPTVBfRklMVEVSX0ZMQUdfTkVXX0xJU1RF
TkVSICBmbGFnICBjYW4gIGJlICBtb25pdG9yZWQgIHVzaW5nCj4gPiA+ICAgICAgICBwb2xsKDIp
LCBlcG9sbCg3KSwgYW5kIHNlbGVjdCgyKS4gIFdoZW4gYSBub3RpZmljYXRpb24gIGlzICBwZW5k
4oCQCj4gPiA+ICAgICAgICBpbmcsICB0aGVzZSBpbnRlcmZhY2VzIGluZGljYXRlIHRoYXQgdGhl
IGZpbGUgZGVzY3JpcHRvciBpcyByZWFk4oCQCj4gPiA+ICAgICAgICBhYmxlLgo+ID4KPiA+IFdl
IHNob3VsZCBwcm9iYWJseSBhbHNvIHBvaW50IG91dCBzb21ld2hlcmUgdGhhdCwgYXMKPiA+IGlu
Y2x1ZGUvdWFwaS9saW51eC9zZWNjb21wLmggc2F5czoKPiA+Cj4gPiAgKiBTaW1pbGFyIHByZWNh
dXRpb25zIHNob3VsZCBiZSBhcHBsaWVkIHdoZW4gc3RhY2tpbmcgU0VDQ09NUF9SRVRfVVNFUl9O
T1RJRgo+ID4gICogb3IgU0VDQ09NUF9SRVRfVFJBQ0UuIEZvciBTRUNDT01QX1JFVF9VU0VSX05P
VElGIGZpbHRlcnMgYWN0aW5nIG9uIHRoZQo+ID4gICogc2FtZSBzeXNjYWxsLCB0aGUgbW9zdCBy
ZWNlbnRseSBhZGRlZCBmaWx0ZXIgdGFrZXMgcHJlY2VkZW5jZS4gVGhpcyBtZWFucwo+ID4gICog
dGhhdCB0aGUgbmV3IFNFQ0NPTVBfUkVUX1VTRVJfTk9USUYgZmlsdGVyIGNhbiBvdmVycmlkZSBh
bnkKPiA+ICAqIFNFQ0NPTVBfSU9DVExfTk9USUZfU0VORCBmcm9tIGVhcmxpZXIgZmlsdGVycywg
ZXNzZW50aWFsbHkgYWxsb3dpbmcgYWxsCj4gPiAgKiBzdWNoIGZpbHRlcmVkIHN5c2NhbGxzIHRv
IGJlIGV4ZWN1dGVkIGJ5IHNlbmRpbmcgdGhlIHJlc3BvbnNlCj4gPiAgKiBTRUNDT01QX1VTRVJf
Tk9USUZfRkxBR19DT05USU5VRS4gTm90ZSB0aGF0IFNFQ0NPTVBfUkVUX1RSQUNFIGNhbiBlcXVh
bGx5Cj4gPiAgKiBiZSBvdmVycmlkZW4gYnkgU0VDQ09NUF9VU0VSX05PVElGX0ZMQUdfQ09OVElO
VUUuCj4gPgo+ID4gSW4gb3RoZXIgd29yZHMsIGZyb20gYSBzZWN1cml0eSBwZXJzcGVjdGl2ZSwg
eW91IG11c3QgYXNzdW1lIHRoYXQgdGhlCj4gPiB0YXJnZXQgcHJvY2VzcyBjYW4gYnlwYXNzIGFu
eSBTRUNDT01QX1JFVF9VU0VSX05PVElGIChvcgo+ID4gU0VDQ09NUF9SRVRfVFJBQ0UpIGZpbHRl
cnMgdW5sZXNzIGl0IGlzIGNvbXBsZXRlbHkgcHJvaGliaXRlZCBmcm9tCj4gPiBjYWxsaW5nIHNl
Y2NvbXAoKS4gVGhpcyBzaG91bGQgYWxzbyBiZSBub3RlZCBvdmVyIGluIHRoZSBtYWluCj4gPiBz
ZWNjb21wKDIpIG1hbnBhZ2UsIGVzcGVjaWFsbHkgdGhlIFNFQ0NPTVBfUkVUX1RSQUNFIHBhcnQu
Cj4KPiBTbyBJIHdhcyBhY3R1YWxseSB3b25kZXJpbmcgYWJvdXQgdGhpcyB3aGVuIEkgc2tpbW1l
ZCB0aGlzIGFuZCBhIHdoaWxlCj4gYWdvIGJ1dCBmb3Jnb3QgYWJvdXQgdGhpcyBhZ2Fpbi4uLiBB
ZmFpY3QsIHlvdSBjYW4gb25seSBldmVyIGxvYWQgYQo+IHNpbmdsZSBmaWx0ZXIgd2l0aCBTRUND
T01QX0ZJTFRFUl9GTEFHX05FV19MSVNURU5FUiBzZXQuIElmIHRoZXJlCj4gYWxyZWFkeSBpcyBh
IGZpbHRlciB3aXRoIHRoZSBTRUNDT01QX0ZJTFRFUl9GTEFHX05FV19MSVNURU5FUiBwcm9wZXJ0
eQo+IGluIHRoZSB0YXNrcyBmaWx0ZXIgaGllcmFyY2h5IHRoZW4gdGhlIGtlcm5lbCB3aWxsIHJl
ZnVzZSB0byBsb2FkIGEgbmV3Cj4gb25lPwo+Cj4gc3RhdGljIHN0cnVjdCBmaWxlICppbml0X2xp
c3RlbmVyKHN0cnVjdCBzZWNjb21wX2ZpbHRlciAqZmlsdGVyKQo+IHsKPiAgICAgICAgIHN0cnVj
dCBmaWxlICpyZXQgPSBFUlJfUFRSKC1FQlVTWSk7Cj4gICAgICAgICBzdHJ1Y3Qgc2VjY29tcF9m
aWx0ZXIgKmN1cjsKPgo+ICAgICAgICAgZm9yIChjdXIgPSBjdXJyZW50LT5zZWNjb21wLmZpbHRl
cjsgY3VyOyBjdXIgPSBjdXItPnByZXYpIHsKPiAgICAgICAgICAgICAgICAgaWYgKGN1ci0+bm90
aWYpCj4gICAgICAgICAgICAgICAgICAgICAgICAgZ290byBvdXQ7Cj4gICAgICAgICB9Cj4KPiBz
aG91bGRuJ3QgdGhhdCBiZSBzdWZmaWNpZW50IHRvIGd1YXJhbnRlZSB0aGF0IFVTRVJfTk9USUYg
ZmlsdGVycyBjYW4ndAo+IG92ZXJyaWRlIGVhY2ggb3RoZXIgZm9yIHRoZSBzYW1lIHRhc2sgc2lt
cGx5IGJlY2F1c2UgdGhlcmUgY2FuIG9ubHkgZXZlcgo+IGJlIGEgc2luZ2xlIG9uZT8KCkdvb2Qg
cG9pbnQuIEV4Y2VlZWVwdCB0aGF0IHRoYXQgY2hlY2sgc2VlbXMgaW5lZmZlY3RpdmUgYmVjYXVz
ZSB0aGlzCmhhcHBlbnMgYmVmb3JlIHdlIHRha2UgdGhlIGxvY2tzIHRoYXQgZ3VhcmQgYWdhaW5z
dCBUU1lOQywgYW5kIGFsc28KYmVmb3JlIHdlIGRlY2lkZSB0byB3aGljaCBleGlzdGluZyBmaWx0
ZXIgd2Ugd2FudCB0byBjaGFpbiB0aGUgbmV3CmZpbHRlci4gU28gaWYgdHdvIHRocmVhZHMgcmFj
ZSB3aXRoIFRTWU5DLCBJIHRoaW5rIHRoZXknbGwgYmUgYWJsZSB0bwpjaGFpbiB0d28gZmlsdGVy
cyB3aXRoIGxpc3RlbmVycyB0b2dldGhlci4KCkkgZG9uJ3Qga25vdyB3aGV0aGVyIHdlIHdhbnQg
dG8gZXRlcm5hbGl6ZSB0aGlzICJvbmx5IG9uZSBsaXN0ZW5lcgphY3Jvc3MgYWxsIHRoZSBmaWx0
ZXJzIiByZXN0cmljdGlvbiBpbiB0aGUgbWFucGFnZSB0aG91Z2gsIG9yIHdoZXRoZXIKdGhlIG1h
biBwYWdlIHNob3VsZCBqdXN0IHNheSB0aGF0IHRoZSBrZXJuZWwgY3VycmVudGx5IGRvZXNuJ3Qg
c3VwcG9ydAppdCBidXQgdGhhdCBzZWN1cml0eS13aXNlIHlvdSBzaG91bGQgYXNzdW1lIHRoYXQg
aXQgbWlnaHQgYXQgc29tZQpwb2ludC4KClsuLi5dCj4gPiA+ICAgICAgICAgICAgaWYgKHByb2NN
ZW1GZCA9PSAtMSkKPiA+ID4gICAgICAgICAgICAgICAgZXJyRXhpdCgiU3VwZXJ2aXNvcjogb3Bl
biIpOwo+ID4gPgo+ID4gPiAgICAgICAgICAgIC8qIENoZWNrIHRoYXQgdGhlIHByb2Nlc3Mgd2hv
c2UgaW5mbyB3ZSBhcmUgYWNjZXNzaW5nIGlzIHN0aWxsIGFsaXZlLgo+ID4gPiAgICAgICAgICAg
ICAgIElmIHRoZSBTRUNDT01QX0lPQ1RMX05PVElGX0lEX1ZBTElEIG9wZXJhdGlvbiAocGVyZm9y
bWVkCj4gPiA+ICAgICAgICAgICAgICAgaW4gY2hlY2tOb3RpZmljYXRpb25JZElzVmFsaWQoKSkg
c3VjY2VlZHMsIHdlIGtub3cgdGhhdCB0aGUKPiA+ID4gICAgICAgICAgICAgICAvcHJvYy9QSUQv
bWVtIGZpbGUgZGVzY3JpcHRvciB0aGF0IHdlIG9wZW5lZCBjb3JyZXNwb25kcyB0byB0aGUKPiA+
ID4gICAgICAgICAgICAgICBwcm9jZXNzIGZvciB3aGljaCB3ZSByZWNlaXZlZCBhIG5vdGlmaWNh
dGlvbi4gSWYgdGhhdCBwcm9jZXNzCj4gPiA+ICAgICAgICAgICAgICAgc3Vic2VxdWVudGx5IHRl
cm1pbmF0ZXMsIHRoZW4gcmVhZCgpIG9uIHRoYXQgZmlsZSBkZXNjcmlwdG9yCj4gPiA+ICAgICAg
ICAgICAgICAgd2lsbCByZXR1cm4gMCAoRU9GKS4gKi8KPiA+ID4KPiA+ID4gICAgICAgICAgICBj
aGVja05vdGlmaWNhdGlvbklkSXNWYWxpZChub3RpZnlGZCwgcmVxLT5pZCk7Cj4gPiA+Cj4gPiA+
ICAgICAgICAgICAgLyogU2VlayB0byB0aGUgbG9jYXRpb24gY29udGFpbmluZyB0aGUgcGF0aG5h
bWUgYXJndW1lbnQgKGkuZS4sIHRoZQo+ID4gPiAgICAgICAgICAgICAgIGZpcnN0IGFyZ3VtZW50
KSBvZiB0aGUgbWtkaXIoMikgY2FsbCBhbmQgcmVhZCB0aGF0IHBhdGhuYW1lICovCj4gPiA+Cj4g
PiA+ICAgICAgICAgICAgaWYgKGxzZWVrKHByb2NNZW1GZCwgcmVxLT5kYXRhLmFyZ3NbMF0sIFNF
RUtfU0VUKSA9PSAtMSkKPiA+ID4gICAgICAgICAgICAgICAgZXJyRXhpdCgiU3VwZXJ2aXNvcjog
bHNlZWsiKTsKPiA+ID4KPiA+ID4gICAgICAgICAgICBzc2l6ZV90IHMgPSByZWFkKHByb2NNZW1G
ZCwgcGF0aCwgUEFUSF9NQVgpOwo+ID4gPiAgICAgICAgICAgIGlmIChzID09IC0xKQo+ID4gPiAg
ICAgICAgICAgICAgICBlcnJFeGl0KCJyZWFkIik7Cj4gPgo+ID4gV2h5IG5vdCBwcmVhZCgpIGlu
c3RlYWQgb2YgbHNlZWsoKStyZWFkKCk/Cj4KPiBXaXRoIG11bHRpcGxlIGFyZ3VtZW50cyB0byBi
ZSByZWFkIHByb2Nlc3Nfdm1fcmVhZHYoKSBzaG91bGQgYWxzbyBiZQo+IGNvbnNpZGVyZWQuCgpw
cm9jZXNzX3ZtX3JlYWR2KCkgY2FuIGVuZCB1cCBkb2luZyBlYWNoIHJlYWQgYWdhaW5zdCBhIGRp
ZmZlcmVudApwcm9jZXNzLCB3aGljaCBpcyBzb3J0IG9mIHdlaXJkIHNlbWFudGljYWxseS4gWW91
IHdvdWxkIGVuZCB1cCB0YWtpbmcKcGFnZSBmYXVsdHMgYXQgcmFuZG9tIGFkZHJlc3NlcyBpbiB1
bnJlbGF0ZWQgcHJvY2Vzc2VzLCBibG9ja2luZyBvbgp0aGVpciBtbWFwIGxvY2tzLCBwb3RlbnRp
YWxseSB0cmlnZ2VyaW5nIHRoZWlyIHVzZXJmYXVsdGZkIG5vdGlmaWVycywKYW5kIHNvIG9uLgoK
V2hlcmVhcyBpZiB5b3UgZmlyc3Qgb3BlbiAvcHJvYy8kdGlkL21lbSwgdGhlbiByZS1jaGVjawpT
RUNDT01QX0lPQ1RMX05PVElGX0lEX1ZBTElELCBhbmQgdGhlbiBkbyB0aGUgcmVhZCwgeW91IGtu
b3cgdGhhdAp5b3UncmUgb25seSB0YWtpbmcgcGFnZSBmYXVsdHMgb24gdGhlIHByb2Nlc3Mgd2hl
cmUgeW91IGludGVuZGVkIHRvIGRvCml0LgoKU28gdW50aWwgdGhlcmUgaXMgYSB2YXJpYW50IG9m
IHByb2Nlc3Nfdm1fcmVhZHYoKSB0aGF0IG9wZXJhdGVzIG9uCnBpZGZkcywgSSB3b3VsZCBub3Qg
cmVjb21tZW5kIHVzaW5nIHRoYXQgaGVyZS4KX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX18KQ29udGFpbmVycyBtYWlsaW5nIGxpc3QKQ29udGFpbmVyc0BsaXN0
cy5saW51eC1mb3VuZGF0aW9uLm9yZwpodHRwczovL2xpc3RzLmxpbnV4Zm91bmRhdGlvbi5vcmcv
bWFpbG1hbi9saXN0aW5mby9jb250YWluZXJz
