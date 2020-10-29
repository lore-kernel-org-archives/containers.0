Return-Path: <SRS0=MeFG=EE=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11CD4C4363A
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 14:16:44 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 0B32F2076B
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 14:16:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B32F2076B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tycho.pizza
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 9AF1586BEF;
	Thu, 29 Oct 2020 14:16:38 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 6u5fAMVXqW-r; Thu, 29 Oct 2020 14:16:37 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 2C66786BCC;
	Thu, 29 Oct 2020 14:16:37 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 22D69C0859;
	Thu, 29 Oct 2020 14:16:37 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id E307DC0051
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 14:16:35 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id CA00C86BCC
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 14:16:35 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 9P7nsb2W1Rsd
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 14:16:34 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from wnew1-smtp.messagingengine.com (wnew1-smtp.messagingengine.com
 [64.147.123.26])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 78CAD86B2A
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 14:16:34 +0000 (UTC)
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
 by mailnew.west.internal (Postfix) with ESMTP id A726993E;
 Thu, 29 Oct 2020 10:16:32 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
 by compute6.internal (MEProxy); Thu, 29 Oct 2020 10:16:33 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tycho.pizza; h=
 date:from:to:cc:subject:message-id:references:mime-version
 :content-type:in-reply-to; s=fm1; bh=bUDW6PtTo3PC+fDxUGWKolAwTcb
 V8hO89WZ6Tih+cig=; b=cIAygEEmj1gIxWnXqljUrRR/JW4Och0+rq0hSSTbESN
 naTR1MK5sI16MTOUiXlvWHTHLtHu9NAFDtDrt2UGMjE1AkPmyD3MSfxnArdY1kL6
 FlRcmpccEm6MRJMjexE6i726yFd09Z7H5EVdDCIY8YalLzCaQAD0cMM1OA5qHjX7
 QSM2Y8A+xBbvpmOle64w4zze8N6XLTk7+D1yIXifBq7GxoLCmc1ZTgXJJKLYWPkt
 Yz+r1xXSP9zzTWwp9teKcJPR3lM5UAXwA4GmT/3BLFflrGgUIaGTJE6IyzloKxUV
 5ptx+bJvZaCEFAneXPrOfiZkx161G4GA1KQjJCGPXuQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
 messagingengine.com; h=cc:content-type:date:from:in-reply-to
 :message-id:mime-version:references:subject:to:x-me-proxy
 :x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; bh=bUDW6P
 tTo3PC+fDxUGWKolAwTcbV8hO89WZ6Tih+cig=; b=YNVYr8ouvC8lMcDNIOw8gv
 QO/P6oisC45qysN59aF44ig8NUXaCZ/4Amlh/WxoGZFeSrDFNW8+n0Dmutw1nUUl
 uJA1GKDflFuPuFLWuEGafHdj1JUygDlflaXz8+tJ77IXSB69mOQi7tJHr8FsLMsj
 lAGSMxkjIOx0wr7i7Vg/MBwsFNkfw7KHigCUXO4uPZib/P8xFAkbORhgXNNJTk97
 SB8GmoRXZZNhKsIncximvO/ikiqpMOh9b8KK8TjPthg79bQtc9E9sy2ekpW2cG4n
 j7TxLe4/gF6mCHvncJOv6p48bsL01PLQ5V76F9gWXa+Qrkuy9Jn4OgK5zg2V8ayQ
 ==
X-ME-Sender: <xms:vs6aX37qBtHL5_HTaZgHZiT5alQ_ac-1r-tMq6IScWuZw65DsyZHng>
 <xme:vs6aX84nve5aoxAxghMry9pPtwQV_Vnc45Y7qfeOIDFJR484cFQbtDNBpDhVB3HSX
 EqNVB16rY_9SW1G04w>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedujedrleefgdeivdcutefuodetggdotefrodftvf
 curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
 uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
 fjughrpeffhffvuffkfhggtggujgesthdtredttddtvdenucfhrhhomhepvfihtghhohcu
 tehnuggvrhhsvghnuceothihtghhohesthihtghhohdrphhiiiiirgeqnecuggftrfgrth
 htvghrnhepffeukeekudejfefhjeevgeejgffhkefhffetleduvddufeekteelkeekhfef
 udejnecuffhomhgrihhnpehkvghrnhgvlhdrohhrghenucfkphepjeefrddvudejrddutd
 driedtnecuvehluhhsthgvrhfuihiivgeptdenucfrrghrrghmpehmrghilhhfrhhomhep
 thihtghhohesthihtghhohdrphhiiiiirg
X-ME-Proxy: <xmx:v86aX-deleWb_WUoPVBT6H1tUXs8CwIaQ4laEoaIkl33ZjElTKM8Sw>
 <xmx:v86aX4JetAcI6n-HyUpyOK3IAmlYy3J417lKsMNy92QdhV0XGvJ1sg>
 <xmx:v86aX7LN0Gwp4UcC67vCyA05O10ka2yDdXFgjqHYhe9Gr8TcpdTmfg>
 <xmx:wM6aX9hbw5ZcXSTUH0WAsy-Fa0cB6bjvXukWarUQVc99MTvT8MVhmGDmaTM>
Received: from cisco (c-73-217-10-60.hsd1.co.comcast.net [73.217.10.60])
 by mail.messagingengine.com (Postfix) with ESMTPA id B7423306467E;
 Thu, 29 Oct 2020 10:16:29 -0400 (EDT)
