Received: from out03.mta.xmission.com (out03.mta.xmission.com [166.70.13.233])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D2C4A1106
	for <containers@lists.linux.dev>; Sat, 14 Oct 2023 04:21:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=xmission.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=xmission.com
Authentication-Results: smtp.subspace.kernel.org; dkim=none
Received: from in01.mta.xmission.com ([166.70.13.51]:48410)
	by out03.mta.xmission.com with esmtps  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1qrW9n-005sgw-48; Fri, 13 Oct 2023 22:21:43 -0600
Received: from ip68-227-168-167.om.om.cox.net ([68.227.168.167]:47692 helo=email.froward.int.ebiederm.org.xmission.com)
	by in01.mta.xmission.com with esmtpsa  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1qrW9k-00100L-Fq; Fri, 13 Oct 2023 22:21:42 -0600
From: "Eric W. Biederman" <ebiederm@xmission.com>
To: yunhui cui <cuiyunhui@bytedance.com>
Cc: akpm@linux-foundation.org,  keescook@chromium.org,  brauner@kernel.org,
  jeffxu@google.com,  frederic@kernel.org,  mcgrof@kernel.org,
  cyphar@cyphar.com,  rongtao@cestc.cn,  linux-kernel@vger.kernel.org,
  Linux Containers <containers@lists.linux.dev>
References: <20231011065446.53034-1-cuiyunhui@bytedance.com>
	<87sf6gcyb3.fsf@email.froward.int.ebiederm.org>
	<CAEEQ3wm8oE1dXo7AuU3gY90oF_G21OqNZwnkqhhd1-_j4wWbYQ@mail.gmail.com>
	<87r0lyad40.fsf@email.froward.int.ebiederm.org>
	<CAEEQ3wmerA8p2qpEAn9pGW5BW35777VFwabusyFTAEyaf-0JPg@mail.gmail.com>
