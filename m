Received: from us-smtp-delivery-44.mimecast.com (us-smtp-delivery-44.mimecast.com [205.139.111.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 46A122C80
	for <containers@lists.linux.dev>; Fri, 21 Jan 2022 13:10:24 +0000 (UTC)
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 us-mta-286-qgc-g0hKP0O-lYa8qA8vPA-1; Fri, 21 Jan 2022 08:10:20 -0500
X-MC-Unique: qgc-g0hKP0O-lYa8qA8vPA-1
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 8ED5C83DEE1;
	Fri, 21 Jan 2022 13:10:18 +0000 (UTC)
Received: from comp-core-i7-2640m-0182e6.redhat.com (unknown [10.36.110.3])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 1AC8178AA0;
	Fri, 21 Jan 2022 13:10:14 +0000 (UTC)
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
Subject: [RFC PATCH v3 4/4] ipc: Allow to modify ipc/mq sysctls if CAP_SYS_RESOURCE is present
Date: Fri, 21 Jan 2022 14:08:41 +0100
Message-Id: <9351533c4114f160d7b7d2db32d9636747bdede9.1642769810.git.legion@kernel.org>
In-Reply-To: <cover.1642769810.git.legion@kernel.org>
References: <87tuebwo99.fsf@email.froward.int.ebiederm.org> <cover.1642769810.git.legion@kernel.org>
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

The mq_overview(7) says that mq sysctls are available for modification
to a privileged process (CAP_SYS_RESOURCE). Right now, within userns, a
privileged process cannot modify these files. Once the mq and ipc
sysctls have been moved to the ipc namespace we can grant access to
these files.

mqueue sysctls
--------------

The mq sysctls are protected by an upper limit that cannot be exceeded
on the system:

For /proc/sys/fs/mqueue/msg_max the upper limit is HARD_MSGMAX.
For /proc/sys/fs/mqueue/msgsize_max the upper limit is HARD_MSGSIZEMAX.

Also RLIMIT_MSGQUEUE limits all queues used by the process. This limit
is also tied to userns.

ipc sysctls
-----------

The implementation has no specific limits for the per-process maximum
number of shared memory segments. Only SHM_LOCK and SHM_HUGETLB limited
by RLIMIT_MEMLOCK which is also tied to userns.

This patch is RPC only and should not be applied without a security
discussion.

Signed-off-by: Alexey Gladkov <legion@kernel.org>
---
 ipc/ipc_sysctl.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/ipc/ipc_sysctl.c b/ipc/ipc_sysctl.c
index 9fc8e3e75be7..f1d1c83656f9 100644
--- a/ipc/ipc_sysctl.c
+++ b/ipc/ipc_sysctl.c
@@ -254,6 +254,21 @@ static struct ctl_table mq_sysctls[] =3D {
 =09{}
 };
=20
+static int set_permissions(struct ctl_table_header *head, struct ctl_table=
 *table)
+{
+=09struct ipc_namespace *ns =3D container_of(head->set, struct ipc_namespa=
ce, set);
+=09int mode;
+
+=09/* Allow users with CAP_SYS_RESOURCE unrestrained access */
+=09if (ns_capable(ns->user_ns, CAP_SYS_RESOURCE))
+=09=09mode =3D (table->mode & S_IRWXU) >> 6;
+=09else
+=09/* Allow all others at most read-only access */
+=09=09mode =3D table->mode & S_IROTH;
+
+=09return (mode << 6) | (mode << 3) | mode;
+}
+
 static struct ctl_table_set *set_lookup(struct ctl_table_root *root)
 {
 =09return &current->nsproxy->ipc_ns->set;
@@ -266,6 +281,7 @@ static int set_is_seen(struct ctl_table_set *set)
=20
 static struct ctl_table_root set_root =3D {
 =09.lookup =3D set_lookup,
+=09.permissions =3D set_permissions,
 };
=20
 static bool register_ipc_sysctl_table(struct ipc_namespace *ns)
--=20
2.33.0

