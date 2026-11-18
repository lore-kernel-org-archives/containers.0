Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.remote-ip=209.85.167.53
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=fail;
	t=1795038587;
	b=zO3N1KfAsFUZqcu4ds8d0LozXuOH24YOV/5yi4KHGaz5UFJjp64viPP1dmQS4+yBS6DE
	 YQikLrVrOiC6eoX2XmZRMODK2lqWN8hphQR5ZCVmXFNxl29ZOUc+RyPkp75GZd46wNoZK
	 eZOhG5x12dm+nnbvtEzHQau5sxYmvekfTqlvc8kNmvSdCc1wEpQ6euMfaAYql9nM55KIN
	 IV5vSMSeN4nkdqJBXVo4TxTx7gta6yMhoSDClSB76M1FRJ2wN9DUK+aD441yC/qkCnOSU
	 HIiPEB8UTf72RHiYdo5yfK4QfYQCr+nup2q2hMjjagB8FJoKPzIX/jJ7mlK2f6D77ZQ==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795038587;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=CZPHqjEKi2vg5bpASOGDI+kJVhoG5JNXko8FEV4Oxfg=;
	b=Msft6SGLynyRelRO1WRIC9Hp6cbCIcTtcBTwEfkiLgiNfOUVQg5D5bILGGecKpahWVc1
	 TBxDAC461LIbmepqZs+jR+1BXxha4Ze/fcAPmgzp87MtfLkv4w+fuv9D9QAAYLGh4VwoC
	 T0cvMm+YzFP5xGsI2oermA1widd2UHaESq0sh4Pl+gVDYRv7r9ZxDGOkH81+IgJDQqQDJ
	 4ULFTc8mh2CKb3TKzOi2n4kIu79gpuvfPoa9DV9OFWCHbUVUVCU9j8JlqiJBFpze2TL8r
	 X9rIBPDj4dCjHbovRhwZjOtWWa9swZPLgcEk49xBPushsNqPIsg+Z1WBZTHn9rJ6cGA==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=none header.from=amacapital.net;
	spf=pass smtp.mailfrom=amacapital.net;
	dkim=pass header.d=amacapital-net.20260707.gappssmtp.com header.i=@amacapital-net.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=JtGzWSlx;
	arc=fail smtp.remote-ip=209.85.167.53
Received: from mail-lf1-f53.google.com (mail-lf1-f53.google.com [209.85.167.53])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9BC44606A333
	for <containers@lists.linux.dev>; Wed, 18 Nov 2026 21:49:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 9BC44606A333
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amacapital.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=amacapital-net.20260707.gappssmtp.com header.i=@amacapital-net.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=JtGzWSlx
Received: by mail-lf1-f53.google.com with SMTP id 2adb3069b0e04-5be4fea434bso266871e87.1
        for <containers@lists.linux.dev>; Wed, 18 Nov 2026 13:49:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795038585; cv=none;
        d=google.com; s=arc-20260327;
        b=fJHoi2UvLPmCpiFRGtpQNUQ4lOY8pK+cH6A35kfCIQatwBATgLr/pSwbvj+gyXP0iG
         qR9pkM4zB2yKhm3qeOLmMTfj5a0yqAXJEiDe5M4BwEtQ5TlhMQ+SciohXe/9EdRw7yUP
         WPGZnFt+UJjxCAmluh8MFdBxdJy5u8wIm6t2p4ekCRMlB477Yqj2CCP1tTLJ1fTGR6Nf
         1Zbfo/n6Vb9ZSvSxzXLMSvKCEPg8h9TKRtwqdwO8ru5Ntxp/FaUWbagx1ZOcRuC9UhIu
         2ZbPHxTTjpRsC6eEBzpZ2UKEqRrlD6rEfu9NJ0+jZ44L2Zlo6+JcnBRPCQ1QR67Gw+Zx
         NV7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=CZPHqjEKi2vg5bpASOGDI+kJVhoG5JNXko8FEV4Oxfg=;
        fh=5yDBlUXn+mM1NG69ombsIwhioin43EM4TuqbPRX+4Vg=;
        b=G+fWyDmoXi/qMN5uoGwqMQbJMPiHq+wG3ZCUGz3Xm27VJYFCc8E7OX/GMFSfCGtrhx
         LNFpMhe+QZ/5YTJIv2MGqzpsGNqsUsh4c2xiKIldhbGO/tcJWctikP5DV5GT0NnJ/6JO
         1tLBjf5oRdvDt1X1fDwgDcZqXvkFO9V5HK+SHxqy/A5tTl6n9fhfBRSt+Ne83lxKP0sV
         B1rjH+eUTZSKJU5uI1TWV6hCEt6RbeFYrJb1dW3ew/mnbu3L/XF+62mKjT4uRzzl7J/b
         Fuxpm1zps8dB4aZ8ssUHbS9eDryzeQW94N1aaLPXuYJO2SrR0Utox/as6zF3FNASxmod
         hdHg==;
        darn=lists.linux.dev
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20260707.gappssmtp.com; s=20260707; t=1795038585; x=1795643385; darn=lists.linux.dev;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=CZPHqjEKi2vg5bpASOGDI+kJVhoG5JNXko8FEV4Oxfg=;
        b=JtGzWSlxLvx1+qrHotdfFwTVh2ALXFLxkPVKKBTolskLgH2aPBNubAyE2w9Xrxi35j
         Tt/2N19DTIunG+ISfuB4TQSgvEX6uXZJqG6IzP2gVR1KN5TLrTcj06LHUQKIhKVaym0G
         YO0wiPBnac7emw1xshm132/kopxcOwpWLA2hZmIyK0MDAvRmNd/V+Y4dchDve/9tqQSN
         0VbkmH2RStonRWi4B6rsuVysSqDGVo1yGJ9o9G8J00FQjvxNybAYhRznZMLqbmOtcbfD
         jUaelz5Wasn9Ou2ss9eV5x/6W6I4lCdvxNZXDPoctkXY+bZUaY4+HiqJWRLlNImvk85s
         XUZw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795038585; x=1795643385;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=CZPHqjEKi2vg5bpASOGDI+kJVhoG5JNXko8FEV4Oxfg=;
        b=ia78yqjE1krgL5/kvO+M8nJEm7mIT68X9V1DAZYauYTyMI4q/DWNTXoXSZtFoO84MT
         BCKs4GDFoIuEBnzO8/BdkSDR0vLjTDeHrxBLrfhhiMV5Xmxl7WueUrTTmOkFO49TGmpc
         yEH9EXQHF4760sGqMJhZdy2gxgKhj+mBYo3jvBkP9GSuRfeUSCwQ+OYTx9et0bTUnEcz
         D3q6ygV1Hy20jgq045hWQcmXdVbnDDcZQuAZTAHlVFgDQ5swrV99Og7aFDLCTHxTENFu
         o/PFQsY+nV+wE68zoDm5kJ1RfjbL1Pjp3Tf1uKiLFA88q1Xd2tI6ZIetrpyIJannqwGE
         ZR5Q==
