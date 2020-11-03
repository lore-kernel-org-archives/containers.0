Return-Path: <SRS0=6hu2=EJ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C23D9C388F7
	for <containers@archiver.kernel.org>; Tue,  3 Nov 2020 14:32:35 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3FE90223AB
	for <containers@archiver.kernel.org>; Tue,  3 Nov 2020 14:32:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=kinvolk.io header.i=@kinvolk.io header.b="jNSrYWNM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3FE90223AB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kinvolk.io
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id E153D861C8;
	Tue,  3 Nov 2020 14:32:34 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id hsnlbC8f8Gz3; Tue,  3 Nov 2020 14:32:33 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id A586D861A3;
	Tue,  3 Nov 2020 14:32:33 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 8274CC0889;
	Tue,  3 Nov 2020 14:32:32 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 6F31FC0051
 for <containers@lists.linux-foundation.org>;
 Tue,  3 Nov 2020 14:32:31 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 3ADC92051F
 for <containers@lists.linux-foundation.org>;
 Tue,  3 Nov 2020 14:32:31 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id tgC63CaIxkTT
 for <containers@lists.linux-foundation.org>;
 Tue,  3 Nov 2020 14:32:29 +0000 (UTC)
X-Greylist: delayed 00:21:40 by SQLgrey-1.7.6
Received: from mail-lj1-f195.google.com (mail-lj1-f195.google.com
 [209.85.208.195])
 by silver.osuosl.org (Postfix) with ESMTPS id 0B095203E5
 for <containers@lists.linux-foundation.org>;
 Tue,  3 Nov 2020 14:32:28 +0000 (UTC)
Received: by mail-lj1-f195.google.com with SMTP id m16so19275796ljo.6
 for <containers@lists.linux-foundation.org>;
 Tue, 03 Nov 2020 06:32:28 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kinvolk.io; s=google;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc:content-transfer-encoding;
 bh=y8WQjpT9rqVrgeh99s8m7L7lW+jgLfIjyGz2M8+krP0=;
 b=jNSrYWNMri4UzTfQTwvUoeI3d9PbxAntszBtbkOHWPbsmFNLXoekIJ8TcfDFJbJf7v
 6+eYLKBEUBAXwADA9DJI10J7imuIzSuwLQhtXLJY1nc7fmB3dMavlYA1Xmy9wmU6aG0F
 m9nefJssTHLgeDNMLEKBtF2hV/CbFCCq5QOzc=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc:content-transfer-encoding;
 bh=y8WQjpT9rqVrgeh99s8m7L7lW+jgLfIjyGz2M8+krP0=;
 b=YnZREH4wgGYkfpn/Y8q4uOLt2oEJNk4h2XBt5nv0Ie+Zvx3oHdGw27FuQGCUhPEYH9
 7+xZuzXrqlHiXidvJObnxgqRc1vA/Dh4cUwZ3k4cJ+2Cq1jyLvmKyxvv2dwDX8ZImn8m
 1UjLNiS1J8BXqFaYW9joedIuBql0p1Owvj76GUJ0D+mqzY5PjFlkqX7AT8d84au8ejXS
 Fgs26j3cw5MRy7G6WgZqvH27s7fjiVF9CYmEYUhQKPkW96RD8gXg+ODf8CXYHtvsbJhd
 eVYmTFQrjP8Fl5BG+0k2Spf5pzyU1231UdJ74MeVIZtIZHmWrlMnBE9pifx7QhZR0LLI
 mu1Q==
X-Gm-Message-State: AOAM531YB5mRcDh++rSHZ9IdoO3VvZwqylWrxix+BrL5F976IlPd8y36
 nKptZ9a9cQn+4uj65e+7s0UGfE4DGIQ+zxjr8odoBiG8zBskk3qQ
X-Google-Smtp-Source: ABdhPJwp4QL8RwmQmcT2CoPcUplHSU9HiByLsXAEntwM01IPEN+3MiJMYkcJQ6Od81V70aDSuFwsTxILAnA/OMfjXrI=
X-Received: by 2002:a05:6402:a57:: with SMTP id
 bt23mr10741907edb.62.1604412647178; 
 Tue, 03 Nov 2020 06:10:47 -0800 (PST)
