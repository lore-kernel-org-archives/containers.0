Return-Path: <SRS0=vxAo=GQ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2FFFEC433E0
	for <containers@archiver.kernel.org>; Wed, 13 Jan 2021 18:02:08 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id AC59821534
	for <containers@archiver.kernel.org>; Wed, 13 Jan 2021 18:02:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC59821534
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 48FE286B2D;
	Wed, 13 Jan 2021 18:02:07 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 47-zXU4jaInr; Wed, 13 Jan 2021 18:02:06 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 79F7386B4A;
	Wed, 13 Jan 2021 18:02:06 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 5C0D4C0893;
	Wed, 13 Jan 2021 18:02:06 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 88A4AC013A
 for <containers@lists.linux-foundation.org>;
 Wed, 13 Jan 2021 18:02:05 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 73F9A86B3F
 for <containers@lists.linux-foundation.org>;
 Wed, 13 Jan 2021 18:02:05 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id kKu61DBjpM0L
 for <containers@lists.linux-foundation.org>;
 Wed, 13 Jan 2021 18:02:01 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pf1-f171.google.com (mail-pf1-f171.google.com
 [209.85.210.171])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 3B2B686B39
 for <containers@lists.linux-foundation.org>;
 Wed, 13 Jan 2021 18:01:57 +0000 (UTC)
Received: by mail-pf1-f171.google.com with SMTP id q20so1701266pfu.8
 for <containers@lists.linux-foundation.org>;
 Wed, 13 Jan 2021 10:01:57 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=2yOASqLXCFmH8rHiDFY5aK5IF9dZ2OI5aQ21Vbh1eP8=;
 b=gHtUHzUPG5nr4qeM6RqXwHoa31eiMAo2G3XbBdMPhPetpWhM+8FxJcVQrQckAjJOts
 a+PuAK+iIngRm+Yp1MRDCVK0BKRkRO9ogHvQh8O/VHesI2z8n5+VeisZVKsjgEqjLV5k
 U3cHR0de4KgfDQBMl4Uj4g9/NyiGrIcwhViN8=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=2yOASqLXCFmH8rHiDFY5aK5IF9dZ2OI5aQ21Vbh1eP8=;
 b=Gx4xpT/lslHUmNUZAYf8j83Fp6gO/meESLFdIKrwUvwAgVABZJ37c0KPkkm9SFgo9u
 YQ7sCRm0EOayWLj/F5V9mgVZfD9wFOhC53fYGKLxXXJaboLzxRM3EMA2Tmk9be+CCbp3
 egcBZrNqqUHsOlLAcdO9qN+tUDKdZe1RgOzP7ObDNilV/grAZZf1ldEvNhaMg2bYi67d
 JHOhXMZScnMaBVukUWTYX+re0suSQdnHLqoOP3EVU4hq7XWFh3LK7fOz0cPamVy4DCrR
 oFkdQP+Yle4io+BRxjYZLVvclbDix0KYHQuiCOMx37Cj4HLtH5DEAQBmoMrnkWcvwvCG
 uqKw==
X-Gm-Message-State: AOAM532s9B6Nj7lDcWl0ORqIdHsamSK9AYTTw4EzAIyVO94axPlamiJ5
 tOcdJCmUU9ddidBfRnODfVPHKQ==
X-Google-Smtp-Source: ABdhPJy/l5JCoFPdFR12hWOnKrP/lLjwYszhjP/WNJBh99XAQ0ifkW1xWHqHas6EDvPBSGX8HpJRMQ==
X-Received: by 2002:a63:8f19:: with SMTP id n25mr3154262pgd.17.1610560917380; 
 Wed, 13 Jan 2021 10:01:57 -0800 (PST)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id c5sm3574184pjo.4.2021.01.13.10.01.56
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Wed, 13 Jan 2021 10:01:56 -0800 (PST)
Date: Wed, 13 Jan 2021 10:01:55 -0800
From: Kees Cook <keescook@chromium.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: Re: [RFC PATCH v2 1/8] Use atomic type for ucounts reference counting
Message-ID: <202101131001.BF1108F90@keescook>
References: <cover.1610299857.git.gladkov.alexey@gmail.com>
 <447547b12bba1894d3f1f79d6408dfc60b219b0c.1610299857.git.gladkov.alexey@gmail.com>
 <878s8wdcib.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <878s8wdcib.fsf@x220.int.ebiederm.org>
