Received: from mail-b.sr.ht (mail-b.sr.ht [173.195.146.151])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C60A1206B7
	for <containers@lists.linux.dev>; Tue, 30 May 2023 19:00:02 +0000 (UTC)
Authentication-Results: mail-b.sr.ht; dkim=none 
Received: from git.sr.ht (unknown [173.195.146.142])
	by mail-b.sr.ht (Postfix) with ESMTPSA id 3822211EE8C;
	Tue, 30 May 2023 18:50:50 +0000 (UTC)
From: ~akihirosuda <akihirosuda@git.sr.ht>
Date: Tue, 30 May 2023 18:50:50 +0000
Subject:
 [PATCH linux 0/3] [PATCH] userns: add sysctl "kernel.userns_group_range"
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Message-ID: <168547265011.24337.4306067683997517082-0@git.sr.ht>
X-Mailer: git.sr.ht
Reply-to: ~akihirosuda <suda.kyoto@gmail.com>
To: linux-kernel@vger.kernel.org, containers@lists.linux.dev, serge@hallyn.com,
 brauner@kernel.org, paul@paul-moore.com, ebiederm@xmission.com
Cc: suda.kyoto@gmail.com, akihiro.suda.cz@hco.ntt.co.jp
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit

This sysctl limits groups who can create a new userns without
CAP_SYS_ADMIN in the current userns, so as to mitigate potential kernel
vulnerabilities around userns.

The sysctl value format is same as "net.ipv4.ping_group_range".

To disable creating new unprivileged userns, set the sysctl value to "1
0" in the initial userns.

To allow everyone to create new userns, set the sysctl value to "0
4294967294". This is the default value.

This sysctl replaces "kernel.unprivileged_userns_clone" that is found in
Ubuntu [1] and Debian GNU/Linux.

Link: https://git.launchpad.net/~ubuntu-
kernel/ubuntu/+source/linux/+git/jammy/commit?id=3422764 [1]

Signed-off-by: Akihiro Suda <akihiro.suda.cz@hco.ntt.co.jp>

Akihiro Suda (3):
  net/ipv4: split group_range logic to kernel/group_range.c
  group_range: allow GID from 2147483648 to 4294967294
  userns: add sysctl "kernel.userns_group_range"

 include/linux/group_range.h    |  18 +++++
 include/linux/user_namespace.h |   5 ++
 include/net/netns/ipv4.h       |   9 +--
 include/net/ping.h             |   6 --
 kernel/Makefile                |   2 +-
 kernel/fork.c                  |  24 +++++++
 kernel/group_range.c           | 123 +++++++++++++++++++++++++++++++++
 kernel/sysctl.c                |  30 ++++++++
 kernel/user.c                  |   9 +++
 net/ipv4/ping.c                |  39 +----------
 net/ipv4/sysctl_net_ipv4.c     |  56 ++-------------
 11 files changed, 219 insertions(+), 102 deletions(-)
 create mode 100644 include/linux/group_range.h
 create mode 100644 kernel/group_range.c

-- 
2.38.4
