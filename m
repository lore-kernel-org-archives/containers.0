From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: how to do not allow to mount /cgroup inside container?
Date: Tue, 25 Aug 2009 09:05:37 -0500
Message-ID: <20090825140537.GA19644@us.ibm.com>
References: <ac1c4bf20908250517j43d49f9fv1b5d6d5beae8aa@mail.gmail.com>
	<4A93DD67.5030905@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A93DD67.5030905-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, kt-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Daniel Lezcano (daniel.lezcano-GANU6spQydw@public.gmane.org):
> Krzysztof Taraszka wrote:
>> Hi,
>>
>> I was looking for possibility to secure lxc container to do not allow 'root
>> container user'  from changing limits from cgroup. Right now without STACK64
>> or SELinux he can do this easily.
>> I read the http://www.ibm.com/developerworks/linux/library/l-lxc-security/cookbook
>> and decided to use STACK64 kernel mechanism.
>> Well... mounting cgroup inside container fails (great!, i am looked for that
>> ;)) but networking fails too (interface bring up, sshd bring up, connection
>> beetween host and container is, but 'mtr', 'ping' even 'apt-get update'
>> fails and I do not know why). I secure my container exactly like in the
>> cookbook.

Yeah, smack's use of cipso can make things tricky, and it's possible things
have changed a bit recently.  Although I'm currently running smack in my
everyday s390 kernel to test checkpointing of its labels, and networking
is working fine.

Can you give me a few details - what distro, smack policy, and precise kernel
version are you using, for starters?

>> Is there any other possilbility to have secure container without network
>> problems or any hint now to enable networking with stack64 enabled? If so,
>> maybe the l-lxc-security cookbook have to updated? Maybe another kernel
>> patch to do not allow container to mount cgroup when the mount call come
>> from container?
>>
>> Any ideas?
>>   
> I think Serge can help you on this area (Cc'ed).

Well the idea is that user namespaces will provide this.  The files in
the cgroupfs will be labeled as being owned by users in the initial
user namespace.  The users in the container would be in a child user
namespace, the namespaces being hierarchical, so for instance the
container might have been created by uid 500 in the initial namespace
(ns=1), with the new namespace being (ns=2).  Then uid 0 in the container
is actually (1:500,2:0) and uid 1000 in the container is (1:500,2:1000).
Now tasks in the container will only own files which are owned by 1:500,
and root tasks in the container can only get privileges (CAP_DAC_OVERRIDE
etc) to files owned by 1:500.  So regular DAC permissions then suffice to
prevent containers from messing with their cgroup constraints.

Unfortunately that is (still) a ways off.  If you have time to work
on that, I think the last time Eric and I discussed how to go about
introducing this functionality was in the thread starting here:
https://lists.linux-foundation.org/pipermail/containers/2008-August/thread.html#12675
and i.e. https://lists.linux-foundation.org/pipermail/containers/2008-August/012691.html
where Eric suggests starting with sorting out 'capable' with respect to
namespaces first.

-serge