MIME-Version: 1.0
References: <20201029003252.2128653-1-christian.brauner@ubuntu.com>
 <87pn51ghju.fsf@x220.int.ebiederm.org>
 <20201029155148.5odu4j2kt62ahcxq@yavin.dot.cyphar.com>
 <87361xdm4c.fsf@x220.int.ebiederm.org>
In-Reply-To: <87361xdm4c.fsf@x220.int.ebiederm.org>
From: Alban Crequy <alban@kinvolk.io>
Date: Tue, 3 Nov 2020 15:10:35 +0100
Message-ID: <CADZs7q4abuN6n8HMrpe2R2kRBUDVPoYRNpezKk4cvXRk7CVHng@mail.gmail.com>
Subject: Re: [PATCH 00/34] fs: idmapped mounts
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Lennart Poettering <lennart@poettering.net>,
 Mimi Zohar <zohar@linux.ibm.com>, David Howells <dhowells@redhat.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tycho Andersen <tycho@tycho.ws>, Miklos Szeredi <miklos@szeredi.hu>,
 smbarber@chromium.org, Christoph Hellwig <hch@infradead.org>,
 linux-ext4@vger.kernel.org, Mrunal Patel <mpatel@redhat.com>,
 Kees Cook <keescook@chromium.org>, Arnd Bergmann <arnd@arndb.de>,
 Jann Horn <jannh@google.com>, selinux@vger.kernel.org,
 Josh Triplett <josh@joshtriplett.org>,
 linux-fsdevel <linux-fsdevel@vger.kernel.org>,
 Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 Geoffrey Thomas <geofft@ldpreload.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 John Johansen <john.johansen@canonical.com>, Theodore Tso <tytso@mit.edu>,
 Seth Forshee <seth.forshee@canonical.com>,
 Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
 Stephen Smalley <stephen.smalley.work@gmail.com>,
 Jonathan Corbet <corbet@lwn.net>, linux-unionfs@vger.kernel.org,
 LSM <linux-security-module@vger.kernel.org>, linux-audit@redhat.com,
 linux-api@vger.kernel.org, Casey Schaufler <casey@schaufler-ca.com>,
 linux-integrity <linux-integrity@vger.kernel.org>,
 Todd Kjos <tkjos@google.com>
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

