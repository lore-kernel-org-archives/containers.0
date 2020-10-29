Return-Path: <SRS0=MeFG=EE=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA8FDC4363A
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 02:14:01 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 10B7020720
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 02:13:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 10B7020720
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tycho.pizza
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 87BDB86429;
	Thu, 29 Oct 2020 02:13:58 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 0R95FnnLaL3e; Thu, 29 Oct 2020 02:13:57 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 429E48491C;
	Thu, 29 Oct 2020 02:13:57 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 169EEC088B;
	Thu, 29 Oct 2020 02:13:57 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 6F611C0051
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 02:13:56 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 62F4286407
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 02:13:56 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id c_FAu_g39mAr
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 02:13:55 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from new2-smtp.messagingengine.com (new2-smtp.messagingengine.com
 [66.111.4.224])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id EA56D860FE
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 02:13:54 +0000 (UTC)
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
 by mailnew.nyi.internal (Postfix) with ESMTP id CB9E0580354;
 Wed, 28 Oct 2020 22:13:53 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
 by compute6.internal (MEProxy); Wed, 28 Oct 2020 22:13:53 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tycho.pizza; h=
 date:from:to:cc:subject:message-id:references:mime-version
 :content-type:in-reply-to; s=fm1; bh=fkArUsIh5xt8az+QMQ0qOvRGJDy
 zUoXC98ZBbRco6Tg=; b=MZZkvcEPwN52FnSurwXKENrqbWa65arxCgMbhK9KATR
 1YnxIR8u9s9O8MXeZVWzdbl+7DIbJbRkZgjEmkGQBLLkoQIpAPEJY0iWTb3swvKE
 27/QT2PhnLfGBlM/RNPlU6+pwnhRvzoOL46SLbmjBmPr4Vw6fI5IWdpw+8dsg9vj
 u385Mr+cxGtsEVLd5xAKi2tV4yVVlzOvFrtJmL7GkK3xGpS62wd1JeiZkSwh1/A8
 X354tZB/0pbqQX4UbCtfWz2aTsA3PxbQrOEIHCZRZiu0+UVTLRl0pb9SYJb2lVz2
 /mBDURy1ATFTmU9QU/z16dMoZe42CDgR7gMsXS+GDrw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
 messagingengine.com; h=cc:content-type:date:from:in-reply-to
 :message-id:mime-version:references:subject:to:x-me-proxy
 :x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; bh=fkArUs
 Ih5xt8az+QMQ0qOvRGJDyzUoXC98ZBbRco6Tg=; b=Tj4GA9NtQMFE1PK5MKCJ8i
 WvnxJC5APi3tJJ5IypRZp2Oz/uY0AERLqSF8Gb+CpMtkx8sSnfGWDfM91QGMEKrw
 jNMTOyD61NKqI71hOGqNtoC9SJyjeMa9afD39hzBh/DHztEO8FajXXaXz+y8GQZo
 DltRyPCy66mx/q0VhiGvMxj+My9Ykmw9Sd5tVuQK/OvMvo3en2Jl5ywXSVaHohGp
 Y9IDpgmULdgpYZkKcGGQ6vGCjjDhlTYyJ1KreeEBtRD+wCIG9i6SYc+W4WlstfOi
 4MoM5q5cUKVYkwZxBWCSqwIlfJXCwO52k55Fi1xc0AuSIAm7ZoDqarOLtM5bS0CA
 ==
X-ME-Sender: <xms:XiWaX9hNOXMFeN9b2uzmKXYIv2OfipLHqaTriBBz6YMHEQ9Zaq14yQ>
 <xme:XiWaXyBRbOaECbquG9Eu5XX-0py1B1mSScy29ho8PKR3RVprey86bG45i-KL4T764
 DLgBEqe7Rden3oeAaQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedujedrledvgdejudcutefuodetggdotefrodftvf
 curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
 uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
 fjughrpeffhffvuffkfhggtggujgesthdtredttddtvdenucfhrhhomhepvfihtghhohcu
 tehnuggvrhhsvghnuceothihtghhohesthihtghhohdrphhiiiiirgeqnecuggftrfgrth
 htvghrnhepffeukeekudejfefhjeevgeejgffhkefhffetleduvddufeekteelkeekhfef
 udejnecuffhomhgrihhnpehkvghrnhgvlhdrohhrghenucfkphepjeefrddvudejrddutd
 driedtnecuvehluhhsthgvrhfuihiivgeptdenucfrrghrrghmpehmrghilhhfrhhomhep
 thihtghhohesthihtghhohdrphhiiiiirg
