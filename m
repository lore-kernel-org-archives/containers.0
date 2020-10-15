Return-Path: <SRS0=BJMF=DW=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,NICE_REPLY_A,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D1DBC433DF
	for <containers@archiver.kernel.org>; Thu, 15 Oct 2020 11:24:10 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 9EA1C2080A
	for <containers@archiver.kernel.org>; Thu, 15 Oct 2020 11:24:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GA8BbyLO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9EA1C2080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 2178587F89;
	Thu, 15 Oct 2020 11:24:09 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id TteppgRmCjBO; Thu, 15 Oct 2020 11:24:08 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id AD94587F6D;
	Thu, 15 Oct 2020 11:24:08 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 982D5C0052;
	Thu, 15 Oct 2020 11:24:08 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 36A82C0051
 for <containers@lists.linux-foundation.org>;
 Thu, 15 Oct 2020 11:24:07 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 25D4C885CF
 for <containers@lists.linux-foundation.org>;
 Thu, 15 Oct 2020 11:24:07 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id BotjXa5zrzvz
 for <containers@lists.linux-foundation.org>;
 Thu, 15 Oct 2020 11:24:06 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-wr1-f68.google.com (mail-wr1-f68.google.com
 [209.85.221.68])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 434D0885A9
 for <containers@lists.linux-foundation.org>;
 Thu, 15 Oct 2020 11:24:06 +0000 (UTC)
Received: by mail-wr1-f68.google.com with SMTP id n6so2937299wrm.13
 for <containers@lists.linux-foundation.org>;
 Thu, 15 Oct 2020 04:24:06 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=cc:subject:to:references:from:message-id:date:user-agent
 :mime-version:in-reply-to:content-language:content-transfer-encoding;
 bh=3I0P08vNaQzgXoL9rCvvnpgGw7KyV9D8ViZvp/Lcn6s=;
 b=GA8BbyLOTTUBvhKPL+heprvfYzsNBiCMAxJMYy0/AJJtI0lP01IeXgRR8yWgnVEDLc
 8ldtbGqRI9P2uAUoL03HFwi5dWLVFJnZ3Aetj62avK/6Mo5xxpfsMHQy2BrvzpkyQgaR
 uYAskzZaFS+t+kkUVZJBnOeWGt4EqF/javGOQVJ2uEApe97rh5U5Zk16xL7XRhfYKPLE
 gtlsZvRXR0yfy9w9K8KFZp2zpixzNvKFfpTMhfHa/BcFgiuoc/POCluJybykDFIyfpXd
 gzaDaIDqZS7MuqVxMLrzVTye//Cs00bcFZpKDMZ/jlpPKK2iL+Hn5ImKPj5RW+deFPMY
 1PvQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:cc:subject:to:references:from:message-id:date
 :user-agent:mime-version:in-reply-to:content-language
 :content-transfer-encoding;
 bh=3I0P08vNaQzgXoL9rCvvnpgGw7KyV9D8ViZvp/Lcn6s=;
 b=LOrKSplofhwRMtM1B6nGBrii0wq3ObC3EnKrgl1JJZmNG7YMY4fVv4CgX9mfRrEskd
 EkgnTsik6hlSFOpORnTVIkecBZZ7706MzUv/3h5K1zEr9DLf8yp8tp3qcdMgLEH71j4q
 kbMJ36kwsmxYYoLJeUxwWg5kDQoKXa3sI6f0shZ0KKTc26O4MjQi4r7muBOKB9r1TUxE
 Edzk8vXtyU5UQxCVfnKiZv9B/mehR0rcunGUiUwsN6wcLyxwUsw9Fd10XBBjpob12FhW
 D7uxFR7kw+5CetXXYhikU6ztdLj2jFcXEYlnI1E2yjfrG9R+VJqmjuqZua4Mdzwd819r
 df2g==
X-Gm-Message-State: AOAM533ASaz4DRMmu81Njv3VWBw8DK9lLnEuYReGJmvzWBwdiD/qldse
 OZ+/2SOeY7fGReZt848YA3g=
X-Google-Smtp-Source: ABdhPJzb6M1OrC9nHpzbrwyV+nSGdr5lyNygxRFdgLbzIwScpgFYrjGw7EHJFCs1NG0j4AIYHz91Hw==
X-Received: by 2002:a05:6000:18d:: with SMTP id
 p13mr3770081wrx.248.1602761044681; 
 Thu, 15 Oct 2020 04:24:04 -0700 (PDT)