Date: Fri, 13 Oct 2023 23:21:10 -0500
In-Reply-To: <CAEEQ3wmerA8p2qpEAn9pGW5BW35777VFwabusyFTAEyaf-0JPg@mail.gmail.com>
	(yunhui cui's message of "Sat, 14 Oct 2023 11:41:06 +0800")
Message-ID: <87h6mt96mh.fsf@email.froward.int.ebiederm.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/27.1 (gnu/linux)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-XM-SPF: eid=1qrW9k-00100L-Fq;;;mid=<87h6mt96mh.fsf@email.froward.int.ebiederm.org>;;;hst=in01.mta.xmission.com;;;ip=68.227.168.167;;;frm=ebiederm@xmission.com;;;spf=pass
X-XM-AID: U2FsdGVkX1/F6unJ1dKS955e9zrTtEgBvvT4H5HFBuY=
X-SA-Exim-Connect-IP: 68.227.168.167
X-SA-Exim-Mail-From: ebiederm@xmission.com
X-Spam-Checker-Version: SpamAssassin 3.4.2 (2018-09-13) on sa06.xmission.com
X-Spam-Level: 
X-Spam-Status: No, score=0.7 required=8.0 tests=ALL_TRUSTED,BAYES_50,
	DCC_CHECK_NEGATIVE,T_TM2_M_HEADER_IN_MSG,XMSubLong,XM_B_SpammyWords,
	XM_B_Unicode shortcircuit=no autolearn=disabled version=3.4.2
X-Spam-Report: 
	* -1.0 ALL_TRUSTED Passed through trusted hosts only via SMTP
	*  0.8 BAYES_50 BODY: Bayes spam probability is 40 to 60%
	*      [score: 0.4233]
	*  0.7 XMSubLong Long Subject
	*  0.0 T_TM2_M_HEADER_IN_MSG BODY: No description available.
	*  0.0 XM_B_Unicode BODY: Testing for specific types of unicode
	* -0.0 DCC_CHECK_NEGATIVE Not listed in DCC
	*      [sa06 1397; Body=1 Fuz1=1 Fuz2=1]
	*  0.2 XM_B_SpammyWords One or more commonly used spammy words
X-Spam-DCC: XMission; sa06 1397; Body=1 Fuz1=1 Fuz2=1 
X-Spam-Combo: ;yunhui cui <cuiyunhui@bytedance.com>
X-Spam-Relay-Country: 
X-Spam-Timing: total 1917 ms - load_scoreonly_sql: 0.08 (0.0%),
	signal_user_changed: 12 (0.7%), b_tie_ro: 11 (0.6%), parse: 1.52
	(0.1%), extract_message_metadata: 20 (1.0%), get_uri_detail_list: 3.3
	(0.2%), tests_pri_-2000: 23 (1.2%), tests_pri_-1000: 2.5 (0.1%),
	tests_pri_-950: 1.32 (0.1%), tests_pri_-900: 1.10 (0.1%),
	tests_pri_-200: 0.90 (0.0%), tests_pri_-100: 3.8 (0.2%),
	tests_pri_-90: 1459 (76.1%), check_bayes: 1446 (75.4%), b_tokenize: 10
	(0.5%), b_tok_get_all: 9 (0.5%), b_comp_prob: 3.1 (0.2%),
	b_tok_touch_all: 1419 (74.0%), b_finish: 0.95 (0.0%), tests_pri_0: 379
	(19.8%), check_dkim_signature: 0.65 (0.0%), check_dkim_adsp: 3.3
	(0.2%), poll_dns_idle: 0.31 (0.0%), tests_pri_10: 2.2 (0.1%),
	tests_pri_500: 7 (0.4%), rewrite_mail: 0.00 (0.0%)
Subject: Re: [External] Re: [PATCH] pid_ns: support pidns switching between
 sibling
X-SA-Exim-Version: 4.2.1 (built Sat, 08 Feb 2020 21:53:50 +0000)
X-SA-Exim-Scanned: Yes (on in01.mta.xmission.com)

yunhui cui <cuiyunhui@bytedance.com> writes:

> Hi Eric=EF=BC=8C
>
> On Fri, Oct 13, 2023 at 9:04=E2=80=AFPM Eric W. Biederman <ebiederm@xmiss=
ion.com> wrote:
>>
>> yunhui cui <cuiyunhui@bytedance.com> writes:
>>
>> > Hi Eric,
>> >
>> > On Thu, Oct 12, 2023 at 11:31=E2=80=AFAM Eric W. Biederman
>> > <ebiederm@xmission.com> wrote:
>> >>
>> >> The check you are deleting is what verifies the pid namespaces you are
>> >> attempting to change pid_ns_for_children to is a member of the tasks
>> >> current pid namespace (aka task_active_pid_ns).
>> >>
>> >>
>> >> There is a perfectly good comment describing why what you are attempt=
ing
>> >> to do is unsupportable.
>> >>
>> >>         /*
>> >>          * Only allow entering the current active pid namespace
>> >>          * or a child of the current active pid namespace.
>> >>          *
>> >>          * This is required for fork to return a usable pid value and
>> >>          * this maintains the property that processes and their
>> >>          * children can not escape their current pid namespace.
>> >>          */
>> >>
>> >>
>> >> If you pick a pid namespace that does not meet the restrictions you a=
re
>> >> removing the pid of the new child can not be mapped into the pid
>> >> namespace of the parent that called setns.
>> >>
>> >> AKA the following code can not work.
>> >>
>> >> pid =3D fork();
>> >> if (!pid) {
>> >>         /* child */
>> >>         do_something();
>> >>         _exit(0);
>> >> }
>> >> waitpid(pid);
>> >
>> > Sorry, I don't understand what you mean here.
>>
>> What I mean is that if your simple patch was adopted,
>> then the classic way of controlling a fork would fail.
>>
>>         pid =3D fork()
>>         ^--------------- Would return 0 for both parent and child
>>         ^--------------- Look at pid_nr_ns to understand.
>>         if (!pid() {
>>                 /* child */
>>                 do_something();
>>                 _exit(0);
>>         }
>>         waitpid(pid);
>
> okay, The reason here is that pid_nr_ns has no pid in the current
> pidns of the child process, and returns 0.
> Can this also support sibling traversal?

Not without a complete redesign.

> If so, it means that the process also has a pid in its sibling's pidns.



>> For your use case there are more serious problems as well.  The entire
>> process hierarchy built would be incorrect.   Which means children
>> signaling parents when they exit would be incorrect, and that parents
>> would not be able to wait on their children.
>
> Therefore, support for slibing pidns must be added to the entire logic of=
 pidns.
> Do you have any plans to support this,

No plans to support it.

> or what are the good reasons for not supporting it?

I see no point, it is a lot of work, and your container acceleration
still won't work.

By forking from your original processes instead of properly building
the process hierarchy.  If a pair of your original processes are doing:

	pid =3D fork()
	if (!pid() {
	        /* child */
                <-------------------------- clone created here
	        do_something();
	        _exit(0);
	}
        <---------------------------------- clone created here
	waitpid(pid);


Their clones won't work.  Not because the pids aren't the same, but
because the clones are not parent and child.  Which causes waitpid
not to see the other process.



I believe you want to do this sibling pid_ns fork so that you can
have copy-on-write of the anonymous pages of the original process.
Which is a completely reasonable thing to want.




For performing copy-on-write between machines we have userfaultfd.

For simply reading the pages we have process_vm_readv.

I think what you want is essentially process_vm_cow_map.  Unfortunately
no one has built that yet.

Maybe memfd is a better model to start from?  Something where you pause
process a, setup the cow in process a, and place the pages in process
b.  With the final result that either process a or process b writing
to the page will cause the copy on write to happen the and page to be
unshared.

I really think you need something that will decouple the copy-on-write
mechanism of fork from the rest of fork, so you can build a proper
process hierarchy.

Eric
