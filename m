Received: from us-smtp-delivery-44.mimecast.com (us-smtp-delivery-44.mimecast.com [207.211.30.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C5231748E
	for <containers@lists.linux.dev>; Tue, 20 Sep 2022 18:10:02 +0000 (UTC)
Received: from mimecast-mx02.redhat.com (mx3-rdu2.redhat.com
 [66.187.233.73]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 us-mta-257-x-Fw1OT7PQyBs5EUD9ZOWQ-1; Tue, 20 Sep 2022 14:08:45 -0400
X-MC-Unique: x-Fw1OT7PQyBs5EUD9ZOWQ-1
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.rdu2.redhat.com [10.11.54.6])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mimecast-mx02.redhat.com (Postfix) with ESMTPS id 035CA29AB42D;
	Tue, 20 Sep 2022 18:08:45 +0000 (UTC)
Received: from comp-core-i7-2640m-0182e6.redhat.com (unknown [10.40.208.17])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 9463D2166B26;
	Tue, 20 Sep 2022 18:08:43 +0000 (UTC)
From: Alexey Gladkov <legion@kernel.org>
To: LKML <linux-kernel@vger.kernel.org>,
	Linux Containers <containers@lists.linux.dev>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christian Brauner <brauner@kernel.org>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	Kees Cook <keescook@chromium.org>,
	Manfred Spraul <manfred@colorfullife.com>
Subject: [PATCH v2 0/3] Allow to change ipc/mq sysctls inside ipc namespace
Date: Tue, 20 Sep 2022 20:08:19 +0200
Message-Id: <cover.1663696560.git.legion@kernel.org>
In-Reply-To: <YynnI2ySUkpu9j6S@example.org>
References: <YynnI2ySUkpu9j6S@example.org>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.1 on 10.11.54.6

Right now ipc and mq limits count as per ipc namespace, but only real
root can change them. By default, the current values of these limits are
such that it can only be reduced. Since only root can change the values,
it is impossible to reduce these limits in the rootless container.

We can allow limit changes within ipc namespace because mq parameters
are limited by RLIMIT_MSGQUEUE and ipc parameters are not limited to
anything other than cgroups.

--

Alexey Gladkov (3):
  sysctl: Allow change system v ipc sysctls inside ipc namespace
  sysctl: Allow to change limits for posix messages queues
  docs: Add information about ipc sysctls limitations

 Documentation/admin-guide/sysctl/kernel.rst | 14 ++++++--
 ipc/ipc_sysctl.c                            | 34 ++++++++++++++++--
 ipc/mq_sysctl.c                             | 38 +++++++++++++++++++++
 3 files changed, 80 insertions(+), 6 deletions(-)

-- 
2.33.4

