Received: from us-smtp-delivery-44.mimecast.com (us-smtp-delivery-44.mimecast.com [205.139.111.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 024FF7A
	for <containers@lists.linux.dev>; Fri, 22 Apr 2022 12:55:01 +0000 (UTC)
Received: from mimecast-mx02.redhat.com (mx3-rdu2.redhat.com
 [66.187.233.73]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 us-mta-614-Bd_z2wt5MJGVJ2gBpQCfPQ-1; Fri, 22 Apr 2022 08:53:49 -0400
X-MC-Unique: Bd_z2wt5MJGVJ2gBpQCfPQ-1
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.rdu2.redhat.com [10.11.54.8])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mimecast-mx02.redhat.com (Postfix) with ESMTPS id 53F1A38337E2;
	Fri, 22 Apr 2022 12:53:48 +0000 (UTC)
Received: from comp-core-i7-2640m-0182e6.redhat.com (unknown [10.36.110.3])
	by smtp.corp.redhat.com (Postfix) with ESMTP id BC8A3C28107;
	Fri, 22 Apr 2022 12:53:45 +0000 (UTC)
From: Alexey Gladkov <legion@kernel.org>
To: LKML <linux-kernel@vger.kernel.org>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	Linus Torvalds <torvalds@linux-foundation.org>
Cc: Alexander Mikhalitsyn <alexander.mikhalitsyn@virtuozzo.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christian Brauner <christian.brauner@ubuntu.com>,
	Daniel Walsh <dwalsh@redhat.com>,
	Davidlohr Bueso <dbueso@suse.de>,
	Kirill Tkhai <ktkhai@virtuozzo.com>,
	Linux Containers <containers@lists.linux.dev>,
	Manfred Spraul <manfred@colorfullife.com>,
	Serge Hallyn <serge@hallyn.com>,
	Varad Gautam <varad.gautam@suse.com>,
	Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH v1 0/4] ipc: Remove extra1 field abuse to pass ipc namespace
Date: Fri, 22 Apr 2022 14:53:36 +0200
Message-Id: <cover.1650631347.git.legion@kernel.org>
In-Reply-To: <CAHk-=wgBB8iPd0W=MQWnQJukMAPAqgsC0QX2wwiSvcct9zu_RA@mail.gmail.com>
References: <CAHk-=wgBB8iPd0W=MQWnQJukMAPAqgsC0QX2wwiSvcct9zu_RA@mail.gmail.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.85 on 10.11.54.8

These patches are made on top of branch:

git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git per-namespace-ipc-sysctls-for-v5.18

After discussion, I took into account Eric Biederman's fixes. With these
changes, the hacks of passing namespace through .extra1 are not required.

With the current design of sysctl dynamic memory allocation is
necessary.

Yes, Linus, these changes are not the refactoring you were talking
about, but I plan to try to do such a refactoring in the my next
patchset.

--

Alexey Gladkov (4):
  ipc: Remove extra1 field abuse to pass ipc namespace
  ipc: Use proper ipc namespace
  ipc: Check permissions for checkpoint_restart sysctls at open time
  ipc: Remove extra braces

 ipc/ipc_sysctl.c | 108 +++++++++++++++++++++--------------------------
 1 file changed, 49 insertions(+), 59 deletions(-)

-- 
2.33.2

