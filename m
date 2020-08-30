Return-Path: <SRS0=zxUI=CI=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8ED8C433E7
	for <containers@archiver.kernel.org>; Sun, 30 Aug 2020 11:38:09 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id B43CD207DA
	for <containers@archiver.kernel.org>; Sun, 30 Aug 2020 11:38:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="CCZpTSX8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B43CD207DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 832D086072;
	Sun, 30 Aug 2020 11:38:09 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id rQbmC4m2s4Mi; Sun, 30 Aug 2020 11:38:08 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id E657F86044;
	Sun, 30 Aug 2020 11:38:08 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id DCF25C07FF;
	Sun, 30 Aug 2020 11:38:08 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id A8DFEC0051
 for <containers@lists.linux-foundation.org>;
 Sun, 30 Aug 2020 11:38:07 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 9911286061
 for <containers@lists.linux-foundation.org>;
 Sun, 30 Aug 2020 11:38:07 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id TJ65qcVJVLCn
 for <containers@lists.linux-foundation.org>;
 Sun, 30 Aug 2020 11:38:06 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-il1-f193.google.com (mail-il1-f193.google.com
 [209.85.166.193])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 98F9F86044
 for <containers@lists.linux-foundation.org>;
 Sun, 30 Aug 2020 11:38:06 +0000 (UTC)
Received: by mail-il1-f193.google.com with SMTP id h11so1484071ilj.11
 for <containers@lists.linux-foundation.org>;
 Sun, 30 Aug 2020 04:38:06 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=3C2VhaDgHqk43asHwygaKOqge31MS0kwvc1z6NYH8+0=;
 b=CCZpTSX8jlDPdgTyrOW4tgJKgVJIJssBtIh0D9RESUBL/pZftdAI9nj+5Vyl7xPmtG
 vnr4nfYOiQj9GUTu5//EjtVWoNimkeiRFIajv3aqGqR06tteWLrhawdEJqzpEzI3FETF
 9wD7uaEGck9I6ZkF0nV1vBa6Ow32Ql4Pt8DOTU75t0M3BZ6Rd68oQGM0TAptsz+ZY0qa
 q8bFe9cF7S6ATvrqFxtG1laG2VU1IsAleQ5Mmhb0laJsxN3Huu1i7pIIgLd/ABx0d+gS
 fsasPqDaepCQaYYayGbAcGw7ndpEjNie9+AQv3YE4vz+vkk7iwfD1Y9V+JWlK9ZCcl5b
 x3DQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=3C2VhaDgHqk43asHwygaKOqge31MS0kwvc1z6NYH8+0=;
 b=PCmlJnyQ4f1++WyTbf01QS7H3LTovUw9X4KM22fQZf/ls9XGZTwwbir99XgbC2L7Uz
 SeYQDx40y9DUxgJy6m3hnePJ1b5dcqD805e4PHITQybK8JSn5PcpNPd8YLUcSp9yfNZd
 +TZBzAh3s6Z8ewJYyvBayblDHAGpHwUDaoMybR44GLr0uqtYlbXyM7QTtBPbFGOWu4U9
 N0msenfZnB2H363Q7zmo+X4y4i0xTWlNdY5JyIjaAQUP5mJpwEjizDA4zX2aaMfOx24h
 VVa+6HiAk4cItQKcv0vsy92PQIXCfvXTWDzH5o9drGoOAzp0YIVpx7XhK17NgC95X1RV
 iMBg==
X-Gm-Message-State: AOAM533of0in6BPrs6m716ECb+5EzBuRz6lPfM5DNxiNXA0b0ya1Iola
 VG+70c6bF4vCNOcuZofpJvRh7utrWSvtNGble9s=
