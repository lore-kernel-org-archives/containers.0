Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CA9A633EC
	for <containers@lists.linux.dev>; Wed, 25 Jan 2023 23:36:43 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 51763C433D2;
	Wed, 25 Jan 2023 23:36:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=linux-foundation.org;
	s=korg; t=1674689803;
	bh=1nARB3FTAdYjtZqX7vYONUeuqTdddfC0dxS1JOmypwQ=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=enclec76DcMAyUgxx5/lk1nf/tEIYioG9e+4TpA7HIe+dr/YPGscH+P6uzpWrI2vv
	 A/1F6mTmgo3EytMftMkC3sEB/0Zt+3uqnsVMDQ8Yv8CQgY3+VTNgtNb+myh5MZ9z/5
	 oLn0nl16yJCTdz2GMhy7Tm0pOOtn/ylYZ/pF9aeU=
Date: Wed, 25 Jan 2023 15:36:42 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Alexey Gladkov <legion@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, containers@lists.linux.dev,
 linux-fsdevel@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>, Al
 Viro <viro@zeniv.linux.org.uk>, Christian Brauner <brauner@kernel.org>, Val
 Cowan <vcowan@redhat.com>
Subject: Re: [RFC PATCH v1 2/6] proc: Add allowlist to control access to
 procfs files
Message-Id: <20230125153642.db8c733f5b21e27d3aa80b7d@linux-foundation.org>
In-Reply-To: <d87edbe023efb28f60ea04a2e694330db44aa868.1674660533.git.legion@kernel.org>
References: <cover.1674660533.git.legion@kernel.org>
	<d87edbe023efb28f60ea04a2e694330db44aa868.1674660533.git.legion@kernel.org>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.33; x86_64-pc-linux-gnu)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Wed, 25 Jan 2023 16:28:49 +0100 Alexey Gladkov <legion@kernel.org> wrote:

> If, after creating a container and mounting procfs, the system
> configuration may change and new files may appear in procfs. Files
> including writable root or any other users.
> 
> In most cases, it is known in advance which files in procfs the user
> needs in the container. It is much easier to control the list of what
> you want than to control the list of unwanted files.
> 
> To do this, subset=allowlist is added to control the visibility of
> static files in procfs (not process pids). After that, the control file
> /proc/allowlist appears in the root of the filesystem. This file
> contains a list of files and directories that will be visible in this
> vmountpoint. Immediately after mount, this file contains only one
> name - the name of the file itself.
> 
> The admin can add names, read this file to get the current state of the
> allowlist. The file behaves almost like a regular file. Changes are
> applied when the file is closed.

"the admin" is a bit vague.  Precisely which capabilities are required
for this?

> To prevent changes to allowlist, admin should remove its name from the
> list of allowed files. After this change, the file will disappear.

