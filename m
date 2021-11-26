Received: from us-smtp-delivery-44.mimecast.com (us-smtp-delivery-44.mimecast.com [207.211.30.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E8FEF29CA
	for <containers@lists.linux.dev>; Fri, 26 Nov 2021 14:39:01 +0000 (UTC)
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 us-mta-377-FEoH74sPP-WpnJKCXXDBfQ-1; Fri, 26 Nov 2021 09:37:34 -0500
X-MC-Unique: FEoH74sPP-WpnJKCXXDBfQ-1
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 24BCA2F22;
	Fri, 26 Nov 2021 14:37:33 +0000 (UTC)
Received: from comp-core-i7-2640m-0182e6.redhat.com (unknown [10.36.110.3])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 0955C60BF4;
	Fri, 26 Nov 2021 14:37:31 +0000 (UTC)
From: Alexey Gladkov <legion@kernel.org>
To: LKML <linux-kernel@vger.kernel.org>,
	Linux Containers <containers@lists.linux.dev>
Cc: "Eric W . Biederman" <ebiederm@xmission.com>
Subject: [PATCH v1 0/2] ucounts: Fix rlimit max values check
Date: Fri, 26 Nov 2021 15:37:25 +0100
Message-Id: <cover.1637934917.git.legion@kernel.org>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Mimecast-Spam-Score: 0
X-Mimecast-Originator: kernel.org
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=WINDOWS-1252

Checking the rlimit value specified in init_user_ns from the created userns=
 does
not work properly. The issue is that the maximum value is taken by the same
rules as for ucounts. Because of this, we check the current rlimit counter =
value
with RLIM_INFINITY in init_user_ns.

--

Alexey Gladkov (2):
  ucounts: Fix rlimit max values check
  ucounts: Move rlimit max values from ucounts max

 include/linux/user_namespace.h | 13 ++++++++++---
 kernel/fork.c                  |  8 ++++----
 kernel/ucount.c                | 15 +++++++++------
 kernel/user_namespace.c        |  8 ++++----
 4 files changed, 27 insertions(+), 17 deletions(-)

--=20
2.33.0

