Return-Path: <SRS0=WbUC=DI=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC65FC4727F
	for <containers@archiver.kernel.org>; Thu,  1 Oct 2020 11:28:46 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 441C120691
	for <containers@archiver.kernel.org>; Thu,  1 Oct 2020 11:28:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Q8WmUFrI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 441C120691
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 02C7384E3A;
	Thu,  1 Oct 2020 11:28:46 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id NwJHhaAbZOuO; Thu,  1 Oct 2020 11:28:45 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 8BFFD84806;
	Thu,  1 Oct 2020 11:28:45 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 7DE12C016F;
	Thu,  1 Oct 2020 11:28:45 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id A4A76C0051
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 11:28:44 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 941FF84E3A
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 11:28:44 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id YTlbbfQ17MuQ
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 11:28:44 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pf1-f193.google.com (mail-pf1-f193.google.com
 [209.85.210.193])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 3DE3E84806
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 11:28:44 +0000 (UTC)
Received: by mail-pf1-f193.google.com with SMTP id d9so4205367pfd.3
 for <containers@lists.linux-foundation.org>;
 Thu, 01 Oct 2020 04:28:44 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=xdFfszEFg+9Y0mvLhElhzYRXmvD0D1SVXUuvXh8QwZ4=;
 b=Q8WmUFrIr/vc603KGTrAmH4cx8UN3Ns0p7FV9d6oV5G0E1UzW2wcIiKTGzi/psXe0F
 dbYbCtnVnsep5+BlbHWMxUST09bcWmkT5/DlEasfOfYdjVErM4OLqFXwE1anqT36Of46
 wkU7w4dCfExHzBvLmM5QCQMLzRdRxnG1CSJrhx1Co6XcyJukk03V4RRlKnb4NIXbBAiA
 jf1jzIBvMaHEfxkvHIRXHLSIZlJBo0JMCluU5rqH+wFWA9elNqu9sIokczXBmUDPo3su
 n76qt4Pq8eWh4ueXAplBInEYIeWhZnIJlHMIZftRjnGTu9F3JxzBCDpxqB5Y0rkUCz+x
 XRhw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=xdFfszEFg+9Y0mvLhElhzYRXmvD0D1SVXUuvXh8QwZ4=;
 b=EYqkOa9DrMAAyOJT6B/CY+AOcDxzPOKpPYY5DRH7n/0hQmWhuTs5yijW43E+a+SD0K
 yIxIh4fHFfb/PqhKhV07a+rS//bVt7uH+E/DiycuOMiDjQ+RE09RCh6k6XBQ2wAj4ajy
 D9VWu5tC5y4WWPxsSH/WypKKsqcRvY5pafttJ+GVUw/K4lstVUaVHjoh0GmUHY2hA2Pn
 Fy1g4uuKgCUKjZfyhf2hdLqOvpfUwWuakHNWeNbfOzp3ImH0wMHhnult4wOi39o48SqD
 6WIf8N8LYs7txTQsqYeJT1ktWuvmOhLC7OskWsbFSd8Iz0Vu4UBXeiasAsjz5lrQrpTk
 qrIQ==
X-Gm-Message-State: AOAM530xfCxwHWMLVyma/XISr/j48L9rnuCHMG96XKl3oNLQYMrdFNqJ
 JEYih27DiMcD44XuGGB0WU0gI3sBwfUV7uJCy4I=
X-Google-Smtp-Source: ABdhPJxo9xb5Y/FPu8g8kJ6peODTF6LK6ttQzuwFH2GQul5cR5TkHOeuFJgkfgM8IzutagCPnnpWe3UnBvrCt6BBy/I=
X-Received: by 2002:a63:906:: with SMTP id 6mr5779235pgj.66.1601551723753;
 Thu, 01 Oct 2020 04:28:43 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1601478774.git.yifeifz2@illinois.edu>
 <b16456e8dbc378c41b73c00c56854a3c30580833.1601478774.git.yifeifz2@illinois.edu>
 <CAG48ez0Njm0oS+9k-cgUqzyUWXV=cHPope2Xe9vVNPUVZ1PB4w@mail.gmail.com>
In-Reply-To: <CAG48ez0Njm0oS+9k-cgUqzyUWXV=cHPope2Xe9vVNPUVZ1PB4w@mail.gmail.com>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Thu, 1 Oct 2020 06:28:32 -0500
Message-ID: <CABqSeASwCXaP_vNe1=E3EeWAApFYiB1S5xEb9BdH10b0rn0Q6A@mail.gmail.com>
Subject: Re: [PATCH v3 seccomp 2/5] seccomp/cache: Add "emulator" to check if
 filter is constant allow
To: Jann Horn <jannh@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Kees Cook <keescook@chromium.org>,
 YiFei Zhu <yifeifz2@illinois.edu>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>,
 kernel list <linux-kernel@vger.kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Hubertus Franke <frankeh@us.ibm.com>,
 David Laight <David.Laight@aculab.com>, Jack Chen <jianyan2@illinois.edu>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
 Josep Torrellas <torrella@illinois.edu>, Will Drewry <wad@chromium.org>,
 bpf <bpf@vger.kernel.org>, Tianyin Xu <tyxu@illinois.edu>
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

On Wed, Sep 30, 2020 at 5:24 PM Jann Horn <jannh@google.com> wrote:
> If you did the architecture enablement for X86 later in the series,
> you could move this part over into that patch, that'd be cleaner.

As in, patch 1: bitmap check logic. patch 2: emulator. patch 3: enable for x86?

> > + * Tis struct is ordered to minimize padding holes.
>
> I think this comment can probably go away, there isn't really much
> trickery around padding holes in the struct as it is now.

Oh right, I was trying the locks and adding bits to indicate if
certain arches are primed, then I undid that.

> > +                       set_bit(nr, bitmap);
>
> set_bit() is atomic, but since we only do this at filter setup, before
> the filter becomes globally visible, we don't need atomicity here. So
> this should probably use __set_bit() instead.

Right

YiFei Zhu
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
