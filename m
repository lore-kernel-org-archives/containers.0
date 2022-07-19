Received: from mr85p00im-ztdg06011901.me.com (mr85p00im-ztdg06011901.me.com [17.58.23.198])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 850B6EA9
	for <containers@lists.linux.dev>; Tue, 19 Jul 2022 02:11:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=icloud.com;
	s=1a1hai; t=1658196704;
	bh=T4xK7W1C8/EAKpZlNLBDLSvbQJQGFkNtPL6rJnWFjMw=;
	h=Content-Type:From:Mime-Version:Subject:Message-Id:Date:To;
	b=X5cnwMG7gsS20huIL/ZBS0AlIG1NvH37KKHp57BZgvKa2V/TbAaWoBUTy5awoXA//
	 Zu3DVR8+lr0GSDRJgeKbScojjeoBvI+Kay06EaCQG+nAlAy03MsGiidyAmIjFIh2z1
	 xt0eehL6zIcCKe0s28XrhWqIiAjCsF+bzSuUqzbDvpPTLy0FQjYg/r/1EmvUG0eHKI
	 G3GF5B1MTOph6rfkKx5XDRGW6CHwEBlWPt3n3G707rO5doOgRGnLkVQ1+gLDbIHg8u
	 Myl0ogxbQoJM8ChtFXSCuv1PL+S2EJVe7sgbrXRt5xJlJhfVldOFlVhHZc8Tp2Q8ry
	 bfPpel15XldYQ==
Received: from smtpclient.apple (mr38p00im-dlb-asmtp-mailmevip.me.com [17.57.152.18])
	by mr85p00im-ztdg06011901.me.com (Postfix) with ESMTPSA id 6C732900474;
	Tue, 19 Jul 2022 02:11:44 +0000 (UTC)
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
From: Robin Naccari <robianna1973@icloud.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH v2 3/4] seccomp: Support atomic "addfd + send reply"
Message-Id: <197A77C8-41B4-43E9-9779-CA68F39FD92E@icloud.com>
Date: Mon, 18 Jul 2022 19:11:43 -0700
Cc: christian.brauner@ubuntu.com, containers@lists.linux.dev,
 gscrivan@redhat.com, keescook@chromium.org, linux-kernel@vger.kernel.org,
 luto@kernel.org, mauricio@kinvolk.io, mic@linux.microsoft.com,
 rodrigo@kinvolk.io, tycho@tycho.pizza
To: robianna1973@icloud.com
X-Mailer: iPad Mail (19F77)
X-Proofpoint-GUID: 1SsgwYhOc9jBbmZaufleECSYZXZX-DG5
X-Proofpoint-ORIG-GUID: 1SsgwYhOc9jBbmZaufleECSYZXZX-DG5
X-Proofpoint-Virus-Version: =?UTF-8?Q?vendor=3Dfsecure_engine=3D1.1.170-22c6f66c430a71ce266a39bfe25bc?=
 =?UTF-8?Q?2903e8d5c8f:6.0.138,18.0.572,17.0.605.474.0000000_definitions?=
 =?UTF-8?Q?=3D2020-02-14=5F11:2020-02-14=5F02,2020-02-14=5F11,2020-01-23?=
 =?UTF-8?Q?=5F02_signatures=3D0?=
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 bulkscore=0
 malwarescore=0 spamscore=0 phishscore=0 clxscore=1011 mlxscore=0
 adultscore=0 mlxlogscore=519 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.12.0-2202240000 definitions=main-2207190006

=EF=BB=BF


Sent from my iPad=
