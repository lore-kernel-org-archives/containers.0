Received: from us-smtp-delivery-44.mimecast.com (us-smtp-delivery-44.mimecast.com [207.211.30.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3E57B748E
	for <containers@lists.linux.dev>; Tue, 20 Sep 2022 18:09:28 +0000 (UTC)
Received: from mimecast-mx02.redhat.com (mimecast-mx02.redhat.com
 [66.187.233.88]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 us-mta-185-DMmJYzxEOWSPHuBH53reNA-1; Tue, 20 Sep 2022 14:09:23 -0400
X-MC-Unique: DMmJYzxEOWSPHuBH53reNA-1
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.rdu2.redhat.com [10.11.54.6])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mimecast-mx02.redhat.com (Postfix) with ESMTPS id D5E38802801;
	Tue, 20 Sep 2022 18:09:22 +0000 (UTC)
Received: from comp-core-i7-2640m-0182e6.redhat.com (unknown [10.40.208.17])
	by smtp.corp.redhat.com (Postfix) with ESMTP id EC0032166B26;
	Tue, 20 Sep 2022 18:09:20 +0000 (UTC)
From: Alexey Gladkov <legion@kernel.org>
To: LKML <linux-kernel@vger.kernel.org>,
	Linux Containers <containers@lists.linux.dev>,
	linux-doc@vger.kernel.org,
	linux-man@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christian Brauner <brauner@kernel.org>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	Kees Cook <keescook@chromium.org>,
	Manfred Spraul <manfred@colorfullife.com>,
	Jonathan Corbet <corbet@lwn.net>
Subject: [PATCH v2 3/3] docs: Add information about ipc sysctls limitations
Date: Tue, 20 Sep 2022 20:08:22 +0200
Message-Id: <f54cc99145e1968e0f52dbe44e25ab057b8082dc.1663696560.git.legion@kernel.org>
In-Reply-To: <cover.1663696560.git.legion@kernel.org>
References: <YynnI2ySUkpu9j6S@example.org> <cover.1663696560.git.legion@kernel.org>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.1 on 10.11.54.6

After 25b21cb2f6d6 ("[PATCH] IPC namespace core") and 4e9823111bdc
("[PATCH] IPC namespace - shm") the shared memory page count stopped
being global and started counting per ipc namespace. The documentation
and shmget(2) still says that shmall is a global option.

shmget(2):

SHMALL System-wide limit on the total amount of shared memory, measured
in units of the system page size. On Linux, this limit can be read and
modified via /proc/sys/kernel/shmall.

I think the changes made in 2006 should be documented.

Signed-off-by: Alexey Gladkov <legion@kernel.org>
Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 Documentation/admin-guide/sysctl/kernel.rst | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/Documentation/admin-guide/sysctl/kernel.rst b/Documentation/admin-guide/sysctl/kernel.rst
index ee6572b1edad..c8b89bd8f004 100644
--- a/Documentation/admin-guide/sysctl/kernel.rst
+++ b/Documentation/admin-guide/sysctl/kernel.rst
@@ -541,6 +541,9 @@ default (``MSGMNB``).
 ``msgmni`` is the maximum number of IPC queues. 32000 by default
 (``MSGMNI``).
 
+All of these parameters are set per ipc namespace. The maximum number of bytes
+in POSIX message queues is limited by ``RLIMIT_MSGQUEUE``. This limit is
+respected hierarchically in the each user namespace.
 
 msg_next_id, sem_next_id, and shm_next_id (System V IPC)
 ========================================================
@@ -1181,15 +1184,20 @@ are doing anyway :)
 shmall
 ======
 
-This parameter sets the total amount of shared memory pages that
-can be used system wide. Hence, ``shmall`` should always be at least
-``ceil(shmmax/PAGE_SIZE)``.
+This parameter sets the total amount of shared memory pages that can be used
+inside ipc namespace. The shared memory pages counting occurs for each ipc
+namespace separately and is not inherited. Hence, ``shmall`` should always be at
+least ``ceil(shmmax/PAGE_SIZE)``.
 
 If you are not sure what the default ``PAGE_SIZE`` is on your Linux
 system, you can run the following command::
 
 	# getconf PAGE_SIZE
 
+To reduce or disable the ability to allocate shared memory, you must create a
+new ipc namespace, set this parameter to the required value and prohibit the
+creation of a new ipc namespace in the current user namespace or cgroups can
+be used.
 
 shmmax
 ======
-- 
2.33.4

