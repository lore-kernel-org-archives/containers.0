Return-Path: <SRS0=hUL4=EF=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.8 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,NICE_REPLY_A,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64BAEC55178
	for <containers@archiver.kernel.org>; Fri, 30 Oct 2020 20:08:03 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A0787206F7
	for <containers@archiver.kernel.org>; Fri, 30 Oct 2020 20:08:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="YcN9bdqu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A0787206F7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 02B5D86C6D;
	Fri, 30 Oct 2020 20:08:02 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id eARPgHbw_yRV; Fri, 30 Oct 2020 20:08:00 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 0347C84AE2;
	Fri, 30 Oct 2020 20:07:59 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id E0298C0859;
	Fri, 30 Oct 2020 20:07:59 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id DF10AC0051
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Oct 2020 20:07:58 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id D8D8B86CEB
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Oct 2020 20:07:58 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id ej8h+GvtNjKu
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Oct 2020 20:07:58 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-wm1-f68.google.com (mail-wm1-f68.google.com
 [209.85.128.68])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 0622386CE9
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Oct 2020 20:07:58 +0000 (UTC)
Received: by mail-wm1-f68.google.com with SMTP id e2so4016643wme.1
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Oct 2020 13:07:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=cc:subject:to:references:from:message-id:date:user-agent
 :mime-version:in-reply-to:content-language:content-transfer-encoding;
 bh=FpCslJZ/vqty4l/vz2YpbZGTlDZJ7cQIaDs0z8MBb9Q=;
 b=YcN9bdquotAjnrthfpW3IwHIEkgx6h42SlkjKXvr0CpceHRxdmjmaYllQhz0bPMBZt
 3icp020XsDQDBucbMTtt1SU6D/cUzNLj1NRRgq8OKrrZCDmSBnhhJcGGWoLyYP/5AtoJ
 XlnMFNSB4iOVvfOQ16M14Dd8tGmwatI/40hvL8dPt7tuMQAURvwDrISXwJgwyBzhXfbg
 XzLdvwZP+9ZhFYrcn+lKV0mwT63/XGHADrurSBn6/tQg0CPWeJcMklmELuSNJ/RBT/+S
 MEZRpvWfuwB3oCbxo8nlbfgbaqv8p+IF4/SA+AqrZB1jyW1tt3hVIbzxQLqEB/4VA4Kq
 8/HQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:cc:subject:to:references:from:message-id:date
 :user-agent:mime-version:in-reply-to:content-language
 :content-transfer-encoding;
 bh=FpCslJZ/vqty4l/vz2YpbZGTlDZJ7cQIaDs0z8MBb9Q=;
 b=Uz5fZ7hknJ4ZEfRIGB40qcvf5WlBSe75eo2ITSlJccVtUxT+9j6cQgcVrMFqKIp56i
 bolt0OOfgPqfoULCzxlud4gcHlf52CiGzCRUvfi5EO2IX4Z1nbz8s2/Vb6qdwhd85HrE
 nv0bUinVXTQ1EYgr1j8ubvv0WROOiMX0Mn+StC9EK9IkVhZ/MqDbJLod6MNfxiP57zKR
 cQp4nrXJSHLEit3vk4weJCGoavaIRU8lj2LmonE6BhpEstsnPBBn1dELueqJhsvW0tRI
 ue4Wz3y64MZXLdEqn/ybMu4DfgVB9hyc2WkRHZ3YqYn9LbvNjbO5RgOUz7655dL1n8S3
 qg4w==
X-Gm-Message-State: AOAM5328CauKH4PjT0SOFdOrcc4qRr+3SBkkPHz+YQeO43ZuUoQ8mUVJ
 yG79jJMxseQUt+FRVD6DI2Q=
X-Google-Smtp-Source: ABdhPJztQtotCRmX3fj5tBmhKO5lYUgAvoZG+N03iU1161n3w8ULxgpWHp87pzLrq1ac+M8i05ZZQQ==
X-Received: by 2002:a1c:c90b:: with SMTP id f11mr4614649wmb.54.1604088476501; 
 Fri, 30 Oct 2020 13:07:56 -0700 (PDT)
Received: from ?IPv6:2001:a61:245a:d801:2e74:88ad:ef9:5218?
 ([2001:a61:245a:d801:2e74:88ad:ef9:5218])
 by smtp.gmail.com with ESMTPSA id j9sm11929205wrp.59.2020.10.30.13.07.54
 (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
 Fri, 30 Oct 2020 13:07:55 -0700 (PDT)
Subject: Re: For review: seccomp_user_notif(2) manual page [v2]
To: Jann Horn <jannh@google.com>
References: <63598b4f-6ce3-5a11-4552-cdfe308f68e4@gmail.com>
 <20201029152609.k3urvzjocf3s7uml@gmail.com>
 <91b74ce1-de95-2b92-c62e-e2715d6071d3@gmail.com>
 <CAG48ez0TZrwBoEi4d6n+FUN19hq6Pc+DOGNrRb-zHDSZVm9kfw@mail.gmail.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <f610cecf-d824-3501-e188-357efd9b1c76@gmail.com>
Date: Fri, 30 Oct 2020 21:07:54 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101
 Thunderbird/78.3.1
MIME-Version: 1.0
In-Reply-To: <CAG48ez0TZrwBoEi4d6n+FUN19hq6Pc+DOGNrRb-zHDSZVm9kfw@mail.gmail.com>
Content-Language: en-US
Cc: Giuseppe Scrivano <gscrivan@redhat.com>, Song Liu <songliubraving@fb.com>,
 Will Drewry <wad@chromium.org>, Kees Cook <keescook@chromium.org>,
 Daniel Borkmann <daniel@iogearbox.net>, linux-man <linux-man@vger.kernel.org>,
 Robert Sesek <rsesek@google.com>,
 Containers <containers@lists.linux-foundation.org>,
 lkml <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
 Christian Brauner <christian.brauner@canonical.com>, mtk.manpages@gmail.com,
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
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

On 10/30/20 8:24 PM, Jann Horn wrote:
> On Thu, Oct 29, 2020 at 8:53 PM Michael Kerrisk (man-pages)
> <mtk.manpages@gmail.com> wrote:
>> On 10/29/20 4:26 PM, Christian Brauner wrote:
>>> I like this manpage. I think this is the most comprehensive explanation
>>> of any seccomp feature
>>
>> Thanks (at least, I think so...)
>>
>>> and somewhat understandable.
>>       ^^^^^^^^
>>
>> (... but I'm not sure ;-).)
> 
> Relevant: http://tinefetz.net/files/gimgs/78_78_17.jpg

Perfekt :-).


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