X-Forwarded-Encrypted: i=1; AL+hErEbVpUsa1QF5wbUcrsLpUh2+o3ZE7uPagOsIICRi7n2Yh/8NQhGS2hdBCNHGRNw/gLOW2IHLnlcapTg@lists.linux.dev
X-Gm-Message-State: APuU4Z/YFVcYfPc063/cIcwIjLX0Ig6buVVxoz/9HdUKvy3dzksO02X0
	tl7sU7F+isGjILlY9Dqi8YX4ILI+f+2tzNpSjl2ES0A4gHsbeJzMb0a2UoPOGWH4c5z4dBC603+
	2PNWE3HMToHa1cGH/cSltufI5MmBujtxTNjm+4h32
X-Gm-Gg: AYBFou0rnzoFUnMQ2UWizSmvIXt797tpvJ9JHT0g5DMLNKSC8a7MrbYc97RjzmAISo4
	9clqU0wd3zivw1FUFIe9nTUcMIJoLdbE76yVoWLNtV5b5aNi4JuQ6nFc34AOxO2MzC63PVMy1JQ
	fZVFU6rqTdRX7RD/+2nztPG7Dd1qZJcRTHFT3skwMMiZmCm/8VArveCtQn/+il5X8Th4eDOkFHE
	S1eOniyMpfAof6QKiVXfT50arz+SKsm9TFS1yL6WzvoQMqXaDswT2sz+X7q5752vNlMBnin8Ocq
	eZNg1jf/UC88JgZShqgShXsQviViDE+PhmBYtdCEpF/c7T70Nu6s8Mc4EgHSUP8D2br29+8p/KP
	MZHO0D3sqbyjzYIuHsRAqXmMl+WAv/+RTnA==
X-Received: by 2002:a05:6512:3c8e:b0:5c1:ac5f:e596 with SMTP id
 2adb3069b0e04-5c1b40e9b72mr9362e87.23.1795038584801; Wed, 18 Nov 2026
 13:49:44 -0800 (PST)
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Post: <mailto:containers@lists.linux.dev>
List-Help: <mailto:containers+help@lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
List-Owner: <mailto:containers+owner@lists.linux.dev>
Precedence: list
MIME-Version: 1.0
References: <20261106-befreien-addieren-eislauf-e09212803534@brauner>
 <CALCETrWa1SBLcb5oWjqjgzZvKvCoHjmYFk=Lf5ytEM9uqm5jYA@mail.gmail.com>
 <avM41a80aig2de-R@google.com> <20261111-behagen-faktisch-entgegen-e2e714373895@brauner>
 <CALCETrUjW=kXxyggDUvEN+Pxc-pE98eVbdW8XBU8JzfqXj_voA@mail.gmail.com>
 <20261117-rational-ohnehin-unbeugsam-e5c04759a156@brauner>
 <CALCETrWhuOnBy0N0KznmczD4S2XEK0fbr0C=1KFQqTnoTJbQbg@mail.gmail.com>
 <20261118-stapeln-eckpunkte-lesbar-ee73537f474d@brauner> <20261118-zufahrt-baubeginn-gutsbetrieb-c09004227e8f@brauner>
 <CALCETrUMNr=32ENT6VBKPzoyJDfaX6nzZsjMVxuz9O3z+6LRhw@mail.gmail.com> <20261118-professionell-kondition-kerzen-5dd23c1ee490@brauner>
