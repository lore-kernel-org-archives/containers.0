From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 0/3] Sysctl shadow management
Date: Tue, 20 Nov 2007 12:47:26 -0700
Message-ID: <m1myt8snqp.fsf@ebiederm.dsl.xmission.com>
References: <4742C73C.3010904@openvz.org>
	<m1y7ctrrrd.fsf@ebiederm.dsl.xmission.com>
	<4742DF51.8060402@openvz.org>
	<m1tznhrli5.fsf@ebiederm.dsl.xmission.com>
	<4742FEF6.6080609@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4742FEF6.6080609-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> (Pavel Emelyanov's message of "Tue,
	20 Nov 2007 18:36:22 +0300")
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> writes:

> Eric W. Biederman wrote:
>> To be very very very clear.
>> 
>> This is the way I think we should do the core sysctl infrastructure.
>> 
>> On top of the register_sysctl_table patch, getting all of the
>> infrastructure in at once.
>> 
>> With a list of lists so we don't kill ourselves when we try to
>> implement sysctls that are per network devices.
>
> Hm... My patch looks to do very very same thing, but in
> a bit simpler manner. Except for the absence of the
> sysctl paths, but they are just cleanups. I think I can
> port them on top of my shadows :) Thanks

Then slow down and listen.

Your code simply does not address module unload races. BAD BAD BAD.

Your code skips sysctl_check allowing buggy sysctl tables to continue
to exist BAD BAD BAD.

Your code does not implement a list of lists needed to implement
a dynamic list of network devices, instead leaving it to the user of
sysctl registration code to do. (Which is where the bulk of your
simplicity seems to come from).  BAD BAD BAD. 

So I'm sorry.  Your code is simpler because it is WORSE.

Your code is race prone, encourages buggy users, and doesn't even
solve the same problem.  So no I don't think it makes a bit
of sense.

Eric
