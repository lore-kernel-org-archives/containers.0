Return-Path: <SRS0=MeFG=EE=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.8 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,NICE_REPLY_A,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A578EC4363A
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 19:15:02 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id DC4292075E
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 19:15:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="i9kfCzOC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC4292075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 3301486BE9;
	Thu, 29 Oct 2020 19:15:01 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id o0Mvo1IyBGHK; Thu, 29 Oct 2020 19:14:59 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 20B8286BE1;
	Thu, 29 Oct 2020 19:14:59 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 11D54C088B;
	Thu, 29 Oct 2020 19:14:59 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 177DDC0051
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 19:14:58 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id E31F120532
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 19:14:57 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id bNgj9MmyIP-3
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 19:14:56 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-wm1-f68.google.com (mail-wm1-f68.google.com
 [209.85.128.68])
 by silver.osuosl.org (Postfix) with ESMTPS id DB3632037B
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 19:14:55 +0000 (UTC)
Received: by mail-wm1-f68.google.com with SMTP id a72so846859wme.5
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 12:14:55 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=cc:subject:to:references:from:message-id:date:user-agent
 :mime-version:in-reply-to:content-language:content-transfer-encoding;
 bh=tzpyO8iGd6ISqQqB76LQ2KRMJcjgxpyukpb6ZzZ/qvE=;
 b=i9kfCzOCGtS9KMw8oYc1qSbcxpwLdGZowXhT3dMtToGHcRX1ULk0IvYdInIlb3jvV8
 b+HMFAFpqgF/Ydf8YxHBhQFpUV6UDvanpuV13RBYXwiAzP7VoFPK9fuxLSZpsb8+Marf
 Ambv+Tz1gSb0pUjlxS9Sf1mdlZzZ53zzIb1hAQPBa0EvJwqZyZSwTg/6c/YcHahKHyyy
 39pN8cJSg3j8WRIRoYT+p7CSI41bzBeVjq4PuCbPwrlsSKkiSF1k+xUi/e781l3h6R8x
 lZGwor4THZFGSuv/Qly+7OOhiGXWJD5TlKHXhEYv8sfuZzTjQd8VNQsqEyn3Qmb/wDgn
 /0Mg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:cc:subject:to:references:from:message-id:date
 :user-agent:mime-version:in-reply-to:content-language
 :content-transfer-encoding;
 bh=tzpyO8iGd6ISqQqB76LQ2KRMJcjgxpyukpb6ZzZ/qvE=;
 b=Luy7+QzGUo++f9lWkpH3v773AF0RrpJyqX+rXBf+Eev0wjygWICJWMTQV4G7BUxh2M
 0Y9muyDBj3JGQCgYChuqNVHw/WsDsjgvhptiSWwhG/KUphgOy6K08ZiN41hHKeVsiSXN
 wfPtofhQz+GBrQ/h25MhtFOiPuKtz4Y+Y1Rx+SviN8nAR3okGv1cD/dKZ/Wjx69T/pAz
 GKOIxxf7aAdepPLlGmBCPfGVHuvw3q+JvGwnrb6F5+wVBMIvLPP+8iGoY0YgApplMXXM
 ddARgk5ShtK6oAVaMzlAMLBMw2bKbAdzt9YroPUACMBtt9mhOXqd5JQ8BQH3LWfhbLV6
 fcLA==
X-Gm-Message-State: AOAM532tHgJ7blLPqWJ/fgFilEof3i7Yai14CkuZA8SONbs2m3PuF6Vq
 8vJdHPk+zFb0m8dMTKg4Xd0=
X-Google-Smtp-Source: ABdhPJyMDfgiSIKtY0aILPTyTuQphrwaTfKpj58BkdDWPukoZrBGtNtR5YqHCMlsAzRuOSAyoLrlhA==
X-Received: by 2002:a1c:e4c1:: with SMTP id b184mr689291wmh.73.1603998894166; 
 Thu, 29 Oct 2020 12:14:54 -0700 (PDT)
