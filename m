Received: from us-smtp-delivery-44.mimecast.com (us-smtp-delivery-44.mimecast.com [205.139.111.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 60EFC2C80
	for <containers@lists.linux.dev>; Fri, 21 Jan 2022 13:10:22 +0000 (UTC)
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 us-mta-211-doWXCRcfM-qAes0kr1kiQQ-1; Fri, 21 Jan 2022 08:09:09 -0500
X-MC-Unique: doWXCRcfM-qAes0kr1kiQQ-1
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 85879100C609;
	Fri, 21 Jan 2022 13:09:07 +0000 (UTC)
Received: from comp-core-i7-2640m-0182e6.redhat.com (unknown [10.36.110.3])
	by smtp.corp.redhat.com (Postfix) with ESMTP id AB67378AA8;
	Fri, 21 Jan 2022 13:09:03 +0000 (UTC)
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
Subject: [RFC PATCH v3 0/4] ipc: Store mq and ipc sysctls in the ipc namespace
Date: Fri, 21 Jan 2022 14:08:37 +0100
Message-Id: <cover.1642769810.git.legion@kernel.org>
In-Reply-To: <87tuebwo99.fsf@email.froward.int.ebiederm.org>
References: <87tuebwo99.fsf@email.froward.int.ebiederm.org>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
Authentication-Results: relay.mimecast.com;
	auth=pass smtp.auth=CUSA124A263 smtp.mailfrom=legion@kernel.org
X-Mimecast-Spam-Score: 0
X-Mimecast-Originator: kernel.org
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=WINDOWS-1252

This patchset changes the implementation of mq and ipc sysctls. It moves th=
e
sysctls inside the ipc namespace.This will allow us to manage these sysctls
inside the user namespace. The implementation also removes helpers duplicat=
ion
between mq and ipc sysctls.

--

Alexey Gladkov (4):
  ipc: Store mqueue sysctls in the ipc namespace
  ipc: Store ipc sysctls in the ipc namespace
  ipc: Merge ipc_sysctl and mq_sysctl
  ipc: Allow to modify ipc/mq sysctls if CAP_SYS_RESOURCE is present

 include/linux/ipc_namespace.h |  24 ++-
 ipc/Makefile                  |   7 +-
 ipc/ipc_sysctl.c              | 318 +++++++++++++++++++++++++++-------
 ipc/mq_sysctl.c               | 120 -------------
 ipc/mqueue.c                  |   7 -
 ipc/namespace.c               |   6 +
 ipc/util.h                    |   4 +-
 7 files changed, 273 insertions(+), 213 deletions(-)
 delete mode 100644 ipc/mq_sysctl.c

--=20
2.33.0

