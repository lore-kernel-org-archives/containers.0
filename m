Received: from us-smtp-delivery-44.mimecast.com (us-smtp-delivery-44.mimecast.com [207.211.30.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B2E493204
	for <containers@lists.linux.dev>; Tue,  3 May 2022 15:06:39 +0000 (UTC)
Received: from mimecast-mx02.redhat.com (mx3-rdu2.redhat.com
 [66.187.233.73]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 us-mta-453-75oE-M6RP7eBPNBNfwRyUg-1; Tue, 03 May 2022 11:05:38 -0400
X-MC-Unique: 75oE-M6RP7eBPNBNfwRyUg-1
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.rdu2.redhat.com [10.11.54.5])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mimecast-mx02.redhat.com (Postfix) with ESMTPS id 0F29F3D32CC7;
	Tue,  3 May 2022 13:40:18 +0000 (UTC)
Received: from comp-core-i7-2640m-0182e6.redhat.com (unknown [10.36.110.3])
	by smtp.corp.redhat.com (Postfix) with ESMTP id D9EF19E60;
	Tue,  3 May 2022 13:40:09 +0000 (UTC)
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
Subject: Re: [PATCH v1 2/4] ipc: Use proper ipc namespace 
Date: Tue,  3 May 2022 15:39:53 +0200
Message-Id: <cover.1651584847.git.legion@kernel.org>
In-Reply-To: <87sfprudal.fsf@email.froward.int.ebiederm.org>
References: <87sfprudal.fsf@email.froward.int.ebiederm.org>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.11.54.5

On Mon, May 02, 2022 at 11:09:22AM -0500, Eric W. Biederman wrote:
> Alexey Gladkov <legion@kernel.org> writes:
> 
> > As Eric Biederman pointed out, changing the namespace broke checkpoint
> > restore. I have reverted my previous changes.
> 
> Can you remind me the bug that is being fixed here?
> 
> I am probably just going to fast to see it, but it would be good to have
> it described in the commit comment.

It was preparation for the "ipc: Check permissions for checkpoint_restart
sysctls at open time". I wanted to split the commit and make it more readable,
but it looks like I just confused everyone. This change should be part of the
next commit.

Here is a new version of the patchset where I moved the bugfix to a separate
commit as you requested in the next email.

Does that look better?

--

Alexey Gladkov (4):
  ipc: Use the same namespace to modify and validate
  ipc: Remove extra1 field abuse to pass ipc namespace
  ipc: Check permissions for checkpoint_restart sysctls at open time
  ipc: Remove extra braces

 ipc/ipc_sysctl.c | 108 +++++++++++++++++++++--------------------------
 1 file changed, 49 insertions(+), 59 deletions(-)

-- 
2.33.3