Date: Thu, 29 Oct 2020 08:16:28 -0600
From: Tycho Andersen <tycho@tycho.pizza>
To: Jann Horn <jannh@google.com>
Subject: Re: For review: seccomp_user_notif(2) manual page [v2]
Message-ID: <20201029141628.GC25673@cisco>
References: <63598b4f-6ce3-5a11-4552-cdfe308f68e4@gmail.com>
 <CAG48ez0fBE6AJfWh0in=WKkgt98y=KjAen=SQPyTYtvsUbF1yA@mail.gmail.com>
 <20201029020438.GA25673@cisco>
 <CAG48ez1Jz5YqqEMFYoFhgSroHwMeiNqUU9i=QqLN2uLibKthDQ@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CAG48ez1Jz5YqqEMFYoFhgSroHwMeiNqUU9i=QqLN2uLibKthDQ@mail.gmail.com>
Cc: Giuseppe Scrivano <gscrivan@redhat.com>, Song Liu <songliubraving@fb.com>,
 Will Drewry <wad@chromium.org>, Kees Cook <keescook@chromium.org>,
 Daniel Borkmann <daniel@iogearbox.net>, linux-man <linux-man@vger.kernel.org>,
 Robert Sesek <rsesek@google.com>,
 Containers <containers@lists.linux-foundation.org>,
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

On Thu, Oct 29, 2020 at 05:43:35AM +0100, Jann Horn wrote:
> On Thu, Oct 29, 2020 at 3:04 AM Tycho Andersen <tycho@tycho.pizza> wrote:
> > On Thu, Oct 29, 2020 at 02:42:58AM +0100, Jann Horn wrote:
> > > On Mon, Oct 26, 2020 at 10:55 AM Michael Kerrisk (man-pages)
> > > <mtk.manpages@gmail.com> wrote:
> > > >        static bool
> > > >        getTargetPathname(struct seccomp_notif *req, int notifyFd,
> > > >                          char *path, size_t len)
> > > >        {
> > > >            char procMemPath[PATH_MAX];
> > > >
> > > >            snprintf(procMemPath, sizeof(procMemPath), "/proc/%d/mem", req->pid);
> > > >
> > > >            int procMemFd = open(procMemPath, O_RDONLY);
> > > >            if (procMemFd == -1)
> > > >                errExit("\tS: open");
> > > >
> > > >            /* Check that the process whose info we are accessing is still alive.
> > > >               If the SECCOMP_IOCTL_NOTIF_ID_VALID operation (performed
> > > >               in checkNotificationIdIsValid()) succeeds, we know that the
> > > >               /proc/PID/mem file descriptor that we opened corresponds to the
> > > >               process for which we received a notification. If that process
> > > >               subsequently terminates, then read() on that file descriptor
> > > >               will return 0 (EOF). */
> > > >
> > > >            checkNotificationIdIsValid(notifyFd, req->id);
> > > >
> > > >            /* Read bytes at the location containing the pathname argument
> > > >               (i.e., the first argument) of the mkdir(2) call */
> > > >
> > > >            ssize_t nread = pread(procMemFd, path, len, req->data.args[0]);
> > > >            if (nread == -1)
> > > >                errExit("pread");
> > >
> > > As discussed at
> > > <https://lore.kernel.org/r/CAG48ez0m4Y24ZBZCh+Tf4ORMm9_q4n7VOzpGjwGF7_Fe8EQH=Q@mail.gmail.com>,
> > > we need to re-check checkNotificationIdIsValid() after reading remote
> > > memory but before using the read value in any way. Otherwise, the
> > > syscall could in the meantime get interrupted by a signal handler, the
> > > signal handler could return, and then the function that performed the
> > > syscall could free() allocations or return (thereby freeing buffers on
> > > the stack).
> > >
> > > In essence, this pread() is (unavoidably) a potential use-after-free
> > > read; and to make that not have any security impact, we need to check
> > > whether UAF read occurred before using the read value. This should
> > > probably be called out elsewhere in the manpage, too...
> > >
> > > Now, of course, **reading** is the easy case. The difficult case is if
> > > we have to **write** to the remote process... because then we can't
> > > play games like that. If we write data to a freed pointer, we're
> > > screwed, that's it. (And for somewhat unrelated bonus fun, consider
> > > that /proc/$pid/mem is originally intended for process debugging,
> > > including installing breakpoints, and will therefore happily write
> > > over "readonly" private mappings, such as typical mappings of
> > > executable code.)
> > >
> > > So, uuuuh... I guess if anyone wants to actually write memory back to
> > > the target process, we'd better come up with some dedicated API for
> > > that, using an ioctl on the seccomp fd that magically freezes the
> >
> > By freeze here you mean a killable wait instead of an interruptible
> > wait, right?
> 
> Nope, nonkillable.
> 
> Consider the case of vfork(), where a target process does something like this:
> 
> void spawn_executable(char **argv, char **envv) {
>   pid_t child = vfork();
>   if (child == 0) {
>     char path[1000];
>     sprintf(path, ...);
>     execve(path, argv, envv);
>   }
> }
> 
> and the seccomp notifier wants to look at the execve() path (as a
> somewhat silly example). The child process is just borrowing the
> parent's stack, and as soon as the child either gets far enough into
> execve() or dies, the parent continues using that stack.

Ah ha, yes. Thanks for the explanation.

Tycho
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
