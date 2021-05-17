Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com [66.111.4.25])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9AFAF70
	for <containers@lists.linux.dev>; Mon, 17 May 2021 18:10:41 +0000 (UTC)
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id D6AE65C0194;
	Mon, 17 May 2021 14:10:40 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute2.internal (MEProxy); Mon, 17 May 2021 14:10:40 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tycho.pizza; h=
	date:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm3; bh=staAu2NQSD+sUEvD6aPKW7Ph2gm
	xQzl1MyMLLgSmbIw=; b=3RDlHGPrfd1Khe9wxpViyXgqUn1BL+UvWv4TGjZ/QYS
	kLi699KaIqzt6UCcbJl9oytmRhI2ww0nvVwVevbxOFysJXv+P9bVyzryOoY53iul
	dCZS7FsbgSAdHzEJSPjnxdftKn6E9uDkjBxfwGhyOEX28H3qVl5htl7ht6cb3kNs
	0WIvLkmlPGdfAuH5AwTyaAd3I13dyRqwzBdcZlilwSyBj4shjTm6bKtv9FKRxOpy
	h0uaF2oI1DmDeKi5N+JKK6B0yaLYBXkuE1Xlvp11KXYdDgRcxhA+EcBjZLO2Y1eB
	LvGdOEbBUg71gvzhLPIvuCFvZZUXVQfnKD/jaeOV9Ow==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=staAu2
	NQSD+sUEvD6aPKW7Ph2gmxQzl1MyMLLgSmbIw=; b=QWPTUklssD8iMmMu7zqjP/
	kbcVPYoZB3wfVji1aRotB/ty6pkO6i+yzYKrzVhW+mWy/boQOMMHavIFG0xA1+hn
	J3SdUKfch/NO6wQmHxFijBfppDAia5nbH5ogqtFDptlGZup80zhCu5579ZDVj//Z
	+5nLP6H4YKMkAdGDVmd1Zu2fwF/baVTJskol3qn70Zv64l7EcFXgAl9CKK2spkkO
	Q9hDBykBFtx5nxbisOA0c4EiY4clroAFggBH1B6Ektl3kXE/+Bscz5S71yHca8fr
	up6lWnjlTy0/MUdkDoPuntnm69Vuy7RHCw4wplTEHn7eQFW4DrR/nGTphD/lXhfw
	==
X-ME-Sender: <xms:n7GiYGSX7cO8sbFs-w4rkfV4PyZHVN4MiRiUcH4QZUFaTGd4-FHYYw>
    <xme:n7GiYLxpU3JxymrxLIg_WVOzx9pM3amDWSYpBqCv2fXYArST42NGhyH4TkN_yUg6q
    tUmyORRVdUXyvseorw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduledrvdeihedguddvtdcutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfgh
    necuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmd
    enucfjughrpeffhffvuffkfhggtggujgesthdtredttddtvdenucfhrhhomhepvfihtghh
    ohcutehnuggvrhhsvghnuceothihtghhohesthihtghhohdrphhiiiiirgeqnecuggftrf
    grthhtvghrnhepgeekfeejgeektdejgfefudelkeeuteejgefhhfeugffffeelheegieef
    vdfgtefhnecukfhppeduvdekrddutdejrddvgedurddujeegnecuvehluhhsthgvrhfuih
    iivgeptdenucfrrghrrghmpehmrghilhhfrhhomhepthihtghhohesthihtghhohdrphhi
    iiiirg
X-ME-Proxy: <xmx:n7GiYD1FMxeBCstzj_0EYyjRZGQznwUt2xTFYVOR75bzGxCW-LG8cw>
    <xmx:n7GiYCC1KPDc0aB4ReyJEzfYRvKtEmyu8szSDIcHIhcnAoxGlTpymw>
    <xmx:n7GiYPii08k2lf8BkiqJQl_FzpHLoSPwNMQc7pbh4o_Qk94WrUSWYg>
    <xmx:oLGiYPjamglJnJGNDhu6SeNT8xoBzVBmJ9DXYkG3F4yxXeGGQTbaHw>