X-Google-Smtp-Source: ABdhPJy1b/FW+fRcXbt0qLdxNH5gFdTYR9ZUs9GDbJUKN3kLSWICKqqQqIYZeRKpcWY8ENE6yVJKARIiCrAowr/r6nU=
X-Received: by 2002:a05:6e02:dc3:: with SMTP id
 l3mr5570878ilj.137.1598787485963; 
 Sun, 30 Aug 2020 04:38:05 -0700 (PDT)
MIME-Version: 1.0
References: <CAOQ4uxjXZdXZAaeiJ_p9n7NJziBv2yvWqSDs0hDd1ONUrVKxOQ@mail.gmail.com>
 <87tuwmiy4j.fsf@x220.int.ebiederm.org>
 <20200828155849.k46uk3x63aio3g3o@yavin.dot.cyphar.com>
 <CAMp4zn83CwpfuFq7+JSkYGZmFC03pUrt_30Wzn42AxqAaSDSpg@mail.gmail.com>
In-Reply-To: <CAMp4zn83CwpfuFq7+JSkYGZmFC03pUrt_30Wzn42AxqAaSDSpg@mail.gmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Sun, 30 Aug 2020 14:37:54 +0300
Message-ID: <CAOQ4uxiQ9KguY+x71C-D8O_Gi4-H6gGoPdkQM0LxoaB=F4RzDQ@mail.gmail.com>
Subject: Re: Overlayfs @Plumbers
To: Sargun Dhillon <sargun@sargun.me>
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

On Sat, Aug 29, 2020 at 6:41 PM Sargun Dhillon <sargun@sargun.me> wrote:
>
> On Fri, Aug 28, 2020 at 8:59 AM Aleksa Sarai <asarai@suse.de> wrote:
> >
> > On 2020-08-28, Eric W. Biederman <ebiederm@xmission.com> wrote:
> > > Amir Goldstein <amir73il@gmail.com> writes:
> > >
> > > > Hi Guys,
> > > >
> > > > It's been nice to virtually meet with you yesterday.
> > > > Some of you wanted to follow up on overlayfs related issues.
> > > >
> > > > If you want to discuss, try to find me in one of the
> > > > https://meet.2020.linuxplumbersconf.org/hackrooms
> > > > today between 16:00-17:00 UTC
> > > > (No need to enter the room to see who's inside)
> > > >
> > > > If those times do not work for you, contact me and we can try
> > > > to schedule another time.
> > >
> > > Did this conversation wind up happening?  Do we need to reschedule?
> >
> > This conversation already happened in a Hackroom on Tuesday. I'm not
> > sure if the Hackrooms will have their recordings published, so maybe
> > Amir can post any of the takeaways we had?
> >
> > --
> > Aleksa Sarai
> > Senior Software Engineer (Containers)
> > SUSE Linux GmbH
> > <https://www.cyphar.com/>
>
> I unfortunately missed this conversation. I wanted to bring up OverlayFS, and
> ephemeral upper dirs. We use overlayfs with Docker containers, and we waste
> a lot of time on writing things back to disk.
>
> We're not so peeved about the fact that OVL does any sync operations, as that's
> what our users have been used to. The big problem is on unmount, ovelfs decides
> syncing the upperdirs is a good idea. IIRC, this regression was
> introduced somewhere
> in the 4.X series.
>
> We've been carrying a patch to short-circuit this behaviour for a while now:
> https://github.com/Netflix-Skunkworks/linux/commit/edb195d9b73cc22d095078010a14a690f41ee253
>
> I know that this behaviour (and any behaviour that short-circuits
> O_SYNC / FUA is
> technically "wrong", but in this case, can we make an exception? I originally
> thought about using device mapper to remove the FUA bit from all BIOs, but it
> turns out that my underlying storage *always* persists data to disk,
> so every write
> takes...a long time.
>
> Amir, what's your take?

It's not only FUA that is causing slow down.
syncfs() takes internal filesystem locks (e.g. to commit a journal transaction),
so it causes interference with other writers on the same underlying filesystem.

As Giuseppe pointed out, a patch has already been submitted to address
this issue.

Thanks,
Amir.
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
