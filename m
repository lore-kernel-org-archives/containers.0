Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AA5DC3D65
	for <containers@lists.linux.dev>; Fri,  3 Jun 2022 23:25:01 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPS id 56A38C385A9;
	Fri,  3 Jun 2022 23:25:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1654298701;
	bh=6UHUqQdzkTj73A96QlRsG/2L/VVa49Rs5IzIFnm9O/4=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc:From;
	b=T2jYltGAgHZP1k0F85gmYoQRb6jOppkwBft4PeesB0wbCR6Lx/Pr+r8bsT7dOvcVo
	 11mFtZ5QYV+G2yNnys6wYroJ8ve0GlF66cRErmNRhVr4enu9sYEP88nbPxwYoPoVdB
	 nWjDhbedschgo3Fkb/ayazkMLoP36ZsQbffjpkGN/tobFYUxHkbGB1QDBd+GVNuLfy
	 MfELpLL/heTTNIUpnwOL9dorWFyH2/utl7+jj+YU+B2V89VEJOTKTt4lJQ5nWVsbgL
	 Qm6srEfBmpaNiz8p9ioPOFJpzbbHPyPZBjnvXEvlz9EBFynRuZyKXvMmxOG3ZaaKr1
	 sT0lHAhN2I2Kg==
Received: from aws-us-west-2-korg-oddjob-1.ci.codeaurora.org (localhost.localdomain [127.0.0.1])
	by aws-us-west-2-korg-oddjob-1.ci.codeaurora.org (Postfix) with ESMTP id 39323F5F176;
	Fri,  3 Jun 2022 23:25:01 +0000 (UTC)
Subject: Re: [GIT PULL] ipc: per namespace ipc sysctl changes for v5.19
From: pr-tracker-bot@kernel.org
In-Reply-To: <875ylh8xxx.fsf@email.froward.int.ebiederm.org>
References: <875ylh8xxx.fsf@email.froward.int.ebiederm.org>
X-PR-Tracked-List-Id: <containers.lists.linux.dev>
X-PR-Tracked-Message-Id: <875ylh8xxx.fsf@email.froward.int.ebiederm.org>
X-PR-Tracked-Remote: git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git per-namespace-ipc-sysctls-for-v5.19
X-PR-Tracked-Commit-Id: 38cd5b12b7854941ede1954cf5a2393eb94b5d37
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 1888e9b4bb78c88514b24ecafa9e4e4faf761747
Message-Id: <165429870122.22913.6194143729922958016.pr-tracker-bot@kernel.org>
Date: Fri, 03 Jun 2022 23:25:01 +0000
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, Alexey Gladkov <legion@kernel.org>, Linux Containers <containers@lists.linux.dev>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>

The pull request you sent on Fri, 03 Jun 2022 12:21:46 -0500:

> git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git per-namespace-ipc-sysctls-for-v5.19

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/1888e9b4bb78c88514b24ecafa9e4e4faf761747

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
