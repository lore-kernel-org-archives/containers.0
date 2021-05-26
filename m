Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1A7B170
	for <containers@lists.linux.dev>; Wed, 26 May 2021 00:39:50 +0000 (UTC)
Received: by mail.kernel.org (Postfix) with ESMTPSA id 3E86B61417;
	Wed, 26 May 2021 00:39:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1621989590;
	bh=3zgyZ7zoBJ+hkeHoXCzHp9CwIXm2cdXOf80HROm53hY=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=fkm9ndfDupj8s5n/4/6rrAbb+eXW8zopJv1M6OxIOCLl0dR0AJSykkdvHQxT+jJ0Z
	 ciVWVIBJURvGSJ6DNr1baOyoLzh2SwFOgpv9W7HTmsHop4Uf09bysR6SxtUyDbq2Zh
	 knYV2NZc6y94jO2lvi0j0SnP8g249qvncNbZRL+v3ajjvJo7CZbzODOixOr8kiopth
	 ghq/iBkPoGZI0ZfIldDGx3zIEtXu1vYGfwgTQDjJrJOcj2jK+SBbD1rn1xBOGV0OrM
	 rUpSUYqWnokjh1aUMK69iHloimM14dWIuG6A2wX6v71YZizpcQUF+u6ze/ww2LNGHA
	 cDc3UlqUmYe8A==
Subject: Re: Preemption Signal Management
To: Sargun Dhillon <sargun@sargun.me>,
 Linux Containers <containers@lists.linux.dev>,
 LKML <linux-kernel@vger.kernel.org>
Cc: Kees Cook <keescook@chromium.org>,
 Christian Brauner <christian.brauner@ubuntu.com>,
 Tycho Andersen <tycho@tycho.pizza>, Giuseppe Scrivano <gscrivan@redhat.com>,
 Rodrigo Campos <rodrigo@kinvolk.io>,
 =?UTF-8?Q?Mauricio_V=c3=a1squez_Bernal?= <mauricio@kinvolk.io>
References: <CAMp4zn93WRF5u=et=detunN7exhQNoFctr-7Qb8-a9=As8vaQw@mail.gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Message-ID: <f9e0126e-2bd4-eda4-0c07-9393d56d1421@kernel.org>
Date: Tue, 25 May 2021 17:39:49 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101
 Thunderbird/78.10.1
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
In-Reply-To: <CAMp4zn93WRF5u=et=detunN7exhQNoFctr-7Qb8-a9=As8vaQw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit

On 5/21/21 9:23 AM, Sargun Dhillon wrote:
> Andy pointed out that we need a mechanism to determine whether or
> notifications are preempted. He suggested we use EPOLLPRI to indicate
> whether or not notifications are preempted. My outstanding question is
> whether or not we need to be able to get insight of what caused the
> preemption, and to which notification.
> 
> In the past, Christian has suggested just background polling
> notification IDs for validity, which is a fine mechanism to determine
> that preemption has occurred. We could raise EPOLLPRI whenever a
> notification has changed into the preempted state, but that would
> require an O(n) operations across all outstanding notifications to
> determine which one was preempted, and in addition, it doesn't give a
> lot of information as to why the preemption occurred (fatal signal,
> preemption?).
> 
> In order to try to break this into small parts, I suggest:
> 1. We make it so EPOLLPRI is raised (always) on preempted notifications
> 2. We allow the user to set a flag to "track" notifications. If they
> specify this flag, they can then run a "stronger" ioctl -- let's say
> SECCOMP_IOCTL_NOTIF_STATUS, which, if the flag was specified upon
> receiving the notification will return the current state of the
> notification and if a signal preempted it, it will always do that.
> 
> ---
> Alternatively (and this is my preference), we add another filter flag,
> like SECCOMP_FILTER_FLAG_NOTIF_PREEMPT, which changes the behaviour
> to:
> 1. Raise EPOLLPRI on preempted notifications
> 2. All preemption notifications must be cleared via
> SECCOMP_IOCTL_NOTIF_RECV_STATUS.

This seems sensible, except I don't think "preempted" is the right word.
 The state machine is pretty simple:

live -> signaled -> killed

(and we can go straight from live to killed, too.)  So EPOLLPRI could be
signaled if any notification changes state, and a new ioctl could read
the list of notifications that have changed state.

--Andy