Received: from ?IPv6:2001:a61:245a:d801:2e74:88ad:ef9:5218?
 ([2001:a61:245a:d801:2e74:88ad:ef9:5218])
 by smtp.gmail.com with ESMTPSA id u195sm1433563wmu.18.2020.10.29.12.14.52
 (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
 Thu, 29 Oct 2020 12:14:52 -0700 (PDT)
Subject: Re: For review: seccomp_user_notif(2) manual page [v2]
To: Jann Horn <jannh@google.com>, Kees Cook <keescook@chromium.org>
References: <63598b4f-6ce3-5a11-4552-cdfe308f68e4@gmail.com>
 <CAG48ez0fBE6AJfWh0in=WKkgt98y=KjAen=SQPyTYtvsUbF1yA@mail.gmail.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <93cfdc79-4c48-bceb-3620-4c63e9f4822e@gmail.com>
Date: Thu, 29 Oct 2020 20:14:51 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101
 Thunderbird/78.3.1
MIME-Version: 1.0
In-Reply-To: <CAG48ez0fBE6AJfWh0in=WKkgt98y=KjAen=SQPyTYtvsUbF1yA@mail.gmail.com>
Content-Language: en-US
Cc: Giuseppe Scrivano <gscrivan@redhat.com>, Song Liu <songliubraving@fb.com>,
 Will Drewry <wad@chromium.org>, Robert Sesek <rsesek@google.com>,
 Daniel Borkmann <daniel@iogearbox.net>, linux-man <linux-man@vger.kernel.org>,
 Containers <containers@lists.linux-foundation.org>,
 lkml <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
 mtk.manpages@gmail.com, bpf <bpf@vger.kernel.org>,
 Andy Lutomirski <luto@amacapital.net>,
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

SGVsbG8gSmFubiwKCk9uIDEwLzI5LzIwIDI6NDIgQU0sIEphbm4gSG9ybiB3cm90ZToKPiBPbiBN
b24sIE9jdCAyNiwgMjAyMCBhdCAxMDo1NSBBTSBNaWNoYWVsIEtlcnJpc2sgKG1hbi1wYWdlcykK
PiA8bXRrLm1hbnBhZ2VzQGdtYWlsLmNvbT4gd3JvdGU6Cj4+ICAgICAgICBzdGF0aWMgYm9vbAo+
PiAgICAgICAgZ2V0VGFyZ2V0UGF0aG5hbWUoc3RydWN0IHNlY2NvbXBfbm90aWYgKnJlcSwgaW50
IG5vdGlmeUZkLAo+PiAgICAgICAgICAgICAgICAgICAgICAgICAgY2hhciAqcGF0aCwgc2l6ZV90
IGxlbikKPj4gICAgICAgIHsKPj4gICAgICAgICAgICBjaGFyIHByb2NNZW1QYXRoW1BBVEhfTUFY
XTsKPj4KPj4gICAgICAgICAgICBzbnByaW50Zihwcm9jTWVtUGF0aCwgc2l6ZW9mKHByb2NNZW1Q
YXRoKSwgIi9wcm9jLyVkL21lbSIsIHJlcS0+cGlkKTsKPj4KPj4gICAgICAgICAgICBpbnQgcHJv
Y01lbUZkID0gb3Blbihwcm9jTWVtUGF0aCwgT19SRE9OTFkpOwo+PiAgICAgICAgICAgIGlmIChw
cm9jTWVtRmQgPT0gLTEpCj4+ICAgICAgICAgICAgICAgIGVyckV4aXQoIlx0Uzogb3BlbiIpOwo+
Pgo+PiAgICAgICAgICAgIC8qIENoZWNrIHRoYXQgdGhlIHByb2Nlc3Mgd2hvc2UgaW5mbyB3ZSBh
cmUgYWNjZXNzaW5nIGlzIHN0aWxsIGFsaXZlLgo+PiAgICAgICAgICAgICAgIElmIHRoZSBTRUND
T01QX0lPQ1RMX05PVElGX0lEX1ZBTElEIG9wZXJhdGlvbiAocGVyZm9ybWVkCj4+ICAgICAgICAg
ICAgICAgaW4gY2hlY2tOb3RpZmljYXRpb25JZElzVmFsaWQoKSkgc3VjY2VlZHMsIHdlIGtub3cg
dGhhdCB0aGUKPj4gICAgICAgICAgICAgICAvcHJvYy9QSUQvbWVtIGZpbGUgZGVzY3JpcHRvciB0
aGF0IHdlIG9wZW5lZCBjb3JyZXNwb25kcyB0byB0aGUKPj4gICAgICAgICAgICAgICBwcm9jZXNz
IGZvciB3aGljaCB3ZSByZWNlaXZlZCBhIG5vdGlmaWNhdGlvbi4gSWYgdGhhdCBwcm9jZXNzCj4+
ICAgICAgICAgICAgICAgc3Vic2VxdWVudGx5IHRlcm1pbmF0ZXMsIHRoZW4gcmVhZCgpIG9uIHRo
YXQgZmlsZSBkZXNjcmlwdG9yCj4+ICAgICAgICAgICAgICAgd2lsbCByZXR1cm4gMCAoRU9GKS4g
Ki8KPj4KPj4gICAgICAgICAgICBjaGVja05vdGlmaWNhdGlvbklkSXNWYWxpZChub3RpZnlGZCwg
cmVxLT5pZCk7Cj4+Cj4+ICAgICAgICAgICAgLyogUmVhZCBieXRlcyBhdCB0aGUgbG9jYXRpb24g
Y29udGFpbmluZyB0aGUgcGF0aG5hbWUgYXJndW1lbnQKPj4gICAgICAgICAgICAgICAoaS5lLiwg
dGhlIGZpcnN0IGFyZ3VtZW50KSBvZiB0aGUgbWtkaXIoMikgY2FsbCAqLwo+Pgo+PiAgICAgICAg
ICAgIHNzaXplX3QgbnJlYWQgPSBwcmVhZChwcm9jTWVtRmQsIHBhdGgsIGxlbiwgcmVxLT5kYXRh
LmFyZ3NbMF0pOwo+PiAgICAgICAgICAgIGlmIChucmVhZCA9PSAtMSkKPj4gICAgICAgICAgICAg
ICAgZXJyRXhpdCgicHJlYWQiKTsKPiAKPiBBcyBkaXNjdXNzZWQgYXQKPiA8aHR0cHM6Ly9sb3Jl
Lmtlcm5lbC5vcmcvci9DQUc0OGV6MG00WTI0WkJaQ2grVGY0T1JNbTlfcTRuN1ZPenBHandHRjdf
RmU4RVFIPVFAbWFpbC5nbWFpbC5jb20+LAo+IHdlIG5lZWQgdG8gcmUtY2hlY2sgY2hlY2tOb3Rp
ZmljYXRpb25JZElzVmFsaWQoKSBhZnRlciByZWFkaW5nIHJlbW90ZQo+IG1lbW9yeSBidXQgYmVm
b3JlIHVzaW5nIHRoZSByZWFkIHZhbHVlIGluIGFueSB3YXkuIE90aGVyd2lzZSwgdGhlCj4gc3lz
Y2FsbCBjb3VsZCBpbiB0aGUgbWVhbnRpbWUgZ2V0IGludGVycnVwdGVkIGJ5IGEgc2lnbmFsIGhh
bmRsZXIsIHRoZQo+IHNpZ25hbCBoYW5kbGVyIGNvdWxkIHJldHVybiwgYW5kIHRoZW4gdGhlIGZ1
bmN0aW9uIHRoYXQgcGVyZm9ybWVkIHRoZQo+IHN5c2NhbGwgY291bGQgZnJlZSgpIGFsbG9jYXRp
b25zIG9yIHJldHVybiAodGhlcmVieSBmcmVlaW5nIGJ1ZmZlcnMgb24KPiB0aGUgc3RhY2spLgo+
IAo+IEluIGVzc2VuY2UsIHRoaXMgcHJlYWQoKSBpcyAodW5hdm9pZGFibHkpIGEgcG90ZW50aWFs
IHVzZS1hZnRlci1mcmVlCj4gcmVhZDsgYW5kIHRvIG1ha2UgdGhhdCBub3QgaGF2ZSBhbnkgc2Vj
dXJpdHkgaW1wYWN0LCB3ZSBuZWVkIHRvIGNoZWNrCj4gd2hldGhlciBVQUYgcmVhZCBvY2N1cnJl
ZCBiZWZvcmUgdXNpbmcgdGhlIHJlYWQgdmFsdWUuIFRoaXMgc2hvdWxkCj4gcHJvYmFibHkgYmUg
Y2FsbGVkIG91dCBlbHNld2hlcmUgaW4gdGhlIG1hbnBhZ2UsIHRvby4uLgo+IAo+IE5vdywgb2Yg
Y291cnNlLCAqKnJlYWRpbmcqKiBpcyB0aGUgZWFzeSBjYXNlLiBUaGUgZGlmZmljdWx0IGNhc2Ug
aXMgaWYKPiB3ZSBoYXZlIHRvICoqd3JpdGUqKiB0byB0aGUgcmVtb3RlIHByb2Nlc3MuLi4gYmVj
YXVzZSB0aGVuIHdlIGNhbid0Cj4gcGxheSBnYW1lcyBsaWtlIHRoYXQuIElmIHdlIHdyaXRlIGRh
dGEgdG8gYSBmcmVlZCBwb2ludGVyLCB3ZSdyZQo+IHNjcmV3ZWQsIHRoYXQncyBpdC4gKEFuZCBm
b3Igc29tZXdoYXQgdW5yZWxhdGVkIGJvbnVzIGZ1biwgY29uc2lkZXIKPiB0aGF0IC9wcm9jLyRw
aWQvbWVtIGlzIG9yaWdpbmFsbHkgaW50ZW5kZWQgZm9yIHByb2Nlc3MgZGVidWdnaW5nLAo+IGlu
Y2x1ZGluZyBpbnN0YWxsaW5nIGJyZWFrcG9pbnRzLCBhbmQgd2lsbCB0aGVyZWZvcmUgaGFwcGls
eSB3cml0ZQo+IG92ZXIgInJlYWRvbmx5IiBwcml2YXRlIG1hcHBpbmdzLCBzdWNoIGFzIHR5cGlj
YWwgbWFwcGluZ3Mgb2YKPiBleGVjdXRhYmxlIGNvZGUuKQo+IAo+IFNvLCB1dXV1aC4uLiBJIGd1
ZXNzIGlmIGFueW9uZSB3YW50cyB0byBhY3R1YWxseSB3cml0ZSBtZW1vcnkgYmFjayB0bwo+IHRo
ZSB0YXJnZXQgcHJvY2Vzcywgd2UnZCBiZXR0ZXIgY29tZSB1cCB3aXRoIHNvbWUgZGVkaWNhdGVk
IEFQSSBmb3IKPiB0aGF0LCB1c2luZyBhbiBpb2N0bCBvbiB0aGUgc2VjY29tcCBmZCB0aGF0IG1h
Z2ljYWxseSBmcmVlemVzIHRoZQo+IHRhcmdldCBwcm9jZXNzIGluc2lkZSB0aGUgc3lzY2FsbCB3
aGlsZSB3cml0aW5nIHRvIGl0cyBtZW1vcnksIG9yCj4gc29tZXRoaW5nIGxpa2UgdGhhdD8gQW5k
IHVudGlsIHRoZW4sIHRoZSBtYW5wYWdlIHNob3VsZCBoYXZlIGEgYmlnIGZhdAo+IHdhcm5pbmcg
dGhhdCB3cml0aW5nIHRvIHRoZSB0YXJnZXQncyBtZW1vcnkgaXMgc2ltcGx5IG5vdCBwb3NzaWJs
ZQo+IChzYWZlbHkpLgoKVGhhbmsgeW91IGZvciB5b3VyIHZlcnkgY2xlYXIgZXhwbGFuYXRpb24h
IEl0IHR1cm5lZCBvdXQgdG8gYmUgCnRyaXZpYWxseSBlYXN5IHRvIGRlbW9uc3RyYXRlIHRoaXMg
aXNzdWUgd2l0aCBhIHNsaWdodGx5IG1vZGlmaWVkCnZlcnNpb24gb2YgbXkgcHJvZ3JhbS4KCkFz
IHdlbGwgYXMgdGhlIGNoYW5nZSB0byB0aGUgY29kZSBleGFtcGxlIHRoYXQgSSBhbHJlYWR5IG1l
bnRpb25lZApteSByZXBseSBvZiBhIGZldyBob3VycyBhZ28sIEkndmUgYWRkZWQgdGhlIGZvbGxv
d2luZyB0ZXh0IHRvIHRoZSAKcGFnZToKCiAgIENhdmVhdHMgcmVnYXJkaW5nIHRoZSB1c2Ugb2Yg
L3Byb2MvW3RpZF0vbWVtCiAgICAgICBUaGUgZGlzY3Vzc2lvbiBhYm92ZSBub3RlZCB0aGUgbmVl
ZCB0byB1c2UgdGhlCiAgICAgICBTRUNDT01QX0lPQ1RMX05PVElGX0lEX1ZBTElEIGlvY3RsKDIp
IHdoZW4gb3BlbmluZyB0aGUKICAgICAgIC9wcm9jL1t0aWRdL21lbSBmaWxlIG9mIHRoZSB0YXJn
ZXQgdG8gYXZvaWQgdGhlIHBvc3NpYmlsaXR5IG9mCiAgICAgICBhY2Nlc3NpbmcgdGhlIG1lbW9y
eSBvZiB0aGUgd3JvbmcgcHJvY2VzcyBpbiB0aGUgZXZlbnQgdGhhdCB0aGUKICAgICAgIHRhcmdl
dCB0ZXJtaW5hdGVzIGFuZCBpdHMgSUQgaXMgcmVjeWNsZWQgYnkgYW5vdGhlciAodW5yZWxhdGVk
KQogICAgICAgdGhyZWFkLiAgSG93ZXZlciwgdGhlIHVzZSBvZiB0aGlzIGlvY3RsKDIpIG9wZXJh
dGlvbiBpcyBhbHNvCiAgICAgICBuZWNlc3NhcnkgaW4gb3RoZXIgc2l0dWF0aW9ucywgYXMgZXhw
bGFpbmVkIGluIHRoZSBmb2xsb3dpbmcKICAgICAgIHBhcmdyYXBocy4KCiAgICAgICBDb25zaWRl
ciB0aGUgZm9sbG93aW5nIHNjZW5hcmlvLCB3aGVyZSB0aGUgc3VwZXJ2aXNvciB0cmllcyB0bwog
ICAgICAgcmVhZCB0aGUgcGF0aG5hbWUgYXJndW1lbnQgb2YgYSB0YXJnZXQncyBibG9ja2VkIG1v
dW50KDIpIHN5c3RlbQogICAgICAgY2FsbDoKCiAgICAgICDigKIgRnJvbSBvbmUgb2YgaXRzIGZ1
bmN0aW9ucyAoZnVuYygpKSwgdGhlIHRhcmdldCBjYWxscyBtb3VudCgyKSwKICAgICAgICAgd2hp
Y2ggdHJpZ2dlcnMgYSB1c2VyLXNwYWNlIG5vdGlmaWNhdGlvbiBhbmQgY2F1c2VzIHRoZSB0YXJn
ZXQKICAgICAgICAgdG8gYmxvY2suCgogICAgICAg4oCiIFRoZSBzdXBlcnZpc29yIHJlY2VpdmVz
IHRoZSBub3RpZmljYXRpb24sIG9wZW5zCiAgICAgICAgIC9wcm9jL1t0aWRdL21lbSwgYW5kIChz
dWNjZXNzZnVsbHkpIHBlcmZvcm1zIHRoZQogICAgICAgICBTRUNDT01QX0lPQ1RMX05PVElGX0lE
X1ZBTElEIGNoZWNrLgoKICAgICAgIOKAoiBUaGUgdGFyZ2V0IHJlY2VpdmVzIGEgc2lnbmFsLCB3
aGljaCBjYXVzZXMgdGhlIG1vdW50KDIpIHRvCiAgICAgICAgIGFib3J0LgoKICAgICAgIOKAoiBU
aGUgc2lnbmFsIGhhbmRsZXIgZXhlY3V0ZXMgaW4gdGhlIHRhcmdldCwgYW5kIHJldHVybnMuCgog
ICAgICAg4oCiIFVwb24gcmV0dXJuIGZyb20gdGhlIGhhbmRsZXIsIHRoZSBleGVjdXRpb24gb2Yg
ZnVuYygpIHJlc3VtZXMsCiAgICAgICAgIGFuZCBpdCByZXR1cm5zIChhbmQgcGVyaGFwcyBvdGhl
ciBmdW5jdGlvbnMgYXJlIGNhbGxlZCwKICAgICAgICAgb3ZlcndyaXRpbmcgdGhlIG1lbW9yeSB0
aGF0IGhhZCBiZWVuIHVzZWQgZm9yIHRoZSBzdGFjayBmcmFtZQogICAgICAgICBvZiBmdW5jKCkp
LgoKICAgICAgIOKAoiBVc2luZyB0aGUgYWRkcmVzcyBwcm92aWRlZCBpbiB0aGUgbm90aWZpY2F0
aW9uIGluZm9ybWF0aW9uLCB0aGUKICAgICAgICAgc3VwZXJ2aXNvciByZWFkcyBmcm9tIHRoZSB0
YXJnZXQncyBtZW1vcnkgbG9jYXRpb24gdGhhdCB1c2VkIHRvCiAgICAgICAgIGNvbnRhaW4gdGhl
IHBhdGhuYW1lLgoKICAgICAgIOKAoiBUaGUgc3VwZXJ2aXNvciBub3cgY2FsbHMgbW91bnQoMikg
d2l0aCBzb21lIGFyYml0cmFyeSBieXRlcwogICAgICAgICBvYnRhaW5lZCBpbiB0aGUgcHJldmlv
dXMgc3RlcC4KCiAgICAgICBUaGUgY29uY2x1c2lvbiBmcm9tIHRoZSBhYm92ZSBzY2VuYXJpbyBp
cyB0aGlzOiBzaW5jZSB0aGUKICAgICAgIHRhcmdldCdzIGJsb2NrZWQgc3lzdGVtIGNhbGwgbWF5
IGJlIGludGVycnVwdGVkIGJ5IGEgc2lnbmFsCiAgICAgICBoYW5kbGVyLCB0aGUgc3VwZXJ2aXNv
ciBtdXN0IGJlIHdyaXR0ZW4gdG8gZXhwZWN0IHRoYXQgdGhlIHRhcmdldAogICAgICAgbWF5IGFi
YW5kb24gaXRzIHN5c3RlbSBjYWxsIGF0IGFueSB0aW1lOyBpbiBzdWNoIGFuIGV2ZW50LCBhbnkK
ICAgICAgIGluZm9ybWF0aW9uIHRoYXQgdGhlIHN1cGVydmlzb3Igb2J0YWluZWQgZnJvbSB0aGUg
dGFyZ2V0J3MgbWVtb3J5CiAgICAgICBtdXN0IGJlIGNvbnNpZGVyZWQgaW52YWxpZC4KCiAgICAg
ICBUbyBwcmV2ZW50IHN1Y2ggc2NlbmFyaW9zLCBldmVyeSByZWFkIGZyb20gdGhlIHRhcmdldCdz
IG1lbW9yeQogICAgICAgbXVzdCBiZSBzZXBhcmF0ZWQgZnJvbSB1c2Ugb2YgdGhlIGJ5dGVzIHNv
IG9idGFpbmVkIGJ5IGEKICAgICAgIFNFQ0NPTVBfSU9DVExfTk9USUZfSURfVkFMSUQgY2hlY2su
ICBJbiB0aGUgYWJvdmUgZXhhbXBsZSwgdGhlCiAgICAgICBjaGVjayB3b3VsZCBiZSBwbGFjZWQg
YmV0d2VlbiB0aGUgdHdvIGZpbmFsIHN0ZXBzLiAgQW4gZXhhbXBsZSBvZgogICAgICAgc3VjaCBh
IGNoZWNrIGlzIHNob3duIGluIEVYQU1QTEVTLgoKICAgICAgIEZvbGxvd2luZyBvbiBmcm9tIHRo
ZSBhYm92ZSwgaXQgc2hvdWxkIGJlIGNsZWFyIHRoYXQgYSB3cml0ZSBieQogICAgICAgdGhlIHN1
cGVydmlzb3IgaW50byB0aGUgdGFyZ2V0J3MgbWVtb3J5IGNhbiBuZXZlciBiZSBjb25zaWRlcmVk
CiAgICAgICBzYWZlLgoKU2VlbSBva2F5PwoKQnkgdGhlIHdheSwgaXMgdGhlcmUgYW55IGFuYWxv
Z291cyBraW5kIG9mIGlzc3VlIGNvbmNlcm5pbmcKcGlkZmRfZ2V0ZmQoKT8gSSdtIHRoaW5raW5n
IG5vdCwgYnV0IEkgd29uZGVyIGlmIEkndmUgbWlzc2VkCnNvbWV0aGluZy4KCkNoZWVycywKCk1p
Y2hhZWwKCi0tIApNaWNoYWVsIEtlcnJpc2sKTGludXggbWFuLXBhZ2VzIG1haW50YWluZXI7IGh0
dHA6Ly93d3cua2VybmVsLm9yZy9kb2MvbWFuLXBhZ2VzLwpMaW51eC9VTklYIFN5c3RlbSBQcm9n
cmFtbWluZyBUcmFpbmluZzogaHR0cDovL21hbjcub3JnL3RyYWluaW5nLwpfX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpDb250YWluZXJzIG1haWxpbmcgbGlz
dApDb250YWluZXJzQGxpc3RzLmxpbnV4LWZvdW5kYXRpb24ub3JnCmh0dHBzOi8vbGlzdHMubGlu
dXhmb3VuZGF0aW9uLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2NvbnRhaW5lcnM=
