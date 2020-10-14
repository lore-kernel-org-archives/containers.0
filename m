Return-Path: <SRS0=5CWv=DV=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.8 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,NICE_REPLY_A,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8C45FC433DF
	for <containers@archiver.kernel.org>; Wed, 14 Oct 2020 05:41:19 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id CD4FA2177B
	for <containers@archiver.kernel.org>; Wed, 14 Oct 2020 05:41:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AYQcWHx4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD4FA2177B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 6AE1F87985;
	Wed, 14 Oct 2020 05:41:18 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id eeuJv9W22YeM; Wed, 14 Oct 2020 05:41:17 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 49AB48797C;
	Wed, 14 Oct 2020 05:41:17 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 28301C07FF;
	Wed, 14 Oct 2020 05:41:17 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 5B4BBC0051
 for <containers@lists.linux-foundation.org>;
 Wed, 14 Oct 2020 05:41:15 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 3DF9C2E190
 for <containers@lists.linux-foundation.org>;
 Wed, 14 Oct 2020 05:41:15 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id crf3WEGcA4oa
 for <containers@lists.linux-foundation.org>;
 Wed, 14 Oct 2020 05:41:13 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-wr1-f66.google.com (mail-wr1-f66.google.com
 [209.85.221.66])
 by silver.osuosl.org (Postfix) with ESMTPS id DF7EC20445
 for <containers@lists.linux-foundation.org>;
 Wed, 14 Oct 2020 05:41:12 +0000 (UTC)
Received: by mail-wr1-f66.google.com with SMTP id h5so2190581wrv.7
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Oct 2020 22:41:12 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=cc:subject:to:references:from:message-id:date:user-agent
 :mime-version:in-reply-to:content-language:content-transfer-encoding;
 bh=5ZD1Q1ycqo0UA6f9xY0VJ9HAjkT2BLtIOvzScJIKi9M=;
 b=AYQcWHx49JTyiIvfHAlkFzIhR6WG3kcBicmvcevU3yWLq5+Gspl272RNPtjAzKPT9e
 n8SPo6JiEuTivW7zt0Gvu0lQKKnMzaX2SoP+QqmO6/9+pmcVyteTPXEjvVqBivl/Dm9k
 KLjGCU2OSfbEzJu+cJYYSphQFyuZSpnjPFN3h04e3kvtET6Zlr5szW61p5MrMJBIZvUh
 sKlCvlwIGsAKwj+XW+EMLvl9CKPFmPNIPgXDKx4Ay4xO+le7aeQKP/jkkmP8U2y5LlXu
 lV3W0sQgBYtWgD5WpYetbxeCzmwkK42RQJsq8opSJfQhtFmZ0hh8FD6j5VjTZbUJt4rS
 LWPA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:cc:subject:to:references:from:message-id:date
 :user-agent:mime-version:in-reply-to:content-language
 :content-transfer-encoding;
 bh=5ZD1Q1ycqo0UA6f9xY0VJ9HAjkT2BLtIOvzScJIKi9M=;
 b=p4fuK/f1cRyjWZ9p0nFGVZyxp8GTkbHzOekzn8GBSrSkrohBRvU1kLkx4lE/6HtS2S
 v714oFdY8ZMDstMDAGk+Nz717LlffBQcyIPWM761p2NcwdvaJ3pPwjVOIcRBngzSuezL
 5ocmwTxfz14k5LCGD42WNRpPu/DANLYvkvUGOA7XjhTeBXb/USOw3phHKb1rw4WdOd8a
 +1tU6iW6TVXzLZEVSzDPIEu4mTfArIZu9a61WRxAM+g2WMV4g/hBFW8xFXOOBF4c8jgm
 Uvu/OHVSlwtt1L4ZU2TWBJ+ywuQCygJPCCctKCHQ5cwZb1KftBfxZ1JyZnnvPqQ1+zHk
 wnxQ==
