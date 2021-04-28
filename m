Return-Path: <SRS0=hje2=JZ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF68DC433ED
	for <containers@archiver.kernel.org>; Wed, 28 Apr 2021 00:22:29 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 70A03613D8
	for <containers@archiver.kernel.org>; Wed, 28 Apr 2021 00:22:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70A03613D8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tycho.pizza
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp4.osuosl.org (Postfix) with ESMTP id 29DDD4067D;
	Wed, 28 Apr 2021 00:22:29 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp4.osuosl.org ([127.0.0.1])
	by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id PU1U-p2FT-fq; Wed, 28 Apr 2021 00:22:28 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [IPv6:2605:bc80:3010:104::8cd3:938])
	by smtp4.osuosl.org (Postfix) with ESMTP id D2594405A2;
	Wed, 28 Apr 2021 00:22:27 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id A85BDC001C;
	Wed, 28 Apr 2021 00:22:27 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 7076BC0001
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Apr 2021 00:22:26 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp1.osuosl.org (Postfix) with ESMTP id 53C1683E2F
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Apr 2021 00:22:26 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp1.osuosl.org (amavisd-new);
 dkim=pass (2048-bit key) header.d=tycho.pizza header.b="8GWExJPs";
 dkim=pass (2048-bit key) header.d=messagingengine.com
 header.b="tVR8T28R"
Received: from smtp1.osuosl.org ([127.0.0.1])
 by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id bb8Ajyv0_A84
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Apr 2021 00:22:25 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.8.0
Received: from new2-smtp.messagingengine.com (new2-smtp.messagingengine.com
 [66.111.4.224])
 by smtp1.osuosl.org (Postfix) with ESMTPS id 7085583E2C
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Apr 2021 00:22:25 +0000 (UTC)
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
 by mailnew.nyi.internal (Postfix) with ESMTP id 5AFD358096B;
 Tue, 27 Apr 2021 20:22:19 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
 by compute3.internal (MEProxy); Tue, 27 Apr 2021 20:22:19 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tycho.pizza; h=
 date:from:to:cc:subject:message-id:references:mime-version
 :content-type:in-reply-to; s=fm3; bh=bPTuTe7blkVLywwWCJqNsQlHWvk
 gDsPComF+4qCOu3Y=; b=8GWExJPszyZ8s4DyPGKY/UyVc6bfmj9RPjmG3uRrBhP
 qAx+PDRD092TF+8bcwDCJ4vuMh17M4gkza25rTXXvUHvm6wh9nGvf90ZlA2NWz4n
 tIH1kLOvpd1p3jA/4w2RtEZ8TVETQYWSNsjoDcHwi/VMcbcGa6Gh+0uvQ/q8FtvB
 WmzMHb2u5Id7eXtjW0qexxNb1Qu9loap1cerF+L+0JXxAzBr5m6HRDZZMO/mpnLs
 3rf9fB8+mNK0uuJjsSnt9zSS4nUd8P6LvoYoADWxuRjDz/Q2MHUKXf4T7wRUFAyH
 qfI+5pqsbz3KLkZglobOMEGel/Eo3UmH3/iDMXPxFRQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
 messagingengine.com; h=cc:content-type:date:from:in-reply-to
 :message-id:mime-version:references:subject:to:x-me-proxy
 :x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=bPTuTe
 7blkVLywwWCJqNsQlHWvkgDsPComF+4qCOu3Y=; b=tVR8T28R0rAHwIVdWjb08u
 HHkuDl7o0lArL1B72Xsq/Fq96Om07a1VudTh8SDMoFmEb9p08fCnzCB37nS1NbMg
 QX1rXbCH9lBsInT/Nsp51SFMHh8Hy7Jwx2qfcVD8yJTlA0xdjIzsgzDEEdblI410
 F8x3eDYP+yNy3HaiF1uIonpsB129FK9/Xc3W7y6ilfMYxZi55Kih6WpjET3MgxBX
 yugXoiVpmSNCuxCzIhLODHjxqnNhVXgFnMJqJM+QgFy/XTXOCBSz875JtJrR/7th
 U4eT8RccSSEveYv1JeslalftaxPBcDulzANWMCwNQZpORmeQeI5/CKZxGHOa7tbg
 ==
X-ME-Sender: <xms:uqqIYJbTlm_AK0sYc6Td0NVo4ibBmN7xsmHbNs2letPPFkla00aZTw>
 <xme:uqqIYAb3jm-SY0aefqj6OJm-hGXz7ll5bH5BFz82VPtOTK6z0oAQOT1QRogS5v9YR
 eDyltm6BWUjPYBniqU>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduledrvddvuddgfedvucetufdoteggodetrfdotf
 fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfqfgfvpdfurfetoffkrfgpnffqhgen
 uceurghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmne
 cujfgurhepfffhvffukfhfgggtuggjsehttdertddttddvnecuhfhrohhmpefvhigthhho
 ucetnhguvghrshgvnhcuoehthigthhhosehthigthhhordhpihiiiigrqeenucggtffrrg
 htthgvrhhnpeegkeefjeegkedtjefgfeduleekueetjeeghffhuefgffefleehgeeifedv
 gfethfenucfkphepudejfedrfeekrdduudejrdektdenucevlhhushhtvghrufhiiigvpe
 dtnecurfgrrhgrmhepmhgrihhlfhhrohhmpehthigthhhosehthigthhhordhpihiiiigr
