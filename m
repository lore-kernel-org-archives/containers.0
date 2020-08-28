Return-Path: <SRS0=8SPi=CG=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5E1CC433E2
	for <containers@archiver.kernel.org>; Fri, 28 Aug 2020 15:56:10 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 62F412075B
	for <containers@archiver.kernel.org>; Fri, 28 Aug 2020 15:56:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=stgraber.org header.i=@stgraber.org header.b="WGNb3wg8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 62F412075B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 0826420525;
	Fri, 28 Aug 2020 15:56:10 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 39ZhEhA0qWpU; Fri, 28 Aug 2020 15:56:02 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id C7F0B22DB0;
	Fri, 28 Aug 2020 15:56:01 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id AA1D1C016F;
	Fri, 28 Aug 2020 15:56:01 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id F0188C0051
 for <containers@lists.linux-foundation.org>;
 Fri, 28 Aug 2020 15:55:59 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id D744287881
 for <containers@lists.linux-foundation.org>;
 Fri, 28 Aug 2020 15:55:59 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id fTI9Al30Gjzc
 for <containers@lists.linux-foundation.org>;
 Fri, 28 Aug 2020 15:55:58 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from mail-lj1-f175.google.com (mail-lj1-f175.google.com
 [209.85.208.175])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 9072D8785E
 for <containers@lists.linux-foundation.org>;
 Fri, 28 Aug 2020 15:55:58 +0000 (UTC)
Received: by mail-lj1-f175.google.com with SMTP id t23so1864210ljc.3
 for <containers@lists.linux-foundation.org>;
 Fri, 28 Aug 2020 08:55:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=stgraber.org; s=google;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc:content-transfer-encoding;
 bh=6Jt48D0nEIis4HDgHpA+nAzWUx+j00jX6zv0pRBx6ME=;
 b=WGNb3wg8zsV2mk7flVPLwEf/yvfVrtJ1Q5JciittEico/nfn3o512a2xMiQlLVvj71
 ZLPo4YWYFulWaAt2E0s7gY+h/6cT5ZdC+p4ib7nzdP3fCXQKQXc/nMjyt91lXmW98EEp
 XV3MRa2wvUW6r8g0G8AAYtQHeF4NFTo2bv4Ow=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc:content-transfer-encoding;
 bh=6Jt48D0nEIis4HDgHpA+nAzWUx+j00jX6zv0pRBx6ME=;
 b=faCpYwkUsL4Hrbti6CWnwIyv9+g80ZrJDXCbddZwMyIxJwtwo8p0c9hfc+5x2F78pw
 xLJKTN5r8IQRMS6K4t5jF3wV9bdBPLvoPOuSyVRC9aH7JvrWzJRK1FTlm9cGn0p+HyHs
 yGD6RGOG21GZYimUrQSA2j2+1n4Svtb0tP0B056zBfsIZshG+K58iHEeP1c2BDUtNdko
 o1bYJima4cpZHfdOFq4K5KOad2WDP3QaA3a+jczvPYMSGS4EijGUDKbH6LMReWOeHHpf
 x4VGaloJdb+zZuDqrWXT197fQC8/RX+GprmSib1xIVttS33vAq1O8RBFmLvjt7mpKUID
 9Thw==
X-Gm-Message-State: AOAM532H2jJoJqpWkvNce/19CBwU+jgkAqPmX6tbfB8ychov/CQSX7tG
 cTTQAlay9OHdlxeRVIM23AJSxpgotUxlH8xFuGYapw==
X-Google-Smtp-Source: ABdhPJwRxtzjKJVRFaPB601SMEdlxmXMKU6HL8nnuaEWSaE2pYfMh9C1AX8vC1FVXShqI+TkWzLfFVFDiLUtDlFo4OQ=
X-Received: by 2002:a2e:804d:: with SMTP id p13mr1197006ljg.359.1598630156299; 
 Fri, 28 Aug 2020 08:55:56 -0700 (PDT)
MIME-Version: 1.0
References: <87zh6eiyv7.fsf@x220.int.ebiederm.org>
In-Reply-To: <87zh6eiyv7.fsf@x220.int.ebiederm.org>
Date: Fri, 28 Aug 2020 11:55:44 -0400
Message-ID: <CA+enf=u7nenUStSs-UHzQouPVaJSHnEOcoQ_ecvhkrjLuxLkeA@mail.gmail.com>
Subject: Re: Use cases for multiple uid mapping?
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Linux Containers <containers@lists.linux-foundation.org>,
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
From: =?UTF-8?Q?St=C3=A9phane_Graber?= via Containers
 <containers@lists.linux-foundation.org>
