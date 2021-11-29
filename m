Received: from us-smtp-delivery-44.mimecast.com (us-smtp-delivery-44.mimecast.com [205.139.111.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9791E68
	for <containers@lists.linux.dev>; Mon, 29 Nov 2021 20:38:30 +0000 (UTC)
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 us-mta-258-lM7yZ2ULPMyyCWsW7VrROA-1; Mon, 29 Nov 2021 15:38:19 -0500
X-MC-Unique: lM7yZ2ULPMyyCWsW7VrROA-1
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mimecast-mx01.redhat.com (Postfix) with ESMTPS id A9A571853028;
	Mon, 29 Nov 2021 20:38:18 +0000 (UTC)
Received: from comp-core-i7-2640m-0182e6.redhat.com (unknown [10.36.110.3])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 3B5C410013D6;
	Mon, 29 Nov 2021 20:38:17 +0000 (UTC)
From: Alexey Gladkov <legion@kernel.org>
To: LKML <linux-kernel@vger.kernel.org>,
	Linux Containers <containers@lists.linux.dev>
Cc: 0day robot <lkp@intel.com>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	lkp@lists.01.org
Subject: [PATCH v2 0/2] ucounts: Fix rlimit max values check
Date: Mon, 29 Nov 2021 21:37:24 +0100
Message-Id: <cover.1638218242.git.legion@kernel.org>
In-Reply-To: <20211129074730.GB18483@xsang-OptiPlex-9020>
References: <20211129074730.GB18483@xsang-OptiPlex-9020>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
Authentication-Results: relay.mimecast.com;
	auth=pass smtp.auth=CUSA124A263 smtp.mailfrom=legion@kernel.org
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

v2:
- Fix a bug that was found by the lkp project.

--

Alexey Gladkov (2):
  ucounts: Fix rlimit max values check
  ucounts: Move rlimit max values from ucounts max

 include/linux/user_namespace.h | 17 ++++++++++++-----
 kernel/fork.c                  | 10 +++++-----
 kernel/ucount.c                | 19 +++++++++----------
 kernel/user_namespace.c        | 10 +++++-----
 4 files changed, 31 insertions(+), 25 deletions(-)

--=20
2.33.0

