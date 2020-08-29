Return-Path: <SRS0=ibnv=CH=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7B03C433E6
	for <containers@archiver.kernel.org>; Sat, 29 Aug 2020 15:48:32 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 9FC3620707
	for <containers@archiver.kernel.org>; Sat, 29 Aug 2020 15:48:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=sargun.me header.i=@sargun.me header.b="k7Rx1dzo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9FC3620707
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sargun.me
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 745E487DB2;
	Sat, 29 Aug 2020 15:48:32 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id rPgH4hZ1aCTt; Sat, 29 Aug 2020 15:48:31 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id BD30687D5D;
	Sat, 29 Aug 2020 15:48:31 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id ABA9EC07FF;
	Sat, 29 Aug 2020 15:48:31 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 483E4C0051
 for <containers@lists.linux-foundation.org>;
 Sat, 29 Aug 2020 15:48:30 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 3204884D3A
 for <containers@lists.linux-foundation.org>;
 Sat, 29 Aug 2020 15:48:30 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id TrPESLzpCXeN
 for <containers@lists.linux-foundation.org>;
 Sat, 29 Aug 2020 15:48:29 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from mail-ed1-f65.google.com (mail-ed1-f65.google.com
 [209.85.208.65])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 18CCB8486F
 for <containers@lists.linux-foundation.org>;
 Sat, 29 Aug 2020 15:48:29 +0000 (UTC)
Received: by mail-ed1-f65.google.com with SMTP id ay8so1730554edb.8
 for <containers@lists.linux-foundation.org>;
 Sat, 29 Aug 2020 08:48:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sargun.me; s=google;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=64FN1MGxhBWlNF4OVlX0wMFKnJlgUYNSyVxv7Q1pPo0=;
 b=k7Rx1dzobIX6aQK68EIO125za9REv/tKzSmvOJsTEbTdORCYfyxPnCZw76HogwspKa
 oX++2gKzn9oTfxfE7K7rSwRNSXsj8fQvVOEvcsPUsDUviPPIx3Cqr6xv24FhD+7PlNi8
 5TT9WxRWnECSFDTgGmi+8qW8ahUxE2mOtLB/c=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=64FN1MGxhBWlNF4OVlX0wMFKnJlgUYNSyVxv7Q1pPo0=;
 b=hBfXmX7iu5YeRX/JYaAydewrNO67AoIbtNKzgvPbJ+dHyp3sJHx+VCoY86avPxw4AM
 Nxbwi27fmJbziImG6Ue2F+gPgrvgMPf4G0Et7pz58cPaM/l8XWu7ZmplKVLIc/apmsk2
 P48CCQ+SEJXZ68O66ngl5iNa9pVSfVCWbI4+5MkxldFNj82A/DwT5s5SWvnavwnvjBHr
 TrxEVJEiN4oy8OFJ5b5KFtflSC/zWO+bRgTahDvbwNmCkwIKw6vjbNr4y8zN64lj+UPX
 3hrVE/NIICm3j+tYMk/Xp1BgPZ4kc50bLRi+Fcxfmg9MROgY49TGj0Y8LnlDUWcskRjt
 WicA==
X-Gm-Message-State: AOAM530PUzbEseAXJxk07VmXAVel0EplFkQWDPcMrK/roTqipkFww54s
 tvpfPHY28pd4p7byBOE6UVlBhmlCypAD7a3rDJiTNlaryycTWA==
X-Google-Smtp-Source: ABdhPJxKZJiaAQZfxxzd1r42MrxASEuooxd+Rd2LI8Gcysn1tys9iyEksvon0AdGBff2SOOv6BxcvCQ2S5QDLPyohfI=
X-Received: by 2002:a17:906:3609:: with SMTP id
 q9mr4020781ejb.138.1598715672580; 
 Sat, 29 Aug 2020 08:41:12 -0700 (PDT)
MIME-Version: 1.0
References: <CAOQ4uxjXZdXZAaeiJ_p9n7NJziBv2yvWqSDs0hDd1ONUrVKxOQ@mail.gmail.com>
 <87tuwmiy4j.fsf@x220.int.ebiederm.org>
 <20200828155849.k46uk3x63aio3g3o@yavin.dot.cyphar.com>
In-Reply-To: <20200828155849.k46uk3x63aio3g3o@yavin.dot.cyphar.com>
From: Sargun Dhillon <sargun@sargun.me>
Date: Sat, 29 Aug 2020 08:40:36 -0700
Message-ID: <CAMp4zn83CwpfuFq7+JSkYGZmFC03pUrt_30Wzn42AxqAaSDSpg@mail.gmail.com>
Subject: Re: Overlayfs @Plumbers
To: Aleksa Sarai <asarai@suse.de>
Cc: Linux Containers <containers@lists.linux-foundation.org>,
 "Eric W. Biederman" <ebiederm@xmission.com>,
 overlayfs <linux-unionfs@vger.kernel.org>
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

On Fri, Aug 28, 2020 at 8:59 AM Aleksa Sarai <asarai@suse.de> wrote:
>
> On 2020-08-28, Eric W. Biederman <ebiederm@xmission.com> wrote:
> > Amir Goldstein <amir73il@gmail.com> writes:
> >
> > > Hi Guys,
> > >
> > > It's been nice to virtually meet with you yesterday.
> > > Some of you wanted to follow up on overlayfs related issues.
> > >
> > > If you want to discuss, try to find me in one of the
> > > https://meet.2020.linuxplumbersconf.org/hackrooms
> > > today between 16:00-17:00 UTC
> > > (No need to enter the room to see who's inside)
> > >
> > > If those times do not work for you, contact me and we can try
> > > to schedule another time.
> >
> > Did this conversation wind up happening?  Do we need to reschedule?
>
> This conversation already happened in a Hackroom on Tuesday. I'm not
> sure if the Hackrooms will have their recordings published, so maybe
> Amir can post any of the takeaways we had?
>
> --
> Aleksa Sarai
> Senior Software Engineer (Containers)
> SUSE Linux GmbH
> <https://www.cyphar.com/>

I unfortunately missed this conversation. I wanted to bring up OverlayFS, and
ephemeral upper dirs. We use overlayfs with Docker containers, and we waste
a lot of time on writing things back to disk.

We're not so peeved about the fact that OVL does any sync operations, as that's
what our users have been used to. The big problem is on unmount, ovelfs decides
syncing the upperdirs is a good idea. IIRC, this regression was
introduced somewhere
in the 4.X series.

We've been carrying a patch to short-circuit this behaviour for a while now:
https://github.com/Netflix-Skunkworks/linux/commit/edb195d9b73cc22d095078010a14a690f41ee253

I know that this behaviour (and any behaviour that short-circuits
O_SYNC / FUA is
technically "wrong", but in this case, can we make an exception? I originally
thought about using device mapper to remove the FUA bit from all BIOs, but it
turns out that my underlying storage *always* persists data to disk,
so every write
takes...a long time.

Amir, what's your take?
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
