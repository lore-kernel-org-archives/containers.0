From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [DRAFT] Container mini-summit notes v0.01
Date: Wed, 26 Sep 2007 16:14:21 -0400
Message-ID: <46FABD9D.50407@cs.columbia.edu>
References: <46DE9E1C.6010309@fr.ibm.com>	<20070905135357.GE1403@sergelap.austin.ibm.com>	<6599ad830709050700y278d653eu371375c2fc107ef@mail.gmail.com>	<20070905143808.GG1403@sergelap.austin.ibm.com>	<46DF35DA.1090102@cs.columbia.edu>	<20070905235828.GA32475@sergelap.austin.ibm.com>	<46DFBE60.6030404@fr.ibm.com>	<20070906153243.GA15436@sergelap.austin.ibm.com>	<m1wsv0x5sv.fsf@ebiederm.dsl.xmission.com>	<20070910141834.GA5866@sergelap.austin.ibm.com>
	<m1642iqz6x.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1642iqz6x.fsf-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
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
Cc: Kir Kolyshkin <kir-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Masahiko Takahashi <masahiko-3NddpPZAyC0@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org


(sorry from the delay, been away :)

Eric W. Biederman wrote:
> "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:
> 
>> Sorry, I was focusing on the virtual server needs.
>>
>> devpts is it's own fs so I was fully expecting to make it mountable
>> multiple times so a container can have it's own /dev/pts/0.  So what
>> other virtual devices would we want to be able to rec-reate for a
>> migrated application?  (I wonder (a) what gregkh will say about having
>> a device namespace, and (b) what the sysfs implications will be)
> 
> Depends.  There are things like the loop device that could be interesting.
> There may be some others.  I haven't looked at it enough detail to get
> beyond the fact that in some sense it isn't just limited to pts devices.
> 
> A multimount devpts is interesting though.

Devices I had to deal with (in zap) so far - to be able to ckpt/restart
(and migrate) a desktop session:

* /dev/rtc  (e.g. for mplayer)

* /dev/dsp

* /dev/random ?  (to isolate entropy pools ?)

* virtual consoles - e.g. in zap, an X server that uses a virtual device
runs inside a pod/container/VE (and X per-se requires a virtual console)

* virtual terminals - e.g. in zap we allow access to a pod from the host
without a need to run 'sshd' inside and setup a network in the pod. (Then
with a suitable utility and network access to the host, this also allows
sort of remote (a-la serial) console access).
From inside the pod it looks like /dev/tty{1,2,..}, so one can run 'getty'
processes inside the pod. From the outside (for the admin, e.g.) it is an
extended /dev/tty that has an extra ioctl to multiplex access, so the
admin (program) can ask to be connected to tty X of pod Y, and it will
connect to that console (like connecting via serial line).
The main advantage is that as a virtual device it can be migrated (with
its buffers, if not empty, as they reside inside the pod) so upon restart
they go with the 'getty' processes that use them. The (old) admin will
see the line dropped, and the (new) admin after the migration can connect
at the new machine.

Oren.
