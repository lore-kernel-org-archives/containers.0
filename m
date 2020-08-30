Return-Path: <SRS0=zxUI=CI=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3DD88C433E6
	for <containers@archiver.kernel.org>; Sun, 30 Aug 2020 11:44:38 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 03D01207DA
	for <containers@archiver.kernel.org>; Sun, 30 Aug 2020 11:44:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="LQSaD244"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 03D01207DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id C2E7687E78;
	Sun, 30 Aug 2020 11:44:37 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id wwwhkdl7Firs; Sun, 30 Aug 2020 11:44:36 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id C4C3287E6F;
	Sun, 30 Aug 2020 11:44:36 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id AEAAFC07FF;
	Sun, 30 Aug 2020 11:44:36 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 5AE3CC0051
 for <containers@lists.linux-foundation.org>;
 Sun, 30 Aug 2020 11:44:35 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 50A338444E
 for <containers@lists.linux-foundation.org>;
 Sun, 30 Aug 2020 11:44:35 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id wGEIg+R5Huzk
 for <containers@lists.linux-foundation.org>;
 Sun, 30 Aug 2020 11:44:34 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-io1-f48.google.com (mail-io1-f48.google.com
 [209.85.166.48])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 018A784442
 for <containers@lists.linux-foundation.org>;
 Sun, 30 Aug 2020 11:44:33 +0000 (UTC)
Received: by mail-io1-f48.google.com with SMTP id g13so3295792ioo.9
 for <containers@lists.linux-foundation.org>;
 Sun, 30 Aug 2020 04:44:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=90nqvY3TIGZlTWEomvS5xRC/YzJhv+Jw7sidT1nz8MA=;
 b=LQSaD244VrR+3VJ53dxHl+z+SsJ4Gv99iqjb3MzyqdYTOV0GQxPSLp+/I+FE4uZdmy
 Y4A9zrhkp3fPzeZrIdex2Hv0EXNSLn4D0aXYfhkg0dzX/P3psYNJKXmwMHX8i1ENtYdm
 b31PXWJkscY/XeiilliFEgzavMg8sYYCsRIa/W318Hxj2PT0qnEXico+HLhF2p99Pv5Q
 aNtGCzar2t6/NRr3pRHy0a0zOS1ckzOssKSGNUrEU2RzqMYfyW6RRNUYMh9+AD3ype7F
 aI9O3EQg9Vi6s4FeDTHE1ydya4dBeZ34XneyZH9PXp/9nDxdahErvY7vaU0m9szhTKqt
 xC2A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=90nqvY3TIGZlTWEomvS5xRC/YzJhv+Jw7sidT1nz8MA=;
 b=DxBHWn1NYXgWrNOlYvidn1RIA1eQmF+N/tJnJNhlU98HbdQcTVwHiLWeuwQ9SIVaCH
 +Lyqzgvyv4cxpCq2cK7SC/ZEfQhIS39wBHiNdTmjwST1Y24JiWP5wnHSXAy4vsNAIiki
 DQqwvk3cUPcdhQo+6BH1jorQugyD3ysrSkfWCKquXxca/5fATrimVe8hw8NWMicccJIO
 0mjBaXqSkJjFz89N8+xQuoQbTedTAmgyqjnaTbHiV2YRHdmSgKFsJXWZBf+Ip4BxYlQB
 7qAVDP3LbBi6aKSLOZjSTk3NbkqBr85Yhx4zhQSlvJpotZWkAqCtjPFij/x27eGvmFJv
 FdvQ==
X-Gm-Message-State: AOAM531RiTFVafT8Zn5nzMkZzPP4m2S11d+MMtZ9atd5gD+wSzhGylVE
 SPN+pp/Uc/zp1GQinvoPVia/SBn0EV1dQs2PD5M=
X-Google-Smtp-Source: ABdhPJy4vo4H2sC+uVDy8REzBfxyPRw79Lr9Tq96ees6R2BnIAlv5R3U28q9XupNhYnzwoQ+QQDydbTkwqugHMLHKD0=
X-Received: by 2002:a6b:ec17:: with SMTP id c23mr5269194ioh.186.1598787871854; 
 Sun, 30 Aug 2020 04:44:31 -0700 (PDT)
MIME-Version: 1.0
References: <CAOQ4uxjXZdXZAaeiJ_p9n7NJziBv2yvWqSDs0hDd1ONUrVKxOQ@mail.gmail.com>
 <87tuwmiy4j.fsf@x220.int.ebiederm.org>
 <20200828155849.k46uk3x63aio3g3o@yavin.dot.cyphar.com>
In-Reply-To: <20200828155849.k46uk3x63aio3g3o@yavin.dot.cyphar.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Sun, 30 Aug 2020 14:44:20 +0300
Message-ID: <CAOQ4uxisYp9nGacXL8LaLiGa2ciXWOHYxgda-G0QEaw9t0MZHw@mail.gmail.com>
Subject: Re: Overlayfs @Plumbers
To: Aleksa Sarai <asarai@suse.de>
Cc: Linux Containers <containers@lists.linux-foundation.org>,
 "Eric W. Biederman" <ebiederm@xmission.com>,
 Josh Triplett <josh@joshtriplett.org>,
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

On Fri, Aug 28, 2020 at 6:58 PM Aleksa Sarai <asarai@suse.de> wrote:
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

AFAIK we had discussed two issues.
1. Watching changes on upper layer
2. OCI format v2

#1 was brought up by Josh Triplett.
He asked whether watching changes using inotify/fanotify on upper dir
and reading changes from upper dir is a reasonable practice.
I suggested that he use fanotify filesystem mark to watch changes
on overlay sb and read the changes from overlay mount.

#2 TBH I lost track and you guys continued the discussion after I left.
From what I gathered we need a way to describe clones and renames
more efficiently, but I did not hear any solid plan of how to do that.
So perhaps you would be able to fill in some details here.

Thanks,
Amir.
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
