Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4C8AF110F
	for <containers@lists.linux.dev>; Thu, 26 Jan 2023 11:13:42 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 32C25C433EF;
	Thu, 26 Jan 2023 11:13:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1674731622;
	bh=D55D9VV7InbUoonDE1/srS8l75cDDnc92dbzMzbWAnk=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=D4WyawDjvW2ueu1Ybe7Qc+zVGVyiQEBad2a44XU1vrVKMU9aPwJNDSxI843iRNLnP
	 iwv2WZjOYktPYAawLOV71cRpd52d175alPbCt23DKpFonL++/Acv9gMpf6mKaY+5rf
	 F5+9vCSyD/L0s+h7/0iTdqxf4p7TWRrSDRFhS+p4OnTGlBL9fHRnMNx8IfStWOAiT4
	 RczhxkciCb2rcjO5rsAlYDbDQnSYGA7abJkW/kGbYpzng9twzA9ESq659px8oe7AwJ
	 Q5p+YFdiFCeAEFnUQzjZ80TiY8V3CzemSdDkUD/8+mGQpd/9asNuVZKJjaVCBtEGgW
	 lf2tpOWsq73NA==
Date: Thu, 26 Jan 2023 12:13:36 +0100
From: Alexey Gladkov <legion@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, containers@lists.linux.dev,
	linux-fsdevel@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Val Cowan <vcowan@redhat.com>
Subject: Re: [RFC PATCH v1 2/6] proc: Add allowlist to control access to
 procfs files
Message-ID: <Y9JgYPHebozyuTTe@example.org>
References: <cover.1674660533.git.legion@kernel.org>
 <d87edbe023efb28f60ea04a2e694330db44aa868.1674660533.git.legion@kernel.org>
 <20230125153642.db8c733f5b21e27d3aa80b7d@linux-foundation.org>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20230125153642.db8c733f5b21e27d3aa80b7d@linux-foundation.org>

On Wed, Jan 25, 2023 at 03:36:42PM -0800, Andrew Morton wrote:
> On Wed, 25 Jan 2023 16:28:49 +0100 Alexey Gladkov <legion@kernel.org> wrote:
> 
> > If, after creating a container and mounting procfs, the system
> > configuration may change and new files may appear in procfs. Files
> > including writable root or any other users.
> > 
> > In most cases, it is known in advance which files in procfs the user
> > needs in the container. It is much easier to control the list of what
> > you want than to control the list of unwanted files.
> > 
> > To do this, subset=allowlist is added to control the visibility of
> > static files in procfs (not process pids). After that, the control file
> > /proc/allowlist appears in the root of the filesystem. This file
> > contains a list of files and directories that will be visible in this
> > vmountpoint. Immediately after mount, this file contains only one
> > name - the name of the file itself.
> > 
> > The admin can add names, read this file to get the current state of the
> > allowlist. The file behaves almost like a regular file. Changes are
> > applied when the file is closed.
> 
> "the admin" is a bit vague.  Precisely which capabilities are required
> for this?

In this commit, the admin is the one with CAP_SYS_ADMIN. You're right,
I'll fix the commit message.

> > To prevent changes to allowlist, admin should remove its name from the
> > list of allowed files. After this change, the file will disappear.
> 

-- 
Rgrds, legion

