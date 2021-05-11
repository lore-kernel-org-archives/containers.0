Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com [64.147.123.25])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 84E1971
	for <containers@lists.linux.dev>; Tue, 11 May 2021 21:50:17 +0000 (UTC)
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id 411CF179C;
	Tue, 11 May 2021 17:50:16 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Tue, 11 May 2021 17:50:16 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tycho.pizza; h=
	date:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm3; bh=iTB27FskG3qCZ/2+bDx/QlZWQqb
	cFgHZ/tiyid5nlZI=; b=7wOTtwaBCKi2Ph3V7Bp4qMNOOqG+9iAw7K2WYx0ZMY2
	1DJxVEVwVrm/LLM6oNsp07CN/qc76Y3WgW5m0N4XKnLYzv6JyTWWiDo3iONQT3z4
	FrTsdhnCwS1a2AyHoRbt8AkaX7GEZFBKyXd1VK3stqcR/TYac1qKew+mVG0yj+ox
	2Y0TfZ6nQTn7ntugviIRC/z5HmmzHdtR0JOmvo2TsWOGIeZxHtKWPSx+ylG72eCj
	IRiMjThdighylcMGhbs/obPyynJWta2Ac8tsGBUrYWP7296Kl9dS65bV5gCO9d1L
	WKiSiHlDsucoM2IzKXJZ4l6d/M60tJa4dZmIIegsKzg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=iTB27F
	skG3qCZ/2+bDx/QlZWQqbcFgHZ/tiyid5nlZI=; b=gfRlOifrWLAtiISTbrk8TX
	MhLuJ0GVYscP6MPJVvVP9NbMBg7jLtyka6pVCQ/Hq8y6tgrYrxDGoYjO/QnGKPw8
	DcBuZPw5pWPiTvMGeFvfHi0VZpqoraH5cfs0YawHI1gHJc9++EmGjhas/sXltSjL
	jinfgoV7vdqXpqUut7ZUFLGvmcxTT/diAVUlSFIUhviJrpiAs4ov9ILXFrxPRcQ4
	HWJPmMJ8i+prsdypFG7Y7XVCEu9dJmV+dc6okplURcuxFbJtpGcb86MRLBbGQ6QK
	BsfF8aDj8B8qrLLeFdRbrFFFdYiB53mpz4/b0G98EzV6EBC/NgtIQPV8SZY/QMcA
	==
X-ME-Sender: <xms:F_yaYJ-IXBmopj3q39YpU_7Svquf8PwQTGtLVz6eNjzlo-pGmK6hJw>
    <xme:F_yaYNshrwshbFYUDXGK4l9Pl_I8Kz-ZuMB2KE3w2wICM5avCvDrWf104GgOMXrQW
    8XMI_Kt0h6p5OTkBbY>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduledrvdehuddgtddvucetufdoteggodetrfdotf
    fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfqfgfvpdfurfetoffkrfgpnffqhgen
    uceurghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmne
    cujfgurhepfffhvffukfhfgggtuggjsehttdertddttddvnecuhfhrohhmpefvhigthhho
    ucetnhguvghrshgvnhcuoehthigthhhosehthigthhhordhpihiiiigrqeenucggtffrrg
    htthgvrhhnpeegkeefjeegkedtjefgfeduleekueetjeeghffhuefgffefleehgeeifedv
    gfethfenucfkphepuddvkedruddtjedrvdeguddrudejieenucevlhhushhtvghrufhiii
    gvpedtnecurfgrrhgrmhepmhgrihhlfhhrohhmpehthigthhhosehthigthhhordhpihii
    iigr
X-ME-Proxy: <xmx:F_yaYHCEQGkr_49ALjrWzFHv2hSaMaKUdLRbow1YEX4KV7kzdUHAJg>
    <xmx:F_yaYNdvmEOUAzcYtgn52UB95jJAO1NUa2K3yckU3_49t7fCmQOnmA>
    <xmx:F_yaYOOM2oQxNCLYH5EUNRG4bg5cK3XqmgIWYiUNK7XUgXkm6OaxVA>
    <xmx:F_yaYNfYYL_nrzbe4OnTWDVsHzie_VwKWLYMSbVxc-S49DBtcFBUbg>
Received: from cisco (unknown [128.107.241.176])
	by mail.messagingengine.com (Postfix) with ESMTPA;
	Tue, 11 May 2021 17:50:12 -0400 (EDT)
Date: Tue, 11 May 2021 15:50:10 -0600
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
Message-ID: <20210511215010.GB1964106@cisco>
References: <20210502001851.3346-1-sargun@sargun.me>
 <20210502001851.3346-4-sargun@sargun.me>
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20210502001851.3346-4-sargun@sargun.me>

Hi,

On Sat, May 01, 2021 at 05:18:50PM -0700, Sargun Dhillon wrote:

[snip]

> Other patches in this series add a way to block signals when a syscall
> is put to wait by seccomp.

I guess we can drop this bit from the message if the series is split.

> The struct seccomp_notif_resp, used when doing SECCOMP_IOCTL_NOTIF_SEND
> ioctl() to send a response to the target, has three more fields that we
> don't allow to set when doing the addfd ioctl() to also return. The
> reasons to disallow each field are:
>  * val: This will be set to the new allocated fd. No point taking it
>    from userspace in this case.
>  * error: If this is non-zero, the value is ignored. Therefore,
>    it is pointless in this case as we want to return the value.
>  * flags: The only flag is to let userspace continue to execute the
>    syscall. This seems pointless, as we want the syscall to return the
>    allocated fd.
> 
> This is why those fields are not possible to set when using this new
> flag.

I don't quite understand this; you don't need a NOTIF_SEND at all
with the way this currently works, right?

> @@ -1113,7 +1136,7 @@ static int seccomp_do_user_notification(int this_syscall,
>  						 struct seccomp_kaddfd, list);
>  		/* Check if we were woken up by a addfd message */
>  		if (addfd)
> -			seccomp_handle_addfd(addfd);
> +			seccomp_handle_addfd(addfd, &n);
>  
>  	}  while (n.state != SECCOMP_NOTIFY_REPLIED);
>  

This while() bit is introduced in the previous patch, can we fold this
deletion into that somehow?

Thanks,

Tycho
