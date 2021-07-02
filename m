Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2A12870
	for <containers@lists.linux.dev>; Fri,  2 Jul 2021 15:22:08 +0000 (UTC)
Received: by mail.kernel.org (Postfix) with ESMTPSA id 6665761206;
	Fri,  2 Jul 2021 15:22:05 +0000 (UTC)
Date: Fri, 2 Jul 2021 17:22:03 +0200
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Rodrigo Campos <rodrigo@kinvolk.io>
Cc: Kees Cook <keescook@chromium.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Will Drewry <wad@chromium.org>, linux-kernel@vger.kernel.org,
	containers@lists.linux.dev, Alban Crequy <alban@kinvolk.io>,
	Mauricio =?utf-8?Q?V=C3=A1squez?= Bernal <mauricio@kinvolk.io>,
	Sargun Dhillon <sargun@sargun.me>
Subject: Re: [PATCH] Documentation: seccomp: Fix typo in user notification
Message-ID: <20210702152203.injvt65gceq43swo@wittgenstein>
References: <20210702151927.263402-1-rodrigo@kinvolk.io>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20210702151927.263402-1-rodrigo@kinvolk.io>

On Fri, Jul 02, 2021 at 05:19:27PM +0200, Rodrigo Campos wrote:
> The close on exec flag is O_CLOEXEC, not O_EXEC. This patch just fixes
> the typo.
> 
> Suggested-by: Christian Brauner <christian.brauner@ubuntu.com>
> Signed-off-by: Rodrigo Campos <rodrigo@kinvolk.io>
> ---

Acked-by: Christian Brauner <christian.brauner@ubuntu.com>