Cc: Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 LKML <linux-kernel@vger.kernel.org>,
 Linus Torvalds <torvalds@linux-foundation.org>,
 Alexey Gladkov <legion@kernel.org>, Christian Brauner <christian@brauner.io>
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

On Wed, Jan 13, 2021 at 10:31:40AM -0600, Eric W. Biederman wrote:
> Alexey Gladkov <gladkov.alexey@gmail.com> writes:
> 
> We might want to use refcount_t instead of atomic_t.  Not a big deal
> either way.

Yes, please use refcount_t, and don't use _read() since that introduces
races.

-Kees

> 
> > Signed-off-by: Alexey Gladkov <gladkov.alexey@gmail.com>
> > ---
> >  include/linux/user_namespace.h |  2 +-
> >  kernel/ucount.c                | 10 +++++-----
> >  2 files changed, 6 insertions(+), 6 deletions(-)
> >
> > diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
> > index 64cf8ebdc4ec..84fefa9247c4 100644
> > --- a/include/linux/user_namespace.h
> > +++ b/include/linux/user_namespace.h
> > @@ -92,7 +92,7 @@ struct ucounts {
> >  	struct hlist_node node;
> >  	struct user_namespace *ns;
> >  	kuid_t uid;
> > -	int count;
> > +	atomic_t count;
> >  	atomic_t ucount[UCOUNT_COUNTS];
> >  };
> >  
> > diff --git a/kernel/ucount.c b/kernel/ucount.c
> > index 11b1596e2542..0f2c7c11df19 100644
> > --- a/kernel/ucount.c
> > +++ b/kernel/ucount.c
> > @@ -141,7 +141,8 @@ static struct ucounts *get_ucounts(struct user_namespace *ns, kuid_t uid)
> >  
> >  		new->ns = ns;
> >  		new->uid = uid;
> > -		new->count = 0;
> > +
> > +		atomic_set(&new->count, 0);
> >  
> >  		spin_lock_irq(&ucounts_lock);
> >  		ucounts = find_ucounts(ns, uid, hashent);
> > @@ -152,10 +153,10 @@ static struct ucounts *get_ucounts(struct user_namespace *ns, kuid_t uid)
> >  			ucounts = new;
> >  		}
> >  	}
> > -	if (ucounts->count == INT_MAX)
> > +	if (atomic_read(&ucounts->count) == INT_MAX)
> >  		ucounts = NULL;
> >  	else
> > -		ucounts->count += 1;
> > +		atomic_inc(&ucounts->count);
> >  	spin_unlock_irq(&ucounts_lock);
> >  	return ucounts;
> >  }
> > @@ -165,8 +166,7 @@ static void put_ucounts(struct ucounts *ucounts)
> >  	unsigned long flags;
> >  
> >  	spin_lock_irqsave(&ucounts_lock, flags);
> > -	ucounts->count -= 1;
> > -	if (!ucounts->count)
> > +	if (atomic_dec_and_test(&ucounts->count))
> >  		hlist_del_init(&ucounts->node);
> >  	else
> >  		ucounts = NULL;
> 
> 
> This can become:
> static void put_ucounts(struct ucounts *ucounts)
> {
> 	unsigned long flags;
> 
>         if (atomic_dec_and_lock_irqsave(&ucounts->count, &ucounts_lock, flags)) {
>         	hlist_del_init(&ucounts->node);
>                 spin_unlock_irqrestore(&ucounts_lock);
>                 kfree(ucounts);
>         }
> }
> 

-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