Received: from cisco (unknown [128.107.241.174])
	by mail.messagingengine.com (Postfix) with ESMTPA;
	Mon, 17 May 2021 14:10:37 -0400 (EDT)
Date: Mon, 17 May 2021 12:10:35 -0600
From: Tycho Andersen <tycho@tycho.pizza>
To: Sargun Dhillon <sargun@sargun.me>
Cc: Kees Cook <keescook@chromium.org>, LKML <linux-kernel@vger.kernel.org>,
	Linux Containers <containers@lists.linux.dev>,
	Andy Lutomirski <luto@kernel.org>,
	Rodrigo Campos <rodrigo@kinvolk.io>,
	Mauricio =?iso-8859-1?Q?V=E1squez?= Bernal <mauricio@kinvolk.io>,
	Giuseppe Scrivano <gscrivan@redhat.com>,
	Christian Brauner <christian.brauner@ubuntu.com>,
	=?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@linux.microsoft.com>
Subject: Re: [PATCH 3/4] seccomp: Support atomic "addfd + send reply"
Message-ID: <20210517181035.GH1964106@cisco>
References: <20210502001851.3346-1-sargun@sargun.me>
 <20210502001851.3346-4-sargun@sargun.me>
 <20210511215010.GB1964106@cisco>
 <CAMp4zn-crcdi6AR9VfAmpb0TO9sDtpdwA4C59ERqwdoQW7yTAg@mail.gmail.com>
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMp4zn-crcdi6AR9VfAmpb0TO9sDtpdwA4C59ERqwdoQW7yTAg@mail.gmail.com>

On Mon, May 17, 2021 at 10:53:55AM -0700, Sargun Dhillon wrote:
> On Tue, May 11, 2021 at 2:50 PM Tycho Andersen <tycho@tycho.pizza> wrote:
> > > The struct seccomp_notif_resp, used when doing SECCOMP_IOCTL_NOTIF_SEND
> > > ioctl() to send a response to the target, has three more fields that we
> > > don't allow to set when doing the addfd ioctl() to also return. The
> > > reasons to disallow each field are:
> > >  * val: This will be set to the new allocated fd. No point taking it
> > >    from userspace in this case.
> > >  * error: If this is non-zero, the value is ignored. Therefore,
> > >    it is pointless in this case as we want to return the value.
> > >  * flags: The only flag is to let userspace continue to execute the
> > >    syscall. This seems pointless, as we want the syscall to return the
> > >    allocated fd.
> > >
> > > This is why those fields are not possible to set when using this new
> > > flag.
> >
> > I don't quite understand this; you don't need a NOTIF_SEND at all
> > with the way this currently works, right?
> >
> I reworded:
> 
> This effectively combines SECCOMP_IOCTL_NOTIF_ADDFD and
> SECCOMP_IOCTL_NOTIF_SEND into an atomic opteration. The notification's
> return value, nor error can be set by the user. Upon successful invocation
> of the SECCOMP_IOCTL_NOTIF_ADDFD ioctl with the SECCOMP_ADDFD_FLAG_SEND
> flag, the notifying process's errno will be 0, and the return value will
> be the file descriptor number that was installed.
> 
> How does that sound?

Works for me, thanks!

> > > @@ -1113,7 +1136,7 @@ static int seccomp_do_user_notification(int this_syscall,
> > >                                                struct seccomp_kaddfd, list);
> > >               /* Check if we were woken up by a addfd message */
> > >               if (addfd)
> > > -                     seccomp_handle_addfd(addfd);
> > > +                     seccomp_handle_addfd(addfd, &n);
> > >
> > >       }  while (n.state != SECCOMP_NOTIFY_REPLIED);
> > >
> >
> > This while() bit is introduced in the previous patch, can we fold this
> > deletion into that somehow?
> I'm not sure what you're getting at. This just an argument change which
> also passes the notification to the addfd function. The patch is split out
> to allow it to be backported to stable.

Yeah, I was mis-reading, you can ignore this. Sorry for the noise.

If you send another version, you can call the series:

Acked-by: Tycho Andersen <tycho@tycho.pizza>

Tycho
