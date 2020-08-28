Return-Path: <SRS0=8SPi=CG=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 061C8C433E2
	for <containers@archiver.kernel.org>; Fri, 28 Aug 2020 17:11:43 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 975ED20776
	for <containers@archiver.kernel.org>; Fri, 28 Aug 2020 17:11:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=sargun.me header.i=@sargun.me header.b="eU0YW04l"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 975ED20776
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sargun.me
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 5C4C088780;
	Fri, 28 Aug 2020 17:11:42 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id EoFTJcAO+gY4; Fri, 28 Aug 2020 17:11:41 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 914AE88763;
	Fri, 28 Aug 2020 17:11:41 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 73A82C016F;
	Fri, 28 Aug 2020 17:11:41 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id B9A41C0051
 for <containers@lists.linux-foundation.org>;
 Fri, 28 Aug 2020 17:11:39 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id A6902231A0
 for <containers@lists.linux-foundation.org>;
 Fri, 28 Aug 2020 17:11:39 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id tcUQyup9LfG4
 for <containers@lists.linux-foundation.org>;
 Fri, 28 Aug 2020 17:11:38 +0000 (UTC)
X-Greylist: delayed 00:07:15 by SQLgrey-1.7.6
Received: from mail-lj1-f194.google.com (mail-lj1-f194.google.com
 [209.85.208.194])
 by silver.osuosl.org (Postfix) with ESMTPS id 46DE722FB9
 for <containers@lists.linux-foundation.org>;
 Fri, 28 Aug 2020 17:11:38 +0000 (UTC)
Received: by mail-lj1-f194.google.com with SMTP id t6so2105985ljk.9
 for <containers@lists.linux-foundation.org>;
 Fri, 28 Aug 2020 10:11:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sargun.me; s=google;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc:content-transfer-encoding;
 bh=S3r4QY1f3FXeYBqg4sGoGX+7ODNPhZ8Qm/pKtU/ehKE=;
 b=eU0YW04lfamI+DDZBKKYd+20gMvyv5AxAZt9JtYtMqcJgMpByMnr/I/m/Rk342McvU
 YI9gz0iRisjTXphcGxvydVwZ6aiUpOTE9X5ehP2ahgH9tTQhvcrZ+J19FK93FydP7+bE
 o7GEvL6EvSP9R+XqgjvGurjppoG6USBXFvqDE=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc:content-transfer-encoding;
 bh=S3r4QY1f3FXeYBqg4sGoGX+7ODNPhZ8Qm/pKtU/ehKE=;
 b=jtXUJr6bNcQV9uuMQKDTAmq8ybmXdDSoJzembbdc3ismGvuAzWgw2I0QJoryVS8cDy
 IKYxiAOW+nT6OzpwIroC6UWVqeoUyQYaB6qSoxOJ51BPUftG0cK7q9EuPvvewJdB7o8e
 MzGfioiub5LOb3Etv8wPW3QqFyJujaboJbCi81jQR2KBPNauMxfL2f24+uY3vRmPJVAP
 ITRshiG6HoDMENIar86oeDINAisMNDXvQCbP51xhkbWtb7Hek15YJRSm3Op11bxL1+Ut
 o2yRGn95mau0BGfBbHA0QMFv+FvrRpgzl00z+VG7eDed9cfVUQ+202M5cyshMhktX+pZ
 g5gw==
X-Gm-Message-State: AOAM532CDtHQGULWaUkLjl6/maVzb6dz3bW01jRQnZwvGdPPpBdH+PDr
 880L2XOaW54oYIgew5lk+kayF5ETVQaxV/7Pb7+miSI6DVA=
X-Google-Smtp-Source: ABdhPJwVAxlBqZsnz+asQVMsFrx5DRFWnH/qU+euNyjBCD46/1cyJCu4Gzr+22CCo1hqFFrPO2DIXrqFXl8GrwaaYyM=
X-Received: by 2002:a50:fb15:: with SMTP id d21mr2890420edq.312.1598634262179; 
 Fri, 28 Aug 2020 10:04:22 -0700 (PDT)
MIME-Version: 1.0
References: <87zh6eiyv7.fsf@x220.int.ebiederm.org>
 <CA+enf=u7nenUStSs-UHzQouPVaJSHnEOcoQ_ecvhkrjLuxLkeA@mail.gmail.com>
