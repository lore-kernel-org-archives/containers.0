Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E24F770
	for <containers@lists.linux.dev>; Fri, 21 May 2021 15:44:51 +0000 (UTC)
Received: by mail.kernel.org (Postfix) with ESMTPSA id AD34A613EC;
	Fri, 21 May 2021 15:44:48 +0000 (UTC)
Date: Fri, 21 May 2021 17:44:45 +0200
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Sargun Dhillon <sargun@sargun.me>
Cc: Kees Cook <keescook@chromium.org>, LKML <linux-kernel@vger.kernel.org>,
	containers@lists.linux.dev, Tycho Andersen <tycho@tycho.pizza>,
	Andy Lutomirski <luto@kernel.org>,
	Mauricio =?utf-8?Q?V=C3=A1squez?= Bernal <mauricio@kinvolk.io>,
	Rodrigo Campos <rodrigo@kinvolk.io>,
	Giuseppe Scrivano <gscrivan@redhat.com>,
	=?utf-8?Q?Micka=C3=ABl_Sala=C3=BCn?= <mic@linux.microsoft.com>
Subject: Re: [PATCH v2 0/4] Atomic addfd send and reply
Message-ID: <20210521154445.yz26ja35t3ux7m6j@wittgenstein>
References: <20210517193908.3113-1-sargun@sargun.me>
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20210517193908.3113-1-sargun@sargun.me>

On Mon, May 17, 2021 at 12:39:04PM -0700, Sargun Dhillon wrote:
> This is somewhat of a respin of "Handle seccomp notification preemption"
> but without the controversial parts.
> 
> 
> This patchset addresses a race condition we've dealt with recently with
> seccomp. Specifically programs interrupting syscalls while they're in
> progress. This was exacerbated by Golang's recent adoption of "async
> preemption", in which they try to interrupt any syscall that's been running
> for more than 10ms during GC. During certain syscalls, it's non-trivial to
> write them in a reetrant manner in userspace (socket).
> 
> It focuses on one use cases, which is adding file descriptors to a process
> "atomically" during the seccomp reply, as opposed to discretizing the calls
> which may result in a potential file descriptor leak and inconsistent
> program state.

Looks good,
Acked-by: Christian Brauner <christian.brauner@ubuntu.com>