In-Reply-To: <20261118-professionell-kondition-kerzen-5dd23c1ee490@brauner>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 18 Nov 2026 13:49:32 -0800
X-Gm-Features: Aa3M54rEY9J5hVHcO1DPxjhsi7Vv-UveBjN-XrYjaJlUs9gt6QOZEnzJ-89YhLo
Message-ID: <CALCETrXAGpb=OZyGQ2=VfKmA6xeizAsusGZ_HmRtp_s99RpRJA@mail.gmail.com>
Subject: Re: [PATCH 0/8] userns: per-namespace capability bounding set and
 opt-in netns loopback
To: Christian Brauner <brauner@kernel.org>
Cc: lennart@poettering.net, Jann Horn <jannh@google.com>, 
	"Hallgrimur H. Gunnarsson" <halg@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, 
	Paul Moore <paul@paul-moore.com>, Serge Hallyn <sergeh@kernel.org>, Kees Cook <kees@kernel.org>, 
	"David S . Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, 
	Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, Jan Kara <jack@suse.cz>, 
	James Morris <jmorris@namei.org>, Simon Horman <horms@kernel.org>, Jonathan Corbet <corbet@lwn.net>, 
	Shuah Khan <skhan@linuxfoundation.org>, Randy Dunlap <rdunlap@infradead.org>, 
	=?UTF-8?Q?G=C3=BCnther_Noack?= <gnoack@google.com>, 
	KP Singh <kpsingh@kernel.org>, Jonathan Calmels <jcalmels@3xx0.net>, 
	Casey Schaufler <casey@schaufler-ca.com>, linux-fsdevel@vger.kernel.org, 
	linux-security-module@vger.kernel.org, linux-api@vger.kernel.org, 
	containers@lists.linux.dev, netdev@vger.kernel.org, linux-doc@vger.kernel.org, 
	linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, Nov 18, 2026 at 1:37=E2=80=AFPM Christian Brauner <brauner@kernel.o=
rg> wrote:
>
> On Wed, Nov 18, 2026 at 01:12:45PM -0800, Andy Lutomirski wrote:

> > > > * deny privilege gain on exec in the initial user namespace and all=
ow it
> > > >   in nested ones. I mused about this in
> > > >   https://github.com/uapi-group/kernel-features/pull/38
> > > >
> > > > Also, since v7.1 there's CLONE_NNP to spawn a child without no_new_=
privs
> > > > set.
> > >
> > > Forgot:
> > >
> > > https://www.thkukuk.de/blog/no_new_privs/
> > >
> > > has an overview of where we're currently at.
> >
> > Nice!
> >
> > I commented in the uapi-group issue:
> >
> > I think there may be a rather more direct solution to this problem. I
> > seem to recall advocating for clearing no_new_privs when entering a
> > userns way back when, and IIRC I dropped this as part of the extensive
> > negotiation to get NNP into the kernel in the first place. (I think
> > dropping it was probably the right decision to keep the final patch
> > simple.)
> >
> > But I think I would still advocate for an option to let clone, unshare
> > and setns callers turn no_new_privs off. The logic is that, if you own
> > a userns, you already have all capabilities in it. If you enter it,
> > you get to keep those by having them raised in cap_permitted. Being
> > able to clear NNP and thus drop and subsequently regain them does not
> > let you do anything you couldn=E2=80=99t already do.
> >
> > An LSM hook for this would be needed because this argument does not
> > apply to non-namespace-scoped LSM-based privileges. But the LSM hook
> > would just be a "may this caller enter this userns and clear
> > no_new_privs while doing so" query. In the absence of LSMs, the
> > operation would be allowed.
> >
> > This would allow a fully no_new_privs host to run an ordinary
> > container that runs, in the ordinary way, without no_new_privs, and
> > without hitting any new LSM calls after it's started.
> >
> > The API could be as simple as a CLONE_CLEAR_NNP bit.
>
> I think that sounds ok. I worry a little it since it would somewhat
> alter the promise that NNP gives. What model do you envision?
> It seems that CLONE_CLEAR_NNP would only be allowed with CLONE_NEWUSER.
> I _think_ this safe even for privileged users that create a user
> namespace and map uid 0 to uid 0. So I think this could work.

Whoops.  I thought that and didn't type that.  Yes, I think you should
only be able to clear NNP with CLONE_NEWUSER.

(And if something like cells ever lands, presumably a task with NNP
set should be allowed to create a cell without NNP in the init task as
long as the same LSM hook says it's okay.)
