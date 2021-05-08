Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 47B8B72
	for <containers@lists.linux.dev>; Sat,  8 May 2021 12:15:55 +0000 (UTC)
Received: by mail.kernel.org (Postfix) with ESMTPSA id 2528661469;
	Sat,  8 May 2021 12:15:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1620476155;
	bh=Z3np8vRR6Fe/+PrLZCrWi/n6U1UYxoqdr9Au8VeyDl4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=mKCG7guD+GJ4pJvZCC7qAcNUTiikvbcWJEM/6HwdG0UqSf8PaVtC/hhRp9J7rCXoD
	 BNuSFJXgdL9qcKPkz+rO/5a5jtPLPmkqitnK6IUof7iM7EM6qfEwTboEKPIS4A4cuJ
	 P+4ZwZ0X72QZHsOgFgEuUf9rkdHkvlryoGSB9hKoyzHW+mvvmgEG2CQqX9HEKq6bH1
	 iZq0DozKQYj46tG8wUD00hM1RtHMIlVorW3OVclJ+GPno1N444rnqqfkIvckNl06h0
	 dvIGTSAYsF76e0HoVbAdOPpVpukFidr1H/8vuRHfClqvc9uA1Ml+SyqUAG0/wqbMrF
	 V1jDyDxgWUQbw==
From: Christian Brauner <brauner@kernel.org>
To: Tejun Heo <tj@kernel.org>,
	Roman Gushchin <guro@fb.com>
Cc: Shakeel Butt <shakeelb@google.com>,
	Zefan Li <lizefan.x@bytedance.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	cgroups@vger.kernel.org,
	containers@lists.linux.dev,
	Christian Brauner <christian.brauner@ubuntu.com>
Subject: [PATCH v3 2/5] docs/cgroup: add entry for cgroup.kill
Date: Sat,  8 May 2021 14:15:39 +0200
Message-Id: <20210508121542.1269256-2-brauner@kernel.org>
X-Mailer: git-send-email 2.27.0
In-Reply-To: <20210508121542.1269256-1-brauner@kernel.org>
References: <20210508121542.1269256-1-brauner@kernel.org>
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
X-Patch-Hashes: v=1; h=sha256; i=zdu4cmCLHejWfxLXMelts0rSpFC8qk9wZuoiNeHiin8=; m=I3MSFmKf1pbbRfbAK7y/Bkq5X38Qg95Sz63m3UUHpxE=; p=y57GkHCBx4K2DRLBiMddNPtk4ONjJhS+uFuQ+wSoBJI=; g=f66b8ed84f77326338a4318eeab17fe419bdcba3
X-Patch-Sig: m=pgp; i=christian.brauner@ubuntu.com; s=0x0x91C61BC06578DCA2; b=iHUEABYKAB0WIQRAhzRXHqcMeLMyaSiRxhvAZXjcogUCYJaA0AAKCRCRxhvAZXjcoq58AQCHzH4 NQBVzfP7eOVRNJjOzlN4mhDlO5sjuibK8P8VqwgD+ID7dvojR3aoBvCxYt94LSZjuK3LYuLQSiLHr FpWwJQI=
Content-Transfer-Encoding: 8bit

From: Christian Brauner <christian.brauner@ubuntu.com>

Give a brief overview of the cgroup.kill functionality.

Link: https://lore.kernel.org/r/20210503143922.3093755-2-brauner@kernel.org
Cc: Roman Gushchin <guro@fb.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: cgroups@vger.kernel.org
Reviewed-by: Shakeel Butt <shakeelb@google.com>
Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>
---
/* v2 */
- Roman Gushchin <guro@fb.com>:
  - Drop sentence that mentions combined useage of cgroup.kill and
    cgroup.freezer.

/* v3 */
unchanged
---
 Documentation/admin-guide/cgroup-v2.rst | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/Documentation/admin-guide/cgroup-v2.rst b/Documentation/admin-guide/cgroup-v2.rst
index 64c62b979f2f..6adc749d863e 100644
--- a/Documentation/admin-guide/cgroup-v2.rst
+++ b/Documentation/admin-guide/cgroup-v2.rst
@@ -949,6 +949,21 @@ All cgroup core files are prefixed with "cgroup."
 	it's possible to delete a frozen (and empty) cgroup, as well as
 	create new sub-cgroups.
 
+  cgroup.kill
+	A write-only single value file which exists in non-root cgroups.
+	The only allowed value is "1".
+
+	Writing "1" to the file causes the cgroup and all descendant cgroups to
+	be killed. This means that all processes located in the affected cgroup
+	tree will be killed via SIGKILL.
+
+	Killing a cgroup tree will deal with concurrent forks appropriately and
+	is protected against migrations.
+
+	In a threaded cgroup, writing this file fails with EOPNOTSUPP as
+	killing cgroups is a process directed operation, i.e. it affects
+	the whole thread-group.
+
 Controllers
 ===========
 
-- 
2.27.0

