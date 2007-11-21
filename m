From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 0/3] Sysctl shadow management
Date: Wed, 21 Nov 2007 12:52:03 +0300
Message-ID: <4743FFC3.9060104@openvz.org>
References: <4742C73C.3010904@openvz.org>	<m1y7ctrrrd.fsf@ebiederm.dsl.xmission.com>	<4742DF51.8060402@openvz.org>	<m1tznhrli5.fsf@ebiederm.dsl.xmission.com>	<4742FEF6.6080609@openvz.org>
	<m1myt8snqp.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1myt8snqp.fsf-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
> Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> writes:
> 
>> Eric W. Biederman wrote:
>>> To be very very very clear.
>>>
>>> This is the way I think we should do the core sysctl infrastructure.
>>>
>>> On top of the register_sysctl_table patch, getting all of the
>>> infrastructure in at once.
>>>
>>> With a list of lists so we don't kill ourselves when we try to
>>> implement sysctls that are per network devices.
>> Hm... My patch looks to do very very same thing, but in
>> a bit simpler manner. Except for the absence of the
>> sysctl paths, but they are just cleanups. I think I can
>> port them on top of my shadows :) Thanks
> 
> Then slow down and listen.

Press my ear close to the monitor.

> Your code simply does not address module unload races. BAD BAD BAD.

Can you unload IPC or UTS module? =)

> Your code skips sysctl_check allowing buggy sysctl tables to continue
> to exist BAD BAD BAD.

The tables are cloned from those who passed these checks. ;)

> Your code does not implement a list of lists needed to implement
> a dynamic list of network devices, instead leaving it to the user of
> sysctl registration code to do. (Which is where the bulk of your
> simplicity seems to come from).  BAD BAD BAD. 

Do we need this stuff for IPC? UTS? Stick to the patches please.

Network sysctls are more complex, I know it. Multiple shadows
per-head are to be done. I agree with that. I'm not trying
to create the most generic code that can solve all our needs
at once.

These patches do not provide any facility to display the
information via sysfs. So? Does anybody care about it?

I already have a bad experience with sending 
doing-it-all-in-one-go patches to the community.

> So I'm sorry.  Your code is simpler because it is WORSE.
> 
> Your code is race prone, encourages buggy users, and doesn't even
> solve the same problem.  So no I don't think it makes a bit
> of sense.

I decidedly object against such an outrageous statements.

> Eric
> 

Pavel