X-ME-Proxy: <xmx:uqqIYL_pttZNVb5IViQGnbatbCt7kXziz0gIR0SSlC4MLf-5Lfl_FA>
 <xmx:uqqIYHqM2iSuKTbibryfLpOPlnCfjTr1HS5LRBNM9PBYyZg72Dcu5Q>
 <xmx:uqqIYEow_5Ol7L_uV7zmu4-xyQS-53j5QfCKmNyd1V_KFcdTYCEoZg>
 <xmx:u6qIYAfAf7SaeoHrFH8z-DxJiQZBGZng2MOA9XMkL4ME8oCSM4I-uw>
Received: from cisco (unknown [173.38.117.80])
 by mail.messagingengine.com (Postfix) with ESMTPA;
 Tue, 27 Apr 2021 20:22:17 -0400 (EDT)
Date: Tue, 27 Apr 2021 18:22:15 -0600
From: Tycho Andersen <tycho@tycho.pizza>
To: Andy Lutomirski <luto@kernel.org>
Subject: Re: [PATCH RESEND 2/5] seccomp: Add wait_killable semantic to
 seccomp user notifier
Message-ID: <20210428002215.GB1786245@cisco>
References: <20210426180610.2363-1-sargun@sargun.me>
 <20210426180610.2363-3-sargun@sargun.me>
 <20210426190229.GB1605795@cisco>
 <20210426221527.GA30835@ircssh-2.c.rugged-nimbus-611.internal>
 <20210427134853.GA1746081@cisco>
 <CALCETrVrfBtQPh=YeDEK4P9+QHQvNxHbn8ZT3fdQNznpSeS5oQ@mail.gmail.com>
 <20210427170753.GA1786245@cisco>
 <20210427221028.GA16602@ircssh-2.c.rugged-nimbus-611.internal>
 <CALCETrX9JnHE9BOhRxCc1bCvEBfbOY8bb2rxeKTsDNxfMruntQ@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CALCETrX9JnHE9BOhRxCc1bCvEBfbOY8bb2rxeKTsDNxfMruntQ@mail.gmail.com>
Cc: Giuseppe Scrivano <gscrivan@redhat.com>, Will Drewry <wad@chromium.org>,
 Kees Cook <keescook@chromium.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 LKML <linux-kernel@vger.kernel.org>, Alban Crequy <alban@kinvolk.io>,
 Christian Brauner <christian.brauner@ubuntu.com>
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

On Tue, Apr 27, 2021 at 04:19:54PM -0700, Andy Lutomirski wrote:
> On Tue, Apr 27, 2021 at 3:10 PM Sargun Dhillon <sargun@sargun.me> wrote:
> >
> > On Tue, Apr 27, 2021 at 11:07:53AM -0600, Tycho Andersen wrote:
> > > On Tue, Apr 27, 2021 at 09:23:42AM -0700, Andy Lutomirski wrote:
> > > > On Tue, Apr 27, 2021 at 6:48 AM Tycho Andersen <tycho@tycho.pizza> wrote:
> > > > >
> > > > > On Mon, Apr 26, 2021 at 10:15:28PM +0000, Sargun Dhillon wrote:
> > > >
> > > > ISTM the current behavior is severely broken, and the new behavior
> > > > isn't *that* much better since it simply ignores signals and can't
> > > > emulate -EINTR (or all the various restart modes, sigh).  Surely the
> > > > right behavior is to have the seccomped process notice that it got a
> > > > signal and inform the monitor of that fact so that the monitor can
> > > > take appropriate action.
> > >
> > > This doesn't help your case (2) though, since the IO could be done
> > > before the supervisor gets the notification.
> 
> Tycho, I disagree.  Here's how native syscalls work:
> 
> 1. Entry work is done and the syscall hander does whatever it does at
> the beginning of the function.  This is entirely non-interruptible.
> 
> 2. The syscall handler decides it wants to wait, interruptibly,
> killably or otherwise.
> 
> 3. It gets signaled.  It takes appropriate action.  Appropriate action
> does *not* mean -EINTR.  It means that something that is correct *for
> that syscall* happens.  For nanosleep(), this involves the restart
> block (and I don't think we need to support the restart block).  For
> accept(), it mostly seems to mean that the syscall completes as usual.
> For write(2), it means that, depending on file type and whether any IO
> has occured, either -EINTR is returned and no IO happens, or fewer
> bytes than requested are transferred, or the syscall completes.  (Or,
> if it's a KILL, the process dies early and partial IO is ignored.)
> For some syscalls (some AF_UNIX writes, for example, or ptrace()), the
> syscall indeed gets interrupted, but it uses one of the -ERESTART
> mecahnisms.
> 
> User notifiers should allow correct emulation.  Right now, it doesn't,
> but there is no reason it can't.

Thanks for the explanation.

Consider fsmount, which has a,

        ret = mutex_lock_interruptible(&fc->uapi_mutex);
        if (ret < 0)
                goto err_fsfd;

If a regular task is interrupted during that wait, it return -EINTR
or whatever back to userspace.

Suppose that we intercept fsmount. The supervisor decides the mount is
OK, does the fsmount, injects the mount fd into the container, and
then the tracee receives a signal. At this point, the mount fd is
visible inside the container. The supervisor gets a notification about
the signal and revokes the mount fd, but there was some time where it
was exposed in the container, whereas with the interrupt in the native
syscall there was never any exposure.

How does the supervisor correctly emulate this syscall? Maybe this
doesn't matter and this is just "completes as usual"? But then
handling signals is just a latency issue, not a correctness one. Or
most likely I'm misunderstanding something else :)

Tycho
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
