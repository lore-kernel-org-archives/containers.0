Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4904CA942
	for <containers@lists.linux.dev>; Wed, 31 May 2023 07:51:01 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 21030C433EF;
	Wed, 31 May 2023 07:50:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1685519460;
	bh=lQ+/+VySnKEwEK2/+enBJ/bdWDZVM2zfusNO9qgsRGk=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=IGGx4xkqTxa27Dd/zbDrwKbe2fnjfPn8LU1q32T9aiAj2XVBNsqcnlbiQ8LdWiTme
	 L4U5C3yybM9sdvhJvL4gtze9LEMDnA0UqfaKfB7cyKVXcjNGMUX135qltl0yE02xP+
	 cA4vlzpBy1CNk9zwwi268tR/D2dCnk/dQju3Z8LHazys6ugI1LmyEmBcmDWGwJ+YKe
	 nnyCV/K44c7x8VUsnPW4eYXX7AWCzt3bCzi8Jh+AD7bnBiJWRinmduu+gOv7vhIvuu
	 QQay6tRPgUgVDGsSjKrnIN5665kDWigBbiDZlCigXDCfxL3U8nYh/45/ZizCAW+x9P
	 B7ubMiDZVOMcQ==
Date: Wed, 31 May 2023 09:50:55 +0200
From: Christian Brauner <brauner@kernel.org>
To: Paul Moore <paul@paul-moore.com>
Cc: ~akihirosuda <suda.kyoto@gmail.com>, linux-kernel@vger.kernel.org,
	containers@lists.linux.dev, serge@hallyn.com, ebiederm@xmission.com,
	akihiro.suda.cz@hco.ntt.co.jp
Subject: Re: [PATCH linux 0/3] [PATCH] userns: add sysctl
 "kernel.userns_group_range"
Message-ID: <20230531-urgestein-utensil-4420b51542c4@brauner>
References: <168547265011.24337.4306067683997517082-0@git.sr.ht>
 <CAHC9VhQhBBPyZE24LM6KvYrET2huW-W_YYsyPndpNkn70Mu3Ug@mail.gmail.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAHC9VhQhBBPyZE24LM6KvYrET2huW-W_YYsyPndpNkn70Mu3Ug@mail.gmail.com>

On Tue, May 30, 2023 at 05:58:48PM -0400, Paul Moore wrote:
> On Tue, May 30, 2023 at 2:50 PM ~akihirosuda <akihirosuda@git.sr.ht> wrote:
> >
> > This sysctl limits groups who can create a new userns without
> > CAP_SYS_ADMIN in the current userns, so as to mitigate potential kernel
> > vulnerabilities around userns.
> >
> > The sysctl value format is same as "net.ipv4.ping_group_range".
> >
> > To disable creating new unprivileged userns, set the sysctl value to "1
> > 0" in the initial userns.
> >
> > To allow everyone to create new userns, set the sysctl value to "0
> > 4294967294". This is the default value.
> >
> > This sysctl replaces "kernel.unprivileged_userns_clone" that is found in
> > Ubuntu [1] and Debian GNU/Linux.
> >
> > Link: https://git.launchpad.net/~ubuntu-
> > kernel/ubuntu/+source/linux/+git/jammy/commit?id=3422764 [1]
> 
> Given the challenges around adding access controls to userns
> operations, have you considered using the LSM support that was added
> upstream last year?  The relevant LSM hook can be found in commit
> 7cd4c5c2101c ("security, lsm: Introduce security_create_user_ns()"),
> and although only SELinux currently provides an access control
> implementation, there is no reason you couldn't add support for your
> favorite LSM, or even just a simple BPF LSM to enforce the group
> controls as you've described them here.

Yes. Please, no more sysctls...