In-Reply-To: <CA+enf=u7nenUStSs-UHzQouPVaJSHnEOcoQ_ecvhkrjLuxLkeA@mail.gmail.com>
From: Sargun Dhillon <sargun@sargun.me>
Date: Fri, 28 Aug 2020 10:03:45 -0700
Message-ID: <CAMp4zn_Z6GVPvx6cuRhsJAfOhez-V-V-io0NXuzaQrWSgqadYw@mail.gmail.com>
Subject: Re: Use cases for multiple uid mapping?
To: =?UTF-8?Q?St=C3=A9phane_Graber?= <stgraber@stgraber.org>
Cc: Linux Containers <containers@lists.linux-foundation.org>,
 "Eric W. Biederman" <ebiederm@xmission.com>,
 Christian Brauner <christian.brauner@ubuntu.com>
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

T24gRnJpLCBBdWcgMjgsIDIwMjAgYXQgODo1NiBBTSBTdMOpcGhhbmUgR3JhYmVyIHZpYSBDb250
YWluZXJzCjxjb250YWluZXJzQGxpc3RzLmxpbnV4LWZvdW5kYXRpb24ub3JnPiB3cm90ZToKPgo+
IE9uIEZyaSwgQXVnIDI4LCAyMDIwIGF0IDExOjIxIEFNIEVyaWMgVy4gQmllZGVybWFuCj4gPGVi
aWVkZXJtQHhtaXNzaW9uLmNvbT4gd3JvdGU6Cj4gPgo+ID4KPiA+IFdlIGhhZCBhIGRpc2N1c3Np
b24gaW4gdGhlIGhhY2tyb29tIGF0IExQQyB0YWxraW5nIGFib3V0IHVzZSBjYXNlcyBmb3IKPiA+
IGEgc2hpZnRmcyBzdHlsZSBzZXR1cCB3aGVyZSB0aGVyZSBhcmUgZGlmZmVyZW50IG1hcHBpbmdz
IG9mIHVpZHMgdG8KPiA+IGRpc2suCj4gPgo+ID4gSW4gdGhlIGRpc2N1c3Npb24gd2UgaGFkIGEg
Y291cGxlIG9mIGlkZWFzIG9mIGtlcm5lbCBkZXZlbG9wbWVudHMKPiA+IHdlIHNob3VsZCBsb29r
IGF0IHRoYXQgYWRkcmVzcyBzb21lIG9mIHRoZXNlLgo+ID4KPiA+IC0gRml4IHJsaW1pdHMgaW4g
dXNlciBuYW1lc3BhY2VzIChUaGlzIHBvdGVudGlhbGx5IGFsbG93cyBtdWx0aXBsZQo+ID4gICBj
b250YWluZXJzIHRvIHJ1biB3aXRoIHRoZSBzYW1lIHVzZXJpZHMgc2ltcGxpZnlpbmcgdGhlIG1h
cHBpbmcKPiA+ICAgcHJvYmxlbSkuCj4gPgo+ID4gLSBMb29rIGF0IGV4dGVuZGluZyBrdWlkX3Qg
dG8gNjRiaXRzIGFuZCB1c2luZyB0aGUgaGlnaGJpdHMgdG8KPiA+ICAgaW1wbGVtZW50IHVpZHMg
dGhhdCBhcmUgcHJpdmF0ZSB0byB1c2VyIG5hbWVzcGFjZXMgYW5kIGRvbid0Cj4gPiAgIG1hcCBv
dXQuCj4gPgo+ID4gLSBMb29rIGF0IHdheXMgZm9yIGFsbG93aW5nIHNldGdyb3VwcyB1bnByaXZp
bGVnZWQuCj4gPgo+ID4KPiA+IFRvZ2V0aGVyIHRoaXMgaGFzIHRoZSBwb3RlbnRpYWwgdGhhdCB0
aGUgZXhpc3RpbmcgdWlkICYgZ2lkIG1hcHBpbmdzCj4gPiB3aWxsIGJlIGFibGUgdG8gZnVuY3Rp
b24gdGhlIHNhbWUgYXMgdGhlIHByb3Bvc2VkIGZ1c2lkIG1hcHBpbmdzLiBGaW5nZXJzIGNyb3Nz
ZWQuCj4gPgo+ID4KPiA+IEkgaGFkIHNvbWUgcHJvYmxlbXMgd2l0aCBhdWRpbyBhbmQgYSBsb3Qg
b2YgcGVvcGxlIHdlcmUgdGFsa2luZwo+ID4gcXVpY2tseS4gIFNvIEkgZGlkIG5vdCBtYW5hZ2Ug
dG8gY2FwdHVyZSBldmVyeW9uZSdzIHVzZSBjYXNlcy4gICBBbmQgSQo+ID4gZGVmaW5pdGVseSB3
YXMgbm90IGFibGUgdG8gc2VlIGhvdyBldmVyeW9uZSdzIHVzZSBjYXNlcyBpbnRlcmFjdGVkIHdp
dGgKPiA+IHRoZSBjaGFuZ2VzIHdlIGFyZSBsb29raW5nIGF0Lgo+ID4KPiA+IEkga25vdyBmb3Ig
Y2VydGFpbiBJIG1pc3NlZCBTZXJnZSdzIHVzZWNhc2UgKGFwb2xvZ2llcykuCj4gPgo+ID4gQ2Fu
IHBlb3BsZSBmb2xsb3cgdXAgdG8gdGhpcyBhbmQgcmVwb3J0IHRoZWlyIHVzZSBjYXNlcz8KPiA+
Cj4gPiBUaGVyZSBhcmUgc29tZSByZWFsIGNoYWxsZW5nZXMgYW5kIEkgd291bGQgbGlrZSB0byBz
ZWUgaWYgd2UKPiA+IGNhbiBzb2x2ZSB0aGVtLCB3aGlsZSBhdm9pZGluZyBzY2FyeSBwcm9ibGVt
cyBsaWtlIGNoYW5naW5nCj4gPiB1aWRzIG9uIHdyaXRlLgo+ID4KPiA+IEVyaWMKPgo+IEhpIEVy
aWMsCj4KPiBJdCB3YXMgZ3JlYXQgdG8gaGF2ZSB5b3UgYW5kIGV2ZXJ5b25lIGVsc2UgcGFydGlj
aXBhdGUgaW4gdGhhdCBzZXNzaW9uLgo+IFRoZXJlIHdhcyBpbmRlZWQgYSBsb3QgY292ZXJlZCBp
biB0aGVyZSBhbmQgYSBsb3Qgb2YgdXNlIGNhc2VzIHdlJ2xsCj4gaGF2ZSB0byBrZWVwIGluIG1p
bmQhCj4KPiBUaGUgbWFpbiBvdXRjb21lcyB3ZSBjYXB0dXJlZCBJIGJlbGlldmUgd2VyZToKPiAg
LSBGaXhpbmcgcmxpbWl0cyBpbiB1c2VyIG5hbWVzcGFjZXMgc3VjaCB0aGF0IG9uZSBuYW1lc3Bh
Y2UgY2Fubm90Cj4gYWZmZWN0IGFub3RoZXIKPiAgLSBDb25zaWRlciBzd2l0Y2hpbmcgdGhlIGtl
cm5lbCB1aWQvZ2l0IHR5cGVzIHRvIDY0Yml0LCBhbGxvd2luZyBmb3IKPiBhIGhpZGRlbiAzMmJp
dCBpZGVudGlmaWVyIGFuZCBmdWxseSB1c2FibGUgMzJiaXQgdWlkL2dpZCByYW5nZSBmb3IgdGhl
Cj4gY29udGFpbmVyClNlY29uZGluZyB0aGlzLiBXZSBydW4gaW50byBhIGxvdCBvZiBwcm9ibGVt
cyB3aXRoIGhpZ2ggVUlEcy4gU29tZQpzeXN0ZW1zIHRoaW5rIHRoYXQgdWlkIDIqKjMxLTEgKEkg
dGhpbmsgaXQncyAyKiozMS0xKSBpcyB0aGVpciB2ZXJzaW9uIG9mCidub2JvZHknLiBCZWluZyBh
YmxlIHRvIGhhdmUgNjQtYml0IFVJRHMgd291bGQgc29sdmUgdGhpcy4KCkFsc28gbWFraW5nIHN1
cmUgdGhpcyB3b3JrcyB3aXRoIE5GU3Y0IChib3RoIElEIG1hcHBlZCwgYW5kIG5vbi0KSUQgbWFw
cGVkKSBpcyB2ZXJ5IGltcG9ydGFudCB0byB1cy4gSXQncyBmaW5lIGlmIHRoZSBVSUQgLyBHSUQg
aXMganVzdAoicGFzc3Rocm91Z2giLCBhbmQgd2UgZG9uJ3QgbmVlZCBkaWZmZXJlbnQgbWFwcGlu
Z3MgYmV0d2VlbgpkaWZmZXJlbnQgZmlsZXN5c3RlbXMgaW4gTkZTIChmb3Igbm93KS4gV2Ugd291
bGQgbGlrZSB0byBiZSBhYmxlCnRvIGJlIGFibGUgdG8gcnVuIGlkbWFwcGVyIGluIHRoZSB1c2Vy
IC8gcGlkIC8gbmV0IG5hbWVzcGFjZSBvZgp0aGUgY29udGFpbmVyLgoKPiAgLSBGaW5kIGEgd2F5
IHRvIGFsbG93IHNldGdyb3VwcygpIGluIGEgdXNlciBuYW1lc3BhY2Ugd2hpbGUga2VlcGluZwo+
IGluIG1pbmQgdGhlIGNhc2Ugb2YgZ3JvdXBzIHVzZWQgZm9yIG5lZ2F0aXZlIGFjY2VzcyBjb250
cm9sCj4gIC0gQWRkIG9wdGlvbmFsIGVuZm9yY2VtZW50IHRoYXQgb3ZlcmZsb3cgdWlkL2dpZCBh
cyBzZXQgdGhyb3VnaAo+IHN5c2N0bCBjYW5ub3QgYmUgdXNlZCBhcyByZWd1bGFyIHVpZC9naWQg
b24gdGhlIHN5c3RlbQo+Cj4gQ2hyaXN0aWFuIGlzIHdvcmtpbmcgb24gYSBjb21wcmVoZW5zaXZl
IHN1bW1hcnkgb2YgdGhlIHNlc3Npb24gYmFzZWQKPiBvbiB0aGUgc2hhcmVkIG5vdGVzIGRvY3Vt
ZW50IHdlIGNpcmN1bGF0ZWQgYXQgdGhlIGJlZ2lubmluZyBvZiB0aGUKPiBzZXNzaW9uIHdoaWNo
IHdpbGwgdHJ5IHRvIHNlcGFyYXRlIHRoZSBkaWZmZXJlbnQgdG9waWNzIGFuZCBjb3ZlciB1c2UK
PiBjYXNlcyBhbmQgcG90ZW50aWFsIHNvbHV0aW9ucyBmb3IgZWFjaCBhcyB3ZSBkaXNjdXNzZWQg
aW4gdGhlIEJvRi4KPgo+IFdlJ2xsIG1ha2Ugc3VyZSB0aGF0IGV2ZXJ5b25lIHdobyBhdHRlbmRl
ZCB0aGUgQm9GIGdldHMgQ0NlZCBvbiB0aGF0LAo+IG9uIHRvcCBvZiB0aGUgdXN1YWwgbWFpbGlu
Zy1saXN0cyBzbyB0aGF0IHNob3VsZCBhbnkgb2YgdGhlIHVzZSByYWlzZWQKPiB1c2UgY2FzZXMg
aGF2ZSBiZWVuIG1pc3NlZCBpbiB0aGUgbm90ZXMsIHRob3NlIGZvbGtzIGNhbiByYWlzZSB0aGVt
Cj4gYWdhaW4gc28gd2UgZG9uJ3QgZW5kIHVwIG1pc3NpbmcgYW55dGhpbmcgOikKPgo+IFN0w6lw
aGFuZQo+IF9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCj4g
Q29udGFpbmVycyBtYWlsaW5nIGxpc3QKPiBDb250YWluZXJzQGxpc3RzLmxpbnV4LWZvdW5kYXRp
b24ub3JnCj4gaHR0cHM6Ly9saXN0cy5saW51eGZvdW5kYXRpb24ub3JnL21haWxtYW4vbGlzdGlu
Zm8vY29udGFpbmVycwpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fXwpDb250YWluZXJzIG1haWxpbmcgbGlzdApDb250YWluZXJzQGxpc3RzLmxpbnV4LWZvdW5k
YXRpb24ub3JnCmh0dHBzOi8vbGlzdHMubGludXhmb3VuZGF0aW9uLm9yZy9tYWlsbWFuL2xpc3Rp
bmZvL2NvbnRhaW5lcnM=
