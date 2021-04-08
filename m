Return-Path: <SRS0=eD1A=JF=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7FB7C433ED
	for <containers@archiver.kernel.org>; Thu,  8 Apr 2021 16:23:07 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 463B3610D1
	for <containers@archiver.kernel.org>; Thu,  8 Apr 2021 16:23:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 463B3610D1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp4.osuosl.org (Postfix) with ESMTP id 0B5C541969;
	Thu,  8 Apr 2021 16:23:07 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp4.osuosl.org ([127.0.0.1])
	by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id sxSCAodLPK4u; Thu,  8 Apr 2021 16:23:05 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [IPv6:2605:bc80:3010:104::8cd3:938])
	by smtp4.osuosl.org (Postfix) with ESMTP id 0E0B640F46;
	Thu,  8 Apr 2021 16:23:05 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id D976EC000C;
	Thu,  8 Apr 2021 16:23:04 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [IPv6:2605:bc80:3010::138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 706EDC000A
 for <containers@lists.linux-foundation.org>;
 Thu,  8 Apr 2021 16:23:03 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp1.osuosl.org (Postfix) with ESMTP id 5773484190
 for <containers@lists.linux-foundation.org>;
 Thu,  8 Apr 2021 16:23:03 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp1.osuosl.org (amavisd-new);
 dkim=pass (1024-bit key) header.d=linux-foundation.org
Received: from smtp1.osuosl.org ([127.0.0.1])
 by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id o5NwF4IbWsjU
 for <containers@lists.linux-foundation.org>;
 Thu,  8 Apr 2021 16:23:02 +0000 (UTC)
X-Greylist: whitelisted by SQLgrey-1.8.0
Received: from mail-lj1-x233.google.com (mail-lj1-x233.google.com
 [IPv6:2a00:1450:4864:20::233])
 by smtp1.osuosl.org (Postfix) with ESMTPS id E152283EF7
 for <containers@lists.linux-foundation.org>;
 Thu,  8 Apr 2021 16:23:01 +0000 (UTC)
Received: by mail-lj1-x233.google.com with SMTP id u4so2991336ljo.6
 for <containers@lists.linux-foundation.org>;
 Thu, 08 Apr 2021 09:23:01 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=linux-foundation.org; s=google;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc:content-transfer-encoding;
 bh=6G3+OZqQp9tJwJbpfeOs5bop8D+dStV4QMNjNUA2tCA=;
 b=TtHskSvLyj69vK1NCJTAi43mfhUPjOkxPD6JbyziSbl7SJzch4R+8xG013pZQnNkeo
 MCi+JyVnrfhl3zL7fyFATmJrEoh6L3MqxEHNYC3Ir+EOyZhzDUDXGuKQ5QhVSoNnyyH1
 PoXSkpV6XJTxGofaxbR4HFXQygQ82aFV+tUZg=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc:content-transfer-encoding;
 bh=6G3+OZqQp9tJwJbpfeOs5bop8D+dStV4QMNjNUA2tCA=;
 b=n0GWwmpCuZst180SoNkCGQDjc97DMJ1Pw4B6meUPPzK9nwAwLKeVZQvqiSdu2rV0JW
 EDgNr/j9TGbJiqJ56Nf8izy7Ty5kbXw6a8qPDeI0NvYDHVa8O3YYjW7qy4talwbUboRS
 xqyRbouEVFiTKAgKhmrQG8JgmnjVU9PAUw5DDHG3s2ARHdNrvqXwr0MIvUt/lEMQJ1Tm
 SG1qc9PDwyrUQrcNF6BOBAlOyD6UrzR4w1b+/5IMPMbPbQP5pvnjwMxim0PKpKqkQ3BF
 cNvNrSdckrOMSyZFKF/sow/L5+G/MKGzt3xor/kNh63oYQ58rOJ/m4ah8iu1Th5o596s
 wIhg==
X-Gm-Message-State: AOAM5313qyvns6XOmCjlf0R6d7omlgO7/oNR/U1M23ZJVcsSwNiq3Ykn
 YWx1iOXsh7X4RRMND9d3AuM357B5EKlzMGaoKTc=
X-Google-Smtp-Source: ABdhPJzvLEGswipctRfoRLXzDsFRjJTMWJhrECMtlXXz2qRnOKbuKH3GR/minQxQ83XP7nzHTjahlw==
X-Received: by 2002:a2e:9cc4:: with SMTP id g4mr6420574ljj.34.1617898979244;
 Thu, 08 Apr 2021 09:22:59 -0700 (PDT)
Received: from mail-lj1-f170.google.com (mail-lj1-f170.google.com.
 [209.85.208.170])
 by smtp.gmail.com with ESMTPSA id c27sm1168325lfv.149.2021.04.08.09.22.57
 for <containers@lists.linux-foundation.org>
 (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
 Thu, 08 Apr 2021 09:22:57 -0700 (PDT)
Received: by mail-lj1-f170.google.com with SMTP id u4so2991208ljo.6
 for <containers@lists.linux-foundation.org>;
 Thu, 08 Apr 2021 09:22:57 -0700 (PDT)
X-Received: by 2002:a2e:a306:: with SMTP id l6mr4543789lje.251.1617898977209; 
 Thu, 08 Apr 2021 09:22:57 -0700 (PDT)
MIME-Version: 1.0
References: <7abe5ab608c61fc2363ba458bea21cf9a4a64588.1617814298.git.gladkov.alexey@gmail.com>
 <20210408083026.GE1696@xsang-OptiPlex-9020>
In-Reply-To: <20210408083026.GE1696@xsang-OptiPlex-9020>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 8 Apr 2021 09:22:40 -0700
X-Gmail-Original-Message-ID: <CAHk-=wigPx+MMQMQ-7EA0pq5_5+kMCNV4qFsOss-WwdCSQmb-w@mail.gmail.com>
Message-ID: <CAHk-=wigPx+MMQMQ-7EA0pq5_5+kMCNV4qFsOss-WwdCSQmb-w@mail.gmail.com>
Subject: Re: 08ed4efad6: stress-ng.sigsegv.ops_per_sec -41.9% regression
To: kernel test robot <oliver.sang@intel.com>
Cc: Jens Axboe <axboe@kernel.dk>, Feng Tang <feng.tang@intel.com>,
 0day robot <lkp@intel.com>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Jann Horn <jannh@google.com>, LKML <linux-kernel@vger.kernel.org>,
 Oleg Nesterov <oleg@redhat.com>, Linux-MM <linux-mm@kvack.org>,
 lkp@lists.01.org, "Eric W . Biederman" <ebiederm@xmission.com>, "Huang,
 Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>,
 zhengjun.xing@intel.com, Alexey Gladkov <legion@kernel.org>,
 Kees Cook <keescook@chromium.org>
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

T24gVGh1LCBBcHIgOCwgMjAyMSBhdCAxOjMyIEFNIGtlcm5lbCB0ZXN0IHJvYm90IDxvbGl2ZXIu
c2FuZ0BpbnRlbC5jb20+IHdyb3RlOgo+Cj4gRllJLCB3ZSBub3RpY2VkIGEgLTQxLjklIHJlZ3Jl
c3Npb24gb2Ygc3RyZXNzLW5nLnNpZ3NlZ3Yub3BzX3Blcl9zZWMgZHVlIHRvIGNvbW1pdAo+IDA4
ZWQ0ZWZhZDY4NCAoIltQQVRDSCB2MTAgNi85XSBSZWltcGxlbWVudCBSTElNSVRfU0lHUEVORElO
RyBvbiB0b3Agb2YgdWNvdW50cyIpCgpPdWNoLgoKSSAqdGhpbmsqIHRoaXMgdGVzdCBtYXkgYmUg
dGVzdGluZyAic2VuZCBzbyBtYW55IHNpZ25hbHMgdGhhdCBpdAp0cmlnZ2VycyB0aGUgc2lnbmFs
IHF1ZXVlIG92ZXJmbG93IGNhc2UiLgoKQW5kIEkgKnRoaW5rKiB0aGF0IHRoZSBwZXJmb3JtYW5j
ZSBkZWdyYWRhdGlvbiBtYXkgYmUgZHVlIHRvIGxvdHMgb2YKdW5uZWNlc3NhcnkgYWxsb2NhdGlv
bnMsIGJlY2F1c2UgaXR5IGxvb2tzIGxpa2UgdGhhdCBjb21taXQgY2hhbmdlcwpfX3NpZ3F1ZXVl
X2FsbG9jKCkgdG8gZG8KCiAgICAgICAgc3RydWN0IHNpZ3F1ZXVlICpxID0ga21lbV9jYWNoZV9h
bGxvYyhzaWdxdWV1ZV9jYWNoZXAsIGZsYWdzKTsKCipiZWZvcmUqIGNoZWNraW5nIHRoZSBzaWdu
YWwgbGltaXQsIGFuZCB0aGVuIGlmIHRoZSBzaWduYWwgbGltaXQgd2FzCmV4Y2VlZGVkLCBpdCB3
aWxsIGp1c3QgYmUgZnJlZSdkIGluc3RlYWQuCgpUaGUgb2xkIGNvZGUgd291bGQgY2hlY2sgdGhl
IHNpZ25hbCBjb3VudCBhZ2FpbnN0IFJMSU1JVF9TSUdQRU5ESU5HCipmaXJzdCosIGFuZCBpZiB0
aGVyZSB3ZXJlIG0gb3JlIHBlbmRpbmcgc2lnbmFscyB0aGVuIGl0IHdvdWxkbid0IGRvCmFueXRo
aW5nIGF0IGFsbCAoaW5jbHVkaW5nIG5vdCBpbmNyZW1lbnRpbmcgdGhhdCBleHBlbnNpdmUgYXRv
bWljCmNvdW50KS4KCkFsc28sIHRoZSBvbGQgY29kZSB3YXMgdmVyeSBjYXJlZnVsIHRvIG9ubHkg
ZG8gdGhlICJnZXRfdXNlcigpIiBmb3IKdGhlICpmaXJzdCogc2lnbmFsIGl0IGFkZGVkIHRvIHRo
ZSBxdWV1ZSwgYW5kIGRvIHRoZSAicHV0X3VzZXIoKSIgZm9yCndoZW4gcmVtb3ZpbmcgdGhlIGxh
c3Qgc2lnbmFsLiBFeGFjdGx5IGJlY2F1c2UgdGhvc2UgYXRvbWljcyBhcmUgdmVyeQpleHBlbnNp
dmUuCgpUaGUgbmV3IGNvZGUganVzdCBkb2VzIGEgbG90IG9mIHRoZXNlIGF0b21pY3MgdW5jb25k
aXRpb25hbGx5LgoKSSBkdW5uby4gVGhlIHByb2ZpbGUgZGF0YSBpbiB0aGVyZSBpcyBhIGJpdCBo
YXJkIHRvIHJlYWQsIGJ1dCB0aGVyZSdzCmEgbG90IG1vcmUgY2FjaGVlIG1pc3NlcywgYW5kIGEg
KmxvdCogb2Ygbm9kZSBjcm9zc2VyczoKCj4gICAgNTk2MTU0NCAgICAgICAgICArMTkwLjQlICAg
MTczMTQzNjEgICAgICAgIHBlcmYtc3RhdC5pLmNhY2hlLW1pc3Nlcwo+ICAgMjIxMDc0NjYgICAg
ICAgICAgKzExOS4yJSAgIDQ4NDU3NjU2ICAgICAgICBwZXJmLXN0YXQuaS5jYWNoZS1yZWZlcmVu
Y2VzCj4gICAgIDE2MzI5MiDEhSAgMyUgICArNDU4Mi4wJSAgICA3NjQ1NDEwICAgICAgICBwZXJm
LXN0YXQuaS5ub2RlLWxvYWQtbWlzc2VzCj4gICAgIDIyNzM4OCDEhSAgMiUgICArMzcwOC44JSAg
ICA4NjYwODI0ICAgICAgICBwZXJmLXN0YXQuaS5ub2RlLWxvYWRzCgphbmQgKHByb2JhYmx5IGFz
IGEgcmVzdWx0KSBhdmVyYWdlIGluc3RydWN0aW9uIGNvc3RzIGhhdmUgZ29uZSB1cCBlbm9ybW91
c2x5OgoKPiAgICAgICAzLjQ3ICAgICAgICAgICArNjYuOCUgICAgICAgNS43OSAgICAgICAgcGVy
Zi1zdGF0Lm92ZXJhbGwuY3BpCj4gICAgICAyMjg0OSAgICAgICAgICAgLTY1LjYlICAgICAgIDc4
NjYgICAgICAgIHBlcmYtc3RhdC5vdmVyYWxsLmN5Y2xlcy1iZXR3ZWVuLWNhY2hlLW1pc3NlcwoK
YW5kIGl0IGRvZXMgc2VlbSB0byBiZSBhdCBsZWFzdCBwYXJ0bHkgYWJvdXQgInB1dF91Y291bnRz
KCkiOgoKPiAgICAgICAwLjAwICAgICAgICAgICAgKzQuNSAgICAgICAgNC40NiAgICAgICAgcGVy
Zi1wcm9maWxlLmNhbGx0cmFjZS5jeWNsZXMtcHAucHV0X3Vjb3VudHMuX19zaWdxdWV1ZV9mcmVl
LmdldF9zaWduYWwuYXJjaF9kb19zaWduYWxfb3JfcmVzdGFydC5leGl0X3RvX3VzZXJfbW9kZV9w
cmVwYXJlCgphbmQgYSBsb3Qgb2YgImdldF91Y291bnRzKCkiLgoKQnV0IGl0IG1heSBhbHNvIGJl
IHRoYXQgdGhlIG5ldyAiZ2V0IHNpZ3BlbmRpbmciIGlzIGp1c3QgKnNvKiBtdWNoCm1vcmUgZXhw
ZW5zaXZlIHRoYW4gaXQgdXNlZCB0byBiZS4KCiAgICAgICAgICAgICAgIExpbnVzCl9fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCkNvbnRhaW5lcnMgbWFpbGlu
ZyBsaXN0CkNvbnRhaW5lcnNAbGlzdHMubGludXgtZm91bmRhdGlvbi5vcmcKaHR0cHM6Ly9saXN0
cy5saW51eGZvdW5kYXRpb24ub3JnL21haWxtYW4vbGlzdGluZm8vY29udGFpbmVycw==
