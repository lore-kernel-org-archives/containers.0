Received: from out01.mta.xmission.com (out01.mta.xmission.com [166.70.13.231])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 79CE12FB8
	for <containers@lists.linux.dev>; Fri, 11 Jun 2021 18:16:01 +0000 (UTC)
Received: from in01.mta.xmission.com ([166.70.13.51])
	by out01.mta.xmission.com with esmtps  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1lrlhA-009KaE-8z; Fri, 11 Jun 2021 12:15:52 -0600
Received: from ip68-227-160-95.om.om.cox.net ([68.227.160.95] helo=email.xmission.com)
	by in01.mta.xmission.com with esmtpsa  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1lrlh8-004O0Y-OF; Fri, 11 Jun 2021 12:15:51 -0600
From: ebiederm@xmission.com (Eric W. Biederman)
To: Christian Brauner <christian.brauner@ubuntu.com>
Cc: Hannes Reinecke <hare@suse.de>,  gregkh@linuxfoundation.org,  containers@lists.linux.dev,  linux-kernel@vger.kernel.org,  lkml@metux.net
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
Date: Fri, 11 Jun 2021 13:14:42 -0500
In-Reply-To: <20210609080918.ma2klvxkjad4pjrn@wittgenstein> (Christian
	Brauner's message of "Wed, 9 Jun 2021 10:09:18 +0200")
Message-ID: <87v96k1d65.fsf@disp2133>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain
X-XM-SPF: eid=1lrlh8-004O0Y-OF;;;mid=<87v96k1d65.fsf@disp2133>;;;hst=in01.mta.xmission.com;;;ip=68.227.160.95;;;frm=ebiederm@xmission.com;;;spf=neutral
X-XM-AID: U2FsdGVkX1+rzWneDtBBHwa+W8ffoQqyKn7+TRmq7ss=
X-SA-Exim-Connect-IP: 68.227.160.95
X-SA-Exim-Mail-From: ebiederm@xmission.com
X-Spam-Checker-Version: SpamAssassin 3.4.2 (2018-09-13) on sa01.xmission.com
X-Spam-Level: *
X-Spam-Status: No, score=1.2 required=8.0 tests=ALL_TRUSTED,BAYES_50,
	DCC_CHECK_NEGATIVE,T_TM2_M_HEADER_IN_MSG,XM_B_SpammyWords,
	XM_Multi_Part_URI autolearn=disabled version=3.4.2
X-Spam-Virus: No
X-Spam-Report: 
	* -1.0 ALL_TRUSTED Passed through trusted hosts only via SMTP
	*  0.8 BAYES_50 BODY: Bayes spam probability is 40 to 60%
	*      [score: 0.5000]
	*  0.0 T_TM2_M_HEADER_IN_MSG BODY: No description available.
	*  1.2 XM_Multi_Part_URI URI: Long-Multi-Part URIs
	* -0.0 DCC_CHECK_NEGATIVE Not listed in DCC
	*      [sa01 1397; Body=1 Fuz1=1 Fuz2=1]
	*  0.2 XM_B_SpammyWords One or more commonly used spammy words
X-Spam-DCC: XMission; sa01 1397; Body=1 Fuz1=1 Fuz2=1 
X-Spam-Combo: *;Christian Brauner <christian.brauner@ubuntu.com>
X-Spam-Relay-Country: 
X-Spam-Timing: total 621 ms - load_scoreonly_sql: 0.03 (0.0%),
	signal_user_changed: 3.8 (0.6%), b_tie_ro: 2.6 (0.4%), parse: 0.71
	(0.1%), extract_message_metadata: 14 (2.3%), get_uri_detail_list: 2.4
	(0.4%), tests_pri_-1000: 13 (2.1%), tests_pri_-950: 0.99 (0.2%),
	tests_pri_-900: 0.79 (0.1%), tests_pri_-90: 229 (36.9%), check_bayes:
	217 (35.0%), b_tokenize: 7 (1.2%), b_tok_get_all: 9 (1.5%),
	b_comp_prob: 2.3 (0.4%), b_tok_touch_all: 195 (31.4%), b_finish: 0.63
	(0.1%), tests_pri_0: 347 (55.9%), check_dkim_signature: 0.41 (0.1%),
	check_dkim_adsp: 1.53 (0.2%), poll_dns_idle: 0.30 (0.0%),
	tests_pri_10: 1.62 (0.3%), tests_pri_500: 7 (1.1%), rewrite_mail: 0.00
	(0.0%)
Subject: Re: device namespaces
X-SA-Exim-Version: 4.2.1 (built Sat, 08 Feb 2020 21:53:50 +0000)
X-SA-Exim-Scanned: Yes (on in01.mta.xmission.com)

Christian Brauner <christian.brauner@ubuntu.com> writes:

> On Wed, Jun 09, 2021 at 09:54:05AM +0200, Hannes Reinecke wrote:
>> On 6/9/21 9:21 AM, Christian Brauner wrote:
>> > On Wed, Jun 09, 2021 at 09:02:36AM +0200, Hannes Reinecke wrote:
>> >> On 6/9/21 8:38 AM, Christian Brauner wrote:
>> >>> On Tue, Jun 08, 2021 at 12:16:43PM -0500, Eric W. Biederman wrote:
>> >>>> Hannes Reinecke <hare@suse.de> writes:
>> >>>>
>> >>>>> On 6/8/21 4:29 PM, Christian Brauner wrote:
>> >>>>>> On Tue, Jun 08, 2021 at 04:10:08PM +0200, Hannes Reinecke wrote:
>> >> [ .. ]
>> >>>>> Granted, modifying sysfs layout is not something for the faint-hearted,
>> >>>>> and one really has to look closely to ensure you end up with a
>> >>>>> consistent layout afterwards.
>> >>>>>
>> >>>>> But let's see how things go; might well be that it turns out to be too
>> >>>>> complex to consider. Can't tell yet.
>> >>>>
>> >>>> I would suggest aiming for something like devptsfs without the
>> >>>> complication of /dev/ptmx.
>> >>>>
>> >>>> That is a pseudo filesystem that has a control node and virtual block
>> >>>> devices that were created using that control node.
>> >>>
>> >>> Also see android/binder/binderfs.c
>> >>>
>> >> Ah. Will have a look.
>> > 
>> > I implemented this a few years back and I think it should've made it
>> > onto Android by default now. So that approach does indeed work well, it
>> > seems:
>> > https://chromium.googlesource.com/aosp/platform/system/core/+/master/rootdir/init.rc#257
>> > 
>> > This should be easier to follow than the devpts case because you don't
>> > need to wade through the {t,p}ty layer.
>> > 
>> >>
>> >>>>
>> >>>> That is the cleanest solution I know and is not strictly limited to use
>> >>>> with containers so it can also gain greater traction.  The interaction
>> >>>> with devtmpfs should be simply having devtmpfs create a mount point for
>> >>>> that filesystem.
>> >>>>
>> >>>> This could be a new cleaner api for things like loopback devices.
>> >>>
>> >>> I sent a patchset that implemented this last year.
>> >>>
>> >> Do you have a pointer/commit hash for this?
>> > 
>> > Yes, sure:
>> > https://lore.kernel.org/linux-block/20200424162052.441452-1-christian.brauner@ubuntu.com/
>> > 
>> > You can also just pull my branch. I think it's still based on v5.7 or sm:
>> > https://git.kernel.org/pub/scm/linux/kernel/git/brauner/linux.git/log/?h=loopfs
>> > 
>> > I'm happy to collaborate on this too.
>> >
>> How _very_ curious. 'kernfs: handle multiple namespace tags' and 'loop:
>> preserve sysfs backwards compability' are essentially the same patches I
>> did for my block namespaces prototyp; I named it 'KOBJ_NS_TYPE_BLK', not
>> 'KOBJ_NS_TYPE_USER', though :-)
>> 
>> Guess we really should cooperate.
>> 
>> Speaking of which: why did you name it 'user' namespace?
>> There already is a generic 'user_namespace' in
>> include/linux/user_namespace.h, serving as a container for all
>> namespaces; as such it probably should include this 'user' namespace,
>> leading to quite some confusion.
>> 
>> Or did I misunderstood something here?
>
> Ah yes, you misunderstand. The KOBJ_NS_TYPE_* tags are namespace tags.
> So KOBJ_NS_TYPE_NET is a network namespace tag. So KOBJ_NS_TYPE_USER is
> a user namespace tag not a completely new namespace. The idea very
> roughly being that devices such as loop devices are ultimately filtered
> by user namespace which is taken from the s_user_ns the loopfs instance
> is mounted in. We should compare notes.

There are two easy possibilities.

- All of the devices on the filesystem show up in sysfs with unique
  major minor numbers.
- None of the devices on the filesystem show up in sysfs.
  (Which I believe is what devpts does).

I favor none of the virtual devices showing up in sysfs.  Maybe existing
userspace needs the devices in sysfs, but if the solution is simply to
skip sysfs for virtual devices that is much simpler.

Eric

