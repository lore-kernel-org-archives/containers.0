Return-Path: <SRS0=pmWk=IR=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EEC1CC433DB
	for <containers@archiver.kernel.org>; Fri, 19 Mar 2021 10:06:57 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 817C764E1F
	for <containers@archiver.kernel.org>; Fri, 19 Mar 2021 10:06:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 817C764E1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kinvolk.io
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp1.osuosl.org (Postfix) with ESMTP id 2B46B83A65;
	Fri, 19 Mar 2021 10:06:57 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp1.osuosl.org ([127.0.0.1])
	by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id VEXF5JsVAXAE; Fri, 19 Mar 2021 10:06:56 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [IPv6:2605:bc80:3010:104::8cd3:938])
	by smtp1.osuosl.org (Postfix) with ESMTP id 532CB83A55;
	Fri, 19 Mar 2021 10:06:55 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 289A1C000A;
	Fri, 19 Mar 2021 10:06:55 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [IPv6:2605:bc80:3010::137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 1BA13C0001
 for <containers@lists.linux-foundation.org>;
 Fri, 19 Mar 2021 10:06:53 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp4.osuosl.org (Postfix) with ESMTP id 0A0D04EB95
 for <containers@lists.linux-foundation.org>;
 Fri, 19 Mar 2021 10:06:53 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp4.osuosl.org (amavisd-new);
 dkim=pass (1024-bit key) header.d=kinvolk.io
Received: from smtp4.osuosl.org ([127.0.0.1])
 by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id sGqFUcQrak9c
 for <containers@lists.linux-foundation.org>;
 Fri, 19 Mar 2021 10:06:51 +0000 (UTC)
X-Greylist: whitelisted by SQLgrey-1.8.0
Received: from mail-lf1-x12c.google.com (mail-lf1-x12c.google.com
 [IPv6:2a00:1450:4864:20::12c])
 by smtp4.osuosl.org (Postfix) with ESMTPS id 9DBD64E59F
 for <containers@lists.linux-foundation.org>;
 Fri, 19 Mar 2021 10:06:51 +0000 (UTC)
Received: by mail-lf1-x12c.google.com with SMTP id q29so9051312lfb.4
 for <containers@lists.linux-foundation.org>;
 Fri, 19 Mar 2021 03:06:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kinvolk.io; s=google;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc:content-transfer-encoding;
 bh=8XzLArLsyk3g5rpI/3JDxf1hyv3KFABRme1zPfvsqFk=;
 b=FX0/ylSlO99cEwowCNM90yJ8AptNYb4gYqODKqjHRomDfA7cyKYnMM+IN1KcmGDw/U
 Gk3BB3yjASGpiRxvFsZnPQjMWyv0u4A2n2sQ92f29IkGZFoCtVx4sLWVoCw/MSljyEcp
 dTW0iStFiRjUhhwzFqsY2Yf5XTkXwRd3BWgCw=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc:content-transfer-encoding;
 bh=8XzLArLsyk3g5rpI/3JDxf1hyv3KFABRme1zPfvsqFk=;
 b=uJT6J08UghMdaMDR0X5i3gOzmntwEXJOCyPnT7dA51JF98RWJfZejN6DWn/2qs+adR
 QbkxN+6cJzTVUjnPhk0pDsEWhlB3Lm8bkhkoAMeUc0v6QXc7h7mZrWZYBqNALd2DtZaM
 qfGfCSvhEvU88XBMSxLZq69q/38j1CCnqwwUUCcdwDgImaQ8J3B2Pq5VMNRSrnLzcpoG
 jNs/Un3SqgQ+tFtBigM7ELAyG3+RSkYNZIEdX1SJO3J/llBWpU+eOIihwtwzcmL5fG6J
 LBjh52v8vCK5159IAERK7flYtFx7WMVxudXEyt5h5bO86OndD+BUxL7UAwib8+FOYb5o
 kYjw==
X-Gm-Message-State: AOAM530rcxFFQ3pyL+0eLexEKpxx3HyfH2kmoVbgYxgRx47/5VZtUmk8
 cbUW7NkbakjQAtFamQs+RSxwO0tmVHu/X79760vhzw==
X-Google-Smtp-Source: ABdhPJyxThMXX8UYrDYd7Tzd5ZgGipqDmmdnDErvXETNp0XlpsA95sItuyuDrQLEOGSsyWBVaT2OT36Z5epdn8RRQh4=
X-Received: by 2002:a05:6512:33cc:: with SMTP id
 d12mr332009lfg.487.1616148409546; 
 Fri, 19 Mar 2021 03:06:49 -0700 (PDT)
MIME-Version: 1.0
References: <CAMp4zn9oEb6bJJLQWjSE1AFg6TqwkF3FOvFk2VSkKd+0Kj7TCg@mail.gmail.com>
 <20210301110907.2qoxmiy55gpkgwnq@wittgenstein>
 <20210301132156.in3z53t5xxy3ity5@wittgenstein>
 <202103011515.3A941F6@keescook> <20210318145454.d2xbetk2werv7j2u@wittgenstein>
 <20210318203912.GA26982@ircssh-2.c.rugged-nimbus-611.internal>
In-Reply-To: <20210318203912.GA26982@ircssh-2.c.rugged-nimbus-611.internal>
From: Rodrigo Campos <rodrigo@kinvolk.io>
Date: Fri, 19 Mar 2021 11:06:13 +0100
Message-ID: <CACaBj2b1nQMeyQmKNFDB0Z=xkoZmHnFc91ssBX-9UKYwY8r3Gw@mail.gmail.com>
Subject: Re: seccomp: Delay filter activation
To: Sargun Dhillon <sargun@sargun.me>
Cc: Giuseppe Scrivano <gscrivan@redhat.com>, Kees Cook <keescook@chromium.org>,
 Keerti Lakshminarayan <keerti@netflix.com>,
 Linux Containers List <containers@lists.linux-foundation.org>,
 LKML <linux-kernel@vger.kernel.org>,
 Hariharan Ananthakrishnan <hari@netflix.com>,
 Kyle Anderson <kylea@netflix.com>, Andy Lutomirski <luto@amacapital.net>
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

T24gVGh1LCBNYXIgMTgsIDIwMjEgYXQgOTozOSBQTSBTYXJndW4gRGhpbGxvbiA8c2FyZ3VuQHNh
cmd1bi5tZT4gd3JvdGU6Cj4gSSBiZWxpZXZlIHRoYXQgdGhlIE9DSSBzcGVjWzJdIGlzIGdvaW5n
IHRvIHJ1biBpbnRvIHRoaXMgY2xhc3Mgb2YgcHJvYmxlbSB1bmxlc3MKPiB3ZSBpbnRyb2R1Y2Ug
YW4gb3V0IG9mIGJhbmQgc2lnbmFsaW5nIG1lY2hhbmlzbS4gSSB0aGluayBhIHZhbGlkIHdheSB0
byBoYW5kbGUKPiB0aGlzIGlzIGRvIGEgc2VuZCgpIG9mIHRoZSBmZCBudW1iZXIgKGxpdGVyYWwp
LCBhbmQgd2FpdCBmb3IgdGhlIG90aGVyIHNpZGUgdG8KPiBwaWRmZF9nZXRmZCB0aGUgc2VjY29t
cCBmaWx0ZXIsIGFuZCB3YWl0IGZvciB0aGUgc29ja2V0IHRvIGJlIGNsb3NlZCB0byBjb250aW51
ZSwKPiBidXQgSSB0aGluayB3ZSBzaG91bGQgbWF5YmUgY3JlYXRlIGFuIGV4YW1wbGUgKEkgdm9s
dW50ZWVyKSBzaG93aW5nIGhvdyB0byBkbyB0aGlzLgoKV2VsbCwgd2UgY3JlYXRlZCBhIHJ1bmMg
aW1wbGVtZW50YXRpb24gZm9yIHRoYXQgT0NJIHNwZWMgY2hhbmdlIGFuZCB3ZQpoaXQgZXhhY3Rs
eSB0aGF0WzFdLgoKcnVuYyBoYXMgYSBwaXBlIG1lY2hhbmlzbSB0byBjb21tdW5pY2F0ZSBhbHJl
YWR5LCBzbyB3ZSB1c2UgdGhhdC4gV2hhdAp3ZSBkbyBpczogZG8gdGhlIHNlY2NvbXAgc3lzY2Fs
bCwgc2VuZCB0aGUgcGxhaW4gZmQgbnVtYmVyIG92ZXIgdGhlCnBpcGUgYW5kIHRoZSBwYXJlbnQg
Z2V0cyB0aGUgZmQgd2l0aCBwaWRmZF9nZXRmZCgpWzJdLiBXZSB1c2UgdGhlIHBpcGUKdG8gc3lu
Yywgc28gbm8gaXNzdWVzIHdpdGggdGhhdCBwYXJ0LgoKQnV0LCBvZiBjb3Vyc2UsIGlmIHRoZSBz
ZWNjb21wIGZpbHRlciBibG9ja3MgdGhlIHN5c2NhbGwgdG8gc2VuZCBvdmVyCnRoZSBwaXBlLCB0
aGlzIGZhaWxzLgoKQ2hyaXN0aWFuLCBjYW4geW91IHBsZWFzZSBlbGFib3JhdGUgb24gaG93IHlv
dSBzb2x2ZSB0aGlzIG9uIGx4ZD8gSSdtCmN1cmlvdXMgdG8gdW5kZXJzdGFuZCBpZiB3ZSBjYW4g
dXNlIHRoZSBzYW1lIGluIHJ1bmMgb3Igbm90LgoKClsxXTogaHR0cHM6Ly9naXRodWIuY29tL29w
ZW5jb250YWluZXJzL3J1bmMvcHVsbC8yNjgyClsyXTogaHR0cHM6Ly9naXRodWIuY29tL29wZW5j
b250YWluZXJzL3J1bmMvcHVsbC8yNjgyL2ZpbGVzI2RpZmYtZjAyMTRhMGYxNjQwOGZjN2YxNjhj
NmZjOTgzN2QxODk1OTAwMjVjYzE4MTNlYmY3YzFkNzUxMTM2OTM2ZGZiZlIxNzIKLS0gClJvZHJp
Z28gQ2FtcG9zCi0tLQpLaW52b2xrIEdtYkggfCBBZGFsYmVydHN0ci42YSwgMTA5OTkgQmVybGlu
IHwgdGVsOiArNDkxNzU1NTg5MzY0Ckdlc2Now6RmdHNmw7xocmVyL0RpcmVjdG9yczogQWxiYW4g
Q3JlcXV5LCBDaHJpcyBLw7xobCwgSWFnbyBMw7NwZXogR2FsZWlyYXMKUmVnaXN0ZXJnZXJpY2h0
L0NvdXJ0IG9mIHJlZ2lzdHJhdGlvbjogQW10c2dlcmljaHQgQ2hhcmxvdHRlbmJ1cmcKUmVnaXN0
ZXJudW1tZXIvUmVnaXN0cmF0aW9uIG51bWJlcjogSFJCIDE3MTQxNCBCClVzdC1JRC1OdW1tZXIv
VkFUIElEIG51bWJlcjogREUzMDIyMDcwMDAKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX18KQ29udGFpbmVycyBtYWlsaW5nIGxpc3QKQ29udGFpbmVyc0BsaXN0
cy5saW51eC1mb3VuZGF0aW9uLm9yZwpodHRwczovL2xpc3RzLmxpbnV4Zm91bmRhdGlvbi5vcmcv
bWFpbG1hbi9saXN0aW5mby9jb250YWluZXJz
