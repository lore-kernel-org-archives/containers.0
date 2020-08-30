Return-Path: <SRS0=zxUI=CI=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F73DC433E2
	for <containers@archiver.kernel.org>; Sun, 30 Aug 2020 11:30:39 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id DDA09207DA
	for <containers@archiver.kernel.org>; Sun, 30 Aug 2020 11:30:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="dYmTJVFJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DDA09207DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id B1EEB85F6D;
	Sun, 30 Aug 2020 11:30:38 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id IgZ9sCnWhTe5; Sun, 30 Aug 2020 11:30:36 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id ED30985E14;
	Sun, 30 Aug 2020 11:30:35 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id D55CDC07FF;
	Sun, 30 Aug 2020 11:30:35 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id C35C4C0051
 for <containers@lists.linux-foundation.org>;
 Sun, 30 Aug 2020 11:30:34 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id AE202852D5
 for <containers@lists.linux-foundation.org>;
 Sun, 30 Aug 2020 11:30:34 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 3QWDbAjDTP0j
 for <containers@lists.linux-foundation.org>;
 Sun, 30 Aug 2020 11:30:34 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from us-smtp-1.mimecast.com (us-smtp-1.mimecast.com [207.211.31.81])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id D080D85239
 for <containers@lists.linux-foundation.org>;
 Sun, 30 Aug 2020 11:30:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
 s=mimecast20190719; t=1598787031;
 h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
 in-reply-to:in-reply-to:references:references;
 bh=ETh2SfT4KHd+5n3USTDSMP5uiOB3sVlZ/3ww+QanKH8=;
 b=dYmTJVFJZ+XIxva4R7R+LrIjs4o2Ai2rF9n0c13hRLvooEC5ZW/iALF/l6UvovUSwiLYaU
 P4mzdaELSJ5QHP6mDgo/XR8CUlR2v3IdAUoO13qjwi0rGU4QEvKIC/nhu8A6NGjfw2oh3N
 ZlC3MZRFwtrQOhx7WKm5VD+9PAN9XLU=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-3-hz1v0BwXPy6kfSE3UYxG2A-1; Sun, 30 Aug 2020 07:30:27 -0400
X-MC-Unique: hz1v0BwXPy6kfSE3UYxG2A-1
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com
 [10.5.11.13])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by mimecast-mx01.redhat.com (Postfix) with ESMTPS id DB5A0189E628;
 Sun, 30 Aug 2020 11:29:55 +0000 (UTC)
Received: from localhost (ovpn-112-59.ams2.redhat.com [10.36.112.59])
 by smtp.corp.redhat.com (Postfix) with ESMTPS id 950007838E;
 Sun, 30 Aug 2020 11:29:54 +0000 (UTC)
From: Giuseppe Scrivano <gscrivan@redhat.com>
To: Sargun Dhillon <sargun@sargun.me>
Subject: Re: Overlayfs @Plumbers
References: <CAOQ4uxjXZdXZAaeiJ_p9n7NJziBv2yvWqSDs0hDd1ONUrVKxOQ@mail.gmail.com>
 <87tuwmiy4j.fsf@x220.int.ebiederm.org>
 <20200828155849.k46uk3x63aio3g3o@yavin.dot.cyphar.com>
 <CAMp4zn83CwpfuFq7+JSkYGZmFC03pUrt_30Wzn42AxqAaSDSpg@mail.gmail.com>
Date: Sun, 30 Aug 2020 13:29:51 +0200
In-Reply-To: <CAMp4zn83CwpfuFq7+JSkYGZmFC03pUrt_30Wzn42AxqAaSDSpg@mail.gmail.com>
 (Sargun Dhillon's message of "Sat, 29 Aug 2020 08:40:36 -0700")
Message-ID: <87imd09xsg.fsf@redhat.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.3 (gnu/linux)
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
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

Hi Sargun,

Sargun Dhillon <sargun@sargun.me> writes:

Q> On Fri, Aug 28, 2020 at 8:59 AM Aleksa Sarai <asarai@suse.de> wrote:
>>
>> On 2020-08-28, Eric W. Biederman <ebiederm@xmission.com> wrote:
>> > Amir Goldstein <amir73il@gmail.com> writes:
>> >
>> > > Hi Guys,
>> > >
>> > > It's been nice to virtually meet with you yesterday.
>> > > Some of you wanted to follow up on overlayfs related issues.
>> > >
>> > > If you want to discuss, try to find me in one of the
>> > > https://meet.2020.linuxplumbersconf.org/hackrooms
>> > > today between 16:00-17:00 UTC
>> > > (No need to enter the room to see who's inside)
>> > >
>> > > If those times do not work for you, contact me and we can try
>> > > to schedule another time.
>> >
>> > Did this conversation wind up happening?  Do we need to reschedule?
>>
>> This conversation already happened in a Hackroom on Tuesday. I'm not
>> sure if the Hackrooms will have their recordings published, so maybe
>> Amir can post any of the takeaways we had?
>>
>> --
>> Aleksa Sarai
>> Senior Software Engineer (Containers)
>> SUSE Linux GmbH
>> <https://www.cyphar.com/>
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

we are having the same issue when building images.  Would the following
patch be helpful?

https://www.spinics.net/lists/linux-unionfs/msg08267.html

Regards,
Giuseppe

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
