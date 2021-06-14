Received: from out01.mta.xmission.com (out01.mta.xmission.com [166.70.13.231])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A433472
	for <containers@lists.linux.dev>; Mon, 14 Jun 2021 17:36:35 +0000 (UTC)
Received: from in01.mta.xmission.com ([166.70.13.51])
	by out01.mta.xmission.com with esmtps  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1lsqVg-00EAHg-Rf; Mon, 14 Jun 2021 11:36:28 -0600
Received: from ip68-227-160-95.om.om.cox.net ([68.227.160.95] helo=email.xmission.com)
	by in01.mta.xmission.com with esmtpsa  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1lsqVf-00AJ9J-8D; Mon, 14 Jun 2021 11:36:28 -0600
From: ebiederm@xmission.com (Eric W. Biederman)
To: "Enrico Weigelt\, metux IT consult" <lkml@metux.net>
Cc: Christian Brauner <christian.brauner@ubuntu.com>,  Hannes Reinecke <hare@suse.de>,  gregkh@linuxfoundation.org,  containers@lists.linux.dev,  linux-kernel@vger.kernel.org
References: <YL9liW99Ytf6uBlu@kroah.com>
	<9157affa-b27a-c0f4-f6ee-def4a991fd4e@suse.de>
	<20210608142911.ievp2rpuquxjuyus@wittgenstein>
	<d956398e-7ee6-ba36-43cc-4cdcea34b5b9@suse.de>
	<877dj4ff9g.fsf@disp2133>
	<20210609063818.xnod4rzvti3ujkvn@wittgenstein>
	<b9ea9116-7120-b0a7-b739-dd8513e12c5e@suse.de>
	<20210609072108.ldhsxfnfql4pacqx@wittgenstein>
	<85a0d777-dea6-9574-8946-9fc8f912c1af@suse.de>
	<20210609080918.ma2klvxkjad4pjrn@wittgenstein>
	<87v96k1d65.fsf@disp2133>
	<c504a8c6-73f8-b45c-6d6b-6f5a1300ab3a@metux.net>
Date: Mon, 14 Jun 2021 12:36:19 -0500
In-Reply-To: <c504a8c6-73f8-b45c-6d6b-6f5a1300ab3a@metux.net> (Enrico
	Weigelt's message of "Mon, 14 Jun 2021 09:49:22 +0200")
Message-ID: <874ke0s60c.fsf@disp2133>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain
X-XM-SPF: eid=1lsqVf-00AJ9J-8D;;;mid=<874ke0s60c.fsf@disp2133>;;;hst=in01.mta.xmission.com;;;ip=68.227.160.95;;;frm=ebiederm@xmission.com;;;spf=neutral
X-XM-AID: U2FsdGVkX18oIIyhANhT0NvXzEtqGitDOHZZn1qI5O4=
X-SA-Exim-Connect-IP: 68.227.160.95
X-SA-Exim-Mail-From: ebiederm@xmission.com
X-Spam-Checker-Version: SpamAssassin 3.4.2 (2018-09-13) on sa06.xmission.com
X-Spam-Level: 
X-Spam-Status: No, score=-0.2 required=8.0 tests=ALL_TRUSTED,BAYES_50,
	DCC_CHECK_NEGATIVE,T_TM2_M_HEADER_IN_MSG autolearn=disabled
	version=3.4.2
X-Spam-Report: 
	* -1.0 ALL_TRUSTED Passed through trusted hosts only via SMTP
	*  0.8 BAYES_50 BODY: Bayes spam probability is 40 to 60%
	*      [score: 0.4981]
	*  0.0 T_TM2_M_HEADER_IN_MSG BODY: No description available.
	* -0.0 DCC_CHECK_NEGATIVE Not listed in DCC
	*      [sa06 1397; Body=1 Fuz1=1 Fuz2=1]
X-Spam-DCC: XMission; sa06 1397; Body=1 Fuz1=1 Fuz2=1 
X-Spam-Combo: ;"Enrico Weigelt\, metux IT consult" <lkml@metux.net>
X-Spam-Relay-Country: 
X-Spam-Timing: total 823 ms - load_scoreonly_sql: 0.07 (0.0%),
	signal_user_changed: 11 (1.3%), b_tie_ro: 9 (1.1%), parse: 1.11 (0.1%),
	 extract_message_metadata: 13 (1.5%), get_uri_detail_list: 1.67 (0.2%),
	 tests_pri_-1000: 6 (0.7%), tests_pri_-950: 1.33 (0.2%),
	tests_pri_-900: 1.13 (0.1%), tests_pri_-90: 137 (16.7%), check_bayes:
	126 (15.3%), b_tokenize: 7 (0.8%), b_tok_get_all: 6 (0.8%),
	b_comp_prob: 2.4 (0.3%), b_tok_touch_all: 107 (13.0%), b_finish: 0.89
	(0.1%), tests_pri_0: 637 (77.4%), check_dkim_signature: 0.96 (0.1%),
	check_dkim_adsp: 3.0 (0.4%), poll_dns_idle: 0.46 (0.1%), tests_pri_10:
	2.1 (0.3%), tests_pri_500: 10 (1.2%), rewrite_mail: 0.00 (0.0%)
Subject: Re: device namespaces
X-SA-Exim-Version: 4.2.1 (built Sat, 08 Feb 2020 21:53:50 +0000)
X-SA-Exim-Scanned: Yes (on in01.mta.xmission.com)

"Enrico Weigelt, metux IT consult" <lkml@metux.net> writes:

> On 11.06.21 20:14, Eric W. Biederman wrote:
>
> Hi,
>
>> I favor none of the virtual devices showing up in sysfs.  Maybe existing
>> userspace needs the devices in sysfs, but if the solution is simply to
>> skip sysfs for virtual devices that is much simpler.
>
> Sorry for being a little bit confused, but by virtual devices you mean
> things like pty's or all the other stuff we already see under
> /sys/device/virtual ?

By virtual devices I mean all devices that are not physical pieces
of hardware.  For block devices I mean devices such as loopback
devices that are created on demand.  Ramdisks that start this
conversation could also be considered virtual devices.

> How would you skip the virtual devices from sysfs ? Adding some filter
> into sysfs that looks at the device class (or some flag within it) ?

I would just not run the code to create sysfs entries when the virtual
devices are created.

If you have virtual devices showing up in their own filesystem they
don't even need major or minor numbers.  You can just have files
that accept ioctls like device nodes.  In principle it is
possible to skip a lot of the historical infrastructure.  If the
infrastructure is not needed it is worth skipping.

I haven't dug into the block layer recently enough to say what is needed
or not.  I think there are some thing such as stat on a mounted
filesystem that need a major and minor numbers.  Which probably means
you have to use major and minor numbers.  By virtue of using common
infrastructure that implies showing up in sysfs and devtmpfs.  Things
would be limited just by not mounting devtmpfs in a container.

It is worth checking how much of the common infrastructure you need when
you start creating virtual devices.

The only reason the network devices need changes to sysfs is to allow
different network devices with the same name to show up in different
network namespaces.

If you can fundamentally avoid the problem of devices with the same
name needing to show up in sysfs and devtmpfs by using filesystems
then sysfs and devtmpfs needs no changes.

Hotplug is sufficiently widespread now that it should be possible
to avoid the hard problem of having duplicate names for block devices,
one way or another.  Thus talking of changing sysfs seems completely
unnecessary.

Eric
