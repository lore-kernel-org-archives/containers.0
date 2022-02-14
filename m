Received: from us-smtp-delivery-44.mimecast.com (us-smtp-delivery-44.mimecast.com [205.139.111.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AD03DA2C
	for <containers@lists.linux.dev>; Mon, 14 Feb 2022 18:20:01 +0000 (UTC)
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 us-mta-50-1WN-g-mKN5yG-edIyRc2Qg-1; Mon, 14 Feb 2022 13:18:48 -0500
X-MC-Unique: 1WN-g-mKN5yG-edIyRc2Qg-1
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mimecast-mx01.redhat.com (Postfix) with ESMTPS id A2A6E814243;
	Mon, 14 Feb 2022 18:18:46 +0000 (UTC)
Received: from comp-core-i7-2640m-0182e6.redhat.com (unknown [10.36.110.3])
	by smtp.corp.redhat.com (Postfix) with ESMTP id B4B5584784;
	Mon, 14 Feb 2022 18:18:41 +0000 (UTC)
From: Alexey Gladkov <legion@kernel.org>
To: LKML <linux-kernel@vger.kernel.org>,
	Linux Containers <containers@lists.linux.dev>
Cc: Alexander Mikhalitsyn <alexander.mikhalitsyn@virtuozzo.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christian Brauner <christian.brauner@ubuntu.com>,
	Daniel Walsh <dwalsh@redhat.com>,
	Davidlohr Bueso <dbueso@suse.de>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	Kirill Tkhai <ktkhai@virtuozzo.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Serge Hallyn <serge@hallyn.com>,
	Varad Gautam <varad.gautam@suse.com>,
	Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH v4 0/2] ipc: Store mq and ipc sysctls in the ipc namespace
Date: Mon, 14 Feb 2022 19:18:13 +0100
Message-Id: <cover.1644862280.git.legion@kernel.org>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
Authentication-Results: relay.mimecast.com;
	auth=pass smtp.auth=CUSA124A263 smtp.mailfrom=legion@kernel.org
X-Mimecast-Spam-Score: 0
X-Mimecast-Originator: kernel.org
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=WINDOWS-1252

This patchset changes the implementation of mq and ipc sysctls. It moves th=
e
sysctls inside the ipc namespace. This will allow us to manage these sysctl=
s
inside the user namespace.

--

Alexey Gladkov (2):
  ipc: Store mqueue sysctls in the ipc namespace
  ipc: Store ipc sysctls in the ipc namespace

 include/linux/ipc_namespace.h |  37 ++++++-
 ipc/ipc_sysctl.c              | 189 ++++++++++++++++++++++------------
 ipc/mq_sysctl.c               | 121 ++++++++++++----------
 ipc/mqueue.c                  |  10 +-
 ipc/namespace.c               |  10 ++
 5 files changed, 235 insertions(+), 132 deletions(-)

--=20
2.33.0

