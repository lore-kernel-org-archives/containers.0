Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DD8B12FAD
	for <containers@lists.linux.dev>; Thu, 27 May 2021 13:06:49 +0000 (UTC)
Received: by mail.kernel.org (Postfix) with ESMTPSA id 151D360FE3;
	Thu, 27 May 2021 13:06:45 +0000 (UTC)
Date: Thu, 27 May 2021 15:06:43 +0200
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Kees Cook <keescook@chromium.org>
Cc: linux-kernel@vger.kernel.org, Sargun Dhillon <sargun@sargun.me>,
	containers@lists.linux.dev, Tycho Andersen <tycho@tycho.pizza>,
	Rodrigo Campos <rodrigo@kinvolk.io>,
	Mauricio =?utf-8?Q?V=C3=A1squez?= Bernal <mauricio@kinvolk.io>,
	Giuseppe Scrivano <gscrivan@redhat.com>,
	=?utf-8?Q?Micka=C3=ABl_Sala=C3=BCn?= <mic@linux.microsoft.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Will Drewry <wad@chromium.org>
Subject: Re: [PATCH] selftests/seccomp: More closely track fds being assigned
Message-ID: <20210527130643.zbkcupofjwryjjm5@wittgenstein>
References: <20210527032948.3730953-1-keescook@chromium.org>
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20210527032948.3730953-1-keescook@chromium.org>

On Wed, May 26, 2021 at 08:29:48PM -0700, Kees Cook wrote:
> Since the open fds might not always start at "4" (especially when
> running under kselftest, etc), start counting from the first assigned
> fd, rather than using the more permissive EXPECT_GE(fd, 0).
> 
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---

Looks good,
Acked-by: Christian Brauner <christian.brauner@ubuntu.com>
