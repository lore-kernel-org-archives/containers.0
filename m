Received: from out03.mta.xmission.com (out03.mta.xmission.com [166.70.13.233])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A1A1E3D97
	for <containers@lists.linux.dev>; Tue, 12 Jul 2022 14:41:52 +0000 (UTC)
Received: from in02.mta.xmission.com ([166.70.13.52]:52280)
	by out03.mta.xmission.com with esmtps  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1oBGh6-00HHYh-JG; Tue, 12 Jul 2022 08:16:56 -0600
Received: from ip68-227-174-4.om.om.cox.net ([68.227.174.4]:44978 helo=email.froward.int.ebiederm.org.xmission.com)
	by in02.mta.xmission.com with esmtpsa  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1oBGh5-00Dcz6-D8; Tue, 12 Jul 2022 08:16:56 -0600
From: "Eric W. Biederman" <ebiederm@xmission.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: David Howells <dhowells@redhat.com>,  linux-kernel@vger.kernel.org,
 Ian Kent <raven@themaw.net>,
 Trond Myklebust <trond.myklebust@hammerspace.com>,
 linux-nfs@vger.kernel.org,  linux-fsdevel@vger.kernel.org,
 Linux Containers <containers@lists.linux.dev> 
References: <cover.1657624639.git.bcodding@redhat.com>
Date: Tue, 12 Jul 2022 09:16:31 -0500
In-Reply-To: <cover.1657624639.git.bcodding@redhat.com> (Benjamin Coddington's
	message of "Tue, 12 Jul 2022 08:35:19 -0400")
Message-ID: <875yk25scg.fsf@email.froward.int.ebiederm.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/27.1 (gnu/linux)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain
X-XM-SPF: eid=1oBGh5-00Dcz6-D8;;;mid=<875yk25scg.fsf@email.froward.int.ebiederm.org>;;;hst=in02.mta.xmission.com;;;ip=68.227.174.4;;;frm=ebiederm@xmission.com;;;spf=softfail
X-XM-AID: U2FsdGVkX19JAGcodrl2XslC9iLjx2+NewTf7WBi7Ko=
X-SA-Exim-Connect-IP: 68.227.174.4
X-SA-Exim-Mail-From: ebiederm@xmission.com
X-Spam-Checker-Version: SpamAssassin 3.4.2 (2018-09-13) on sa04.xmission.com
X-Spam-Level: ****
X-Spam-Status: No, score=4.5 required=8.0 tests=ALL_TRUSTED,BAYES_50,
	DCC_CHECK_NEGATIVE,T_TM2_M_HEADER_IN_MSG,T_TooManySym_01,XMNoVowels,
	XMSubLong,XM_SPF_SoftFail autolearn=disabled version=3.4.2
X-Spam-Report: 
	* -1.0 ALL_TRUSTED Passed through trusted hosts only via SMTP
	*  0.8 BAYES_50 BODY: Bayes spam probability is 40 to 60%
	*      [score: 0.4996]
	*  0.7 XMSubLong Long Subject
	*  1.5 XMNoVowels Alpha-numberic number with no vowels
	*  0.0 T_TM2_M_HEADER_IN_MSG BODY: No description available.
	* -0.0 DCC_CHECK_NEGATIVE Not listed in DCC
	*      [sa04 1397; Body=1 Fuz1=1 Fuz2=1]
	*  2.5 XM_SPF_SoftFail SPF-SoftFail
	*  0.0 T_TooManySym_01 4+ unique symbols in subject
X-Spam-DCC: XMission; sa04 1397; Body=1 Fuz1=1 Fuz2=1 
X-Spam-Combo: ****;Benjamin Coddington <bcodding@redhat.com>
X-Spam-Relay-Country: 
X-Spam-Timing: total 607 ms - load_scoreonly_sql: 0.06 (0.0%),
	signal_user_changed: 11 (1.8%), b_tie_ro: 9 (1.6%), parse: 1.02 (0.2%),
	 extract_message_metadata: 5 (0.9%), get_uri_detail_list: 2.8 (0.5%),
	tests_pri_-1000: 4.0 (0.7%), tests_pri_-950: 1.28 (0.2%),
	tests_pri_-900: 1.04 (0.2%), tests_pri_-90: 178 (29.3%), check_bayes:
	176 (28.9%), b_tokenize: 9 (1.5%), b_tok_get_all: 11 (1.8%),
	b_comp_prob: 3.6 (0.6%), b_tok_touch_all: 147 (24.2%), b_finish: 1.33
	(0.2%), tests_pri_0: 380 (62.6%), check_dkim_signature: 0.67 (0.1%),
	check_dkim_adsp: 3.1 (0.5%), poll_dns_idle: 1.07 (0.2%), tests_pri_10:
	4.5 (0.7%), tests_pri_500: 13 (2.2%), rewrite_mail: 0.00 (0.0%)