Reply-To: =?UTF-8?Q?St=C3=A9phane_Graber?= <stgraber@stgraber.org>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

T24gRnJpLCBBdWcgMjgsIDIwMjAgYXQgMTE6MjEgQU0gRXJpYyBXLiBCaWVkZXJtYW4KPGViaWVk
ZXJtQHhtaXNzaW9uLmNvbT4gd3JvdGU6Cj4KPgo+IFdlIGhhZCBhIGRpc2N1c3Npb24gaW4gdGhl
IGhhY2tyb29tIGF0IExQQyB0YWxraW5nIGFib3V0IHVzZSBjYXNlcyBmb3IKPiBhIHNoaWZ0ZnMg
c3R5bGUgc2V0dXAgd2hlcmUgdGhlcmUgYXJlIGRpZmZlcmVudCBtYXBwaW5ncyBvZiB1aWRzIHRv
Cj4gZGlzay4KPgo+IEluIHRoZSBkaXNjdXNzaW9uIHdlIGhhZCBhIGNvdXBsZSBvZiBpZGVhcyBv
ZiBrZXJuZWwgZGV2ZWxvcG1lbnRzCj4gd2Ugc2hvdWxkIGxvb2sgYXQgdGhhdCBhZGRyZXNzIHNv
bWUgb2YgdGhlc2UuCj4KPiAtIEZpeCBybGltaXRzIGluIHVzZXIgbmFtZXNwYWNlcyAoVGhpcyBw
b3RlbnRpYWxseSBhbGxvd3MgbXVsdGlwbGUKPiAgIGNvbnRhaW5lcnMgdG8gcnVuIHdpdGggdGhl
IHNhbWUgdXNlcmlkcyBzaW1wbGlmeWluZyB0aGUgbWFwcGluZwo+ICAgcHJvYmxlbSkuCj4KPiAt
IExvb2sgYXQgZXh0ZW5kaW5nIGt1aWRfdCB0byA2NGJpdHMgYW5kIHVzaW5nIHRoZSBoaWdoYml0
cyB0bwo+ICAgaW1wbGVtZW50IHVpZHMgdGhhdCBhcmUgcHJpdmF0ZSB0byB1c2VyIG5hbWVzcGFj
ZXMgYW5kIGRvbid0Cj4gICBtYXAgb3V0Lgo+Cj4gLSBMb29rIGF0IHdheXMgZm9yIGFsbG93aW5n
IHNldGdyb3VwcyB1bnByaXZpbGVnZWQuCj4KPgo+IFRvZ2V0aGVyIHRoaXMgaGFzIHRoZSBwb3Rl
bnRpYWwgdGhhdCB0aGUgZXhpc3RpbmcgdWlkICYgZ2lkIG1hcHBpbmdzCj4gd2lsbCBiZSBhYmxl
IHRvIGZ1bmN0aW9uIHRoZSBzYW1lIGFzIHRoZSBwcm9wb3NlZCBmdXNpZCBtYXBwaW5ncy4gRmlu
Z2VycyBjcm9zc2VkLgo+Cj4KPiBJIGhhZCBzb21lIHByb2JsZW1zIHdpdGggYXVkaW8gYW5kIGEg
bG90IG9mIHBlb3BsZSB3ZXJlIHRhbGtpbmcKPiBxdWlja2x5LiAgU28gSSBkaWQgbm90IG1hbmFn
ZSB0byBjYXB0dXJlIGV2ZXJ5b25lJ3MgdXNlIGNhc2VzLiAgIEFuZCBJCj4gZGVmaW5pdGVseSB3
YXMgbm90IGFibGUgdG8gc2VlIGhvdyBldmVyeW9uZSdzIHVzZSBjYXNlcyBpbnRlcmFjdGVkIHdp
dGgKPiB0aGUgY2hhbmdlcyB3ZSBhcmUgbG9va2luZyBhdC4KPgo+IEkga25vdyBmb3IgY2VydGFp
biBJIG1pc3NlZCBTZXJnZSdzIHVzZWNhc2UgKGFwb2xvZ2llcykuCj4KPiBDYW4gcGVvcGxlIGZv
bGxvdyB1cCB0byB0aGlzIGFuZCByZXBvcnQgdGhlaXIgdXNlIGNhc2VzPwo+Cj4gVGhlcmUgYXJl
IHNvbWUgcmVhbCBjaGFsbGVuZ2VzIGFuZCBJIHdvdWxkIGxpa2UgdG8gc2VlIGlmIHdlCj4gY2Fu
IHNvbHZlIHRoZW0sIHdoaWxlIGF2b2lkaW5nIHNjYXJ5IHByb2JsZW1zIGxpa2UgY2hhbmdpbmcK
PiB1aWRzIG9uIHdyaXRlLgo+Cj4gRXJpYwoKSGkgRXJpYywKCkl0IHdhcyBncmVhdCB0byBoYXZl
IHlvdSBhbmQgZXZlcnlvbmUgZWxzZSBwYXJ0aWNpcGF0ZSBpbiB0aGF0IHNlc3Npb24uClRoZXJl
IHdhcyBpbmRlZWQgYSBsb3QgY292ZXJlZCBpbiB0aGVyZSBhbmQgYSBsb3Qgb2YgdXNlIGNhc2Vz
IHdlJ2xsCmhhdmUgdG8ga2VlcCBpbiBtaW5kIQoKVGhlIG1haW4gb3V0Y29tZXMgd2UgY2FwdHVy
ZWQgSSBiZWxpZXZlIHdlcmU6CiAtIEZpeGluZyBybGltaXRzIGluIHVzZXIgbmFtZXNwYWNlcyBz
dWNoIHRoYXQgb25lIG5hbWVzcGFjZSBjYW5ub3QKYWZmZWN0IGFub3RoZXIKIC0gQ29uc2lkZXIg
c3dpdGNoaW5nIHRoZSBrZXJuZWwgdWlkL2dpdCB0eXBlcyB0byA2NGJpdCwgYWxsb3dpbmcgZm9y
CmEgaGlkZGVuIDMyYml0IGlkZW50aWZpZXIgYW5kIGZ1bGx5IHVzYWJsZSAzMmJpdCB1aWQvZ2lk
IHJhbmdlIGZvciB0aGUKY29udGFpbmVyCiAtIEZpbmQgYSB3YXkgdG8gYWxsb3cgc2V0Z3JvdXBz
KCkgaW4gYSB1c2VyIG5hbWVzcGFjZSB3aGlsZSBrZWVwaW5nCmluIG1pbmQgdGhlIGNhc2Ugb2Yg
Z3JvdXBzIHVzZWQgZm9yIG5lZ2F0aXZlIGFjY2VzcyBjb250cm9sCiAtIEFkZCBvcHRpb25hbCBl
bmZvcmNlbWVudCB0aGF0IG92ZXJmbG93IHVpZC9naWQgYXMgc2V0IHRocm91Z2gKc3lzY3RsIGNh
bm5vdCBiZSB1c2VkIGFzIHJlZ3VsYXIgdWlkL2dpZCBvbiB0aGUgc3lzdGVtCgpDaHJpc3RpYW4g
aXMgd29ya2luZyBvbiBhIGNvbXByZWhlbnNpdmUgc3VtbWFyeSBvZiB0aGUgc2Vzc2lvbiBiYXNl
ZApvbiB0aGUgc2hhcmVkIG5vdGVzIGRvY3VtZW50IHdlIGNpcmN1bGF0ZWQgYXQgdGhlIGJlZ2lu
bmluZyBvZiB0aGUKc2Vzc2lvbiB3aGljaCB3aWxsIHRyeSB0byBzZXBhcmF0ZSB0aGUgZGlmZmVy
ZW50IHRvcGljcyBhbmQgY292ZXIgdXNlCmNhc2VzIGFuZCBwb3RlbnRpYWwgc29sdXRpb25zIGZv
ciBlYWNoIGFzIHdlIGRpc2N1c3NlZCBpbiB0aGUgQm9GLgoKV2UnbGwgbWFrZSBzdXJlIHRoYXQg
ZXZlcnlvbmUgd2hvIGF0dGVuZGVkIHRoZSBCb0YgZ2V0cyBDQ2VkIG9uIHRoYXQsCm9uIHRvcCBv
ZiB0aGUgdXN1YWwgbWFpbGluZy1saXN0cyBzbyB0aGF0IHNob3VsZCBhbnkgb2YgdGhlIHVzZSBy
YWlzZWQKdXNlIGNhc2VzIGhhdmUgYmVlbiBtaXNzZWQgaW4gdGhlIG5vdGVzLCB0aG9zZSBmb2xr
cyBjYW4gcmFpc2UgdGhlbQphZ2FpbiBzbyB3ZSBkb24ndCBlbmQgdXAgbWlzc2luZyBhbnl0aGlu
ZyA6KQoKU3TDqXBoYW5lCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fCkNvbnRhaW5lcnMgbWFpbGluZyBsaXN0CkNvbnRhaW5lcnNAbGlzdHMubGludXgtZm91
bmRhdGlvbi5vcmcKaHR0cHM6Ly9saXN0cy5saW51eGZvdW5kYXRpb24ub3JnL21haWxtYW4vbGlz
dGluZm8vY29udGFpbmVycw==
