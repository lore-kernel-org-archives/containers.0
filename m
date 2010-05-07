From: Ferenc Wagner <wferi-eEbw3PyuezQ@public.gmane.org>
Subject: Re: pid namespace bug ?
Date: Fri, 07 May 2010 23:01:48 +0200
Message-ID: <878w7vmnnn.fsf@tac.ki.iif.hu>
References: <8739y6ikjr.fsf@tac.ki.iif.hu> <4BE178BC.4030201@free.fr>
	<87ljbyh1zv.fsf@tac.ki.iif.hu> <4BE18E01.3090103@free.fr>
	<87hbml2uf3.fsf@tac.ki.iif.hu> <4BE2A479.3060805@free.fr>
	<87ocgt12fb.fsf@tac.ki.iif.hu> <4BE322F1.5030500@free.fr>
	<20100506205233.GA23542@us.ibm.com> <4BE3D4AD.1030705@free.fr>
	<20100507194426.GB14799@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100507194426.GB14799-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Sukadev Bhattiprolu's
	message of "Fri, 7 May 2010 12:44:26 -0700")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> writes:

> Daniel Lezcano [daniel.lezcano-GANU6spQydw@public.gmane.org] wrote:
>
>>> Besides a realistic container-init would block such signals, in which case
>>> the complexity in the kernel could be viewed as unnecessary.
>>
>> I am not sure it is good to have the pid 1 immune against signals sent  
>> from outside of the container.
>
> cinit is only immune to unhandled signals that terminate/stop the cinit.
> If a handler is defined for SIGINT, a SIGINT from parent-ns will still be
> delivered but a SIGINT from a descendant of cinit will be ignored.

So is it impossible to send SIGINT to cinit from the container, even if
it has a handler for that?  Your other reply (and the note in kill(2))
seems to say it's possible, so I'm confused again...
-- 
Thanks,
Feri.
