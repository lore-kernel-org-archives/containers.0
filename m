From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Checkpoint/Restart mini-summit
Date: Wed, 16 Jul 2008 14:27:59 -0700
Message-ID: <m1sku9zfhc.fsf@frodo.ebiederm.org>
References: <487C80C9.2040105@fr.ibm.com> <m1prpfc7hj.fsf@frodo.ebiederm.org>
	<20080716151530.GA26496@us.ibm.com>
	<m18ww14pm7.fsf@frodo.ebiederm.org>
	<20080716193538.GA28393@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080716193538.GA28393-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message of
	"Wed, 16 Jul 2008 14:35:38 -0500")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:

> Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
>> "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:
>> 
>> > Right, the whole point of Daniel including a 'reading list' was just so
>> > that we can avoid wasting time discussing existing implementations.  So
>> > he wasn't suggesting that we would be discussing those in detail, in
>> > fact quite the opposite.
>> 
>> Right however he was suggesting we discuss how to implement it without
>> agreeing on basic principles.  Maybe I'm wrong and all of the different
>> development groups have a common idea of what needs to be done but
>> I would be surprised if that were the case.
>
> IMO recent threads have clearly proven that you're right about basic
> principles.  Question is what is the right level to start at first, and
> how do we go about reaching concensus?  I.e. is the first question
> whether we should do a fully in-kernel checkpoint and restart vs
> entirely userspace vs a mix, or is there another place we should start?

Where all good kernel features start.  With the necessary mechanisms in
the kernel and the policy in user space.

If we want to replay all of the user space actions to create the
environment at the time of the checkpoint we already have all of the
kernel support we need as the applications go to their current state
using current system calls.

I think we want something a bit more efficient.

> It sounds like you have some good ideas in any case on where to start so
> I'm glad you'll be there :)


Will we have a white board or a large piece paper or something we can draw
on and talk about?

Eric
