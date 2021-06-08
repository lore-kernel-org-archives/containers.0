Received: from out01.mta.xmission.com (out01.mta.xmission.com [166.70.13.231])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 507BD2F80
	for <containers@lists.linux.dev>; Tue,  8 Jun 2021 18:20:37 +0000 (UTC)
Received: from in01.mta.xmission.com ([166.70.13.51])
	by out01.mta.xmission.com with esmtps  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1lqfLd-001vcX-9C; Tue, 08 Jun 2021 11:17:05 -0600
Received: from ip68-227-160-95.om.om.cox.net ([68.227.160.95] helo=email.xmission.com)
	by in01.mta.xmission.com with esmtpsa  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1lqfLa-00CNrZ-Im; Tue, 08 Jun 2021 11:17:04 -0600
From: ebiederm@xmission.com (Eric W. Biederman)
To: Hannes Reinecke <hare@suse.de>
Cc: Christian Brauner <christian.brauner@ubuntu.com>,  gregkh@linuxfoundation.org,  containers@lists.linux.dev,  linux-kernel@vger.kernel.org,  lkml@metux.net
References: <YL9liW99Ytf6uBlu@kroah.com>
	<9157affa-b27a-c0f4-f6ee-def4a991fd4e@suse.de>
	<20210608142911.ievp2rpuquxjuyus@wittgenstein>
	<d956398e-7ee6-ba36-43cc-4cdcea34b5b9@suse.de>
Date: Tue, 08 Jun 2021 12:16:43 -0500
In-Reply-To: <d956398e-7ee6-ba36-43cc-4cdcea34b5b9@suse.de> (Hannes Reinecke's
	message of "Tue, 8 Jun 2021 17:54:51 +0200")
Message-ID: <877dj4ff9g.fsf@disp2133>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain
X-XM-SPF: eid=1lqfLa-00CNrZ-Im;;;mid=<877dj4ff9g.fsf@disp2133>;;;hst=in01.mta.xmission.com;;;ip=68.227.160.95;;;frm=ebiederm@xmission.com;;;spf=neutral
X-XM-AID: U2FsdGVkX1/Bm2bZBfEjGjpHHg9i+B5/XfEYNItIabs=
X-SA-Exim-Connect-IP: 68.227.160.95
X-SA-Exim-Mail-From: ebiederm@xmission.com
X-Spam-Checker-Version: SpamAssassin 3.4.2 (2018-09-13) on sa08.xmission.com
X-Spam-Level: 
X-Spam-Status: No, score=0.0 required=8.0 tests=ALL_TRUSTED,BAYES_50,
	DCC_CHECK_NEGATIVE,T_TM2_M_HEADER_IN_MSG,XM_B_SpammyWords
	autolearn=disabled version=3.4.2
X-Spam-Report: 
	* -1.0 ALL_TRUSTED Passed through trusted hosts only via SMTP
	*  0.8 BAYES_50 BODY: Bayes spam probability is 40 to 60%
	*      [score: 0.5000]
	*  0.0 T_TM2_M_HEADER_IN_MSG BODY: No description available.
	* -0.0 DCC_CHECK_NEGATIVE Not listed in DCC
	*      [sa08 1397; Body=1 Fuz1=1 Fuz2=1]
	*  0.2 XM_B_SpammyWords One or more commonly used spammy words
X-Spam-DCC: XMission; sa08 1397; Body=1 Fuz1=1 Fuz2=1 
X-Spam-Combo: ;Hannes Reinecke <hare@suse.de>
X-Spam-Relay-Country: 
X-Spam-Timing: total 1119 ms - load_scoreonly_sql: 0.05 (0.0%),
	signal_user_changed: 13 (1.2%), b_tie_ro: 11 (1.0%), parse: 1.10
	(0.1%), extract_message_metadata: 14 (1.3%), get_uri_detail_list: 3.8
	(0.3%), tests_pri_-1000: 5 (0.5%), tests_pri_-950: 1.37 (0.1%),
	tests_pri_-900: 1.15 (0.1%), tests_pri_-90: 172 (15.4%), check_bayes:
	170 (15.2%), b_tokenize: 11 (1.0%), b_tok_get_all: 13 (1.2%),
	b_comp_prob: 6 (0.5%), b_tok_touch_all: 133 (11.9%), b_finish: 1.30
	(0.1%), tests_pri_0: 892 (79.7%), check_dkim_signature: 0.53 (0.0%),
	check_dkim_adsp: 12 (1.0%), poll_dns_idle: 0.72 (0.1%), tests_pri_10:
	4.2 (0.4%), tests_pri_500: 11 (1.0%), rewrite_mail: 0.00 (0.0%)
Subject: Re: device namespaces
X-SA-Exim-Version: 4.2.1 (built Sat, 08 Feb 2020 21:53:50 +0000)
X-SA-Exim-Scanned: Yes (on in01.mta.xmission.com)

Hannes Reinecke <hare@suse.de> writes:

> On 6/8/21 4:29 PM, Christian Brauner wrote:
>> On Tue, Jun 08, 2021 at 04:10:08PM +0200, Hannes Reinecke wrote:
>>> On Tue, Jun 08, 2021 Greg-KH wrote:
>>>> On Tue, Jun 08, 2021 at 02:30:50PM +0200, Christian Brauner wrote:
>>>>> On Tue, Jun 08, 2021 at 11:38:16AM +0200, Enrico Weigelt,
>>>>> metux IT consult wrote:
>>>>>> Hello folks,
>>>>>>
>>>>>>
>>>>>> I'm going to implement device namespaces, where containers can get
>>>>>> an entirely different view of the devices in the machine (usually
>>>>>> just a specific subset, but possibly additional virtual devices).
>>>>>>
>>> [ .. ]
>>>>>> Is this a good way to go ? Or what would be a better one ?
>>>>>
>>>>> Ccing Greg. Without adressing specific problems, I should warn you
>>>>> that this idea is not new and the plan is unlikely to go anywhere.
>>>>> Especially not without support from Greg.
>>>>
>>>> Hah, yeah, this is a non-starter.
>>>>
>>>> Enrico, what real problem are you trying to solve by doing this?  And
>>>> have you tried anything with this yet?  We almost never talk about
>>>> "proposals" without seeing real code as it's pointless to discuss
>>>> things when you haven't even proven that it can work.
>>>>
>>>> So let's see code before even talking about this...
>>>>
>>>> And as Christian points out, you can do this today without any kernel
>>>> changes, so to think you need to modify the kernel means that you
>>>> haven't even tried this at all?
>>>>
>>> Curious, I had been looking into this, too.
>>> And I have to side with Greg and Christian that your proposal should
>>> already be possible today (cf device groups, which curiously has a
>>> near-identical interface to what you proposed).
>>> Also, I think that a generic 'device namespace' is too broad a scope;
>>> some subsystems like net already inherited namespace support, and it
>>> turns out to be not exactly trivial to implement.
>>>
>>> What I'm looking at, though, is to implement 'block' namespaces, to
>>> restrict access to _new_ block devices to any give namespace.
>>> Case in point: if a container creates a ramdisk it's questionable
>>> whether other containers should even see it. iSCSI devices are a similar
>>> case; when starting iSCSI devices from containers their use should be
>>> restricted to that container.
>>> And that's not only the device node in /dev, but would also entail sysfs
>>> access, which from my understanding is not modified with the current code.
>> 
>> Hey Hannes. :)
>> 
>> It isn't and we likely shouldn't. You'd likely need to get into the
>> business of namespacing devtmpfs one way or the other which Seth Forshee
>> and I once did. But that's really not needed anymore imho. Device
>> management, i.e. creating device nodes should be the job of a container
>> manager. We already do that for example (Hotplugging devices ranging
>> from net devices, to disks, to GPUs.) and it works great.
>> 
> Right; clearly you can do that within the container.
> But my main grudge here is not the container but rather the system
> _hosting_ the container.
> That is typically using devtmpfs and hence will see _all_ devices, even
> those belonging to the container.
> This is causing grief to no end if eg the host system starts activating
> LVM on devices which are passed to the qemu instance running within a
> container ...
>
>> To make this really clean you will likely have to significantly rework
>> sysfs too and I don't think that churn is worth it and introduces a
>> layer of complexity I find outright nakable. And ignoring sysfs or
>> hacking around it is also not an option I find tasteful.
>> 
> Network namespaces already have the bits and pieces to modify sysfs, so
> we should be able to leverage that for block, too.
> And I think by restricting it to 'block' devices we should be to keep
> the required sysfs modifications in a manageable level.
>
>>>
>>> uevent redirection would help here, but from what I've seen it's only
>>> for net devices; feels a bit awkward to have a network namespace to get
>>> uevents for block devices, but then I'll have to test.
>> 
>> Just to move everyone on the same page. This is not specific to network
>> devices actually.
>> 
>> You are right though that network devices are correctly namespaced.
>> Specifically you only get uevents in the network namespace that network
>> device is moved into. The sysfs permissions for network devices were
>> correct if you created that network device in the network namespace but
>> they were wrong when you moved a network device between network
>> namespaces (with different owning user namespaces). That lead to all
>> kinds of weird issues. I fixed that a while back.
>> 
> Granted, modifying sysfs layout is not something for the faint-hearted,
> and one really has to look closely to ensure you end up with a
> consistent layout afterwards.
>
> But let's see how things go; might well be that it turns out to be too
> complex to consider. Can't tell yet.

I would suggest aiming for something like devptsfs without the
complication of /dev/ptmx.

That is a pseudo filesystem that has a control node and virtual block
devices that were created using that control node.

That is the cleanest solution I know and is not strictly limited to use
with containers so it can also gain greater traction.  The interaction
with devtmpfs should be simply having devtmpfs create a mount point for
that filesystem.

This could be a new cleaner api for things like loopback devices.

However the limitation for block devices that I am aware of is that we
don't currently have any filesystems in the kernel that are written
robustly enough that we can be expected to be secure when mounted on top
of an evil block device.  Some of the network filesystems are built
to withstand evil network packets, and possibly evil servers.  So with
care we can probably allow for unprivileged mounts there.


Eric