T24gVGh1LCBPY3QgMjksIDIwMjAgYXQgNTozNyBQTSBFcmljIFcuIEJpZWRlcm1hbiA8ZWJpZWRl
cm1AeG1pc3Npb24uY29tPiB3cm90ZToKPgo+IEFsZWtzYSBTYXJhaSA8Y3lwaGFyQGN5cGhhci5j
b20+IHdyaXRlczoKPgo+ID4gT24gMjAyMC0xMC0yOSwgRXJpYyBXLiBCaWVkZXJtYW4gPGViaWVk
ZXJtQHhtaXNzaW9uLmNvbT4gd3JvdGU6Cj4gPj4gQ2hyaXN0aWFuIEJyYXVuZXIgPGNocmlzdGlh
bi5icmF1bmVyQHVidW50dS5jb20+IHdyaXRlczoKPiA+Pgo+ID4+ID4gSGV5IGV2ZXJ5b25lLAo+
ID4+ID4KPiA+PiA+IEkgdmFuaXNoZWQgZm9yIGEgbGl0dGxlIHdoaWxlIHRvIGZvY3VzIG9uIHRo
aXMgd29yayBoZXJlIHNvIHNvcnJ5IGZvcgo+ID4+ID4gbm90IGJlaW5nIGF2YWlsYWJsZSBieSBt
YWlsIGZvciBhIHdoaWxlLgo+ID4+ID4KPiA+PiA+IFNpbmNlIHF1aXRlIGEgbG9uZyB0aW1lIHdl
IGhhdmUgaXNzdWVzIHdpdGggc2hhcmluZyBtb3VudHMgYmV0d2Vlbgo+ID4+ID4gbXVsdGlwbGUg
dW5wcml2aWxlZ2VkIGNvbnRhaW5lcnMgd2l0aCBkaWZmZXJlbnQgaWQgbWFwcGluZ3MsIHNoYXJp
bmcgYQo+ID4+ID4gcm9vdGZzIGJldHdlZW4gbXVsdGlwbGUgY29udGFpbmVycyB3aXRoIGRpZmZl
cmVudCBpZCBtYXBwaW5ncywgYW5kIGFsc28KPiA+PiA+IHNoYXJpbmcgcmVndWxhciBkaXJlY3Rv
cmllcyBhbmQgZmlsZXN5c3RlbXMgYmV0d2VlbiB1c2VycyB3aXRoIGRpZmZlcmVudAo+ID4+ID4g
dWlkcyBhbmQgZ2lkcy4gVGhlIGxhdHRlciB1c2UtY2FzZXMgaGF2ZSBiZWNvbWUgZXZlbiBtb3Jl
IGltcG9ydGFudCB3aXRoCj4gPj4gPiB0aGUgYXZhaWxhYmlsaXR5IGFuZCBhZG9wdGlvbiBvZiBz
eXN0ZW1kLWhvbWVkIChjZi4gWzFdKSB0byBpbXBsZW1lbnQKPiA+PiA+IHBvcnRhYmxlIGhvbWUg
ZGlyZWN0b3JpZXMuCj4gPj4KPiA+PiBDYW4geW91IHdhbGsgdXMgdGhyb3VnaCB0aGUgbW90aXZh
dGluZyB1c2UgY2FzZT8KPiA+Pgo+ID4+IEFzIG9mIHRoaXMgeWVhcidzIExQQyBJIGhhZCB0aGUg
ZGlzdGluY3QgaW1wcmVzc2lvbiB0aGF0IHRoZSBwcmltYXJ5IHVzZQo+ID4+IGNhc2UgZm9yIHN1
Y2ggYSBmZWF0dXJlIHdhcyBkdWUgdG8gdGhlIFJMSU1JVF9OUFJPQyBwcm9ibGVtIHdoZXJlIHR3
bwo+ID4+IGNvbnRhaW5lcnMgd2l0aCB0aGUgc2FtZSB1c2VycyBzdGlsbCB3YW50ZWQgZGlmZmVy
ZW50IHVpZCBtYXBwaW5ncyB0bwo+ID4+IHRoZSBkaXNrIGJlY2F1c2UgdGhlIHVzZXJzIHdlcmUg
Y29uZmxpY3Rpbmcgd2l0aCBlYWNoIG90aGVyIGJlY2F1c2Ugb2YKPiA+PiB0aGUgcGVyIHVzZXIg
cmxpbWl0cy4KPiA+Pgo+ID4+IEZpeGluZyBybGltaXRzIGlzIHN0cmFpZ2h0IGZvcndhcmQgdG8g
aW1wbGVtZW50LCBhbmQgZWFzaWVyIHRvIG1hbmFnZQo+ID4+IGZvciBpbXBsZW1lbnRhdGlvbnMg
YW5kIGFkbWluaXN0cmF0b3JzLgo+ID4KPiA+IFRoaXMgaXMgc2VwYXJhdGUgdG8gdGhlIHF1ZXN0
aW9uIG9mICJpc29sYXRlZCB1c2VyIG5hbWVzcGFjZXMiIGFuZAo+ID4gbWFuYWdpbmcgZGlmZmVy
ZW50IG1hcHBpbmdzIGJldHdlZW4gY29udGFpbmVycy4gVGhpcyBwYXRjaHNldCBpcyBzb2x2aW5n
Cj4gPiB0aGUgc2FtZSBwcm9ibGVtIHRoYXQgc2hpZnRmcyBzb2x2ZWQgLS0gc2hhcmluZyBhIHNp
bmdsZSBkaXJlY3RvcnkgdHJlZQo+ID4gYmV0d2VlbiBjb250YWluZXJzIHRoYXQgaGF2ZSBkaWZm
ZXJlbnQgSUQgbWFwcGluZ3MuIHJsaW1pdHMgKG5vciBhbnkgb2YKPiA+IHRoZSBvdGhlciBwcm9w
b3NhbHMgd2UgZGlzY3Vzc2VkIGF0IExQQykgd2lsbCBoZWxwIHdpdGggdGhpcyBwcm9ibGVtLgo+
Cj4gRmlyc3QgYW5kIGZvcmVtb3N0OiBBIHVpZCBzaGlmdCBvbiB3cml0ZSB0byBhIGZpbGVzeXN0
ZW0gaXMgYSBzZWN1cml0eQo+IGJ1ZyB3YWl0aW5nIHRvIGhhcHBlbi4gIFRoaXMgaXMgZXNwZWNp
YWxseSBpbiB0aGUgY29udGV4dCBvZiBmYWNpbGl0aWVzCj4gbGlrZSBpb3VyaW5nLCB0aGF0IHBs
YXkgdmVyeSBhZ3Jlc3NpdmUgZ2FtZXMgd2l0aCBob3cgcHJvY2VzcyBjb250ZXh0Cj4gbWFrZXMg
aXQgdG8gIHN5c3RlbSBjYWxscy4KPgo+IFRoZSBvbmx5IHJlYXNvbiBjb250YWluZXJzIHdlcmUg
bm90IGltbWVkaWF0ZWx5IGV4cGxvaXRhYmxlIHdoZW4gaW91cmluZwo+IHdhcyBpbnRyb2R1Y2Vk
IGlzIGJlY2F1c2UgdGhlIG1lY2hhbmlzbXMgYXJlIGJ1aWx0IHNvIHRoYXQgZXZlbiBpZgo+IHNv
bWV0aGluZyBlc2NhcGVzIGNvbnRhaW5tZW50IHRoZSBzZWN1cml0eSBwcm9wZXJ0aWVzIHN0aWxs
IGFwcGx5Lgo+IENoYW5nZXMgdG8gdGhlIHVpZCB3aGVuIHdyaXRpbmcgdG8gdGhlIGZpbGVzeXN0
ZW0gZG9lcyBub3QgaGF2ZSB0aGF0Cj4gcHJvcGVydHkuICBUaGUgdGluaWVzdCBzbGlwIGluIGNv
bnRhaW5tZW50IHdpbGwgYmUgYSBzZWN1cml0eSBpc3N1ZS4KPgo+IFRoaXMgaXMgbm90IGV2ZW4g
dGhlIGxlYXN0IGJpdCB0aGVvcmV0aWNhbC4gIEkgaGF2ZSBzZWVtIHJlcG9ydHMgb2YgaG93Cj4g
c2hpdGZzK292ZXJsYXlmcyBjcmVhdGVkIGEgc2l0dWF0aW9uIHdoZXJlIGFueW9uZSBjb3VsZCBy
ZWFkCj4gL2V0Yy9zaGFkb3cuCj4KPiBJZiB5b3UgYXJlIGdvaW5nIHRvIHdyaXRlIHVzaW5nIHRo
ZSBzYW1lIHVpZCB0byBkaXNrIGZyb20gZGlmZmVyZW50Cj4gY29udGFpbmVycyB0aGUgcXVlc3Rp
b24gYmVjb21lcyB3aHkgY2FuJ3QgdGhvc2UgY29udGFpbmVycyBjb25maWd1cmUKPiB0aG9zZSB1
c2VycyB0byB1c2UgdGhlIHNhbWUga3VpZD8KPgo+IFdoYXQgZml4aW5nIHJsaW1pdHMgZG9lcyBp
cyBpdCBmaXhlcyBvbmUgb2YgdGhlIHJlYXNvbnMgdGhhdCBkaWZmZXJlbnQKPiBjb250YWluZXJz
IGNvdWxkIG5vdCBzaGFyZSB0aGUgc2FtZSBrdWlkIGZvciB1c2VycyB0aGF0IHdhbnQgdG8gd3Jp
dGUgdG8KPiBkaXNrIHdpdGggdGhlIHNhbWUgdWlkLgo+Cj4KPiBJIGh1bWJseSBzdWdnZXN0IHRo
YXQgaXQgd2lsbCBiZSBtb3JlIHNlY3VyZSwgYW5kIGVhc2llciB0byBtYWludGFpbiBmb3IKPiBi
b3RoIGRldmVsb3BlcnMgYW5kIHVzZXJzIGlmIHdlIGZpeCB0aGUgcmVhc29ucyBwZW9wbGUgd2Fu
dCBkaWZmZXJlbnQKPiBjb250YWluZXJzIHRvIGhhdmUgdGhlIHNhbWUgdXNlciBydW5uaW5nIHdp
dGggZGlmZmVyZW50IGt1aWRzLgo+Cj4gSWYgbm90IHdoYXQgYXJlIHRoZSByZWFzb25zIHdlIGZ1
bmRhbWVudGFsbHkgbmVlZCB0aGUgc2FtZSBvbi1kaXNrIHVzZXIKPiB1c2luZyBtdWx0aXBsZSBr
dWlkcyBpbiB0aGUga2VybmVsPwoKSSB3b3VsZCBsaWtlIHRvIHVzZSB0aGlzIHBhdGNoIHNldCBp
biB0aGUgY29udGV4dCBvZiBLdWJlcm5ldGVzLiBJCmRlc2NyaWJlZCBteSB0d28gcG9zc2libGUg
c2V0dXBzIGluCmh0dHBzOi8vd3d3LnNwaW5pY3MubmV0L2xpc3RzL2xpbnV4LWNvbnRhaW5lcnMv
bXNnMzY1MzcuaHRtbDoKCjEuIEVhY2ggS3ViZXJuZXRlcyBwb2QgaGFzIGl0cyBvd24gdXNlcm5z
IGJ1dCB3aXRoIHRoZSBzYW1lIHVzZXIgaWQgbWFwcGluZwoyLiBFYWNoIEt1YmVybmV0ZXMgcG9k
IGhhcyBpdHMgb3duIHVzZXJucyB3aXRoIG5vbi1vdmVybGFwcGluZyB1c2VyIGlkCm1hcHBpbmcg
KHByb3ZpZGluZyBhZGRpdGlvbmFsIGlzb2xhdGlvbiBiZXR3ZWVuIHBvZHMpCgpCdXQgZXZlbiBp
biB0aGUgc2V0dXAgd2hlcmUgYWxsIHBvZHMgcnVuIHdpdGggdGhlIHNhbWUgaWQgbWFwcGluZ3Ms
CnRoaXMgcGF0Y2ggc2V0IGlzIHN0aWxsIHVzZWZ1bCB0byBtZSBmb3IgMiByZWFzb25zOgoKMS4g
VG8gYXZvaWQgdGhlIGV4cGVuc2l2ZSByZWN1cnNpdmUgY2hvd24gb2YgdGhlIHJvb3Rmcy4gV2Ug
Y2Fubm90Cm5lY2Vzc2FyaWx5IGV4dHJhY3QgdGhlIHRhcmJhbGwgZGlyZWN0bHkgd2l0aCB0aGUg
cmlnaHQgdWlkcyBiZWNhdXNlCndlIG1pZ2h0IHVzZSB0aGUgc2FtZSBjb250YWluZXIgaW1hZ2Ug
Zm9yIHByaXZpbGVnZWQgY29udGFpbmVycyAod2l0aAp0aGUgaG9zdCB1c2VybnMpIGFuZCB1bnBy
aXZpbGVnZWQgY29udGFpbmVycyAod2l0aCBhIG5ldyB1c2VybnMpLCBzbwp3ZSBoYXZlIGF0IGxl
YXN0IDIg4oCcbWFwcGluZ3PigJ0gKHRha2luZyBtb3JlIHRpbWUgYW5kIHJlc3VsdGluZyBpbiBt
b3JlCnN0b3JhZ2Ugc3BhY2UpLiBBbHRob3VnaCB0aGUg4oCcbWV0YWNvcHnigJ0gbW91bnQgb3B0
aW9uIGluIG92ZXJsYXlmcwpoZWxwcyB0byBtYWtlIHRoZSByZWN1cnNpdmUgY2hvd24gZmFzdGVy
LCBpdCBjYW4gc3RpbGwgdGFrZSB0aW1lIHdpdGgKbGFyZ2UgY29udGFpbmVyIGltYWdlcyB3aXRo
IGxvdHMgb2YgZmlsZXMuIEnigJlkIGxpa2UgdG8gdXNlIHRoaXMgcGF0Y2gKc2V0IHRvIHNldCB1
cCB0aGUgcm9vdCBmcyBpbiBjb25zdGFudCB0aW1lLgoKMi4gVG8gbWFuYWdlIGxhcmdlIGV4dGVy
bmFsIHZvbHVtZXMgKE5GUyBvciBvdGhlciBmaWxlc3lzdGVtcykuIEV2ZW4KaWYgYWRtaW5zIGNh
biBkZWNpZGUgdG8gdXNlIHRoZSBzYW1lIGt1aWQgb24gYWxsIHRoZSBub2RlcyBvZiB0aGUKS3Vi
ZXJuZXRlcyBjbHVzdGVyLCB0aGlzIGlzIGltcHJhY3RpY2FsIGZvciBtaWdyYXRpb24uIFBlb3Bs
ZSBjYW4gaGF2ZQpleGlzdGluZyBLdWJlcm5ldGVzIGNsdXN0ZXJzIChjdXJyZW50bHkgd2l0aG91
dCB1c2luZyB1c2VyIG5hbWVzcGFjZXMpCmFuZCBsYXJnZSBORlMgdm9sdW1lcy4gSWYgdGhleSB3
YW50IHRvIHN3aXRjaCB0byBhIG5ldyB2ZXJzaW9uIG9mCkt1YmVybmV0ZXMgd2l0aCB0aGUgdXNl
ciBuYW1lc3BhY2UgZmVhdHVyZSBlbmFibGVkLCB0aGV5IHdvdWxkIG5lZWQgdG8KcmVjdXJzaXZl
bHkgY2hvd24gYWxsIHRoZSBmaWxlcyBvbiB0aGUgTkZTIHNoYXJlcy4gVGhpcyBjb3VsZCB0YWtl
CnRpbWUgb24gbGFyZ2UgZmlsZXN5c3RlbXMgYW5kIHJlYWxpc3RpY2FsbHksIHdlIHdhbnQgdG8g
c3VwcG9ydApyb2xsaW5nIHVwZGF0ZXMgd2hlcmUgc29tZSBub2RlcyB1c2UgdGhlIHByZXZpb3Vz
IHZlcnNpb24gd2l0aG91dCB1c2VyCm5hbWVzcGFjZXMgYW5kIG5ldyBub2RlcyBhcmUgcHJvZ3Jl
c3NpdmVseSBtaWdyYXRlZCB0byB0aGUgbmV3IHVzZXJucwp3aXRoIHRoZSBuZXcgaWQgbWFwcGlu
Zy4gSWYgYm90aCBzZXRzIG9mIG5vZGVzIHVzZSB0aGUgc2FtZSBORlMgc2hhcmUsCnRoYXQgY2Fu
4oCZdCB3b3JrLgoKQWxiYW4KX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX18KQ29udGFpbmVycyBtYWlsaW5nIGxpc3QKQ29udGFpbmVyc0BsaXN0cy5saW51eC1m
b3VuZGF0aW9uLm9yZwpodHRwczovL2xpc3RzLmxpbnV4Zm91bmRhdGlvbi5vcmcvbWFpbG1hbi9s
aXN0aW5mby9jb250YWluZXJz
