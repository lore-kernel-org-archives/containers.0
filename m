Received: from out03.mta.xmission.com (out03.mta.xmission.com [166.70.13.233])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3B686168
	for <containers@lists.linux.dev>; Thu, 22 Jul 2021 16:35:31 +0000 (UTC)
Received: from in01.mta.xmission.com ([166.70.13.51]:40134)
	by out03.mta.xmission.com with esmtps  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1m6aXQ-001rFh-4t; Thu, 22 Jul 2021 09:23:04 -0600
Received: from ip68-227-160-95.om.om.cox.net ([68.227.160.95]:54554 helo=email.xmission.com)
	by in01.mta.xmission.com with esmtpsa  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1m6aXP-00CAcO-09; Thu, 22 Jul 2021 09:23:03 -0600
From: ebiederm@xmission.com (Eric W. Biederman)
To: Pratik Sampat <psampat@linux.ibm.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,  containers@lists.linux.dev,  containers@lists.linux-foundation.org,  legion@kernel.org,  akpm@linux-foundation.org,  christian.brauner@ubuntu.com,  hannes@cmpxchg.org,  mhocko@kernel.org,  Alexey Makhalov <amakhalov@vmware.com>,  llong@redhat.com,  pratik.r.sampat@gmail.com
References: <ac76aada-f94d-d596-9b3c-1dca5a9914d0@linux.ibm.com>
Date: Thu, 22 Jul 2021 10:22:55 -0500
In-Reply-To: <ac76aada-f94d-d596-9b3c-1dca5a9914d0@linux.ibm.com> (Pratik
	Sampat's message of "Thu, 22 Jul 2021 13:23:33 +0530")
Message-ID: <874kcmmkz4.fsf@disp2133>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain
X-XM-SPF: eid=1m6aXP-00CAcO-09;;;mid=<874kcmmkz4.fsf@disp2133>;;;hst=in01.mta.xmission.com;;;ip=68.227.160.95;;;frm=ebiederm@xmission.com;;;spf=neutral
X-XM-AID: U2FsdGVkX18bFDtghQbEVGy3Tkuyg3y6ZaCJ49dxbag=
X-SA-Exim-Connect-IP: 68.227.160.95
X-SA-Exim-Mail-From: ebiederm@xmission.com
X-Spam-Checker-Version: SpamAssassin 3.4.2 (2018-09-13) on sa07.xmission.com
X-Spam-Level: 
X-Spam-Status: No, score=0.5 required=8.0 tests=ALL_TRUSTED,BAYES_50,
	DCC_CHECK_NEGATIVE,T_TM2_M_HEADER_IN_MSG,XMSubLong autolearn=disabled
	version=3.4.2
X-Spam-Report: 
	* -1.0 ALL_TRUSTED Passed through trusted hosts only via SMTP
	*  0.8 BAYES_50 BODY: Bayes spam probability is 40 to 60%
	*      [score: 0.4997]
	*  0.7 XMSubLong Long Subject
	*  0.0 T_TM2_M_HEADER_IN_MSG BODY: No description available.
	* -0.0 DCC_CHECK_NEGATIVE Not listed in DCC
	*      [sa07 1397; Body=1 Fuz1=1 Fuz2=1]
X-Spam-DCC: XMission; sa07 1397; Body=1 Fuz1=1 Fuz2=1 
X-Spam-Combo: ;Pratik Sampat <psampat@linux.ibm.com>
X-Spam-Relay-Country: 
X-Spam-Timing: total 387 ms - load_scoreonly_sql: 0.05 (0.0%),
	signal_user_changed: 11 (2.9%), b_tie_ro: 10 (2.6%), parse: 0.84
	(0.2%), extract_message_metadata: 3.1 (0.8%), get_uri_detail_list:
	1.23 (0.3%), tests_pri_-1000: 3.8 (1.0%), tests_pri_-950: 1.36 (0.4%),
	tests_pri_-900: 1.02 (0.3%), tests_pri_-90: 80 (20.7%), check_bayes:
	78 (20.2%), b_tokenize: 6 (1.6%), b_tok_get_all: 7 (1.8%),
	b_comp_prob: 2.8 (0.7%), b_tok_touch_all: 59 (15.2%), b_finish: 0.90
	(0.2%), tests_pri_0: 268 (69.4%), check_dkim_signature: 0.49 (0.1%),
	check_dkim_adsp: 3.3 (0.8%), poll_dns_idle: 1.44 (0.4%), tests_pri_10:
	2.1 (0.5%), tests_pri_500: 6 (1.6%), rewrite_mail: 0.00 (0.0%)
Subject: Re: [RFD] Provide virtualized CPU system information for containers
X-SA-Exim-Version: 4.2.1 (built Sat, 08 Feb 2020 21:53:50 +0000)
X-SA-Exim-Scanned: Yes (on in01.mta.xmission.com)


As stated I think this idea is a non-starter.

There is a real problem that there are applications that have a
legitimate need to know what cpu resources are available for them to use
and we don't have a good interfaces for them to request that
information.

I think MESOS solved this by passing a MAX_CPUS environment variable,
and at least the JVM was modified to use that variable.

That said as situations can be a bit more dynamic and fluid having
something where an application can look and see what resources are
available from it's view of the world seems reasonable.

AKA we need something so applications can stop conflating physical
cpu resources that are available with cpu resources that are allowed
to be used in an application.

This might be as simple as implementing a /proc/self/cpus_available
file.

Without the will to go through find existing open source applications
that care and update them so that they will use the new interface I
don't think anything will really happen.

The problem I see with changing existing interfaces that describe the
hardware is that the definition becomes unclear and so different
applications can legitimately expect different things, and it would
become impossible to implement what is needed correctly.

The problem I see with using cgroup interfaces is that they are not
targeted at end user applications and but rather are targeted at the
problem of controlling access to a resource.  Using them report what is
available again gets you into the multiple master problem.  Especially
as cgroups may not be the only thing in the system controlling access to
your resource.

So I really think the only good solution that people won't mind is to go
through the applications figure out what information is legitimately
needed from an application perspective, and build an interface tailored
for applications to get that information.

Then applications can be updated to use the new interface, and as the
implementation of the system changes the implementation in the kernel
can be updated to keep the applications working.

Eric