X-Gm-Message-State: AOAM533OQGodP+sQetSu3VaCnwI+kG93oooWcYZHEBla9UAQel1UVnB2
 Qph/ECAni+q3bLVJ5IjFRXo=
X-Google-Smtp-Source: ABdhPJz5XyrZLGamBlvAuoMrkkPcgWPQMbcczbspT9zKCtHmVhGjFjSIuktq+RJkYJSEg3ti156pOw==
X-Received: by 2002:adf:fa05:: with SMTP id m5mr3595047wrr.57.1602654071185;
 Tue, 13 Oct 2020 22:41:11 -0700 (PDT)
Received: from [192.168.1.10] (static-176-175-73-29.ftth.abo.bbox.fr.
 [176.175.73.29])
 by smtp.gmail.com with ESMTPSA id f189sm1977581wmf.16.2020.10.13.22.41.09
 (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
 Tue, 13 Oct 2020 22:41:10 -0700 (PDT)
Subject: Re: For review: seccomp_user_notif(2) manual page
To: Christian Brauner <christian.brauner@canonical.com>,
 Tycho Andersen <tycho@tycho.pizza>
References: <45f07f17-18b6-d187-0914-6f341fe90857@gmail.com>
 <CAG48ez3aqLs_-xgU0bThOLqRiiDWGObxcg-X9iFe6D5RDnLVJg@mail.gmail.com>
 <20201001125043.dj6taeieatpw3a4w@gmail.com>
 <CAG48ez2U1K2XYZu6goRYwmQ-RSu7LkKSOhPt8_wPVEUQfm7Eeg@mail.gmail.com>
 <20201001165850.GC1260245@cisco> <20201001171206.jvkdx4htqux5agdv@gmail.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <3a417df2-6346-601d-568e-29307347e6aa@gmail.com>
Date: Wed, 14 Oct 2020 07:41:07 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101
 Thunderbird/68.11.0
MIME-Version: 1.0
In-Reply-To: <20201001171206.jvkdx4htqux5agdv@gmail.com>
Content-Language: en-US
Cc: linux-man <linux-man@vger.kernel.org>, Song Liu <songliubraving@fb.com>,
 Will Drewry <wad@chromium.org>, Kees Cook <keescook@chromium.org>,
 Daniel Borkmann <daniel@iogearbox.net>, Jann Horn <jannh@google.com>,
 Robert Sesek <rsesek@google.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 lkml <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
 mtk.manpages@gmail.com, Giuseppe Scrivano <gscrivan@redhat.com>,
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
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

T24gMTAvMS8yMCA3OjEyIFBNLCBDaHJpc3RpYW4gQnJhdW5lciB3cm90ZToKPiBPbiBUaHUsIE9j
dCAwMSwgMjAyMCBhdCAxMDo1ODo1MEFNIC0wNjAwLCBUeWNobyBBbmRlcnNlbiB3cm90ZToKPj4g
T24gVGh1LCBPY3QgMDEsIDIwMjAgYXQgMDU6NDc6NTRQTSArMDIwMCwgSmFubiBIb3JuIHZpYSBD
b250YWluZXJzIHdyb3RlOgo+Pj4gT24gVGh1LCBPY3QgMSwgMjAyMCBhdCAyOjU0IFBNIENocmlz
dGlhbiBCcmF1bmVyCj4+PiA8Y2hyaXN0aWFuLmJyYXVuZXJAY2Fub25pY2FsLmNvbT4gd3JvdGU6
Cj4+Pj4gT24gV2VkLCBTZXAgMzAsIDIwMjAgYXQgMDU6NTM6NDZQTSArMDIwMCwgSmFubiBIb3Ju
IHZpYSBDb250YWluZXJzIHdyb3RlOgo+Pj4+PiBPbiBXZWQsIFNlcCAzMCwgMjAyMCBhdCAxOjA3
IFBNIE1pY2hhZWwgS2VycmlzayAobWFuLXBhZ2VzKQo+Pj4+PiA8bXRrLm1hbnBhZ2VzQGdtYWls
LmNvbT4gd3JvdGU6Cj4+Pj4+PiBOT1RFUwo+Pj4+Pj4gICAgICAgIFRoZSBmaWxlIGRlc2NyaXB0
b3IgcmV0dXJuZWQgd2hlbiBzZWNjb21wKDIpIGlzIGVtcGxveWVkIHdpdGggdGhlCj4+Pj4+PiAg
ICAgICAgU0VDQ09NUF9GSUxURVJfRkxBR19ORVdfTElTVEVORVIgIGZsYWcgIGNhbiAgYmUgIG1v
bml0b3JlZCAgdXNpbmcKPj4+Pj4+ICAgICAgICBwb2xsKDIpLCBlcG9sbCg3KSwgYW5kIHNlbGVj
dCgyKS4gIFdoZW4gYSBub3RpZmljYXRpb24gIGlzICBwZW5k4oCQCj4+Pj4+PiAgICAgICAgaW5n
LCAgdGhlc2UgaW50ZXJmYWNlcyBpbmRpY2F0ZSB0aGF0IHRoZSBmaWxlIGRlc2NyaXB0b3IgaXMg
cmVhZOKAkAo+Pj4+Pj4gICAgICAgIGFibGUuCj4+Pj4+Cj4+Pj4+IFdlIHNob3VsZCBwcm9iYWJs
eSBhbHNvIHBvaW50IG91dCBzb21ld2hlcmUgdGhhdCwgYXMKPj4+Pj4gaW5jbHVkZS91YXBpL2xp
bnV4L3NlY2NvbXAuaCBzYXlzOgo+Pj4+Pgo+Pj4+PiAgKiBTaW1pbGFyIHByZWNhdXRpb25zIHNo
b3VsZCBiZSBhcHBsaWVkIHdoZW4gc3RhY2tpbmcgU0VDQ09NUF9SRVRfVVNFUl9OT1RJRgo+Pj4+
PiAgKiBvciBTRUNDT01QX1JFVF9UUkFDRS4gRm9yIFNFQ0NPTVBfUkVUX1VTRVJfTk9USUYgZmls
dGVycyBhY3Rpbmcgb24gdGhlCj4+Pj4+ICAqIHNhbWUgc3lzY2FsbCwgdGhlIG1vc3QgcmVjZW50
bHkgYWRkZWQgZmlsdGVyIHRha2VzIHByZWNlZGVuY2UuIFRoaXMgbWVhbnMKPj4+Pj4gICogdGhh
dCB0aGUgbmV3IFNFQ0NPTVBfUkVUX1VTRVJfTk9USUYgZmlsdGVyIGNhbiBvdmVycmlkZSBhbnkK
Pj4+Pj4gICogU0VDQ09NUF9JT0NUTF9OT1RJRl9TRU5EIGZyb20gZWFybGllciBmaWx0ZXJzLCBl
c3NlbnRpYWxseSBhbGxvd2luZyBhbGwKPj4+Pj4gICogc3VjaCBmaWx0ZXJlZCBzeXNjYWxscyB0
byBiZSBleGVjdXRlZCBieSBzZW5kaW5nIHRoZSByZXNwb25zZQo+Pj4+PiAgKiBTRUNDT01QX1VT
RVJfTk9USUZfRkxBR19DT05USU5VRS4gTm90ZSB0aGF0IFNFQ0NPTVBfUkVUX1RSQUNFIGNhbiBl
cXVhbGx5Cj4+Pj4+ICAqIGJlIG92ZXJyaWRlbiBieSBTRUNDT01QX1VTRVJfTk9USUZfRkxBR19D
T05USU5VRS4KPj4+Pj4KPj4+Pj4gSW4gb3RoZXIgd29yZHMsIGZyb20gYSBzZWN1cml0eSBwZXJz
cGVjdGl2ZSwgeW91IG11c3QgYXNzdW1lIHRoYXQgdGhlCj4+Pj4+IHRhcmdldCBwcm9jZXNzIGNh
biBieXBhc3MgYW55IFNFQ0NPTVBfUkVUX1VTRVJfTk9USUYgKG9yCj4+Pj4+IFNFQ0NPTVBfUkVU
X1RSQUNFKSBmaWx0ZXJzIHVubGVzcyBpdCBpcyBjb21wbGV0ZWx5IHByb2hpYml0ZWQgZnJvbQo+
Pj4+PiBjYWxsaW5nIHNlY2NvbXAoKS4gVGhpcyBzaG91bGQgYWxzbyBiZSBub3RlZCBvdmVyIGlu
IHRoZSBtYWluCj4+Pj4+IHNlY2NvbXAoMikgbWFucGFnZSwgZXNwZWNpYWxseSB0aGUgU0VDQ09N
UF9SRVRfVFJBQ0UgcGFydC4KPj4+Pgo+Pj4+IFNvIEkgd2FzIGFjdHVhbGx5IHdvbmRlcmluZyBh
Ym91dCB0aGlzIHdoZW4gSSBza2ltbWVkIHRoaXMgYW5kIGEgd2hpbGUKPj4+PiBhZ28gYnV0IGZv
cmdvdCBhYm91dCB0aGlzIGFnYWluLi4uIEFmYWljdCwgeW91IGNhbiBvbmx5IGV2ZXIgbG9hZCBh
Cj4+Pj4gc2luZ2xlIGZpbHRlciB3aXRoIFNFQ0NPTVBfRklMVEVSX0ZMQUdfTkVXX0xJU1RFTkVS
IHNldC4gSWYgdGhlcmUKPj4+PiBhbHJlYWR5IGlzIGEgZmlsdGVyIHdpdGggdGhlIFNFQ0NPTVBf
RklMVEVSX0ZMQUdfTkVXX0xJU1RFTkVSIHByb3BlcnR5Cj4+Pj4gaW4gdGhlIHRhc2tzIGZpbHRl
ciBoaWVyYXJjaHkgdGhlbiB0aGUga2VybmVsIHdpbGwgcmVmdXNlIHRvIGxvYWQgYSBuZXcKPj4+
PiBvbmU/Cj4+Pj4KPj4+PiBzdGF0aWMgc3RydWN0IGZpbGUgKmluaXRfbGlzdGVuZXIoc3RydWN0
IHNlY2NvbXBfZmlsdGVyICpmaWx0ZXIpCj4+Pj4gewo+Pj4+ICAgICAgICAgc3RydWN0IGZpbGUg
KnJldCA9IEVSUl9QVFIoLUVCVVNZKTsKPj4+PiAgICAgICAgIHN0cnVjdCBzZWNjb21wX2ZpbHRl
ciAqY3VyOwo+Pj4+Cj4+Pj4gICAgICAgICBmb3IgKGN1ciA9IGN1cnJlbnQtPnNlY2NvbXAuZmls
dGVyOyBjdXI7IGN1ciA9IGN1ci0+cHJldikgewo+Pj4+ICAgICAgICAgICAgICAgICBpZiAoY3Vy
LT5ub3RpZikKPj4+PiAgICAgICAgICAgICAgICAgICAgICAgICBnb3RvIG91dDsKPj4+PiAgICAg
ICAgIH0KPj4+Pgo+Pj4+IHNob3VsZG4ndCB0aGF0IGJlIHN1ZmZpY2llbnQgdG8gZ3VhcmFudGVl
IHRoYXQgVVNFUl9OT1RJRiBmaWx0ZXJzIGNhbid0Cj4+Pj4gb3ZlcnJpZGUgZWFjaCBvdGhlciBm
b3IgdGhlIHNhbWUgdGFzayBzaW1wbHkgYmVjYXVzZSB0aGVyZSBjYW4gb25seSBldmVyCj4+Pj4g
YmUgYSBzaW5nbGUgb25lPwo+Pj4KPj4+IEdvb2QgcG9pbnQuIEV4Y2VlZWVwdCB0aGF0IHRoYXQg
Y2hlY2sgc2VlbXMgaW5lZmZlY3RpdmUgYmVjYXVzZSB0aGlzCj4+PiBoYXBwZW5zIGJlZm9yZSB3
ZSB0YWtlIHRoZSBsb2NrcyB0aGF0IGd1YXJkIGFnYWluc3QgVFNZTkMsIGFuZCBhbHNvCj4+PiBi
ZWZvcmUgd2UgZGVjaWRlIHRvIHdoaWNoIGV4aXN0aW5nIGZpbHRlciB3ZSB3YW50IHRvIGNoYWlu
IHRoZSBuZXcKPj4+IGZpbHRlci4gU28gaWYgdHdvIHRocmVhZHMgcmFjZSB3aXRoIFRTWU5DLCBJ
IHRoaW5rIHRoZXknbGwgYmUgYWJsZSB0bwo+Pj4gY2hhaW4gdHdvIGZpbHRlcnMgd2l0aCBsaXN0
ZW5lcnMgdG9nZXRoZXIuCj4+Cj4+IFllcCwgc2VlbXMgdGhlIGNoZWNrIG5lZWRzIHRvIGFsc28g
YmUgaW4gc2VjY29tcF9jYW5fc3luY190aHJlYWRzKCkgdG8KPj4gYmUgdG90YWxseSBlZmZlY3Rp
dmUsCj4+Cj4+PiBJIGRvbid0IGtub3cgd2hldGhlciB3ZSB3YW50IHRvIGV0ZXJuYWxpemUgdGhp
cyAib25seSBvbmUgbGlzdGVuZXIKPj4+IGFjcm9zcyBhbGwgdGhlIGZpbHRlcnMiIHJlc3RyaWN0
aW9uIGluIHRoZSBtYW5wYWdlIHRob3VnaCwgb3Igd2hldGhlcgo+Pj4gdGhlIG1hbiBwYWdlIHNo
b3VsZCBqdXN0IHNheSB0aGF0IHRoZSBrZXJuZWwgY3VycmVudGx5IGRvZXNuJ3Qgc3VwcG9ydAo+
Pj4gaXQgYnV0IHRoYXQgc2VjdXJpdHktd2lzZSB5b3Ugc2hvdWxkIGFzc3VtZSB0aGF0IGl0IG1p
Z2h0IGF0IHNvbWUKPj4+IHBvaW50Lgo+Pgo+PiBUaGlzIHJlcXVpcmVtZW50IG9yaWdpbmFsbHkg
Y2FtZSBmcm9tIEFuZHksIGFyZ3VpbmcgdGhhdCB0aGUgc2VtYW50aWNzCj4+IG9mIHRoaXMgd2Vy
ZS9hcmUgY29uZnVzaW5nLCB3aGljaCBzdGlsbCBtYWtlcyBzZW5zZSB0byBtZS4gUGVyaGFwcyB3
ZQo+PiBzaG91bGQgZG8gc29tZXRoaW5nIGxpa2UgdGhlIGJlbG93Pwo+IAo+IEkgdGhpbmsgd2Ug
c2hvdWxkIGVpdGhlciBrZWVwIHVwIHRoaXMgcmVzdHJpY3Rpb24gYW5kIHRoZW4gY2VtZW50IGl0
IGluCj4gdGhlIG1hbnBhZ2Ugb3IgYWRkIGEgZmxhZyB0byBpbmRpY2F0ZSB0aGF0IHRoZSBub3Rp
ZmllciBpcwo+IG5vbi1vdmVycmlkYWJsZS4KPiBJIGRvbid0IGNhcmUgYWJvdXQgdGhlIGRlZmF1
bHQgdG9vIG11Y2gsIGkuZS4gd2hldGhlciBpdCdzIG92ZXJyaWRhYmxlCj4gYnkgZGVmYXVsdCBh
bmQgZXhjbHVzaXZlIGlmIG9wdGluZyBpbiBvciB0aGUgb3RoZXIgd2F5IGFyb3VuZCBkb2Vzbid0
Cj4gbWF0dGVyIHRvbyBtdWNoLiBCdXQgZnJvbSBhIHN1cGVydmlzb3IncyBwZXJzcGVjdGl2ZSBp
dCdkIGJlIHF1aXRlIG5pY2UKPiB0byBiZSBhYmxlIHRvIGJlIHN1cmUgdGhhdCBhIG5vdGlmaWVy
IGNhbid0IGJlIG92ZXJyaWRlbiBieSBhbm90aGVyCj4gbm90aWZpZXIuCj4gCj4gSSB0aGluayBo
YXZpbmcgYSBmbGFnIHdvdWxkIHByb3ZpZGUgdGhlIGdyZWF0ZXN0IGZsZXhpYmlsaXR5IGJ1dCBJ
IGFncmVlCj4gdGhhdCB0aGUgc2VtYW50aWNzIG9mIG11bHRpcGxlIGxpc3RlbmVycyBhcmUga2lu
ZGEgb2RkLgoKU28sIGZvciBub3csIEkgaGF2ZSBhcHBsaWVkIHRoZSBwYXRjaCBhdCB0aGUgZm9v
dCBvZiB0aGlzIG1haWwKdG8gdGhlIHBhZ2VzLiBEb2VzIHRoaXMgc2VlbSBjb3JyZWN0PwoKPiBC
ZWxvdyBsb29rcyBzYW5lIHRvIG1lIHRob3VnaCBhZ2FpbiwgSSdtIG5vdCBzaXR0aW5nIGluIGZy
b24gb2Ygc291cmNlCj4gY29kZS4KWy4uLl0KClRoYW5rcywKCk1pY2hhZWwKClBTIEphbm4sIGlm
IHlvdSBzZWUgdGhpcywgSSdtIHN0aWxsIHdvcmtpbmcgdGhyb3VnaCB5b3VyIChleHRlbnNpdmUK
YW5kIHZlcnkgaGVscGZ1bCkgcmV2aWV3IGNvbW1lbnRzLiBJIHdpbGwgYmUgc2VuZGluZyBhIHJl
c3BvbnNlLgoKPT09PT09CgpkaWZmIC0tZ2l0IGEvbWFuMi9zZWNjb21wLjIgYi9tYW4yL3NlY2Nv
bXAuMgppbmRleCA5YWIwN2Y0YWIuLjQ1YTY5ODRkZiAxMDA2NDQKLS0tIGEvbWFuMi9zZWNjb21w
LjIKKysrIGIvbWFuMi9zZWNjb21wLjIKQEAgLTIyMSw2ICsyMjEsMTEgQEAgcmV0dXJuIGEgbmV3
IHVzZXItc3BhY2Ugbm90aWZpY2F0aW9uIGZpbGUgZGVzY3JpcHRvci4KIFdoZW4gdGhlIGZpbHRl
ciByZXR1cm5zCiAuQlIgU0VDQ09NUF9SRVRfVVNFUl9OT1RJRgogYSBub3RpZmljYXRpb24gd2ls
bCBiZSBzZW50IHRvIHRoaXMgZmlsZSBkZXNjcmlwdG9yLgorLklQCitBdCBtb3N0IG9uZSBzZWNj
b21wIGZpbHRlciB1c2luZyB0aGUKKy5CUiBTRUNDT01QX0ZJTFRFUl9GTEFHX05FV19MSVNURU5F
UgorZmxhZyBjYW4gYmUgaW5zdGFsbGVkIGZvciBhIHRocmVhZC4KKy5JUAogU2VlCiAuQlIgc2Vj
Y29tcF91c2VyX25vdGlmICgyKQogZm9yIGZ1cnRoZXIgZGV0YWlscy4KQEAgLTc4OSw2ICs3OTQs
MTIgQEAgY2FwYWJpbGl0eSBpbiBpdHMgdXNlciBuYW1lc3BhY2UsIG9yIGhhZCBub3Qgc2V0CiBi
ZWZvcmUgdXNpbmcKIC5CUiBTRUNDT01QX1NFVF9NT0RFX0ZJTFRFUiAuCiAuVFAKKy5CUiBFQlVT
WQorV2hpbGUgaW5zdGFsbGluZyBhIG5ldyBmaWx0ZXIsIHRoZQorLkJSIFNFQ0NPTVBfRklMVEVS
X0ZMQUdfTkVXX0xJU1RFTkVSCitmbGFnIHdhcyBzcGVjaWZpZWQsCitidXQgYSBwcmV2aW91cyBm
aWx0ZXIgaGFkIGFscmVhZHkgYmVlbiBpbnN0YWxsZWQgd2l0aCB0aGF0IGZsYWcuCisuVFAKIC5C
UiBFRkFVTFQKIC5JUiBhcmdzCiB3YXMgbm90IGEgdmFsaWQgYWRkcmVzcy4KZGlmZiAtLWdpdCBh
L21hbjIvc2VjY29tcF91c2VyX25vdGlmLjIgYi9tYW4yL3NlY2NvbXBfdXNlcl9ub3RpZi4yCmlu
ZGV4IGE2MDI1ZTRkNC4uZDFhNDA2ZjQ2IDEwMDY0NAotLS0gYS9tYW4yL3NlY2NvbXBfdXNlcl9u
b3RpZi4yCisrKyBiL21hbjIvc2VjY29tcF91c2VyX25vdGlmLjIKQEAgLTkyLDYgKzkyLDcgQEAg
Q29uc2VxdWVudGx5LCB0aGUgcmV0dXJuIHZhbHVlICBvZiB0aGUgKHN1Y2Nlc3NmdWwpCiAuQlIg
c2VjY29tcCAoMikKIGNhbGwgaXMgYSBuZXcgImxpc3RlbmluZyIKIGZpbGUgZGVzY3JpcHRvciB0
aGF0IGNhbiBiZSB1c2VkIHRvIHJlY2VpdmUgbm90aWZpY2F0aW9ucy4KK09ubHkgb25lIHN1Y2gg
Imxpc3RlbmVyIiBjYW4gYmUgZXN0YWJsaXNoZWQuCiAuSVAgXChidQogSW4gY2FzZXMgd2hlcmUg
aXQgaXMgYXBwcm9wcmlhdGUsIHRoZSBzZWNjb21wIGZpbHRlciByZXR1cm5zIHRoZSBhY3Rpb24g
dmFsdWUKIC5CUiBTRUNDT01QX1JFVF9VU0VSX05PVElGIC4KCi0tIApNaWNoYWVsIEtlcnJpc2sK
TGludXggbWFuLXBhZ2VzIG1haW50YWluZXI7IGh0dHA6Ly93d3cua2VybmVsLm9yZy9kb2MvbWFu
LXBhZ2VzLwpMaW51eC9VTklYIFN5c3RlbSBQcm9ncmFtbWluZyBUcmFpbmluZzogaHR0cDovL21h
bjcub3JnL3RyYWluaW5nLwpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fXwpDb250YWluZXJzIG1haWxpbmcgbGlzdApDb250YWluZXJzQGxpc3RzLmxpbnV4LWZv
dW5kYXRpb24ub3JnCmh0dHBzOi8vbGlzdHMubGludXhmb3VuZGF0aW9uLm9yZy9tYWlsbWFuL2xp
c3RpbmZvL2NvbnRhaW5lcnM=