X-ME-Proxy: <xmx:XiWaX9Gi4e39FtVoIXDJoXJHmrZgl3k8ST2h-ckidyArm34vvx2a3A>
 <xmx:XiWaXySF6ZwEqri9aA1_e1cgCjDfvCO_l-T-5NajSSQhEeEGbkColg>
 <xmx:XiWaX6zMf84Mcur_tnZt2t1Th34QPwrBuCpRqTy2a9b9cAV_fj2qgA>
 <xmx:YSWaX_Jql5u7zN88rRtsYIuGQLcKlFE9f66qz0tFG5gTgokhSqXjJw>
Received: from cisco (c-73-217-10-60.hsd1.co.comcast.net [73.217.10.60])
 by mail.messagingengine.com (Postfix) with ESMTPA id 8DD283064684;
 Wed, 28 Oct 2020 22:13:49 -0400 (EDT)
Date: Wed, 28 Oct 2020 20:13:48 -0600
From: Tycho Andersen <tycho@tycho.pizza>
To: Jann Horn <jannh@google.com>
Subject: Re: For review: seccomp_user_notif(2) manual page
Message-ID: <20201029021348.GB25673@cisco>
References: <45f07f17-18b6-d187-0914-6f341fe90857@gmail.com>
 <20200930150330.GC284424@cisco>
 <8bcd956f-58d2-d2f0-ca7c-0a30f3fcd5b8@gmail.com>
 <20200930230327.GA1260245@cisco>
 <CAG48ez1VOUEHVQyo-2+uO7J+-jN5rh7=KmrMJiPaFjwCbKR1Sg@mail.gmail.com>
 <20200930232456.GB1260245@cisco>
 <CAG48ez2xn+_KznEztJ-eVTsTzkbf9CVgPqaAk7TpRNAqbdaRoA@mail.gmail.com>
 <202010251725.2BD96926E3@keescook>
 <CAG48ez2b-fnsp8YAR=H5uRMT4bBTid_hyU4m6KavHxDko1Efog@mail.gmail.com>
 <CAG48ez2OWhpH3HHUJSrAmokJ8=SVwKrmQMSw0gEbTJmKE4myCw@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CAG48ez2OWhpH3HHUJSrAmokJ8=SVwKrmQMSw0gEbTJmKE4myCw@mail.gmail.com>
Cc: linux-man <linux-man@vger.kernel.org>, Song Liu <songliubraving@fb.com>,
 Will Drewry <wad@chromium.org>, Kees Cook <keescook@chromium.org>,
 Daniel Borkmann <daniel@iogearbox.net>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Robert Sesek <rsesek@google.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 lkml <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
 "Michael Kerrisk \(man-pages\)" <mtk.manpages@gmail.com>,
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

> > Consider the following scenario (with supervisor "S" and target "T"; S
> > wants to wait for events on two file descriptors seccomp_fd and
> > other_fd):
> >
> > S: starts poll() to wait for events on seccomp_fd and other_fd
> > T: performs a syscall that's filtered with RET_USER_NOTIF
> > S: poll() returns and signals readiness of seccomp_fd
> > T: receives signal SIGUSR1
> > T: syscall aborts, enters signal handler
> > T: signal handler blocks on unfiltered syscall (e.g. write())
> > S: starts SECCOMP_IOCTL_NOTIF_RECV
> > S: blocks because no syscalls are pending
> >
> > Depending on what other_fd is, this could in a worst case even lead to
> > a deadlock (if e.g. the signal handler wants to write to stdout, but
> > the stdout fd is hooked up to other_fd in the supervisor, but the
> > supervisor can't consume the data written because it's stuck in
> > seccomp handling).
> >
> > So we have to ensure that when existing code (like that crun code you
> > linked to) triggers this case, SECCOMP_IOCTL_NOTIF_RECV returns
> > immediately instead of blocking.
> 
> Or I guess we could also just set O_NONBLOCK on the fd by default?
> Since the one existing user is eventloop-based...

I feel like it's ok to return an error from the RECV ioctl() if
there's never going to be any more events on the fd; was there
something fundamentally wrong with your patch here:
https://lore.kernel.org/bpf/CAG48ez2xn+_KznEztJ-eVTsTzkbf9CVgPqaAk7TpRNAqbdaRoA@mail.gmail.com/
?

That seemed reasonable to me (although maybe nicer if we could get rid
of the open-ish coded semaphore; I couldn't figure out how though).

Tycho
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