Subject: Re: [RFC PATCH 0/2] Keyagents: another call_usermodehelper approach
 for namespaces
X-SA-Exim-Version: 4.2.1 (built Sat, 08 Feb 2020 21:53:50 +0000)
X-SA-Exim-Scanned: Yes (on in02.mta.xmission.com)


Adding the containers list to the discussion so more interested people
have a chance of seeing this.

Benjamin Coddington <bcodding@redhat.com> writes:

> A persistent unsolved problem exists: how can the kernel find and/or create
> the appropriate "container" within which to execute a userspace program to
> construct keys or satisfy users of call_usermodehelper()?
>
> I believe the latest serious attempt to solve this problem was David's "Make
> containers kernel objects":
> https://lore.kernel.org/lkml/149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk/
>
> Over in NFS' space, we've most recently pondered this issue while looking at
> ways to pass a kernel socket to userspace in order to handle TLS events:
> https://lore.kernel.org/linux-nfs/E2BF9CFF-9361-400B-BDEE-CF5E0AFDCA63@redhat.com/
>
> The problem is that containers are not kernel objects, rather a collection
> of namespaces, cgroups, etc.  Attempts at making the kernel aware of
> containers have been mired in discussion and problems.  It has been
> suggested that the best representation of a "container" from the kernel's
> perspective is a process.
>
> Keyagents are processes represented by a key.  If a keyagent's key is linked
> to a session_keyring, it can be sent a realtime signal when a calling
> process requests a matching key_type.  That signal will dispatch the process
> to construct the desired key within the keyagent process context.  Keyagents
> are similar to ssh-agents.  To use a keyagent, one must execute a keyagent
> process in the desired context, and then link the keyagent's key onto other
> process' session_keyrings.
>
> This method of linking keyagent keys to session_keyrings can be used to
> construct the various mappings of callers to keyagents that containers may
> need.  A single keyagent process can answer request-key upcalls across
> container boundaries, or upcalls can be restricted to specific containers.
>
> I'm aware that building on realtime signals may not be a popular choice, but
> using realtime signals makes this work simple and ensures delivery.  Realtime
> signals are able to convey everything needed to construct keys in userspace:
> the under-construction key's serial number.
>
> This work is not complete; it has security implications, it needs
> documentation, it has not been reviewed by anyone.  Thanks for reading this
> RFC.  I wish to collect criticism and validate this approach.

At a high level I do agree that we need to send a message to a userspace
process and that message should contain enough information to start the
user mode helper.

Then a daemon or possibly the container init can receive the message
and dispatch the user mode helper.

Fundamentally that design solves all of the container issues, and I
think solves a few of the user mode helper issues as well.

The challenge with this design is that it requires someone standing up a
daemon to receive the messages and call a user mode helper to retain
compatibility with current systems.



I would prefer to see a file descriptor rather than a signal used to
deliver the message.  Signals suck for many many reasons and a file
descriptor based notification potentially can be much simpler.

One of those many reasons is that by not following the common pattern
for filling in kernel_siginfo you have left uninitialized padding in
your structure that will be copied to userspace thus creating a kernel
information leak.  Similarly your code doesn't fill in about half the
fields that are present in the siginfo union for the _rt case.


I think a file descriptor based design could additionally address the
back and forth your design needs with keys to figure out what event has
happened and what user mode helper to invoke.



Ideally I would also like to see a design less tied to keys.  So that we
could use this for the other user mode helper cases as well.   That said
solving request_key appears to be the truly important part, there aren't
many other user mode helpers.  Still it would be nice if in theory the
design could be used to dispatch the coredump helper as well.

Eric