Received: from [192.168.1.10] (static-176-175-73-29.ftth.abo.bbox.fr.
 [176.175.73.29])
 by smtp.gmail.com with ESMTPSA id t83sm4373249wmf.39.2020.10.15.04.24.03
 (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
 Thu, 15 Oct 2020 04:24:03 -0700 (PDT)
Subject: Re: For review: seccomp_user_notif(2) manual page
To: Kees Cook <keescook@chromium.org>
References: <45f07f17-18b6-d187-0914-6f341fe90857@gmail.com>
 <202009301632.9C6A850272@keescook>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <c1cc0df8-bd06-51e7-d5a0-888c1955683b@gmail.com>
Date: Thu, 15 Oct 2020 13:24:03 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101
 Thunderbird/68.11.0
MIME-Version: 1.0
In-Reply-To: <202009301632.9C6A850272@keescook>
Content-Language: en-US
Cc: linux-man <linux-man@vger.kernel.org>, Song Liu <songliubraving@fb.com>,
 wad@chromium.org, Robert Sesek <rsesek@google.com>,
 Daniel Borkmann <daniel@iogearbox.net>, Jann Horn <jannh@google.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 lkml <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
 mtk.manpages@gmail.com, Giuseppe Scrivano <gscrivan@redhat.com>,
 bpf@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>,
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

SGVsbG8gS2VlcywKCk9uIDEwLzEvMjAgMTozOSBBTSwgS2VlcyBDb29rIHdyb3RlOgo+IE9uIFdl
ZCwgU2VwIDMwLCAyMDIwIGF0IDAxOjA3OjM4UE0gKzAyMDAsIE1pY2hhZWwgS2VycmlzayAobWFu
LXBhZ2VzKSB3cm90ZToKPj4gWy4uLl0gSSBkaWQgOi0pCj4gCj4gWWF5ISBUaGFuayB5b3UhCgpZ
b3UncmUgd2VsY29tZSA6LSkKCj4+IFsuLi5dCj4+ICAgIE92ZXJ2aWV3Cj4+ICAgICAgICBJbiBj
b252ZW50aW9uYWwgdXNhZ2Ugb2YgYSBzZWNjb21wIGZpbHRlciwgdGhlIGRlY2lzaW9uIGFib3V0
IGhvdwo+PiAgICAgICAgdG8gIHRyZWF0ICBhIHBhcnRpY3VsYXIgc3lzdGVtIGNhbGwgaXMgbWFk
ZSBieSB0aGUgZmlsdGVyIGl0c2VsZi4KPj4gICAgICAgIFRoZSB1c2VyLXNwYWNlIG5vdGlmaWNh
dGlvbiBtZWNoYW5pc20gYWxsb3dzIHRoZSBoYW5kbGluZyBvZiAgdGhlCj4+ICAgICAgICBzeXN0
ZW0gIGNhbGwgIHRvICBpbnN0ZWFkICBiZSBoYW5kZWQgb2ZmIHRvIGEgdXNlci1zcGFjZSBwcm9j
ZXNzLgo+PiAgICAgICAgVGhlIGFkdmFudGFnZXMgb2YgZG9pbmcgdGhpcyBhcmUgdGhhdCwgYnkg
Y29udHJhc3Qgd2l0aCB0aGUgIHNlY+KAkAo+PiAgICAgICAgY29tcCAgZmlsdGVyLCAgd2hpY2gg
IGlzICBydW5uaW5nIG9uIGEgdmlydHVhbCBtYWNoaW5lIGluc2lkZSB0aGUKPj4gICAgICAgIGtl
cm5lbCwgdGhlIHVzZXItc3BhY2UgcHJvY2VzcyBoYXMgYWNjZXNzIHRvIGluZm9ybWF0aW9uIHRo
YXQgIGlzCj4+ICAgICAgICB1bmF2YWlsYWJsZSB0byB0aGUgc2VjY29tcCBmaWx0ZXIgYW5kIGl0
IGNhbiBwZXJmb3JtIGFjdGlvbnMgdGhhdAo+PiAgICAgICAgY2FuJ3QgYmUgcGVyZm9ybWVkIGZy
b20gdGhlIHNlY2NvbXAgZmlsdGVyLgo+IAo+IEkgbWlnaHQgY2xhcmlmeSBhIGJpdCB3aXRoIHNv
bWV0aGluZyBsaWtlICh0aG91Z2ggbWF5YmUgdGhlCj4gdGFyZ2V0L3N1cGVydmlzb3IgcGFyYWdy
YXBoIG5lZWRzIHRvIGJlIG1vdmVkIHRvIHRoZSBzdGFydCk6Cj4gCj4gCVRoaXMgaXMgdXNlZCBm
b3IgcGVyZm9ybWluZyBzeXNjYWxscyBvbiBiZWhhbGYgb2YgdGhlIHRhcmdldCwKPiAJcmF0aGVy
IHRoYW4gaGF2aW5nIHRoZSBzdXBlcnZpc29yIG1ha2Ugc2VjdXJpdHkgcG9saWN5IGRlY2lzaW9u
cwo+IAlhYm91dCB0aGUgc3lzY2FsbCwgd2hpY2ggd291bGQgYmUgaW5oZXJlbnRseSByYWNlLXBy
b25lLiBUaGUKPiAJdGFyZ2V0J3Mgc3lzY2FsbCBzaG91bGQgZWl0aGVyIGJlIGhhbmRsZWQgYnkg
dGhlIHN1cGVydmlzb3Igb3IKPiAJYWxsb3dlZCB0byBjb250aW51ZSBub3JtYWxseSBpbiB0aGUg
a2VybmVsICh3aGVyZSBzdGFuZGFyZCBzZWN1cml0eQo+IAlwb2xpY2llcyB3aWxsIGJlIGFwcGxp
ZWQpLgoKWW91LCBDaHJpc3RpYW4sIGFuZCBKYW5uIGFsbCBwdWxsZWQgbWUgdXAgb24gdGhpcyBw
b2ludC4gQW5kIHRoYW5rczsgCkknbSBnb2luZyB0byB1c2Ugc29tZSBvZiB5b3VyIHdvcmRzIGFi
b3ZlLiBTZWUgbXkgcmVwbHkgdG8gSmFubiwgc2VudAphdCBhYm91dCB0aGUgc2FtZSB0aW1lIGFz
IHRoaXMgcmVwbHkuIFBsZWFzZSB0YWtlIGEgbG9vayBhdCB0aGUgdGV4dAppbiBteSByZXBseSB0
byBKYW5uLCBhbmQgbGV0IG1lIGtub3cgd2hhdCB5b3UgdGhpbmsuCgo+IEknbGwgY29tbWVudCBt
b3JlIGxhdGVyLCBidXQgSSd2ZSBydW4gb3V0IG9mIHRpbWUgdG9kYXkgYW5kIEkgZGlkbid0IHNl
ZQo+IGFueW9uZSBtZW50aW9uIHRoaXMgZGV0YWlsIHlldCBpbiB0aGUgZXhpc3RpbmcgdGhyZWFk
cy4uLiA6KQoKTGF0ZXIgbmV2ZXIgY2FtZSA6LSkuIEJ1dCwgSSBob3BlIHlvdSBtYXkgaGF2ZSBj
b21tZW50cyBmb3IgdGhlIApuZXh0IGRyYWZ0LCB3aGljaCBJIHdpbGwgc2VuZCBvdXQgc29vbi4K
ClRoYW5rcywKCk1pY2hhZWwKCi0tIApNaWNoYWVsIEtlcnJpc2sKTGludXggbWFuLXBhZ2VzIG1h
aW50YWluZXI7IGh0dHA6Ly93d3cua2VybmVsLm9yZy9kb2MvbWFuLXBhZ2VzLwpMaW51eC9VTklY
IFN5c3RlbSBQcm9ncmFtbWluZyBUcmFpbmluZzogaHR0cDovL21hbjcub3JnL3RyYWluaW5nLwpf
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpDb250YWluZXJz
IG1haWxpbmcgbGlzdApDb250YWluZXJzQGxpc3RzLmxpbnV4LWZvdW5kYXRpb24ub3JnCmh0dHBz
Oi8vbGlzdHMubGludXhmb3VuZGF0aW9uLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2NvbnRhaW5lcnM=
