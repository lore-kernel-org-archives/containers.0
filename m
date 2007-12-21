From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [patch 1/2] [RFC] Simple tamper-proof device filesystem.
Date: Thu, 20 Dec 2007 20:47:00 -0500
Message-ID: <476B1B14.3060404@cs.columbia.edu>
References: <20071216080628.061470932@I-love.SAKURA.ne.jp>
	<200712161944.HEI26071.MOtOFLVHFSQFOJ@I-love.SAKURA.ne.jp>
	<200712161956.BJE32406.FOOHtQJLMFOSVF@I-love.SAKURA.ne.jp>
	<20071217194802.GA14156@sergelap.austin.ibm.com>
	<200712180003.lBI03N7F092396@www262.sakura.ne.jp>
	<20071218003955.GA27048@sergelap.austin.ibm.com>
	<476724E3.6060901@cs.columbia.edu>
	<20071218020933.GA28745@sergelap.austin.ibm.com>
	<476738A0.9010601@cs.columbia.edu> <4768E7B2.40203@openvz.org>
	<20071219141004.GA31694@sergelap.austin.ibm.com>
	<4769B228.4030705@cs.columbia.edu> <476A1CE0.30505@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <476A1CE0.30505-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Tetsuo Handa <penguin-kernel-1yMVhJb1mP/7nzcFbJAaVXf5DAMn2ifp@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org



Pavel Emelyanov wrote:
> Oren Laadan wrote:
>> Serge E. Hallyn wrote:
>>> Quoting Pavel Emelyanov (xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org):
>>>> Oren Laadan wrote:
>>>>> Serge E. Hallyn wrote:
>>>>>> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
>>>>>>> I hate to bring this again, but what if the admin in the container
>>>>>>> mounts an external file system (eg. nfs, usb, loop mount from a file,
>>>>>>> or via fuse), and that file system already has a device that we would
>>>>>>> like to ban inside that container ?
>>>>>> Miklos' user mount patches enforced that if !capable(CAP_MKNOD),
>>>>>> then mnt->mnt_flags |= MNT_NODEV.  So that's no problem.
>>>>> Yes, that works to disallow all device files from a mounted file system.
>>>>>
>>>>> But it's a black and white thing: either they are all banned or allowed;
>>>>> you can't have some devices allowed and others not, depending on type
>>>>> A scenario where this may be useful is, for instance, if we some apps in
>>>>> the container to execute withing a pre-made chroot (sub)tree within that
>>>>> container.
>>>>>
>>>>>> But that's been pulled out of -mm! ?  Crap.
>>>>>>
>>>>>>> Since anyway we will have to keep a white- (or black-) list of devices
>>>>>>> that are permitted in a container, and that list may change even change
>>>>>>> per container -- why not enforce the access control at the VFS layer ?
>>>>>>> It's safer in the long run.
>>>>>> By that you mean more along the lines of Pavel's patch than my whitelist
>>>>>> LSM, or you actually mean Tetsuo's filesystem (i assume you don't mean that
>>>>>> by 'vfs layer' :), or something different entirely?
>>>>> :)
>>>>>
>>>>> By 'vfs' I mean at open() time, and not at mount(), or mknod() time.
>>>>> Either yours or Pavel's; I tend to prefer not to use LSM as it may
>>>>> collide with future security modules.
>>>> Oren, AFAIS you've seen my patches for device access controller, right?
>> If you mean this one:
>> http://openvz.org/pipermail/devel/2007-September/007647.html
>> then ack :)
> 
> Great! Thanks.
> 
>>>> Maybe we can revisit the issue then and try to come to agreement on what
>>>> kind of model and implementation we all want?
>>> That would be great, Pavel.  I do prefer your solution over my LSM, so
>>> if we can get an elegant block device control right in the vfs code that
>>> would be my preference.
>> I concur.
>>
>> So it seems to me that we are all in favor of the model where open()
>> of a device will consult a black/white-list. Also, we are all in favor
>> of a non-LSM implementation, Pavel's code being a good example.
> 
> Thank you, Oren and Serge! I will revisit this issue then, but
> I have a vacation the next week and, after this, we have a New
> Year and Christmas holidays in Russia. So I will be able to go
> on with it only after the 7th January :( Hope this is OK for you.
> 
> Besides, Andrew told that he would pay little attention to new
> features till the 2.6.24 release, so I'm afraid we won't have this 
> even in -mm in the nearest months :(

Sounds great !  (as for the delay, it wasn't the highest priority issue
to begin with, so no worries).

Ah.. coincidentally they are celebrated here, too, on the same time :D
Merry Christmas and Happy New Year !

Oren.

> 
> Thanks,
> Pavel
> 
>> Oren.
>>
>>> The only thing that makes me keep wanting to go back to an LSM is the
>>> fact that the code defining the whitelist seems out of place in the vfs.
>>> But I guess that's actually separated into a modular cgroup, with the
>>> actual enforcement built in at the vfs.  So that's really the best
>>> solution.
>>>
>>> -serge
> 
