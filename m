From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 00/80] Kernel based checkpoint/restart [v18]
Date: Wed, 30 Sep 2009 17:24:36 -0500
Message-ID: <20090930222436.GA22027@us.ibm.com>
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
	<20090924154139.2a7dd5ec.akpm@linux-foundation.org>
	<20090928163704.GA3327@us.ibm.com> <4AC20BB8.4070509@free.fr>
	<87iqf0o5sf.fsf@caffeine.danplanet.com> <4AC38477.4070007@free.fr>
	<87eipoo0po.fsf@caffeine.danplanet.com> <4AC39CE5.9080908@free.fr>
	<877hvgnv6z.fsf@caffeine.danplanet.com> <4AC3D6DC.9010500@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4AC3D6DC.9010500-GANU6spQydw@public.gmane.org>
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
Cc: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Daniel Lezcano (daniel.lezcano-GANU6spQydw@public.gmane.org):
> Dan Smith wrote:
>> DL> Argh ! I was hoping there was something else than the source code
>>
>> The header file makes it pretty clear what is going on, 
> Certainly for you.
> We are a little far away of the sys_checkpoint / sys_restart simple  
> syscalls we talked about at the cr-minisummit in 2008.

Yes.  We did those, and were asked to provide a fuller
implementation.  Here is what we have so far...  We're
open, in fact eager, to see other people's implementations
based on different designs, but here is what *we*'ve got.

Oh, and it was NEVER said at the cr-minisummit that we would have
simple syscalls doing a full, complicated c/r.  Only that
we would start with simple syscalls to do a single task with
no open resources.  And you can still do that with v18, with
one simple syscall.

-serge
